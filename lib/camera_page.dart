import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'history_service.dart'; 
import 'analytics_page.dart'; // <--- NEW IMPORT

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );
  Interpreter? _interpreter;
  List<String> _labels = [];
  
  // --- SMART LOGIC VARIABLES ---
  final List<String> _emotionHistory = []; 
  static const int _historyMaxLen = 6;
  
  // UI Variables
  String _mainLabel = "Init..."; 
  String _subLabel = ""; 
  
  // --- NEW: STORES THE DATA FOR THE REPORT ---
  Map<String, double> _allScores = {}; 
  // ------------------------------------------

  int _inputWidth = 48;
  int _inputHeight = 48;
  bool _isProcessing = false;
  List<Face> _faces = [];

  @override
  void initState() {
    super.initState();
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    await _loadModelAndLabels();
    await _initializeCamera();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/emotions_model.tflite');
      var inputTensor = _interpreter!.getInputTensors().first;
      _inputWidth = inputTensor.shape[1];
      _inputHeight = inputTensor.shape[2];

      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    } catch (e) {
      setState(() => _mainLabel = "Model Error: $e");
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium, 
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    await _controller!.initialize();
    _controller!.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _isProcessing = true;
        _processImage(image, frontCamera);
      }
    });

    if (mounted) setState(() => _isCameraInitialized = true);
  }

  Future<void> _processImage(CameraImage image, CameraDescription camera) async {
    try {
      final InputImage? inputImage = _inputImageFromCameraImage(image, camera);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (mounted) setState(() => _faces = faces);

      if (faces.isEmpty) {
        if (mounted) setState(() { 
          _mainLabel = "No Face"; 
          _subLabel = "";
          _emotionHistory.clear(); 
          _allScores = {}; 
        });
        return;
      }

      if (_interpreter != null) {
        _runEmotionModel(image, faces.first, camera);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _runEmotionModel(CameraImage cameraImage, Face face, CameraDescription camera) {
    try {
      img.Image? rawImage = _convertYOnly(cameraImage);
      if (rawImage == null) return;

      img.Image uprightImage = img.copyRotate(rawImage, angle: camera.sensorOrientation);
      if (camera.lensDirection == CameraLensDirection.front) {
        uprightImage = img.flipHorizontal(uprightImage);
      }

      int x = face.boundingBox.left.toInt().clamp(0, uprightImage.width - 1);
      int y = face.boundingBox.top.toInt().clamp(0, uprightImage.height - 1);
      int w = face.boundingBox.width.toInt().clamp(1, uprightImage.width - x);
      int h = face.boundingBox.height.toInt().clamp(1, uprightImage.height - y);
      
      img.Image faceCrop = img.copyCrop(uprightImage, x: x, y: y, width: w, height: h);
      img.Image resized = img.copyResize(faceCrop, width: _inputWidth, height: _inputHeight);

      var input = Float32List(1 * _inputWidth * _inputHeight * 1);
      int pixelIndex = 0;
      for (int i = 0; i < _inputHeight; i++) {
        for (int j = 0; j < _inputWidth; j++) {
          var pixel = resized.getPixel(j, i);
          input[pixelIndex++] = pixel.r / 255.0; 
        }
      }

      int numClasses = _labels.length > 0 ? _labels.length : 7;
      var output = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);
      _interpreter!.run(input.reshape([1, _inputWidth, _inputHeight, 1]), output);

      _applySmartLogic(output[0]);

    } catch (e) {
      print("AI Error: $e");
    }
  }

  void _applySmartLogic(List<double> scores) {
    // 1. Basic Setup
    Map<String, double> tempScores = {};
    for(int i=0; i<scores.length; i++) {
      if (i < _labels.length) tempScores[_labels[i]] = scores[i];
    }

    double maxScore = -1;
    int maxIndex = -1;
    double secondScore = -1;
    int secondIndex = -1;

    for(int i=0; i < scores.length; i++) {
      if (scores[i] > maxScore) {
        secondScore = maxScore;
        secondIndex = maxIndex;
        maxScore = scores[i];
        maxIndex = i;
      } else if (scores[i] > secondScore) {
        secondScore = scores[i];
        secondIndex = i;
      }
    }

    String currentEmotion = _labels[maxIndex];
    String secondEmotion = (secondIndex != -1) ? _labels[secondIndex] : "";
    String debugNote = "";

    // ---------------------------------------------------------
    // THE CLEAN HIERARCHY LOGIC
    // ---------------------------------------------------------
    
    // Get key scores
    double neutralScore = tempScores['Neutral'] ?? 0.0;
    double sadScore = tempScores['Sad'] ?? 0.0;
    double angryScore = tempScores['Angry'] ?? 0.0;

    // RULE 1: ANGRY CHECK 
    // Angry is "Tense". If the face is relaxed (Neutral > 10%), it is NOT Angry.
    if (currentEmotion == 'Angry') {
      if (neutralScore > 0.20) {
        // If it looks Angry but also a bit Neutral... it's probably actually Sad.
        currentEmotion = 'Sad';
        debugNote = "(Angry->Sad)";
      }
    }

    // ---------------------------------------------------------
    // RULE 2: THE "HIDDEN SADNESS" BOOST (Fix for Phone Camera)
    // ---------------------------------------------------------
    // Problem: Phone cameras smooth out faces, so "Sad" looks like "Neutral".
    // Solution: If the winner is Neutral, but Sad is close behind, choose Sad.
    
    if (currentEmotion == 'Neutral' && secondEmotion == 'Sad') {
      // If the gap is small (less than 5%), trust Sadness.
      // Example: Neutral 50%, Sad 48% -> Gap is 2% -> Result: SAD
      if ((maxScore - secondScore) < 0.05) {
        currentEmotion = 'Sad';
        debugNote = "(Neu->Sad)";
      }
    }
    
    // RULE 3: DISGUST/FEAR FILTER
    // These are rare. If low confidence, default to second best.
    if ((currentEmotion == 'Disgust' || currentEmotion == 'Fear') && maxScore < 0.7) {
       // Find second best
       double best2 = -1;
       String label2 = "";
       tempScores.forEach((key, value) {
         if (key != currentEmotion && value > best2) {
           best2 = value;
           label2 = key;
         }
       });
       
       if (label2 != "" && label2 != 'Disgust' && label2 != 'Fear' && best2 > 0.3) {
         currentEmotion = label2;
         debugNote = "($currentEmotion->$label2)";
       }
    }

    // ---------------------------------------------------------

    // 4. Temporal Smoothing
    _emotionHistory.add(currentEmotion);
    if (_emotionHistory.length > _historyMaxLen) {
      _emotionHistory.removeAt(0);
    }
    String smoothedEmotion = _getMostCommonEmotion(_emotionHistory);

    if (mounted) {
      setState(() {
        _mainLabel = smoothedEmotion;
        // Print the debug note so you can see WHICH rule triggered
        _subLabel = "Confidence: ${(maxScore*100).toInt()}% $debugNote";
        _allScores = tempScores; 
      });
    }
    
    // DEBUG: Print to your console to see what's happening in real-time
    print("Sad: $sadScore | Angry: $angryScore | Neutral: $neutralScore -> Result: $currentEmotion");
  }

  String _getMostCommonEmotion(List<String> history) {
    if (history.isEmpty) return "Unknown";
    Map<String, int> counts = {};
    for (var emo in history) {
      counts[emo] = (counts[emo] ?? 0) + 1;
    }
    String bestEmo = history.last;
    int maxCount = -1;
    counts.forEach((emo, count) {
      if (count > maxCount) {
        maxCount = count;
        bestEmo = emo;
      }
    });
    return bestEmo;
  }

  // --- STANDARD HELPERS ---
  img.Image? _convertYOnly(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final int stride = image.planes[0].bytesPerRow;
      final bytes = image.planes[0].bytes;
      var imgBuffer = img.Image(width: width, height: height);
      for (int x = 0; x < width; x++) { 
        for (int y = 0; y < height; y++) {
          final int index = y * stride + x;
          if (index < bytes.length) {
             final int gray = bytes[index];
             imgBuffer.setPixelRgb(x, y, gray, gray, gray);
          }
        }
      }
      return imgBuffer;
    } catch (e) { return null; }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image, CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: _concatenatePlanes(image.planes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format ?? InputImageFormat.nv21,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (var plane in planes) { allBytes.putUint8List(plane.bytes); }
    return allBytes.done().buffer.asUint8List();
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    // --- TOGGLE THIS FOR EMULATOR VS PHONE ---
    // Set to TRUE for Real Phone (Selfie mode)
    // Set to FALSE for Emulator (Webcam mode)
    bool isMirrored = true; 
    // -----------------------------------------

    final size = MediaQuery.of(context).size;
    var cameraSize = _controller!.value.previewSize!;
    
    // Scaling
    double scaleX = size.width / cameraSize.height;
    double scaleY = size.height / cameraSize.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Smart Emotion Scanner")),
      body: Stack(
        children: [
          // 1. Camera
          SizedBox(
            width: size.width, 
            height: size.height, 
            child: CameraPreview(_controller!)
          ),
          
          if (_faces.isNotEmpty) ...[
            // 2. Face Box (Now uses the Switch)
            SizedBox(
              width: size.width,
              height: size.height,
              child: CustomPaint(
                painter: FacePainter(_faces.first, scaleX, scaleY, isMirrored: isMirrored),
              ),
            ),
            
            // 3. Label (Also uses the Switch)
            Positioned(
              top: _faces.first.boundingBox.top * scaleY - 70,
              // If mirrored, flip the calculation. If not, use standard left.
              left: isMirrored 
                  ? size.width - (_faces.first.boundingBox.right * scaleX) 
                  : _faces.first.boundingBox.left * scaleX,
              
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.red,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mainLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _subLabel,
                      style: const TextStyle(color: Colors.yellowAccent, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 4. Diagnose Button
          Positioned(
            bottom: 40, left: 30, right: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent
              ),
              onPressed: () {
                Map<String, double> finalScores = Map.from(_allScores);
                if (finalScores.isEmpty) finalScores = {'Neutral': 1.0};

                String winner = "Neutral";
                double max = -1;
                finalScores.forEach((k,v) { if(v>max){max=v; winner=k;} });

                HistoryService.saveMood(winner, "Face Scan Analysis", finalScores);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnalyticsPage(scores: finalScores),
                  ),
                );
              },
              child: const Text("DIAGNOSE & REPORT", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final Face face;
  final double scaleX;
  final double scaleY;
  final bool isMirrored; // <--- NEW VARIABLE

  FacePainter(this.face, this.scaleX, this.scaleY, {required this.isMirrored});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    final rect = face.boundingBox;

    double left, right;

    if (isMirrored) {
      // PHONE MODE: Flip the coordinates
      left = size.width - (rect.right * scaleX);
      right = size.width - (rect.left * scaleX);
    } else {
      // EMULATOR MODE: Use normal coordinates
      left = rect.left * scaleX;
      right = rect.right * scaleX;
    }

    canvas.drawRect(
      Rect.fromLTRB(left, rect.top * scaleY, right, rect.bottom * scaleY),
      paint,
    );
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) => true;
}
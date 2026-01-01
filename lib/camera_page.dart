import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

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
  final List<Map<String, dynamic>> _emotionBuffer = [];

  int _inputWidth = 48;
  int _inputHeight = 48;

  bool _isProcessing = false;
  List<Face> _faces = [];
  String _winnerLabel = "Init..."; 
  Map<String, double> _allScores = {}; // Stores scores for all emotions

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
      _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
    } catch (e) {
      setState(() => _winnerLabel = "Model Error");
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
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.nv21 
          : ImageFormatGroup.bgra8888,
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
        if (mounted) setState(() { _winnerLabel = "No Face"; _allScores = {}; });
        return;
      }

      Face face = faces.first;
      
      if (_interpreter != null) {
        _runEmotionModel(image, face, camera);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _runEmotionModel(CameraImage cameraImage, Face face, CameraDescription camera) {
    try {
      // 1. SAFE CONVERT
      img.Image? rawImage = _convertYOnly(cameraImage);
      if (rawImage == null) return;

      // 2. ROTATE & MIRROR
      img.Image uprightImage = img.copyRotate(rawImage, angle: camera.sensorOrientation);
      if (camera.lensDirection == CameraLensDirection.front) {
        uprightImage = img.flipHorizontal(uprightImage);
      }

      // 3. CROP
      int x = face.boundingBox.left.toInt().clamp(0, uprightImage.width - 1);
      int y = face.boundingBox.top.toInt().clamp(0, uprightImage.height - 1);
      int w = face.boundingBox.width.toInt().clamp(1, uprightImage.width - x);
      int h = face.boundingBox.height.toInt().clamp(1, uprightImage.height - y);
      
      img.Image faceCrop = img.copyCrop(uprightImage, x: x, y: y, width: w, height: h);
      img.Image resized = img.copyResize(faceCrop, width: _inputWidth, height: _inputHeight);

      // 4. PREP
      var input = Float32List(1 * _inputWidth * _inputHeight * 1);
      int pixelIndex = 0;
      for (int i = 0; i < _inputHeight; i++) {
        for (int j = 0; j < _inputWidth; j++) {
          var pixel = resized.getPixel(j, i);
          input[pixelIndex++] = pixel.r / 255.0; 
        }
      }

      // 5. INFERENCE
      int numClasses = _labels.length > 0 ? _labels.length : 7;
      var output = List.filled(1 * numClasses, 0.0).reshape([1, numClasses]);
      _interpreter!.run(input.reshape([1, _inputWidth, _inputHeight, 1]), output);

      // 6. SOFTMAX & PARSE
      List<double> rawScores = output[0];
      List<double> probabilities = _softmax(rawScores);

      Map<String, double> tempScores = {};
      double maxScore = -1;
      String topLabel = "Unknown";

      for (int i = 0; i < probabilities.length; i++) {
        String label = (i < _labels.length) ? _labels[i] : "Id$i";
        double score = probabilities[i];
        
        tempScores[label] = score;
        if (score > maxScore) {
          maxScore = score;
          topLabel = label;
        }
      }

      // 7. UPDATE UI
      if (mounted) {
        setState(() {
          _winnerLabel = "$topLabel ${(maxScore*100).toInt()}%";
          _allScores = tempScores;
        });
        
        // Save for "Capture" button
        _addToBuffer(topLabel, maxScore);
      }

    } catch (e) {
      print("AI Error: $e");
    }
  }

  List<double> _softmax(List<double> logits) {
    double maxLogit = logits.reduce(math.max);
    List<double> exps = logits.map((e) => math.exp(e - maxLogit)).toList();
    double sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  // --- SAFE Y-ONLY CONVERTER ---
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

  void _addToBuffer(String emotion, double score) {
    _emotionBuffer.add({'emotion': emotion, 'score': score, 'time': DateTime.now()});
    final fiveSecsAgo = DateTime.now().subtract(const Duration(seconds: 5));
    _emotionBuffer.removeWhere((e) => (e['time'] as DateTime).isBefore(fiveSecsAgo));
  }

  String _calculateAverage() {
    if (_emotionBuffer.isEmpty) return "No data";
    Map<String, double> totals = {};
    for (var entry in _emotionBuffer) {
      String emo = entry['emotion'];
      totals[emo] = (totals[emo] ?? 0) + (entry['score'] as double);
    }
    String topEmotion = "Unknown";
    double topScore = -1;
    totals.forEach((key, value) {
      if (value > topScore) { topScore = value; topEmotion = key; }
    });
    return topEmotion;
  }

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

    final size = MediaQuery.of(context).size;
    var cameraSize = _controller!.value.previewSize!;
    double scaleX = size.width / cameraSize.height;
    double scaleY = size.height / cameraSize.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Live Scoreboard")),
      body: Stack(
        children: [
          // 1. Camera Feed
          SizedBox(width: size.width, height: size.height, child: CameraPreview(_controller!)),
          
          // 2. Face Box
          if (_faces.isNotEmpty) ...[
            CustomPaint(painter: FacePainter(_faces.first, scaleX, scaleY), child: Container()),
            // Winner Label
            Positioned(
              top: _faces.first.boundingBox.top * scaleY - 60,
              left: _faces.first.boundingBox.left * scaleX,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.red,
                child: Text(
                  _winnerLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],

          // 3. SCOREBOARD (Right Side)
          Positioned(
            top: 20, right: 10,
            child: Container(
              padding: const EdgeInsets.all(10),
              color: Colors.black.withOpacity(0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("LIVE SCORES:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  ..._labels.map((label) {
                    double score = _allScores[label] ?? 0.0;
                    bool isWinner = _winnerLabel.startsWith(label);
                    return Text(
                      "$label: ${(score*100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: isWinner ? Colors.greenAccent : Colors.white,
                        fontSize: 14,
                        fontWeight: isWinner ? FontWeight.bold : FontWeight.normal
                      ),
                    );
                  })
                ],
              ),
            ),
          ),

          // 4. Capture Button
          Positioned(
            bottom: 40, left: 30, right: 30,
            child: ElevatedButton(
              onPressed: () {
                String result = _calculateAverage();
                showDialog(context: context, builder: (_) => AlertDialog(
                  title: const Text("5s Result"),
                  content: Text("Average: $result"),
                ));
              },
              child: const Text("CAPTURE 5s"),
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
  FacePainter(this.face, this.scaleX, this.scaleY);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 3.0..color = Colors.red;
    final rect = face.boundingBox;
    canvas.drawRect(
      Rect.fromLTRB(rect.left * scaleX, rect.top * scaleY, rect.right * scaleX, rect.bottom * scaleY),
      paint,
    );
  }
  @override
  bool shouldRepaint(FacePainter oldDelegate) => true;
}
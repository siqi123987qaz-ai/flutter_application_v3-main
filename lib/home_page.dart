import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'camera_page.dart';
import 'recommendation_page.dart';
import 'history_service.dart';
import 'history_page.dart';
import 'analytics_page.dart';
import 'auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();

  // Sentiment Analysis Logic
  void _analyzeTextAndNavigate() {
    String text = _textController.text.trim();
    
    // 1. Empty Check
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please type something..."), backgroundColor: Colors.orange),
      );
      return;
    }

    // 2. Close Keyboard
    FocusScope.of(context).unfocus();

    // --- CRISIS INTERVENTION CHECK 🛑 ---
    if (_isCrisis(text)) {
      _showCrisisDialog();
      return;
    }
    // ------------------------------------

    // 3. Normal Analysis (Now gets the Full Report)
    // Returns: {'Happy': 0.8, 'Neutral': 0.2, ...}
    Map<String, double> analysisScores = SentimentEngine.analyze(text);

    // 4. Find "Winner" (For History Saving)
    String winner = "Neutral";
    double max = -1;
    analysisScores.forEach((k, v) { 
      if(v > max){ max = v; winner = k; } 
    });

    // 5. Save & Navigate
    HistoryService.saveMood(winner, text, analysisScores);
    
    _textController.clear();
    
    if (!mounted) return;

    // 6. Navigate to THE LAB REPORT (Analytics Page)
    Navigator.push(
      context,
      MaterialPageRoute(
        // We pass the FULL MAP here
        builder: (context) => AnalyticsPage(scores: analysisScores),
      ),
    );
  }

  // --- SAFETY NET LOGIC ---
  bool _isCrisis(String text) {
    String lower = text.toLowerCase();
    List<String> triggers = [
      "kill myself", "suicide", "want to die", "end my life", 
      "hurt myself", "cutting myself", "no reason to live", 
      "better off dead", "give up on life"
    ];

    for (var t in triggers) {
      if (lower.contains(t)) return true;
    }
    return false;
  }

  void _showCrisisDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text("You are not alone"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("It sounds like you are going through a very difficult time."),
            SizedBox(height: 10),
            Text("Please reach out for help. There are people who want to support you."),
            SizedBox(height: 20),
            Text("Emergency Hotline: 988 (or your local number)", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _textController.clear();
            },
            child: const Text("I'm Safe", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Calling Emergency Services..."))
              );
            },
            child: const Text("Get Help Now", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCameraInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.face_retouching_natural, size: 50, color: Colors.blueAccent),
            SizedBox(height: 10),
            Text("Best Results Guide", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("For the most accurate diagnosis, please ensure:", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 15),
            _InstructionRow(icon: Icons.light_mode, text: "Use good lighting"),
            SizedBox(height: 10),
            _InstructionRow(icon: Icons.block, text: "Remove glasses if possible"),
            SizedBox(height: 10),
            _InstructionRow(icon: Icons.face, text: "Keep hair/bangs off forehead"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // START THE CAMERA
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraPage()),
              );
            },
            child: const Text("I'm Ready", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.email?.split('@')[0] ?? "User";

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Feeling Diagnosis"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.blue),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
            },
          ),
          IconButton(
            onPressed: () async {
              // This calls the helper function that signs out of BOTH
              await AuthService.signOut(); 
              
              // (Optional) Force navigation back to Login Page if your Stream doesn't catch it
              // Navigator.pop(context); 
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $displayName 👋",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // AI CAMERA CARD
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => const CameraPage()),
                // );
                _showCameraInstructions();
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt, color: Colors.white, size: 40),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("AI Face Scan", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text("Let AI analyze your facial expression", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            // TEXT INPUT
            const Text("📝 Type how you feel", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)],
              ),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _analyzeTextAndNavigate(),
                decoration: InputDecoration(
                  hintText: "e.g., 'I am NOT happy...'",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () => _textController.clear()),
                      IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: _analyzeTextAndNavigate),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // MANUAL EMOJI SELECTION
            const Text("Or select emoji directly", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              children: [
                _buildMoodCard(context, "Happy", "😊", Colors.green),
                _buildMoodCard(context, "Sad", "😢", Colors.blue),
                _buildMoodCard(context, "Angry", "😡", Colors.red),
                _buildMoodCard(context, "Fear", "😨", Colors.purple),
                _buildMoodCard(context, "Surprise", "😲", Colors.pink),
                _buildMoodCard(context, "Disgust", "🤢", Colors.orange),
                _buildMoodCard(context, "Neutral", "😐", Colors.grey),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, String emotion, String emoji, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecommendationPage(emotion: emotion),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(emotion, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

// --- UPDATED NLP ENGINE (RETURNS MAP) ---
class SentimentEngine {
  // Returns: {'Happy': 0.6, 'Sad': 0.1, ...}
  static Map<String, double> analyze(String text) {
    String lowerText = text.toLowerCase();
    
    // 1. Initialize Scores
    Map<String, double> scores = {
      'Happy': 0.0, 'Sad': 0.0, 'Angry': 0.0, 
      'Fear': 0.0, 'Surprise': 0.0, 'Disgust': 0.0, 'Neutral': 0.1 
    };

    // --- A. PRE-PROCESS PHRASES (Handle multi-word meanings first) ---
    // We remove them from text after finding them so they aren't counted twice.
    Map<String, String> phrases = {
      "give up": "Sad", "fed up": "Angry", "don't care": "Neutral",
      "freak out": "Fear", "blown away": "Surprise", "make me sick": "Disgust",
      "can't wait": "Happy", "looking forward": "Happy", "break down": "Sad"
    };

    phrases.forEach((phrase, emotion) {
      if (lowerText.contains(phrase)) {
        scores[emotion] = (scores[emotion] ?? 0) + 2.0; // Strong points for phrases
        lowerText = lowerText.replaceAll(phrase, ""); // Remove to avoid double counting
      }
    });

    // --- B. EMOJI DETECTION (Run this BEFORE regex strips them!) ---
    Map<String, List<String>> emojiMap = {
      'Happy': ["😊", "😂", "🤣", "😁", "🥰", "😍", "👍", "🔥", "✨", "🎉"],
      'Sad': ["😢", "😭", "😔", "😞", "💔", "☹️", "😓", "😿"],
      'Angry': ["😡", "🤬", "😠", "😤", "👿", "🖕", "👎"],
      'Fear': ["😱", "😨", "😰", "😖", "😬", "👀"],
      'Surprise': ["😲", "🤯", "😮", "😯", "😳"],
      'Disgust': ["🤢", "🤮", "💩", "😖"],
    };

    // Scan for emojis in the raw text
    text.runes.forEach((int rune) {
      var character = String.fromCharCode(rune);
      emojiMap.forEach((emotion, emojis) {
        if (emojis.contains(character)) {
          scores[emotion] = (scores[emotion] ?? 0) + 1.5; // Emojis are worth 1.5 words
        }
      });
    });

    // --- C. VOCABULARY (Enhanced with Slang) ---
    final Map<String, List<String>> vocab = {
      'Happy': ["happy", "joy", "love", "excited", "great", "awesome", "good", "best", "wonderful", "blessed", "fun", "lit", "syok", "steady", "nice"],
      'Sad': ["sad", "cry", "depressed", "lonely", "hurt", "bad", "down", "broken", "tears", "hopeless", "miss", "sien", "shag", "tired", "exhausted", "fail", "loser"],
      'Angry': ["angry", "mad", "hate", "furious", "rage", "stupid", "annoyed", "irritated", "frustrated", "bengang", "geram", "stress", "stressed", "idiot", "useless"],
      'Fear': ["scared", "fear", "afraid", "terrified", "nervous", "anxious", "panic", "worry", "worried", "shaking", "unsafe", "threat"],
      'Surprise': ["wow", "shock", "shocked", "amazing", "surprised", "omg", "gosh", "stunned", "crazy", "insane", "unexpected"],
      'Disgust': ["ew", "eww", "gross", "disgust", "sick", "nasty", "yuck", "vile", "foul", "trash", "garbage"]
    };

    // --- D. TOKENIZE & ANALYZE WORDS ---
    // Now we split the remaining text to find keywords
    List<String> words = lowerText.split(RegExp(r"[^a-z0-9']+"));
    
    double segmentMultiplier = 1.0; 

    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isEmpty) continue;

      // Context Switchers
      if (["but", "however", "yet"].contains(word)) {
        scores.updateAll((key, value) => value * 0.5); // Dampen previous feelings
        segmentMultiplier = 1.5; // Boost upcoming feelings
        continue;
      }

      // Check Previous Word for Modifiers
      double localMultiplier = 1.0;
      if (i > 0) {
        String prev = words[i - 1];
        // Negation (Inverters)
        if (["not", "dont", "don't", "cant", "can't", "never", "no", "didnt", "didn't", "wouldnt"].contains(prev)) {
          localMultiplier = -1.0; 
        } 
        // Boosters (Intensifiers)
        else if (["very", "really", "so", "extremely", "super", "too", "totally"].contains(prev)) {
          localMultiplier = 2.0; 
        }
        // Dampeners (Diminishers)
        else if (["kinda", "sorta", "bit", "little", "slightly"].contains(prev)) {
          localMultiplier = 0.5;
        }
      }

      // Match Word to Emotion
      vocab.forEach((emotion, keywords) {
        if (keywords.contains(word) || (word.length > 4 && keywords.any((k) => word.startsWith(k)))) {
          double points = 1.0 * segmentMultiplier * localMultiplier;
          scores[emotion] = (scores[emotion] ?? 0) + points;
        }
      });
    }

    // --- E. POST-PROCESSING (Fix Negatives & Normalize) ---
    
    // 1. Handle Negative Scores (e.g., "Not Happy" -> Adds to Sad)
    if (scores['Happy']! < 0) { scores['Sad'] = (scores['Sad'] ?? 0) + scores['Happy']!.abs(); scores['Happy'] = 0; }
    if (scores['Sad']! < 0) { scores['Happy'] = (scores['Happy'] ?? 0) + scores['Sad']!.abs(); scores['Sad'] = 0; }
    if (scores['Angry']! < 0) { scores['Neutral'] = (scores['Neutral'] ?? 0) + 0.5; scores['Angry'] = 0; }
    if (scores['Fear']! < 0) { scores['Neutral'] = (scores['Neutral'] ?? 0) + 0.5; scores['Fear'] = 0; }

    // 2. Convert to Percentages
    double total = 0.0;
    scores.forEach((key, value) => total += value);

    if (total > 0) {
      scores.updateAll((key, value) => value / total); // e.g., 2.0 -> 0.4 (40%)
    } else {
      scores['Neutral'] = 1.0; // Default if nothing detected
    }

    return scores;
  }
}

class _InstructionRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InstructionRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    );
  }
}
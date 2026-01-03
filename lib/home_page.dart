import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'camera_page.dart';
import 'recommendation_page.dart';
import 'history_service.dart';
import 'history_page.dart';
import 'analytics_page.dart'; // <--- NEW IMPORT

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
              await FirebaseAuth.instance.signOut();
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CameraPage()),
                );
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
  // Return type changed to Map<String, double>
  static Map<String, double> analyze(String text) {
    String lowerText = text.toLowerCase();
    
    // 1. Initialize Scores
    Map<String, double> scores = {
      'Happy': 0.0, 'Sad': 0.0, 'Angry': 0.0, 
      'Fear': 0.0, 'Surprise': 0.0, 'Disgust': 0.0, 'Neutral': 0.1 
    };

    // 2. Vocabulary
    final Map<String, List<String>> vocab = {
      'Happy': ["happy", "joy", "love", "excited", "great", "awesome", "good", "best", "wonderful", "blessed", "cheerful", "glad", "delighted", "fantastic", "content", "peaceful", "proud", "win", "won", "yay", "fun", "better", "recovered"],
      'Sad': ["sad", "cry", "crying", "depressed", "unhappy", "lonely", "hurt", "grief", "bad", "down", "broken", "tears", "hopeless", "miss", "sorrow", "melancholy", "miserable", "pain", "loss", "fail", "terrible"],
      'Angry': ["angry", "mad", "hate", "furious", "rage", "stupid", "annoyed", "irritated", "frustrated", "resent", "jealous", "envy", "livid", "pissed", "fuming", "outrage", "offended", "hostile", "idiot"],
      'Fear': ["scared", "fear", "afraid", "terrified", "nervous", "anxious", "panic", "worry", "worried", "horror", "frightened", "dread", "uneasy", "stressed", "tense", "phobia", "threat", "shaking"],
      'Surprise': ["wow", "shock", "shocked", "amazing", "surprised", "surprise", "unbelievable", "omg", "gosh", "stunned", "astonished", "startled", "unexpected", "sudden", "disbelief", "whoa", "crazy", "insane"],
      'Disgust': ["ew", "eww", "gross", "disgust", "disgusting", "sick", "nasty", "awful", "yuck", "repulsive", "revolting", "vomit", "puke", "nauseous", "vile", "foul", "detest", "loathe", "ugh"]
    };

    // 3. Tokenize
    List<String> words = lowerText.split(RegExp(r"[^a-z0-9']+"));
    
    double segmentMultiplier = 1.0; 

    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isEmpty) continue;

      if (["but", "however", "yet", "although", "though"].contains(word)) {
        scores.updateAll((key, value) => value * 0.5);
        segmentMultiplier = 1.5;
        continue;
      }

      double localMultiplier = 1.0;
      if (i > 0) {
        String prev = words[i - 1];
        if (["not", "dont", "don't", "cant", "can't", "never", "no", "didnt", "didn't"].contains(prev)) {
          localMultiplier = -1.0; 
        } else if (["very", "really", "so", "extremely", "super", "too", "totally"].contains(prev)) {
          localMultiplier = 2.0; 
        }
      }

      vocab.forEach((emotion, keywords) {
        for (var k in keywords) {
          if (word == k || (word.length > 3 && word.startsWith(k))) {
            double points = 1.0 * segmentMultiplier * localMultiplier;
            scores[emotion] = (scores[emotion] ?? 0) + points;
          }
        }
      });
    }

    // Post-Processing
    if (scores['Happy']! < 0) { scores['Sad'] = (scores['Sad'] ?? 0) + scores['Happy']!.abs(); scores['Happy'] = 0; }
    if (scores['Sad']! < 0) { scores['Happy'] = (scores['Happy'] ?? 0) + scores['Sad']!.abs(); scores['Sad'] = 0; }
    if (scores['Fear']! < 0) { scores['Neutral'] = (scores['Neutral'] ?? 0) + 1.0; scores['Fear'] = 0; }

    // --- NEW: NORMALIZATION (Calculate Percentages) ---
    double total = 0.0;
    scores.forEach((key, value) => total += value);

    if (total > 0) {
      scores.updateAll((key, value) => value / total); // Convert 2.0 -> 0.4 (40%)
    } else {
      scores['Neutral'] = 1.0;
    }

    return scores;
  }
}
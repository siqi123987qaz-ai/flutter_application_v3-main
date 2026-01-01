import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'camera_page.dart';
import 'recommendation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();

  // Simple Sentiment Analysis Logic
  void _analyzeTextAndNavigate() {
    String text = _textController.text.trim();
    
    // 1. ROBUSTNESS: Empty Check
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please type something..."), backgroundColor: Colors.orange),
      );
      return;
    }

    // 2. ROBUSTNESS: Close Keyboard
    FocusScope.of(context).unfocus();

    // 3. NLP ENGINE: Calculate Scores
    // This uses the "Incredible" scoring logic below
    String detectedEmotion = SentimentEngine.analyze(text);

    // 4. Clear & Navigate
    _textController.clear();
    
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendationPage(emotion: detectedEmotion),
      ),
    );
  }

  // Helper to make code cleaner
  bool _containsAny(String text, List<String> keywords) {
    for (var word in keywords) {
      if (text.contains(word)) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Get current user email for display
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
            // 1. WELCOME SECTION
            Text(
              "Hello, $displayName 👋",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // 2. AI DIAGNOSIS CARD (Camera)
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
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt, color: Colors.white, size: 40),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "AI Face Scan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Let AI analyze your facial expression",
                            style: TextStyle(color: Colors.white.withOpacity(0.9)),
                          ),
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

            // 3. TEXT ANALYSIS SECTION (New Feature!)
            const Text(
              "📝 Type how you feel",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)
                ],
              ),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send, // Keyboard shows "Send" arrow
                onSubmitted: (_) => _analyzeTextAndNavigate(),
                decoration: InputDecoration(
                  hintText: "e.g., 'I am NOT happy...'",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  
                  // Clear Button (X)
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Clear X Button
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _textController.clear(),
                      ),
                      // Send Button
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: _analyzeTextAndNavigate,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 4. MANUAL SELECTION TITLE
            const Text(
              "Or select emoji directly",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // 5. EMOJI GRID
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
            
            const SizedBox(height: 50), // Bottom padding
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
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              emotion,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PRO NLP ENGINE ---
class SentimentEngine {
  static String analyze(String text) {
    String lowerText = text.toLowerCase();
    
    // 1. Initialize Scores
    Map<String, double> scores = {
      'Happy': 0, 'Sad': 0, 'Angry': 0, 
      'Fear': 0, 'Surprise': 0, 'Disgust': 0, 'Neutral': 0
    };

    // 2. The Brain (Vocabulary)
    final Map<String, List<String>> vocab = {
      'Happy': [
        "happy", "joy", "love", "excited", "great", "awesome", "good", "best",
        "wonderful", "blessed", "cheerful", "glad", "delighted", "fantastic",
        "content", "peaceful", "proud", "win", "won", "yay", "fun", "better", "recovered"
      ],
      'Sad': [
        "sad", "cry", "crying", "depressed", "unhappy", "lonely", "hurt",
        "grief", "bad", "down", "broken", "tears", "hopeless", "miss",
        "sorrow", "melancholy", "miserable", "pain", "loss", "fail", "terrible"
      ],
      'Angry': [
        "angry", "mad", "hate", "furious", "rage", "stupid", "annoyed",
        "irritated", "frustrated", "resent", "jealous", "envy", "livid",
        "pissed", "fuming", "outrage", "offended", "hostile", "idiot"
      ],
      'Fear': [
        "scared", "fear", "afraid", "terrified", "nervous", "anxious",
        "panic", "worry", "worried", "horror", "frightened", "dread",
        "uneasy", "stressed", "tense", "phobia", "threat", "shaking"
      ],
      'Surprise': [
        "wow", "shock", "shocked", "amazing", "surprised", "surprise",
        "unbelievable", "omg", "gosh", "stunned", "astonished", "startled",
        "unexpected", "sudden", "disbelief", "whoa", "crazy", "insane"
      ],
      'Disgust': [
        "ew", "eww", "gross", "disgust", "disgusting", "sick", "nasty",
        "awful", "yuck", "repulsive", "revolting", "vomit", "puke",
        "nauseous", "vile", "foul", "detest", "loathe", "ugh"
      ]
    };

    // 3. Tokenize (Clean split)
    List<String> words = lowerText.split(RegExp(r"[^a-z0-9']+"));
    
    // 4. Analysis Loop
    double segmentMultiplier = 1.0; // Changes when "but" is found

    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isEmpty) continue;

      // --- A. CONTRAST LOGIC (The "But" Rule) ---
      if (["but", "however", "yet", "although", "though"].contains(word)) {
        // Punish previous emotions (divide by 2) because they are "old news"
        scores.updateAll((key, value) => value * 0.5);
        
        // Boost future emotions (x1.5) because they are the "current state"
        segmentMultiplier = 1.5;
        continue;
      }

      // --- B. NEGATION & INTENSIFIERS ---
      double localMultiplier = 1.0;
      
      if (i > 0) {
        String prev = words[i - 1];
        
        // Negation: "not happy" -> Flip score
        if (["not", "dont", "don't", "cant", "can't", "never", "no", "didnt", "didn't"].contains(prev)) {
          localMultiplier = -1.0; 
        } 
        // Intensifier: "very happy" -> Double score
        else if (["very", "really", "so", "extremely", "super", "too", "totally"].contains(prev)) {
          localMultiplier = 2.0; 
        }
      }

      // --- C. SCORING ---
      vocab.forEach((emotion, keywords) {
        for (var k in keywords) {
          // Robust Match: "crying" matches "cry", "sadness" matches "sad"
          if (word == k || (word.length > 3 && word.startsWith(k))) {
            
            // Total Weight = (Base 1.0) * (Segment Importance) * (Negation/Intensifier)
            double points = 1.0 * segmentMultiplier * localMultiplier;
            
            scores[emotion] = (scores[emotion] ?? 0) + points;
          }
        }
      });
    }

    // 5. Post-Processing Fixes
    // If "Happy" is negative (e.g. "not happy"), move points to "Sad"
    if (scores['Happy']! < 0) {
      scores['Sad'] = (scores['Sad'] ?? 0) + scores['Happy']!.abs();
      scores['Happy'] = 0;
    }
    // If "Sad" is negative (e.g. "not sad"), move to "Happy"
    if (scores['Sad']! < 0) {
      scores['Happy'] = (scores['Happy'] ?? 0) + scores['Sad']!.abs();
      scores['Sad'] = 0;
    }
    // "Not afraid" -> Neutral or Happy? Let's treat as Neutral boost
    if (scores['Fear']! < 0) {
      scores['Neutral'] = (scores['Neutral'] ?? 0) + 1.0;
      scores['Fear'] = 0;
    }

    // 6. Tie-Breaker Logic (Long sentences might have ties)
    String winner = "Neutral";
    double maxScore = 0.1; // Minimal threshold

    scores.forEach((emotion, score) {
      if (score > maxScore) {
        maxScore = score;
        winner = emotion;
      }
    });

    return winner;
  }
}
import 'package:flutter/material.dart';
import 'recommendation_page.dart'; // We need this to link to the "Prescription"

class AnalyticsPage extends StatelessWidget {
  // This Map holds the data: "Happy" -> 0.8 (80%)
  final Map<String, double> scores;
  
  const AnalyticsPage({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    // 1. Calculate the "Winner" (Highest Score)
    String winner = "Neutral";
    double maxScore = -1;
    scores.forEach((key, value) {
      if (value > maxScore) {
        maxScore = value;
        winner = key;
      }
    });

    // 2. Sort the list (Highest % at the top)
    var sortedEntries = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Diagnosis Report"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- SECTION A: THE DIAGNOSIS (Big Emoji) ---
            const SizedBox(height: 20),
            Text(_getEmoji(winner), style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 10),
            const Text("Primary Diagnosis", style: TextStyle(color: Colors.grey)),
            Text(
              winner.toUpperCase(),
              style: TextStyle(
                fontSize: 32, 
                fontWeight: FontWeight.bold, 
                color: _getColor(winner)
              ),
            ),
            const SizedBox(height: 40),

            // --- SECTION B: THE LAB RESULTS (The Chart) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Detailed Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Divider(),
                  const SizedBox(height: 10),
                  
                  // Loop through scores and create bars
                  ...sortedEntries.map((entry) {
                    // Hide very small numbers (noise)
                    if (entry.value < 0.01) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Column(
                        children: [
                          // Text Row: "Happy ...... 80%"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text("${(entry.value * 100).toStringAsFixed(1)}%"),
                            ],
                          ),
                          const SizedBox(height: 5),
                          // Bar Row
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: entry.value, // 0.0 to 1.0
                              minHeight: 10,
                              backgroundColor: Colors.grey[100],
                              color: _getColor(entry.key),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- SECTION C: THE PRESCRIPTION BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColor(winner),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Navigate to Recommendations
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecommendationPage(emotion: winner),
                    ),
                  );
                },
                child: const Text("VIEW TREATMENT", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Colors
  Color _getColor(String emotion) {
    switch (emotion) {
      case 'Angry': return Colors.red;
      case 'Happy': return Colors.green;
      case 'Sad': return Colors.blue;
      case 'Fear': return Colors.purple;
      case 'Surprise': return Colors.orange;
      case 'Disgust': return Colors.brown;
      default: return Colors.grey;
    }
  }

  // Helper: Emojis
  String _getEmoji(String emotion) {
    switch (emotion) {
      case 'Angry': return "😡";
      case 'Happy': return "😊";
      case 'Sad': return "😢";
      case 'Fear': return "😨";
      case 'Surprise': return "😲";
      case 'Disgust': return "🤢";
      default: return "😐";
    }
  }
}
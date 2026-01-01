import 'package:flutter/material.dart';
import 'content_list_page.dart'; // We will create this next

class RecommendationPage extends StatelessWidget {
  final String emotion;

  const RecommendationPage({super.key, required this.emotion});

  @override
  Widget build(BuildContext context) {
    // 1. Get Theme Color based on Emotion
    final Color themeColor = _getEmotionColor(emotion);
    final Color textColor = themeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Healing Prescription"),
        backgroundColor: themeColor,
        foregroundColor: textColor,
      ),
      body: Column(
        children: [
          // HEADER: Detected Emotion
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: themeColor.withOpacity(0.1),
            child: Column(
              children: [
                const Text("Current Mood", style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 5),
                Text(
                  emotion.toUpperCase(),
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: themeColor
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _getEmotionMessage(emotion),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),

          // GRID: 4 Categories
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildCategoryCard(context, "Songs", Icons.music_note, themeColor),
                _buildCategoryCard(context, "Articles", Icons.article, themeColor),
                _buildCategoryCard(context, "Videos", Icons.play_circle_fill, themeColor),
                _buildCategoryCard(context, "Stories", Icons.menu_book, themeColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Navigate to the list of content
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentListPage(
              emotion: emotion,
              category: title,
              themeColor: color,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            )
          ],
        ),
      ),
    );
  }

  // --- HELPER: Colors & Messages ---
  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'Angry': return Colors.red;
      case 'Disgust': return Colors.orange;
      case 'Fear': return Colors.purple;
      case 'Happy': return Colors.green;
      case 'Neutral': return Colors.blueGrey;
      case 'Sad': return Colors.blue;
      case 'Surprise': return Colors.pink;
      default: return Colors.indigo;
    }
  }

  String _getEmotionMessage(String emotion) {
    switch (emotion) {
      case 'Angry': return "Take a deep breath. Let's find some calm.";
      case 'Happy': return "You're glowing! Let's keep this vibe going.";
      case 'Sad': return "It's okay not to be okay. Here is a hug.";
      case 'Neutral': return "A balanced mind is a powerful thing.";
      default: return "Here are some recommendations for you.";
    }
  }
}
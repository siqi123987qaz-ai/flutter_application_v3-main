import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import the launcher

class ContentListPage extends StatelessWidget {
  final String emotion;
  final String category;
  final Color themeColor;

  const ContentListPage({
    super.key, 
    required this.emotion, 
    required this.category,
    required this.themeColor
  });

  // --- FUNCTION TO OPEN LINKS ---
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open link: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = _getSpecificContent(emotion, category);

    return Scaffold(
      appBar: AppBar(
        title: Text("$category for $emotion"),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
      ),
      body: items.isEmpty 
        ? Center(child: Text("No recommendations found for $category"))
        : ListView.separated(
            padding: const EdgeInsets.all(15),
            itemCount: items.length,
            separatorBuilder: (c, i) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: themeColor.withOpacity(0.2),
                  child: Icon(_getIconForCategory(category), color: themeColor),
                ),
                title: Text(
                  item['title']!, 
                  style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                subtitle: Text(item['subtitle']!),
                trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
                onTap: () {
                  // Open the Real URL
                  if (item['url'] != null && item['url']!.isNotEmpty) {
                    _launchURL(context, item['url']!);
                  }
                },
              );
            },
          ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Songs': return Icons.music_note;
      case 'Articles': return Icons.article;
      case 'Videos': return Icons.play_circle_fill;
      case 'Stories': return Icons.book;
      default: return Icons.star;
    }
  }

  // --- THE DATA DATABASE (Now with REAL LINKS) ---
  List<Map<String, String>> _getSpecificContent(String emotion, String category) {
    final String cleanEmotion = emotion.trim(); 

    // 1. ANGRY 😡
    if (cleanEmotion == 'Angry') {
      if (category == 'Songs') {
        return [
          {'title': 'Weightless - Marconi Union', 'subtitle': 'Most relaxing song on earth', 'url': 'https://www.youtube.com/watch?v=UfcAVejslrU'},
          {'title': 'Rain Sounds 1 Hour', 'subtitle': 'Wash away the frustration', 'url': 'https://www.youtube.com/watch?v=mPZkdNFkNps'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': '5 Min Anger Meditation', 'subtitle': 'Guided session to cool down', 'url': 'https://www.youtube.com/watch?v=wkse4PPxkk4'},
          {'title': 'Breathing Exercises', 'subtitle': 'Box breathing technique', 'url': 'https://www.youtube.com/watch?v=tEmt1Znux58'},
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'Controlling Anger', 'subtitle': 'Tips from APA', 'url': 'https://www.apa.org/topics/anger/control'},
        ];
      }
    }

    // 2. HAPPY 😊
    else if (cleanEmotion == 'Happy') {
      if (category == 'Songs') {
        return [
          {'title': 'Happy - Pharrell Williams', 'subtitle': 'Keep the vibe high', 'url': 'https://www.youtube.com/watch?v=ZbZSe6N_BXs'},
          {'title': 'Walking on Sunshine', 'subtitle': 'Classic upbeat hit', 'url': 'https://www.youtube.com/watch?v=iPUmE-tne5U'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': 'Humans Being Bros', 'subtitle': 'Restore faith in humanity', 'url': 'https://www.youtube.com/results?search_query=humans+being+bros'},
        ];
      }
    }

    // 3. SAD 😢
    else if (cleanEmotion == 'Sad') {
      if (category == 'Songs') {
        return [
          {'title': 'Fix You - Coldplay', 'subtitle': 'Lights will guide you home', 'url': 'https://www.youtube.com/watch?v=k4V3Mo61fJM'},
          {'title': 'Lofi Hip Hop Radio', 'subtitle': 'Beats to relax/study to', 'url': 'https://www.youtube.com/watch?v=jfKfPfyJRdk'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': 'Guided Meditation for Sadness', 'subtitle': 'Let go of grief', 'url': 'https://www.youtube.com/watch?v=WJk03cZ68y0'},
          {'title': 'Funny Animal Compilation', 'subtitle': 'Instant mood boost', 'url': 'https://www.youtube.com/results?search_query=funny+animals'},
        ];
      } else if (category == 'Articles') {
         return [
          {'title': 'Coping with Sadness', 'subtitle': 'Healthy ways to deal', 'url': 'https://www.healthline.com/health/how-to-stop-being-sad'},
        ];
      }
    }

    // 4. FEAR / ANXIETY 😨
    else if (cleanEmotion == 'Fear') {
      if (category == 'Videos') {
        return [
          {'title': '10 Minute Yoga for Anxiety', 'subtitle': 'Release physical tension', 'url': 'https://www.youtube.com/watch?v=hJbRpHZr_d0'},
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'Grounding Techniques', 'subtitle': '5-4-3-2-1 Method', 'url': 'https://www.healthline.com/health/grounding-techniques'},
        ];
      }
    }

    // DEFAULT / FALLBACK
    return [
      {'title': 'Daily Mindfulness', 'subtitle': 'General wellness', 'url': 'https://www.youtube.com/results?search_query=mindfulness'},
      {'title': 'Google News', 'subtitle': 'Read the latest', 'url': 'https://news.google.com'},
    ];
  }
}
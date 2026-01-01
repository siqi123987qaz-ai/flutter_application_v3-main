import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    // 1. Get the specific list for this Emotion + Category
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
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Action when clicked (e.g. open YouTube link)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Opening: ${item['title']}"))
                  );
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
      case 'Videos': return Icons.play_arrow;
      case 'Stories': return Icons.book;
      default: return Icons.star;
    }
  }

  // --- THE DATA DATABASE ---
  List<Map<String, String>> _getSpecificContent(String emotion, String category) {
    
    // Clean the input to avoid bugs
    final String cleanEmotion = emotion.trim(); 
    
    print("DEBUG: Checking content for '$cleanEmotion' in '$category'"); // Check your Debug Console!
    
    // 1. ANGRY 😡
    if (emotion == 'Angry') {
      if (category == 'Songs') {
        return [
          {'title': 'Weightless - Marconi Union', 'subtitle': 'Scientifically proven to reduce anxiety'},
          {'title': 'Calm Down Playlist', 'subtitle': 'Soft vibes to cool the heat'},
          {'title': 'Rain Sounds 1 Hour', 'subtitle': 'Wash away the frustration'},
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'The 4-7-8 Breathing Technique', 'subtitle': 'Cool down in 60 seconds'},
          {'title': 'Why We Get Angry?', 'subtitle': 'Understanding the psychology of rage'},
          {'title': 'Boxing for Stress Relief', 'subtitle': 'Channeling energy positively'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': '5 Minute Anger Management Meditation', 'subtitle': 'Guided session'},
          {'title': 'Funny Cat Fail Compilation', 'subtitle': 'Distract yourself with laughter'},
        ];
      } else { // Stories
        return [
          {'title': 'The Monk and the Boat', 'subtitle': 'A Zen story about anger'},
          {'title': 'The Two Wolves', 'subtitle': 'Which one do you feed?'},
        ];
      }
    }

    // 2. HAPPY 😊
    else if (emotion == 'Happy') {
      if (category == 'Songs') {
        return [
          {'title': 'Walking on Sunshine', 'subtitle': 'Classic upbeat hit'},
          {'title': 'Happy - Pharrell Williams', 'subtitle': 'Keep the mood high'},
          {'title': 'Best Pop Hits 2025', 'subtitle': 'Dance it out!'},
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'The Science of Gratitude', 'subtitle': 'How to keep this feeling'},
          {'title': 'Share the Joy', 'subtitle': 'Activities to do when happy'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': 'Humans Being Bros', 'subtitle': 'Restoring faith in humanity'},
          {'title': 'Uplifting TED Talks', 'subtitle': 'Inspiration for your day'},
        ];
      } else {
        return [
          {'title': 'The Golden Goose', 'subtitle': 'A classic fairy tale'},
          {'title': 'Success Stories', 'subtitle': 'Real life inspiration'},
        ];
      }
    }

    // 3. SAD 😢
    else if (emotion == 'Sad') {
      if (category == 'Songs') {
        return [
          {'title': 'Fix You - Coldplay', 'subtitle': 'A song for healing'},
          {'title': 'Here Comes The Sun', 'subtitle': 'Reminding you it gets better'},
          {'title': 'Lo-Fi Hip Hop Beats', 'subtitle': 'Chill beats to relax to'},
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'It is Okay Not To Be Okay', 'subtitle': 'Accepting your feelings'},
          {'title': 'Self-Care Checklist', 'subtitle': 'Small steps to feel better'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': 'Guided Meditation for Sadness', 'subtitle': 'Letting go of grief'},
          {'title': 'Baby Animals Compilation', 'subtitle': 'Instant serotonin boost'},
        ];
      } else {
        return [
          {'title': 'The Star Thrower', 'subtitle': 'You make a difference'},
          {'title': 'Everything Will Be Okay', 'subtitle': 'A short story of hope'},
        ];
      }
    }

    // 4. FEAR / ANXIETY 😨
    else if (emotion == 'Fear') {
      if (category == 'Songs') {
        return [
          {'title': 'Breathe - Pink Floyd', 'subtitle': 'Slow down your heart rate'},
          {'title': 'Theta Waves', 'subtitle': 'Deep relaxation frequencies'},
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'Grounding Techniques', 'subtitle': '5-4-3-2-1 Method'},
          {'title': 'Understanding Anxiety', 'subtitle': 'You are safe'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': '10 Minute Yoga for Anxiety', 'subtitle': 'Release tension'},
          {'title': 'Box Breathing Visual', 'subtitle': 'Follow along guide'},
        ];
      } else {
        return [
          {'title': 'The Brave Little Toaster', 'subtitle': 'Courage in small places'},
        ];
      }
    }

    // 5. SURPRISE 😲
    else if (emotion == 'Surprise') {
       if (category == 'Videos') {
         return [{'title': 'Top 10 Plot Twists', 'subtitle': 'Keep the surprise going'}];
       }
       return [{'title': 'Curiosity Killed the Cat', 'subtitle': 'But satisfaction brought it back'}];
    }
    
    // 6. DISGUST 🤢
    else if (emotion == 'Disgust') {
       if (category == 'Videos') {
         return [{'title': 'Satisfying Deep Cleaning', 'subtitle': 'Cleanse your mind'}];
       }
       return [{'title': 'Fresh Start', 'subtitle': 'Reset your environment'}];
    }

    // 7. NEUTRAL 😐
    else {
      if (category == 'Songs') {
        return [
          {'title': 'Focus Playlist', 'subtitle': 'Music for work/study'},
          {'title': 'Jazz Vibes', 'subtitle': 'Smooth background noise'},
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'Mindfulness 101', 'subtitle': 'Staying in the present'},
          {'title': 'Productivity Hacks', 'subtitle': 'Make the most of your day'},
        ];
      } else {
        return [
          {'title': 'Daily News', 'subtitle': 'Stay updated'},
          {'title': 'Podcast: The Daily', 'subtitle': 'Stories of our time'},
        ];
      }
    }
  }
}
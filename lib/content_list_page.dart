import 'package:flutter/material.dart';
import 'browser_page.dart'; // <--- IMPORT THE NEW PAGE

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
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                
                // --- NEW NAVIGATION LOGIC ---
                onTap: () {
                  if (item['url'] != null && item['url']!.isNotEmpty) {
                    // Navigate to Internal Browser
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BrowserPage(
                          url: item['url']!,
                          title: item['title']!,
                          themeColor: themeColor,
                        ),
                      ),
                    );
                  }
                },
                // -----------------------------
              );
            },
          ),
    );
  }

  // ... (Keep the rest of your _getIconForCategory and _getSpecificContent code exactly the same) ...
  // (Paste the _getSpecificContent database from previous step here)
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Songs': return Icons.music_note;
      case 'Articles': return Icons.article;
      case 'Videos': return Icons.play_circle_fill;
      case 'Stories': return Icons.book;
      default: return Icons.star;
    }
  }

  List<Map<String, String>> _getSpecificContent(String emotion, String category) {
      // ... PASTE YOUR DATABASE CODE HERE FROM PREVIOUS STEPS ...
      // (This is the long list of "if emotion == Angry return ...")
      // I will not repeat it here to save space, but make sure it is inside this class.
      
      final String cleanEmotion = emotion.trim(); 

    // 1. ANGRY 😡
    if (cleanEmotion == 'Angry') {
      if (category == 'Songs') {
        return [
          {'title': 'Weightless - Marconi Union', 'subtitle': 'Most relaxing song on earth', 'url': 'https://www.youtube.com/watch?v=UfcAVejslrU'},
          {'title': 'Rain Sounds 1 Hour', 'subtitle': 'Wash away the frustration', 'url': 'https://www.youtube.com/watch?v=mPZkdNFkNps'},
          {'title': 'Numb - Linkin Park', 'subtitle': 'Expresses frustration and feeling misunderstood', 'url': 'https://www.youtube.com/watch?v=kXYiU_JCYtU'},
          {'title': 'Believer - Imagine Dragons', 'subtitle': 'Transforms pain into inner strength', 'url': 'https://www.youtube.com/watch?v=7wtfhZwyrcc'},
          {'title': 'Too Good at Goodbyes - Sam Smith', 'subtitle': 'Help process sadness behind anger', 'url': 'https://www.youtube.com/watch?v=J_ub7Etch2U'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': '5 Min Anger Meditation', 'subtitle': 'Guided session to cool down', 'url': 'https://www.youtube.com/watch?v=wkse4PPxkk4'},
          {'title': 'Punching bag workout', 'subtitle': 'Release anger through physical movement and adrenaline', 'url': 'https://www.youtube.com/shorts/C76SnI5S7z8'},
          {'title': 'Breathing Exercises', 'subtitle': 'Box breathing technique', 'url': 'https://www.youtube.com/watch?v=tEmt1Znux58'},
          {'title': 'Slow ASMR', 'subtitle': 'Creates a sense of safety and relaxation', 'url': 'https://www.youtube.com/watch?v=WJKm74IERAs'},
          
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'Controlling Anger', 'subtitle': 'Tips from APA', 'url': 'https://www.apa.org/topics/anger/control'},
          {'title': 'Why Am I So Angry?', 'subtitle': 'Helps identify hidden triggers and unmet needs', 'url': 'https://www.nhsinform.scot/healthy-living/mental-wellbeing/anger-management/why-am-i-so-angry/'},
          {'title': 'What Anger Is Trying to Tell You', 'subtitle': 'Reframes anger as useful emotional information', 'url': 'https://www.pinerest.org/newsroom/articles/deciphering-anger-blog/'},
        ];
      } else if (category == 'Stories') {
        return [
          {'title': 'A Story about Anger', 'subtitle': 'A personal narrative by a parent...', 'url': 'https://www.alisonchino.com/story-anger/'},
          {'title': 'The Moment I Chose to Get Angry', 'subtitle': 'A reflective personal essay on understanding anger', 'url': 'https://medium.com/readers-hub/the-moment-i-chose-to-get-angry-9e09f6f58ac9'},
        ];
      }
    }

    // 2. HAPPY 😊
    else if (cleanEmotion == 'Happy') {
      if (category == 'Songs') {
        return [
          {'title': 'Happy - Pharrell Williams', 'subtitle': 'Keep the vibe high', 'url': 'https://www.youtube.com/watch?v=ZbZSe6N_BXs'},
          {'title': 'Walking on Sunshine', 'subtitle': 'Classic upbeat hit', 'url': 'https://www.youtube.com/watch?v=iPUmE-tne5U'},
          {'title': 'I\'m Yours - Jason Mraz', 'subtitle': 'Easygoing melody promotes contentment', 'url': 'https://www.youtube.com/watch?v=EkHTsc9PU2A'},
          {'title': 'A Sky Full of Stars - Coldplay', 'subtitle': 'Combines joy with inspiration', 'url': 'https://www.youtube.com/watch?v=VPRjCeoBqrI'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': 'Humans Being Bros', 'subtitle': 'Restore faith in humanity', 'url': 'https://www.youtube.com/results?search_query=humans+being+bros'},
          {'title': 'Adorable Animals', 'subtitle': 'Relaxed Joy', 'url': 'https://www.youtube.com/shorts/tWYki6dMU9g'},
          {'title': 'Achieving Your Dreams', 'subtitle': 'Encourage messages from Denzel Washington', 'url': 'https://www.youtube.com/shorts/I85s62OCHHg'},
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'How Gratitude Makes You Happier', 'subtitle': 'Shows how gratitude boosts long-term happiness', 'url': 'https://www.verywellmind.com/how-gratitude-makes-you-happier-5114446'},
          {'title': 'The Science of Happiness', 'subtitle': 'Explores what truly makes us happy', 'url': 'https://greatergood.berkeley.edu/topic/happiness/definition'},
          {'title': 'How Being Happy Makes You Healthier', 'subtitle': 'reinforcing that happiness has real health benefits', 'url': 'https://www.healthline.com/nutrition/happiness-and-health'},
        ];
      } else if (category == 'Stories') {
        return [
          {'title': 'The Little Things That Made My Day', 'subtitle': 'A personal story about noticing tiny moments of happiness', 'url': 'https://medium.com/@Stargirl./the-little-things-that-make-my-day-4ad0dff2cecf'},
          {'title': 'From Routine to Radiance: Finding Joy in Simple Habits', 'subtitle': 'A story about turning everyday moments into joyful rituals', 'url': 'https://medium.com/@david.quitmeyer/how-a-random-act-of-kindness-changed-my-outlook-9068d5dff263'},
        ];
      }
    }

    // 3. SAD 😢
    else if (cleanEmotion == 'Sad') {
      if (category == 'Songs') {
        return [
          {'title': 'Fix You - Coldplay', 'subtitle': 'Lights will guide you home', 'url': 'https://www.youtube.com/watch?v=k4V3Mo61fJM'},
          {'title': 'Lofi Hip Hop Radio', 'subtitle': 'Beats to relax/study to', 'url': 'https://www.youtube.com/watch?v=n61ULEU7CO0&list=RDn61ULEU7CO0&start_radio=1'},
          {'title': 'Someone You Loved - Lewis Capaldi', 'subtitle': 'Emotional ballad about loss', 'url': 'https://www.youtube.com/watch?v=zABLecsR5UE'},
          {'title': 'Paris in the Rain - Lauv', 'subtitle': 'Warm comfort during sadness', 'url': 'https://www.youtube.com/watch?v=kOCkne-Bku4'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': 'Guided Meditation for Sadness', 'subtitle': 'Let go of grief', 'url': 'https://www.youtube.com/watch?v=WJk03cZ68y0'},
          {'title': 'Funny Animal Compilation', 'subtitle': 'Instant mood boost', 'url': 'https://www.youtube.com/results?search_query=funny+animals'},
          {'title': 'a video to watch when you\'re sad.', 'subtitle': 'Gentle encouragement and perspective for coping with sadness', 'url': 'https://www.youtube.com/watch?v=hBzP8MtJf04'},
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'Coping with Sadness', 'subtitle': 'Healthy ways to deal', 'url': 'https://www.talkspace.com/blog/how-to-deal-with-sadness/'},
          {'title': 'What to Do When You’re Sad: 11 Tips to Feel Better', 'subtitle': 'Practical steps to improve your mood', 'url': 'https://www.betterup.com/blog/what-to-do-when-you-are-sad'},
          {'title': 'Coping with Depression', 'subtitle': 'When you\'re depressed, you can\'t just will yourself to "snap out of it."', 'url': 'https://www.helpguide.org/articles/depression/coping-with-depression.htm'},
        ];
      } else if (category == 'Stories') {
        return [
          {'title': 'My Story of Feeling Sad and Keeping it a Secret', 'subtitle': 'This is a first-person story by Sahil Patel about struggling with sadness', 'url': 'https://medium.com/know-thyself-heal-thyself/my-story-of-feeling-sad-and-keeping-it-a-secret-3bf5bf9ccc98'},
          {'title': 'It\'s OK not to be OK', 'subtitle': 'We should distinguish it from ordinary sadness', 'url': 'https://www.theguardian.com/commentisfree/2017/dec/06/its-ok-not-to-be-ok-why-we-need-to-embrace-sadness'},
        ];
      }
    }

    // 4. FEAR / ANXIETY 😨
    else if (cleanEmotion == 'Fear') {
      if (category == 'Songs') {
        return [
          {'title': 'River Flows in You - Yiruma', 'subtitle': 'Soft melody that reduces tension and worry', 'url': 'https://www.youtube.com/watch?v=7maJOI3QMu0'},
          {'title': 'Lofi Hip Hop Radio', 'subtitle': 'Beats to relax/study to', 'url': 'https://www.youtube.com/watch?v=n61ULEU7CO0&list=RDn61ULEU7CO0&start_radio=1'},
          {'title': 'Come Away With Me - Norah Jones', 'subtitle': 'Warm, gentle vocals that ease anxious thoughts', 'url': 'https://www.youtube.com/watch?v=lbjZPFBD6JU'},
          {'title': 'Better Together - Jack Johnson', 'subtitle': 'Calming rhythm and comforting lyrics', 'url': 'https://www.youtube.com/watch?v=seZMOTGCDag'},
        ];
      } else if (category == 'Videos') {
        return [
          {'title': '10 Minute Yoga for Anxiety', 'subtitle': 'Release physical tension', 'url': 'https://www.youtube.com/watch?v=hJbRpHZr_d0'},
          {'title': 'Guided Meditation for Anxiety', 'subtitle': 'Calm the racing mind', 'url': 'https://www.youtube.com/watch?v=MIr3RsUWrdo'},
          {'title': 'ASMR for Anxiety Relief', 'subtitle': 'Soothing sounds to ease anxiety', 'url': 'https://www.youtube.com/watch?v=CM_ZDGorTn8'},
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'Grounding Techniques', 'subtitle': '5-4-3-2-1 Method', 'url': 'https://www.healthline.com/health/grounding-techniques'},
          {'title': 'Managing Anxiety', 'subtitle': 'Tips from Mayo Clinic', 'url': 'https://www.mayoclinichealthsystem.org/hometown-health/speaking-of-health/11-tips-for-coping-with-an-anxiety-disorder'},
          {'title': 'How to Stop Worrying', 'subtitle': 'Practical strategies to manage anxiety', 'url': 'https://www.helpguide.org/mental-health/anxiety/how-to-stop-worrying'},
        ];
      } else if (category == 'Stories') {
        return [
          {'title': 'Crawling Through Fear', 'subtitle': 'This is a first-person story by Sahil Patel about struggling with sadness', 'url': 'https://medium.com/know-thyself-heal-thyself/my-story-of-feeling-sad-and-keeping-it-a-secret-3bf5bf9ccc98'},
          {'title': 'It\'s OK not to be OK', 'subtitle': 'We should distinguish it from ordinary sadness', 'url': 'https://www.theguardian.com/commentisfree/2017/dec/06/its-ok-not-to-be-ok-why-we-need-to-embrace-sadness'},
        ];
      }
    }

    // 5. Neutral
    else if (cleanEmotion == 'Neutral') {
      if (category == 'Songs') {
        return [
          {'title': 'Stop this Train - John Mayer', 'subtitle': 'houghtful and relaxed, encourages reflection without heaviness', 'url': 'https://www.youtube.com/watch?v=2UiX4dUUjWc'},
          {'title': 'Banana Pancakes - Jack Johnson', 'subtitle': 'Easygoing melody that promotes a laid-back vibe', 'url': 'https://www.youtube.com/watch?v=YdgoG8hTMUw'},
          {'title': 'Better Together - Jack Johnson', 'subtitle': 'Calming rhythm and comforting lyrics', 'url': 'https://www.youtube.com/watch?v=fqxNYjDFJUk'},
          {'title': 'Come Away With Me - Norah Jones', 'subtitle': 'Warm, gentle vocals that ease anxious thoughts', 'url': 'https://www.youtube.com/watch?v=lbjZPFBD6JU'},
          
        ];
      } else if (category == 'Videos') {
        return [
          {'title': 'Calm Meditation', 'subtitle': 'Guided focus meditation', 'url': 'https://www.youtube.com/watch?v=2ds7W6SO7_E'},
          {'title': 'Nature Walks', 'subtitle': 'Relaxed Joy', 'url': 'https://www.youtube.com/watch?v=PyFN_FYwqvc'},
          {'title': 'Motivational Speech', 'subtitle': 'Encourage messages from Denzel Washington', 'url': 'https://www.youtube.com/watch?v=34OEqUADYTg'},
          
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'How to Be More Emotionally Stable', 'subtitle': 'Offers actionable strategies to maintain neutral or balanced emotions.', 'url': 'https://www.thefriendlymind.com/how-to-be-more-emotionally-stable/'},
          {'title': 'The Power of Neutral Thinking', 'subtitle': 'Explores how neutral thinking can lead to better decision-making and reduced stress.', 'url': 'https://psychotherapyandcounselingservices.com/en/the-power-of-neutral-thinking/'},
          {'title': 'Finding Balance: The Art of Emotional Neutrality', 'subtitle': 'Discusses the benefits of emotional neutrality and techniques to achieve it.', 'url': 'https://hohoy.no/neutrality-the-art-of-balance-for-an-open-mind/'},
        ];
      } else if (category == 'Stories') {
        return [
          {'title': 'The Story of an Hour', 'subtitle': 'A quiet, reflective narrative about inner freedom and life\'s unexpected turns', 'url': 'https://www.owleyes.org/text/the-story-of-an-hour/read/chopins-short-story'},
          {'title': 'De Daumier-Smith\'s Blue Period', 'subtitle': 'A story about personal growth and self-understanding', 'url': 'https://short-stories.co/@j.d.salinger/de-daumier-smiths-blue-period-r8dl3kqkrvq5'},
        ];
      }
    }

    // 6. Surprise
    else if (cleanEmotion == 'Surprise') {
      if (category == 'Songs') {
        return [
          {'title': 'Celebration - Kool & The Gang', 'subtitle': 'Classic upbeat song that feels like a joyful surprise party', 'url': 'https://www.youtube.com/watch?v=3GwjfUFyY6M'},
          {'title': 'Happy - Pharrell Williams', 'subtitle': 'Infectious tune that brings unexpected joy', 'url': 'https://www.youtube.com/watch?v=ZbZSe6N_BXs'},
          {'title': 'Can\'t Stop the Feeling! - Justin Timberlake', 'subtitle': 'Energetic song that lifts spirits unexpectedly', 'url': 'https://www.youtube.com/watch?v=ru0K8uYEZWw'},    
        ];
      } else if (category == 'Videos') {
        return [
          {'title': 'Guy Surprises Strangers', 'subtitle': 'Random Acts of Kindness', 'url': 'https://www.youtube.com/shorts/QdFdzlQxrUo'},
          {'title': 'Surprise Reunions', 'subtitle': 'Heartwarming moments', 'url': 'https://www.youtube.com/results?search_query=surprise+reunions'},
          {'title': 'Incredible Talent Shows', 'subtitle': 'Unexpectedly amazing performances', 'url': 'https://www.youtube.com/watch?v=8jijNm1y8bE'},        
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'Positive Surprise', 'subtitle': 'Explains what positive surprise is and how it affects experience', 'url': 'https://emotiontypology.com/emotion/positive-surprise/'},
          {'title': 'The Science of Surprise', 'subtitle': 'Explores how surprise impacts the brain and behavior', 'url': 'https://www.melissahughes.rocks/post/the-science-of-surprise'},
          {'title': 'Embracing the Unexpected', 'subtitle': 'Discusses the benefits of being open to surprises in life', 'url': 'https://www.embracingtheunexpected.com/'},
        ];
      } else if (category == 'Stories') {
        return [
          {'title': 'The Angel of the Odd', 'subtitle': 'Humorous and bizarre twist story', 'url': 'https://poestories.com/read/angeloftheodd'},
          {'title': '“Galloping Foxley” by Roald Dahl', 'subtitle': 'Routine turns into surprise identity twist', 'url': 'https://lingualeo.com/en/jungle/galloping-foxley-by-roald-dahl-512927'},
        ];
      }
    }

    // 7. Disgust
    else if (cleanEmotion == 'Disgust') {
      if (category == 'Songs') {
        return [
          {'title': 'Creep - Radiohead', 'subtitle': 'Captures feeling “out of place” and self-disgust', 'url': 'https://www.youtube.com/watch?v=XFkzRNyygfk'},
          {'title': 'Hurt - Nine Inch Nails', 'subtitle': 'Dark emotional intensity that reflects internal disgust or pain', 'url': 'https://www.youtube.com/watch?v=6oGqIfnIAEA'},
          {'title': 'Breaking the Habit - Linkin Park', 'subtitle': 'Emotional release and confronting uncomfortable feelings', 'url': 'https://www.youtube.com/watch?v=v2H4l9RpkwM'},    
        ];
      } else if (category == 'Videos') {
        return [
          {'title': 'How to manage Disgust', 'subtitle': 'Explains what disgust is and how people can manage it', 'url': 'https://www.youtube.com/watch?v=74Z6WrQiu5k'},
          {'title': 'What to Do If You\'re Feeling Disgusted', 'subtitle': 'Advice from a psychologist', 'url': 'https://www.youtube.com/watch?v=rJu4Tc_Oh-0'},
          {'title': 'How disgust controls your decisions', 'subtitle': 'Explores how disgust influences our choices', 'url': 'https://www.youtube.com/watch?v=BYwwtgogAao'},        
        ];
      } else if (category == 'Articles') {
        return [
          {'title': 'Definition of Disgust', 'subtitle': 'how it arises and why we feel it', 'url': 'https://psu.pb.unizin.org/psych425/chapter/definition-of-disgust/'},
          {'title': 'Disgust: Definition, Feelings & Expressions', 'subtitle': 'Explores disgust and how it affects people psychologically', 'url': 'https://www.berkeleywellbeing.com/disgust.html'},
          {'title': 'MANAGEMENT OF EMOTIONS: DISGUST', 'subtitle': 'Offers insight into disgust and how to manage the emotional and physical reactions', 'url': 'https://www.igmanagement.it/en/2020/03/07/management-of-emotions-disgust/'},
        ];
      } else if (category == 'Stories') {
        return [
          {'title': 'The Vulture', 'subtitle': 'A disturbing encounter with a vulture — intense physical revulsion', 'url': 'https://albalearning.com/Capitulo.aspx?id=3479'},
          {'title': 'The Swimmer', 'subtitle': 'Shows disgust as social and existential, rather than just physical.', 'url': 'https://www.newyorker.com/magazine/1964/07/18/the-swimmer'},
        ];
      }
    }

    // DEFAULT / FALLBACK
    return [
      {'title': 'Daily Mindfulness', 'subtitle': 'anxiety doesn\'t disappear instantly, but facing', 'url': 'https://adaa.org/living-with-anxiety/personal-stories/crawling-through-fear'},
      {'title': 'My High-Functioning Anxiety Story', 'subtitle': 'A candid narrative about anxiety that seems “invisible” but still real', 'url': 'https://www.bridgestorecovery.com/blog/high-functioning-anxiety-stories-what-you-should-know/'},
    ];
  }
}
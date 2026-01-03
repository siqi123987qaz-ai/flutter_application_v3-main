import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _key = 'mood_history';

  // Save a new record
  static Future<void> saveMood(String emotion, String note) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Create the record
    Map<String, dynamic> record = {
      'emotion': emotion,
      'note': note,
      'date': DateTime.now().toIso8601String(),
    };

    // 2. Get existing list
    List<String> history = prefs.getStringList(_key) ?? [];
    
    // 3. Add new record (convert to string)
    history.insert(0, jsonEncode(record)); // Add to top
    
    // 4. Save back
    await prefs.setStringList(_key, history);
  }

  // Get all records
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    
    return history.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  // Clear history (Optional)
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
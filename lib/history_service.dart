import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _key = 'mood_history';

  // UPDATED: Now accepts 'scores' map
  static Future<void> saveMood(String winner, String note, Map<String, double>? scores) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Create the record
    Map<String, dynamic> record = {
      'emotion': winner,
      'note': note,
      'scores': scores ?? {winner: 1.0}, // Save full data (or fallback)
      'date': DateTime.now().toIso8601String(),
    };

    // Get old list
    List<String> history = prefs.getStringList(_key) ?? [];
    
    // Add new (at top)
    history.insert(0, jsonEncode(record));
    
    // Save
    await prefs.setStringList(_key, history);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_key) ?? [];
    
    return history.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
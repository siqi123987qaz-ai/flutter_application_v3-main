import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // <--- NEW IMPORT
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  
  // --- PRIVATE HELPER: GET USER-SPECIFIC KEY ---
  // Returns something like "mood_history_abc123..."
  static String? _getUserKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null; // No user is logged in
    return 'mood_history_${user.uid}'; 
  }

  // --- SAVE MOOD (User Specific) ---
  static Future<void> saveMood(String winner, String note, Map<String, double>? scores) async {
    final key = _getUserKey();
    if (key == null) return; // Stop if not logged in

    final prefs = await SharedPreferences.getInstance();
    
    // Create the record
    Map<String, dynamic> record = {
      'emotion': winner,
      'note': note,
      'scores': scores ?? {winner: 1.0},
      'date': DateTime.now().toIso8601String(),
    };

    // Get OLD list for THIS user
    List<String> history = prefs.getStringList(key) ?? [];
    
    // Add NEW item
    history.insert(0, jsonEncode(record));
    
    // Save back to THIS user's box
    await prefs.setStringList(key, history);
  }

  // --- GET HISTORY (User Specific) ---
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final key = _getUserKey();
    if (key == null) return []; // Return empty list if not logged in

    final prefs = await SharedPreferences.getInstance();
    
    // Read from THIS user's box
    List<String> history = prefs.getStringList(key) ?? [];
    
    return history.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }

  // --- CLEAR HISTORY (User Specific) ---
  static Future<void> clearHistory() async {
    final key = _getUserKey();
    if (key != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key); // Only delete THIS user's data
    }
  }
}
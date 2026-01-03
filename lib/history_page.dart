import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'history_service.dart';
import 'analytics_page.dart'; // <--- Now opens Analytics, not Recommendation

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _records = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await HistoryService.getHistory();
    setState(() => _records = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mood Diagnosis History"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await HistoryService.clearHistory();
              _loadData();
            },
          )
        ],
      ),
      body: _records.isEmpty
          ? const Center(child: Text("No history yet. Start diagnosing!"))
          : ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final item = _records[index];
                final date = DateTime.parse(item['date']);
                final dateString = DateFormat('MMM dd, yyyy - hh:mm a').format(date);
                final emotion = item['emotion'];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getColor(emotion).withOpacity(0.2),
                      child: Text(_getEmoji(emotion), style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(emotion, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['note'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(dateString, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    trailing: const Icon(Icons.assessment, size: 20, color: Colors.blue), // Icon changed to Chart
                    
                    // --- NEW NAVIGATION LOGIC ---
                    onTap: () {
                      // 1. Retrieve the saved scores
                      // (We need to convert them carefully from JSON)
                      Map<String, dynamic> rawScores = item['scores'] ?? {};
                      Map<String, double> cleanScores = {};
                      
                      if (rawScores.isNotEmpty) {
                        rawScores.forEach((k, v) => cleanScores[k] = (v as num).toDouble());
                      } else {
                        // Fallback for very old records
                        cleanScores = {emotion: 1.0};
                      }

                      // 2. Open the LAB REPORT
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnalyticsPage(scores: cleanScores),
                        ),
                      );
                    },
                    // -----------------------------
                  ),
                );
              },
            ),
    );
  }

  Color _getColor(String emotion) {
    switch(emotion) {
      case 'Happy': return Colors.green;
      case 'Sad': return Colors.blue;
      case 'Angry': return Colors.red;
      case 'Fear': return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _getEmoji(String emotion) {
    switch(emotion) {
      case 'Happy': return "😊";
      case 'Sad': return "😢";
      case 'Angry': return "😡";
      case 'Fear': return "😨";
      case 'Surprise': return "😲";
      case 'Disgust': return "🤢";
      default: return "😐";
    }
  }
}
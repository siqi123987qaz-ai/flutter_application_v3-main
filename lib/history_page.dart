import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'history_service.dart';
import 'recommendation_page.dart';

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
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      // Re-open recommendation
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommendationPage(emotion: emotion),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Color _getColor(String emotion) {
    if (emotion == 'Happy') return Colors.green;
    if (emotion == 'Sad') return Colors.blue;
    if (emotion == 'Angry') return Colors.red;
    return Colors.grey;
  }

  String _getEmoji(String emotion) {
    if (emotion == 'Happy') return "😊";
    if (emotion == 'Sad') return "😢";
    if (emotion == 'Angry') return "😡";
    if (emotion == 'Fear') return "😨";
    if (emotion == 'Surprise') return "😲";
    if (emotion == 'Disgust') return "🤢";
    return "😐";
  }
}
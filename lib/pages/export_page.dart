import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/emotion_entry.dart';

class ExportPage extends StatelessWidget {
  final List<EmotionEntry> entries;
  const ExportPage({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Entries'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.file_download,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Export Your Emotion Data',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${entries.length} entries ready to export',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (entries.isEmpty) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.sentiment_neutral,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No entries to export'),
                      Text('Add some emotions first!',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () => _exportToClipboard(context),
                icon: const Icon(Icons.content_copy),
                label: const Text('Copy CSV to Clipboard'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _exportJSON(context),
                icon: const Icon(Icons.code),
                label: const Text('Copy JSON to Clipboard'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _showTextExport(context),
                icon: const Icon(Icons.text_snippet),
                label: const Text('View as Text'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Export Info',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• CSV format works with Excel and Google Sheets'),
                    Text('• JSON format is good for data analysis'),
                    Text('• Text format is human-readable'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportToClipboard(BuildContext context) {
    final csvData = _generateCSV();
    Clipboard.setData(ClipboardData(text: csvData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV data copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportJSON(BuildContext context) {
    final jsonData = _generateJSON();
    Clipboard.setData(ClipboardData(text: jsonData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('JSON data copied to clipboard!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showTextExport(BuildContext context) {
    final textData = _generateTextReport();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emotion Report'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              textData,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: textData));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report copied to clipboard!')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _generateCSV() {
    final buffer = StringBuffer();
    buffer.writeln('Timestamp,Emotion,Intensity,Note');

    for (final entry in entries) {
      final timestamp = entry.timestamp.toIso8601String();
      final note = (entry.note ?? '')
          .replaceAll(',', ';'); // Replace commas to avoid CSV issues
      buffer.writeln('$timestamp,${entry.emotion},${entry.intensity},"$note"');
    }

    return buffer.toString();
  }

  String _generateJSON() {
    final jsonList = entries
        .map((entry) => {
              'timestamp': entry.timestamp.toIso8601String(),
              'emotion': entry.emotion,
              'intensity': entry.intensity,
              'note': entry.note,
            })
        .toList();

    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'export_date': DateTime.now().toIso8601String(),
      'total_entries': entries.length,
      'entries': jsonList,
    });
  }

  String _generateTextReport() {
    final buffer = StringBuffer();
    buffer.writeln('=== EMOTION TRACKING REPORT ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('Total Entries: ${entries.length}');
    buffer.writeln('');

    if (entries.isNotEmpty) {
      // Summary statistics
      final emotions = entries.map((e) => e.emotion).toSet();
      final avgIntensity =
          entries.map((e) => e.intensity).reduce((a, b) => a + b) /
              entries.length;

      buffer.writeln('=== SUMMARY ===');
      buffer.writeln('Unique Emotions: ${emotions.join(', ')}');
      buffer
          .writeln('Average Intensity: ${avgIntensity.toStringAsFixed(1)}/10');
      buffer.writeln(
          'Date Range: ${entries.first.timestamp.toString().split(' ')[0]} to ${entries.last.timestamp.toString().split(' ')[0]}');
      buffer.writeln('');

      buffer.writeln('=== DETAILED ENTRIES ===');
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        buffer.writeln('${i + 1}. ${entry.emotion} (${entry.intensity}/10)');
        buffer.writeln('   Date: ${entry.timestamp}');
        if (entry.note != null && entry.note!.isNotEmpty) {
          buffer.writeln('   Note: ${entry.note}');
        }
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }
}

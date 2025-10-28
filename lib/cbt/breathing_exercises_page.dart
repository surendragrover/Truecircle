import 'package:flutter/material.dart';
import '../services/json_data_service.dart';
import '../core/truecircle_app_bar.dart';
import 'package:hive/hive.dart';

class BreathingExercisesPage extends StatelessWidget {
  const BreathingExercisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Breathing Exercises'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataService.instance.getBreathingSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const _EmptyMsg(message: 'No exercises available yet.');
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final technique = (e['technique'] ?? '').toString();
              final duration = (e['duration_minutes'] ?? '').toString();
              final effectiveness = (e['effectiveness'] ?? '').toString();
              // Add precise mantra text and counts where relevant
              String mantraInfo = '';
              final tLower = technique.toLowerCase();
              if (tLower.contains('gayatri mantra')) {
                mantraInfo =
                    '\nMantra: Om Bhur Bhuvah Svaha, Tat Savitur Varenyam, Bhargo Devasya Dhimahi, Dhiyo Yo Nah Prachodayat.\nCounts: 108 • 54 • 27 (choose comfortable pace)';
              } else if (tLower.contains('om chanting')) {
                mantraInfo =
                    '\nMantra: Om (A–U–M), sustain the vibration on exhale.\nCounts: 108 • 54 • 27 (comfortable, unforced)';
              }
              return ListTile(
                title: Text(technique.isEmpty ? 'Technique' : technique),
                subtitle: Text(
                  'Duration: $duration min • Effectiveness: $effectiveness$mantraInfo',
                ),
                isThreeLine: mantraInfo.isNotEmpty,
              );
            },
          );
        },
      ),
    );
  }
}

class MoodJournalPage extends StatefulWidget {
  const MoodJournalPage({super.key});

  @override
  State<MoodJournalPage> createState() => _MoodJournalPageState();
}

class _MoodJournalPageState extends State<MoodJournalPage> {
  Future<Map<String, List<Map<String, dynamic>>>>
  _loadAllJournalEntries() async {
    try {
      // Load user entries from Hive
      final box = await Hive.openBox('mood_journal_entries');
      final userEntries = <Map<String, dynamic>>[];

      for (final key in box.keys) {
        final entry = box.get(key);
        if (entry is Map) {
          userEntries.add(Map<String, dynamic>.from(entry));
        }
      }

      // Sort by date (newest first)
      userEntries.sort((a, b) {
        final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
        final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

      // Load demo entries
      final demoEntries = await JsonDataService.instance
          .getMoodJournalEntries();

      return {'user': userEntries, 'demo': demoEntries};
    } catch (e) {
      debugPrint('Error loading mood journal entries: $e');
      return {
        'user': <Map<String, dynamic>>[],
        'demo': <Map<String, dynamic>>[],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Mood Journal'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntrySheet,
        label: const Text('Add Entry'),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _loadAllJournalEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          final userEntries = data['user'] ?? [];
          final demoEntries = data['demo'] ?? [];

          if (userEntries.isEmpty && demoEntries.isEmpty) {
            return const _EmptyMsg(message: 'No journal entries yet.');
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (userEntries.isNotEmpty) ...[
                const _SectionHeader(title: 'Your Entries'),
                ...userEntries.map(_buildUserEntryTile),
                const SizedBox(height: 12),
              ],
              if (demoEntries.isNotEmpty) ...[
                const _SectionHeader(title: 'Sample Entries'),
                ...demoEntries.take(20).map(_buildDemoEntryTile),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserEntryTile(Map<String, dynamic> e) {
    final date = (e['date'] ?? '').toString();
    final title = (e['title'] ?? '').toString();
    final mood = (e['mood_rating'] ?? '').toString();
    final note = (e['description'] ?? '').toString();
    return Card(
      child: ListTile(
        leading: Text(_emojiForMoodRating(e['mood_rating'])),
        title: Text(title.isEmpty ? 'Entry' : title),
        subtitle: Text('Date: $date • Mood: $mood\n$note'),
        isThreeLine: note.isNotEmpty,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final box = await Hive.openBox('mood_journal_entries');
            // Find and delete the first matching key by identity
            for (final key in box.keys) {
              final val = box.get(key);
              if (val is Map && Map<String, dynamic>.from(val) == e) {
                await box.delete(key);
                break;
              }
            }
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  Widget _buildDemoEntryTile(Map<String, dynamic> e) {
    final date = (e['date'] ?? '').toString();
    final title = (e['title'] ?? '').toString();
    final mood = (e['mood_rating'] ?? '').toString();
    final desc = (e['description'] ?? '').toString();
    return ListTile(
      leading: Text(_emojiForMoodRating(e['mood_rating'])),
      title: Text(title.isEmpty ? 'Entry' : title),
      subtitle: Text('Date: $date • Mood: $mood\n$desc'),
      isThreeLine: desc.isNotEmpty,
    );
  }

  String _emojiForMoodRating(dynamic rating) {
    final r = int.tryParse(rating?.toString() ?? '') ?? 5;
    if (r >= 8) return '😆';
    if (r >= 6) return '😊';
    if (r >= 4) return '😐';
    if (r >= 2) return '😢';
    return '😠';
  }

  void _showAddEntrySheet() {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    double rating = 5;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Mood Entry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('Mood rating (1–10)'),
              StatefulBuilder(
                builder: (context, setModal) => Slider(
                  value: rating,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: rating.round().toString(),
                  onChanged: (v) => setModal(() => rating = v),
                ),
              ),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title (optional)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Entry'),
                  onPressed: () async {
                    final box = await Hive.openBox('mood_journal_entries');
                    final now = DateTime.now();
                    await box.add({
                      'date': now.toIso8601String(),
                      'title': titleCtrl.text.trim(),
                      'mood_rating': rating.round(),
                      'description': noteCtrl.text.trim(),
                    });
                    // Guard both State.context and local BuildContexts after async gap
                    if (!mounted) return;
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!context.mounted) return;
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entry saved')),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class EmotionalCheckinPage extends StatelessWidget {
  const EmotionalCheckinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TrueCircleAppBar(
        title: 'Emotional Check-in',
        actions: [
          TextButton(
            onPressed: () {
              // Go straight back to Home (root of the stack)
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Done'),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: JsonDataService.instance.getEmotionalCheckins(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const _EmptyMsg(message: 'No check-ins yet.');
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final date = (e['date'] ?? '').toString();
              final time = (e['time'] ?? '').toString();
              final emotion = (e['emotion'] ?? '').toString();
              final intensity = (e['intensity'] ?? '').toString();
              return ListTile(
                title: Text('$emotion ($intensity/10)'),
                subtitle: Text('Date: $date • Time: $time'),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyMsg extends StatelessWidget {
  final String message;
  const _EmptyMsg({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 4),
      child: Row(
        children: [
          const Icon(Icons.mood, color: Colors.indigo),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }
}

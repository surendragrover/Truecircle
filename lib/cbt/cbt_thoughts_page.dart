import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/truecircle_app_bar.dart';
import '../services/json_data_service.dart';

class CBTThoughtsPage extends StatefulWidget {
  const CBTThoughtsPage({super.key});

  @override
  State<CBTThoughtsPage> createState() => _CBTThoughtsPageState();
}

class _CBTThoughtsPageState extends State<CBTThoughtsPage> {
  late Future<_ThoughtData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ThoughtData> _load() async {
    // Load starters
    final starters = await JsonDataService.instance.getCbtThoughts();
    // Load user entries from Hive
    final box = await Hive.openBox('cbt_thought_entries');
    final user = <Map<String, dynamic>>[];
    for (final key in box.keys) {
      final v = box.get(key);
      if (v is Map) user.add(Map<String, dynamic>.from(v));
    }
    // Sort newest first
    user.sort((a, b) {
      final da =
          DateTime.tryParse((a['date'] ?? '').toString()) ?? DateTime.now();
      final db =
          DateTime.tryParse((b['date'] ?? '').toString()) ?? DateTime.now();
      return db.compareTo(da);
    });
    return _ThoughtData(userEntries: user, starters: starters);
  }

  Future<void> _addThought() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.psychology_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Add Thought Entry',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText:
                        'What thought came to your mind? Describe the situation briefly...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please write your thought.'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            Navigator.pop(context, true);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    if (saved == true) {
      final text = controller.text.trim();
      final box = await Hive.openBox('cbt_thought_entries');
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await box.put(id, {
        'id': id,
        'text': text,
        'date': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      setState(() => _future = _load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'CBT Thoughts'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addThought,
        icon: const Icon(Icons.add),
        label: const Text('Add Thought'),
      ),
      body: FutureBuilder<_ThoughtData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data =
              snap.data ?? const _ThoughtData(userEntries: [], starters: []);
          return ListView(
            children: [
              if (data.userEntries.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Your Thought Entries',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 0),
                ...data.userEntries.map(
                  (e) => ListTile(
                    leading: const Icon(Icons.edit_note_outlined),
                    title: Text((e['text'] ?? '').toString()),
                    subtitle: Text(_formatDate((e['date'] ?? '').toString())),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'CBT Thought Starters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (data.starters.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No thought starters found.'),
                )
              else
                ...data.starters.map(
                  (t) => Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.psychology_outlined),
                        title: Text(t),
                      ),
                      const Divider(height: 0),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ThoughtData {
  final List<Map<String, dynamic>> userEntries;
  final List<String> starters;
  const _ThoughtData({required this.userEntries, required this.starters});
}

import 'package:flutter/material.dart';
import '../services/json_data_service.dart';
import '../services/emotional_awareness_service.dart';
import '../models/emotional_awareness_selection.dart';

class EmotionalAwarenessPage extends StatefulWidget {
  const EmotionalAwarenessPage({super.key});

  @override
  State<EmotionalAwarenessPage> createState() => _EmotionalAwarenessPageState();
}

class _EmotionalAwarenessPageState extends State<EmotionalAwarenessPage> {
  late Future<List<Map<String, dynamic>>> _future;
  final _service = EmotionalAwarenessService.instance;
  Map<String, EAOccurrenceType> _selections = {};

  @override
  void initState() {
    super.initState();
    _future = JsonDataService.instance.getEmotionalAwarenessCategories();
    _loadSelections();
  }

  Future<void> _loadSelections() async {
    final all = await _service.getAllSelections();
    if (mounted) {
      setState(() => _selections = all);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emotional Awareness')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final cats = snap.data ?? const [];
          if (cats.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'List unavailable — offline asset not found.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                'From these questions, mark the ones that come to your mind often as "Regular/Often". Mark those that show up only on special situations as "Specific occasions". Your choices are stored locally on device.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ...cats.map((c) => _categorySection(context, c)),
            ],
          );
        },
      ),
    );
  }

  Widget _categorySection(BuildContext context, Map<String, dynamic> cat) {
    final title = (cat['title'] ?? '').toString();
    final questions =
        (cat['questions'] as List?)?.cast<String>() ?? const <String>[];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          const Divider(height: 1),
          ...questions.map((q) => _questionRow(context, q)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _questionRow(BuildContext context, String question) {
    final selected = _selections[question];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Regular/Often'),
                selected: selected == EAOccurrenceType.regular,
                onSelected: (val) =>
                    _onSelect(question, val ? EAOccurrenceType.regular : null),
              ),
              ChoiceChip(
                label: const Text('Specific occasions'),
                selected: selected == EAOccurrenceType.specific,
                onSelected: (val) =>
                    _onSelect(question, val ? EAOccurrenceType.specific : null),
              ),
              if (selected != null)
                ActionChip(
                  label: const Text('Remove'),
                  onPressed: () => _onSelect(question, null),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onSelect(String question, EAOccurrenceType? occ) async {
    await _service.setSelection(question: question, occurrence: occ);
    setState(() {
      if (occ == null) {
        _selections.remove(question);
      } else {
        _selections[question] = occ;
      }
    });
  }
}

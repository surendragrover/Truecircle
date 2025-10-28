import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import '../services/json_data_service.dart';
import '../services/emotional_awareness_service.dart';
import '../models/emotional_awareness_selection.dart';
import 'detailed_emotional_intake_form.dart';

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

  List<Map<String, dynamic>> _getFallbackCategories() {
    return [
      {
        'id': 'A',
        'title': 'Emotional Awareness (Feeling Identification)',
        'questions': [
          'How can I tell what I am feeling right now?',
          'Why do I sometimes feel empty even when nothing is wrong?',
          'Can two opposite emotions exist at the same time?',
          'How can I stop ignoring my emotions?',
          'What is the difference between sadness and depression?',
          'How can I express my emotions without hurting others?',
          'Why do I feel guilty for being happy?',
          'How can I recognize emotional burnout?',
          'How can I manage sudden mood swings?',
          'How can I build emotional resilience?',
        ],
      },
      {
        'id': 'B',
        'title': 'Relationship & Social Awareness',
        'questions': [
          'How do I know if a relationship is healthy?',
          'Why do I struggle with setting boundaries?',
          'How can I communicate my needs effectively?',
          'What should I do when someone dismisses my feelings?',
          'How can I maintain relationships without losing myself?',
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Emotional Check-in'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final cats = snap.data ?? _getFallbackCategories();
          if (cats.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Emotional Awareness',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading emotional awareness content...',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(8, 12, 16, 24),
            children: [
              // Detailed Assessment Option
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Complete Detailed Assessment',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Help Dr. Iris understand you better with a comprehensive questionnaire about your life, relationships, and emotional patterns.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DetailedEmotionalIntakeForm(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.assignment_outlined),
                            label: const Text('Take Detailed Assessment'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Divider(),
              const SizedBox(height: 8),

              Text(
                'Quick Check-in: From these questions, mark the ones that come to your mind often as "Regular/Often". Mark those that show up only on special situations as "Specific occasions". Your choices are stored locally on device.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ...cats.map((c) => _categorySection(context, c)),

              const SizedBox(height: 32),

              // Complete Check-in Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: _selections.isNotEmpty
                      ? () => _completeCheckin(context)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selections.isEmpty
                            ? 'Please select at least one item'
                            : 'Complete Emotional Check-in',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip Button (for first-time users)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton(
                  onPressed: () => _completeCheckin(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Skip for now - Go to Dashboard',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
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
      margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('🔥 Regular/Often'),
                selected: selected == EAOccurrenceType.regular,
                selectedColor: const Color(0xFFEC4899), // Hot Pink
                backgroundColor: const Color(0xFFEC4899).withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: selected == EAOccurrenceType.regular
                      ? Colors.white
                      : const Color(0xFFEC4899),
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (val) =>
                    _onSelect(question, val ? EAOccurrenceType.regular : null),
              ),
              ChoiceChip(
                label: const Text('⭐ Specific occasions'),
                selected: selected == EAOccurrenceType.specific,
                selectedColor: const Color(0xFF3B82F6), // Sky Blue
                backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: selected == EAOccurrenceType.specific
                      ? Colors.white
                      : const Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (val) =>
                    _onSelect(question, val ? EAOccurrenceType.specific : null),
              ),
              if (selected != null)
                ActionChip(
                  label: const Text('🗑️ Remove'),
                  backgroundColor: const Color(
                    0xFFFF6B35,
                  ).withValues(alpha: 0.1),
                  labelStyle: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.w600,
                  ),
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

  void _completeCheckin(BuildContext context) {
    // Show completion message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selections.isNotEmpty
                    ? 'Your emotional check-in is complete! ${_selections.length} items selected.'
                    : 'Check-in completed. Welcome to your wellness dashboard!',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to complete the flow
    Navigator.of(context).pop();
  }
}

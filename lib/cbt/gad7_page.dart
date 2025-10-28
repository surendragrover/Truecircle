import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';

class GAD7Page extends StatefulWidget {
  const GAD7Page({super.key});

  @override
  State<GAD7Page> createState() => _GAD7PageState();
}

class _GAD7PageState extends State<GAD7Page> {
  final List<String> _questions = const [
    'Feeling nervous, anxious, or on edge',
    'Not being able to stop or control worrying',
    'Worrying too much about different things',
    'Trouble relaxing',
    'Being so restless that it is hard to sit still',
    'Becoming easily annoyed or irritable',
    'Feeling afraid, as if something awful might happen',
  ];

  final Map<int, int> _answers = {};

  static const List<String> _options = [
    'Not at all',
    'Several days',
    'More than half the days',
    'Nearly every day',
  ];

  int get _total => _answers.values.fold(0, (a, b) => a + b);

  String _band(int total) {
    if (total <= 4) return 'Minimal (0–4)';
    if (total <= 9) return 'Mild (5–9)';
    if (total <= 14) return 'Moderate (10–14)';
    return 'Severe (15–21)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'GAD‑7 (Offline)'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Over the last 2 weeks, how often have you been bothered by the following problems? Select one option per line.',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _questions.length; i++) _questionTile(i),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total: $_total / 21',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text('Band: ${_band(_total)}'),
                  const SizedBox(height: 8),
                  Text(
                    'Educational use only. This does not provide a diagnosis. If you are concerned, consider speaking to a qualified professional in your area.',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionTile(int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${index + 1}. ${_questions[index]}'),
            const SizedBox(height: 8),
            _optionSelector(index),
          ],
        ),
      ),
    );
  }

  Widget _optionSelector(int index) {
    final selected = _answers[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, label: Text('0')),
            ButtonSegment(value: 1, label: Text('1')),
            ButtonSegment(value: 2, label: Text('2')),
            ButtonSegment(value: 3, label: Text('3')),
          ],
          selected: selected == null ? <int>{} : <int>{selected},
          emptySelectionAllowed: true,
          onSelectionChanged: (newSel) {
            final val = newSel.isEmpty ? null : newSel.first;
            setState(() {
              if (val == null) {
                _answers.remove(index);
              } else {
                _answers[index] = val;
              }
            });
          },
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: List.generate(4, (v) => Text('$v: ${_options[v]}')),
        ),
      ],
    );
  }
}

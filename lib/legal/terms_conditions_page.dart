import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TermsConditionsPage extends StatefulWidget {
  const TermsConditionsPage({super.key});

  @override
  State<TermsConditionsPage> createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  late Future<_Terms> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadTerms();
  }

  Future<_Terms> _loadTerms() async {
    try {
      // Note the space in file name
      final raw = await rootBundle.loadString(
        'assets/Terms and Conditions.JSON',
      );
      final map = json.decode(raw) as Map<String, dynamic>;
      return _Terms.fromJson(map);
    } catch (e) {
      return const _Terms(appName: 'TrueCircle', sections: []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: FutureBuilder<_Terms>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final terms =
              snap.data ?? const _Terms(appName: 'TrueCircle', sections: []);
          if (terms.sections.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Terms & Conditions content is not available offline.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Text(
                terms.appName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Terms & Conditions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...terms.sections.map((s) => _sectionCard(context, s)),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionCard(BuildContext context, _Section s) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          s.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(s.content),
          ),
        ],
      ),
    );
  }
}

class _Terms {
  final String appName;
  final List<_Section> sections;
  const _Terms({required this.appName, required this.sections});

  factory _Terms.fromJson(Map<String, dynamic> json) {
    final name = (json['app_name'] ?? 'TrueCircle').toString();
    final list =
        (json['sections'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return _Terms(
      appName: name,
      sections: list
          .map(
            (e) => _Section(
              title: (e['title'] ?? '').toString(),
              content: (e['content'] ?? '').toString(),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _Section {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});
}

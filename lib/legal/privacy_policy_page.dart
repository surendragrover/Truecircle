import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late Future<_Policy> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadPolicy();
  }

  Future<_Policy> _loadPolicy() async {
    try {
      final raw = await rootBundle.loadString('assets/Privacy_Policy.JSON');
      final map = json.decode(raw) as Map<String, dynamic>;
      return _Policy.fromJson(map);
    } catch (e) {
      return const _Policy(appName: 'TrueCircle', sections: []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: FutureBuilder<_Policy>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final policy =
              snap.data ?? const _Policy(appName: 'TrueCircle', sections: []);
          if (policy.sections.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Privacy Policy content is not available offline.',
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
                policy.appName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Privacy Policy',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...policy.sections.map((s) => _sectionCard(context, s)),
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

class _Policy {
  final String appName;
  final List<_Section> sections;
  const _Policy({required this.appName, required this.sections});

  factory _Policy.fromJson(Map<String, dynamic> json) {
    final name = (json['app_name'] ?? 'TrueCircle').toString();
    final list =
        (json['sections'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return _Policy(
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

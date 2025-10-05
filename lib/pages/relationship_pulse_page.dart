import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact.dart';
import '../models/contact_interaction.dart';
import '../services/ai_orchestrator_service.dart';

class RelationshipPulsePage extends StatefulWidget {
  const RelationshipPulsePage({super.key});

  @override
  State<RelationshipPulsePage> createState() => _RelationshipPulsePageState();
}

class _RelationshipPulsePageState extends State<RelationshipPulsePage> {
  List<Contact> _contacts = [];
  Map<String, List<ContactInteraction>> _interactionsByContact = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final contactBox = await Hive.openBox<Contact>('contacts');
      final interactionBox =
          await Hive.openBox<ContactInteraction>('contact_interactions');
      _contacts = contactBox.values.toList();

      // Group interactions
      final map = <String, List<ContactInteraction>>{};
      for (final i in interactionBox.values) {
        map.putIfAbsent(i.contactId, () => []).add(i);
      }
      _interactionsByContact = map;
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relationship Pulse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Reload',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? _buildEmpty()
              : _buildContent(),
    );
  }

  Widget _buildEmpty() => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, size: 56, color: Colors.grey),
              SizedBox(height: 12),
              Text('No contact insights yet', style: TextStyle(fontSize: 16)),
              SizedBox(height: 6),
              Text('Seed data or add contacts to view emotional clustering',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );

  Widget _buildContent() {
    final warm = _contacts
        .where((c) => c.emotionalScore == EmotionalScore.veryWarm)
        .toList();
    final fading = _contacts
        .where((c) => c.emotionalScore == EmotionalScore.friendlyButFading)
        .toList();
    final cold = _contacts
        .where((c) => c.emotionalScore == EmotionalScore.cold)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection('Very Warm', warm, Colors.blue),
        _buildSection('Fading', fading, Colors.amber),
        _buildSection('Distant', cold, Colors.grey),
        const SizedBox(height: 24),
        _buildOrchestratorFooter(),
      ],
    );
  }

  Widget _buildSection(String title, List<Contact> list, Color color) {
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ...list.map(_buildTile),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTile(Contact c) {
    final interactions = _interactionsByContact[c.id] ?? [];
    interactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final last = interactions.isNotEmpty ? interactions.first : null;

    final conflict =
        interactions.where((i) => i.metadata['conflict'] == true).toList();
    final repairs = interactions
        .where((i) => i.metadata['conflict_resolution'] == true)
        .toList();

    final daysGap = c.daysSinceLastContact;
    final reconnectNeeded =
        daysGap > 60 || c.metadata['pending_reconnect'] == true;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(c.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Score: ${c.emotionalScoreValue.toStringAsFixed(0)}  •  Last: ${last != null ? _friendlyTime(last.timestamp) : '—'}'),
            if (reconnectNeeded)
              const Text('Reconnect suggested',
                  style: TextStyle(color: Colors.orange, fontSize: 12)),
            if (conflict.isNotEmpty && repairs.isNotEmpty)
              const Text('Conflict → Repair detected',
                  style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
        trailing: reconnectNeeded
            ? TextButton(
                onPressed: () {
                  // Only a UI nudge for now
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Plan a reconnect with ${c.displayName}')),
                  );
                },
                child: const Text('RECONNECT'),
              )
            : null,
      ),
    );
  }

  String _friendlyTime(DateTime dt) {
    final diff = DateTime.now().difference(dt).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return '${diff}d ago';
  }

  Widget _buildOrchestratorFooter() {
    final last = AIOrchestratorService().lastRefreshed;
    return Center(
      child: Text(
        last == null
            ? 'Insights not refreshed yet'
            : 'Updated ${last.toLocal()}'.split('.').first,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
    );
  }
}

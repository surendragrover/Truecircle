import 'package:flutter/material.dart';

import '../services/json_data_service.dart';
import '../theme/coral_theme.dart';
import '../widgets/truecircle_logo.dart';

class SampleDataDiagnosticsPage extends StatelessWidget {
  const SampleDataDiagnosticsPage({super.key});

  Future<_SampleDataSnapshot> _loadSampleData() async {
    final service = JsonDataService.instance;
    final festivals = await service.getFestivalsData();
    final relationships = await service.getRelationshipData();
    final moods = await service.getMoodJournalData();
    final emotional = await service.getEmotionalCheckInData();
    final meditation = await service.getMeditationData();
    final breathing = await service.getBreathingData();

    return _SampleDataSnapshot(
      festivals: festivals,
      relationships: relationships,
      moodJournal: moods,
      emotionalCheckins: emotional,
      meditation: meditation,
      breathing: breathing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Sample Data Diagnostics / नमूना डेटा रिपोर्ट'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: CoralTheme.appBarGradient),
        ),
      ),
      body: Container(
        decoration: CoralTheme.background,
        child: FutureBuilder<_SampleDataSnapshot>(
          future: _loadSampleData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildError(context, snapshot.error.toString());
            }
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeaderCard(data),
                const SizedBox(height: 16),
                _buildFestivalCard(data),
                const SizedBox(height: 16),
                _buildRelationshipCard(data),
                const SizedBox(height: 16),
                _buildMoodCard(data),
                const SizedBox(height: 16),
                _buildWellnessCard(data),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TrueCircleLogo(size: 72),
            const SizedBox(height: 24),
            Text(
              'Data load failed / डेटा लोड नहीं हुआ',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(_SampleDataSnapshot data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: TrueCircleLogo(size: 42, showText: false),
              title: Text(
                'Sample Data Loaded',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text('नमूना डेटा सफलतापूर्वक लोड हुआ'),
            ),
            const Divider(),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildChip('Festivals: ${data.festivalCount}', 'त्योहार'),
                _buildChip(
                    'Relationships: ${data.relationshipCount}', 'रिश्ते'),
                _buildChip('Mood entries: ${data.moodCount}', 'मूड रिकॉर्ड'),
                _buildChip('Emotional check-ins: ${data.emotionalCount}',
                    'भावनात्मक चेक-इन'),
                _buildChip(
                    'Meditation tips: ${data.meditationCount}', 'ध्यान सुझाव'),
                _buildChip(
                    'Breathing tips: ${data.breathingCount}', 'श्वास सुझाव'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFestivalCard(_SampleDataSnapshot data) {
    final topFestivals = data.festivals['festivals'] as List<dynamic>? ?? [];
    return _buildDataCard(
      titleEn: 'Upcoming Festival Highlights',
      titleHi: 'आगामी त्योहार मुख्य बातें',
      descriptionEn:
          'First two festivals with greeting preview to confirm asset integrity.',
      descriptionHi: 'पहले दो त्योहार और उनके शुभ संदेश – डेटा सत्यापन के लिए।',
      children: topFestivals.take(2).map((festival) {
        final map = Map<String, dynamic>.from(festival);
        final greetings = Map<String, dynamic>.from(map['greetingMessages']);
        return ListTile(
          title: Text('${map['name']} • ${map['date']}'),
          subtitle: Text(
            '${greetings['en'] ?? '-'}\n${greetings['hi'] ?? '-'}',
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRelationshipCard(_SampleDataSnapshot data) {
    return _buildDataCard(
      titleEn: 'Relationship Insights Preview',
      titleHi: 'रिलेशनशिप इनसाइट्स पूर्वावलोकन',
      descriptionEn:
          'Showing top three interactions to validate JsonDataService mapping.',
      descriptionHi:
          'शीर्ष तीन इंटरैक्शन दिखाए गए हैं ताकि JsonDataService मैपिंग सत्यापित हो सके।',
      children: data.relationships.take(3).map((interaction) {
        final name = interaction['contactName'] ?? 'Unknown';
        final score = interaction['sentimentScore'] ?? '—';
        final type = interaction['interactionType'] ?? '—';
        return ListTile(
          leading: CircleAvatar(child: Text(name.toString().characters.first)),
          title: Text(name.toString()),
          subtitle: Text(
            'Type: $type • Score: $score',
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodCard(_SampleDataSnapshot data) {
    final entries = (data.moodJournal['entries'] as List<dynamic>?) ?? [];
    return _buildDataCard(
      titleEn: 'Mood Journal Snapshot',
      titleHi: 'मूड जर्नल स्नैपशॉट',
      descriptionEn:
          'Latest two mood entries with bilingual affirmations for visual QA.',
      descriptionHi:
          'ताज़ा दो मूड प्रविष्टियाँ तथा द्विभाषी संदेश – दृश्य QA के लिए।',
      children: entries.take(2).map((entry) {
        final map = Map<String, dynamic>.from(entry as Map);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange.shade200,
            child: Text(map['mood'].toString().characters.first),
          ),
          title: Text(map['mood']?.toString() ?? '—'),
          subtitle: Text(
            '${map['affirmation_en'] ?? '-'}\n${map['affirmation_hi'] ?? '-'}',
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWellnessCard(_SampleDataSnapshot data) {
    return _buildDataCard(
      titleEn: 'Wellness Routines',
      titleHi: 'वेलनेस रूटीन',
      descriptionEn:
          'Meditation & breathing rotations confirm asset coverage in UI.',
      descriptionHi:
          'ध्यान व श्वास सुझाव यहां प्रदर्शित हैं ताकि एसेट कवरेज सत्यापित हो।',
      children: [
        ListTile(
          leading: const Icon(Icons.self_improvement),
          title: const Text('Meditation Tip / ध्यान सुझाव'),
          subtitle: Text(
            data.meditation.isEmpty
                ? 'No data'
                : '${data.meditation.first['title_en'] ?? ''}\n${data.meditation.first['title_hi'] ?? ''}',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.air),
          title: const Text('Breathing Tip / श्वास सुझाव'),
          subtitle: Text(
            data.breathing.isEmpty
                ? 'No data'
                : '${data.breathing.first['title_en'] ?? ''}\n${data.breathing.first['title_hi'] ?? ''}',
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard({
    required String titleEn,
    required String titleHi,
    required String descriptionEn,
    required String descriptionHi,
    required List<Widget> children,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$titleEn\n$titleHi',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$descriptionEn\n$descriptionHi',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String english, String hindi) {
    return Chip(
      avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
      label: Text('$english • $hindi'),
      backgroundColor: Colors.green.shade50,
    );
  }
}

class _SampleDataSnapshot {
  _SampleDataSnapshot({
    required this.festivals,
    required this.relationships,
    required this.moodJournal,
    required this.emotionalCheckins,
    required this.meditation,
    required this.breathing,
  });

  final Map<String, dynamic> festivals;
  final List<Map<String, dynamic>> relationships;
  final Map<String, dynamic> moodJournal;
  final List<Map<String, dynamic>> emotionalCheckins;
  final List<Map<String, dynamic>> meditation;
  final List<Map<String, dynamic>> breathing;

  int get festivalCount =>
      (festivals['festivals'] as List<dynamic>? ?? const []).length;
  int get relationshipCount => relationships.length;
  int get moodCount =>
      (moodJournal['entries'] as List<dynamic>? ?? const []).length;
  int get emotionalCount => emotionalCheckins.length;
  int get meditationCount => meditation.length;
  int get breathingCount => breathing.length;
}

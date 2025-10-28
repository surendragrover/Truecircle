import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import '../services/json_data_service.dart';
import 'detailed_sleep_entry_form.dart';
import 'package:hive/hive.dart';

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({super.key});

  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  Future<Map<String, List<Map<String, dynamic>>>> _loadAllSleepEntries() async {
    try {
      // Load user entries from Hive
      final box = await Hive.openBox('sleep_entries');
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
          .getSleepTrackerEntries();

      return {'user': userEntries, 'demo': demoEntries};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading sleep entries: $e');
      }
      return {
        'user': <Map<String, dynamic>>[],
        'demo': <Map<String, dynamic>>[],
      };
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Icon(Icons.bedtime, color: Colors.indigo),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSleepCard(Map<String, dynamic> entry) {
    final date = DateTime.tryParse(entry['date'] ?? '') ?? DateTime.now();
    final bedTime = entry['bed_time'] ?? 'N/A';
    final wakeTime = entry['wake_time'] ?? 'N/A';
    final sleepQuality = entry['sleep_quality'] ?? 'N/A';
    final morningMood = entry['morning_mood'] ?? 'N/A';
    final dreams = entry['dreams_description'] ?? '';
    final nightmares = entry['nightmares_description'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                _buildQualityChip(sleepQuality),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(Icons.bedtime, 'Bed Time', bedTime),
                ),
                Expanded(
                  child: _buildInfoRow(Icons.wb_sunny, 'Wake Time', wakeTime),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _buildInfoRow(Icons.mood, 'Morning Mood', morningMood),

            if (dreams.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.nights_stay, 'Dreams', dreams),
            ],

            if (nightmares.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.warning, 'Nightmares', nightmares),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDemoSleepCard(Map<String, dynamic> entry) {
    final day = entry['day'] ?? '';
    final duration = entry['duration'] ?? '';
    final quality = entry['quality'] ?? '';
    final bedtime = entry['bedtime'] ?? '';
    final wakeTime = entry['wakeTime'] ?? '';
    final notes = entry['notes'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Day $day - Sample Entry',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  'Quality: $quality/10',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              'Duration: $duration\nBed: $bedtime → Wake: $wakeTime',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),

            if (notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                notes,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQualityChip(String quality) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (quality.toLowerCase()) {
      case 'excellent':
        backgroundColor = Colors.green;
        break;
      case 'good':
      case 'very good':
        backgroundColor = Colors.lightGreen;
        break;
      case 'fair':
        backgroundColor = Colors.orange;
        break;
      case 'poor':
      case 'very poor':
        backgroundColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        quality,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Sleep Tracker'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailedSleepEntryForm(),
            ),
          ).then((result) {
            if (result == true) {
              setState(() {}); // Refresh the list
            }
          });
        },
        label: const Text('Add Sleep Entry'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _loadAllSleepEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          final userEntries = data['user'] ?? [];
          final demoEntries = data['demo'] ?? [];

          if (userEntries.isEmpty && demoEntries.isEmpty) {
            return const _EmptyMsg();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userEntries.isNotEmpty) ...[
                  _buildSectionHeader('Your Sleep Entries'),
                  ...userEntries.map((entry) => _buildUserSleepCard(entry)),
                  const SizedBox(height: 16),
                ],

                if (demoEntries.isNotEmpty) ...[
                  _buildSectionHeader('Sample Sleep Data'),
                  ...demoEntries
                      .take(3)
                      .map((entry) => _buildDemoSleepCard(entry)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyMsg extends StatelessWidget {
  const _EmptyMsg();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          'No sleep data available. Ensure data/Sleep_Tracker.json is bundled.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

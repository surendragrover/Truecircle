import 'package:flutter/material.dart';
import '../../services/json_data_service.dart';
import '../../sleep/detailed_sleep_entry_form.dart';
import '../../sleep/sleep_tracker_page.dart';

/// Sleep Tracker Widget - Complete sleep monitoring
/// Professional sleep quality and duration tracking for better wellness
class SleepTrackerWidget extends StatelessWidget {
  const SleepTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _viewHistory(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A237E).withValues(alpha: 0.1),
              const Color(0xFF3F51B5).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF3F51B5).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sleep Tracker Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F51B5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bedtime_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sleep Tracker',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Monitor sleep quality and patterns',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Last Night's Sleep (from JSON demo or user-added when available)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: JsonDataService.instance.getSleepTrackerEntries(),
                builder: (context, snapshot) {
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting;
                  final list = snapshot.data ?? const <Map<String, dynamic>>[];
                  final last = list.isNotEmpty ? list.last : null;

                  String duration = last?['duration']?.toString() ?? '—';
                  final bedtime = last?['bedtime']?.toString() ?? '—';
                  final wakeTime = last?['wakeTime']?.toString() ?? '—';
                  final qualityVal =
                      int.tryParse('${last?['quality'] ?? ''}') ?? 0;
                  final chip = _qualityChip(qualityVal);
                  final score = qualityVal.clamp(0, 10) * 10;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Last Night\'s Sleep',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          chip,
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Sleep Duration
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 20,
                            color: Color(0xFF3F51B5),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isLoading ? '—' : duration,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F51B5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'duration',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Sleep Quality Metrics
                      Row(
                        children: [
                          Expanded(
                            child: _buildSleepMetric(
                              'Bedtime',
                              bedtime,
                              Icons.nights_stay_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSleepMetric(
                              'Wake up',
                              wakeTime,
                              Icons.wb_sunny_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Sleep Score Progress
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sleep Score',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                isLoading ? '—' : '$score/100',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3F51B5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: isLoading ? null : (score / 100.0),
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF3F51B5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Weekly Sleep Trend (computed from last 7 entries)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: JsonDataService.instance.getSleepTrackerEntries(),
                builder: (context, snapshot) {
                  final list = snapshot.data ?? const <Map<String, dynamic>>[];
                  // take last 7 entries for weekly trends
                  final week = list.length <= 7
                      ? list
                      : list.sublist(list.length - 7);
                  final avgMinutes = _avgDurationMinutes(week);
                  final avgDur = _formatMinutes(avgMinutes);
                  final avgQuality = week.isEmpty
                      ? 0
                      : (week
                                    .map(
                                      (e) =>
                                          int.tryParse(
                                            '${e['quality'] ?? 0}',
                                          ) ??
                                          0,
                                    )
                                    .fold<int>(0, (a, b) => a + b) /
                                week.length)
                            .toDouble();
                  final avgQualityPct = (avgQuality * 10).round();
                  final avgInterruptions = week.isEmpty
                      ? 0.0
                      : week
                                .map(
                                  (e) =>
                                      int.tryParse(
                                        '${e['interruptions'] ?? 0}',
                                      ) ??
                                      0,
                                )
                                .fold<int>(0, (a, b) => a + b) /
                            week.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Average',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeeklyStat(
                            'Sleep',
                            avgDur,
                            Icons.bedtime_rounded,
                          ),
                          _buildWeeklyStat(
                            'Quality',
                            '$avgQualityPct%',
                            Icons.star_rounded,
                          ),
                          _buildWeeklyStat(
                            'Interruptions',
                            avgInterruptions.toStringAsFixed(1),
                            Icons.timeline_rounded,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _logSleep(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Log Sleep'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewHistory(context),
                    icon: const Icon(Icons.history_rounded, size: 18),
                    label: const Text('History'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF3F51B5).withValues(alpha: 0.7),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildWeeklyStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: const Color(0xFF3F51B5)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _logSleep(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DetailedSleepEntryForm()),
    );
  }

  void _viewHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SleepTrackerPage()),
    );
  }

  // Helpers for weekly calculations
  static int _parseDurationToMinutes(String duration) {
    // Expected format like '7h 30m' or '6h 0m'
    final hMatch = RegExp(r"(\d+)h").firstMatch(duration);
    final mMatch = RegExp(r"(\d+)m").firstMatch(duration);
    final h = hMatch != null ? int.tryParse(hMatch.group(1)!) ?? 0 : 0;
    final m = mMatch != null ? int.tryParse(mMatch.group(1)!) ?? 0 : 0;
    return h * 60 + m;
  }

  static int _avgDurationMinutes(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return 0;
    final total = entries
        .map((e) => _parseDurationToMinutes('${e['duration'] ?? '0h 0m'}'))
        .fold<int>(0, (a, b) => a + b);
    return (total / entries.length).round();
  }

  static String _formatMinutes(int minutes) {
    final h = (minutes ~/ 60).abs();
    final m = (minutes % 60).abs();
    return '${h}h ${m}m';
  }

  static Widget _qualityChip(int q) {
    String label;
    Color color;
    if (q >= 8) {
      label = 'Good';
      color = Colors.green;
    } else if (q >= 6) {
      label = 'Average';
      color = Colors.orange;
    } else if (q > 0) {
      label = 'Poor';
      color = Colors.red;
    } else {
      label = '—';
      color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MetricsSnapshot {
  final double avgMood7d;
  final int checkIns7d;
  final int breathingSessions7d;
  final int meditationSessions7d;
  final double sleepAvgHours7d;
  final int reconnects30d;
  final int conflictRepairs30d;
  final int streakDays;
  final DateTime generatedAt;
  const MetricsSnapshot({
    required this.avgMood7d,
    required this.checkIns7d,
    required this.breathingSessions7d,
    required this.meditationSessions7d,
    required this.sleepAvgHours7d,
    required this.reconnects30d,
    required this.conflictRepairs30d,
    required this.streakDays,
    required this.generatedAt,
  });
  static MetricsSnapshot empty() => MetricsSnapshot(
        avgMood7d: 0,
        checkIns7d: 0,
        breathingSessions7d: 0,
        meditationSessions7d: 0,
        sleepAvgHours7d: 0,
        reconnects30d: 0,
        conflictRepairs30d: 0,
        streakDays: 0,
        generatedAt: DateTime.now(),
      );
}

class MetricsAggregatorService {
  MetricsAggregatorService._internal();
  static final MetricsAggregatorService instance =
      MetricsAggregatorService._internal();

  final ValueNotifier<MetricsSnapshot> snapshotNotifier =
      ValueNotifier(MetricsSnapshot.empty());
  Timer? _timer;

  Future<void> start() async {
    await _compute();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => _compute());
  }

  Future<void> _compute() async {
    try {
      final entriesBox = await Hive.openBox('truecircle_emotional_entries');
      final entries =
          (entriesBox.get('entries', defaultValue: <dynamic>[]) as List)
              .cast<Map>()
              .cast<Map<String, dynamic>>();
      final now = DateTime.now();
      final last7 = entries.where((e) {
        final t = DateTime.tryParse(e['timestamp'] ?? '');
        if (t == null) return false;
        return now.difference(t).inDays < 7;
      }).toList();
      final moodVals =
          last7.map((e) => (e['mood_score'] ?? 0).toDouble()).toList();
      final avgMood = moodVals.isEmpty
          ? 0
          : moodVals.reduce((a, b) => a + b) / moodVals.length;

      // Fake counts from aux box
      final aux = await Hive.openBox('demo_aux_metrics');
      final breathing = aux.get('breathing_session') != null ? 4 : 0;
      final meditation = aux.get('meditation_session') != null ? 3 : 0;
      final sleepAvg =
          (aux.get('progress_tracker_snapshot')?['sleep_avg_hours'] ?? 0)
              .toDouble();

      // Interactions for reconnect/conflict repair
      int reconnects = 0;
      int repairs = 0;
      try {
        final interactionBox = await Hive.openBox('contact_interactions');
        final vals = interactionBox.values.toList();
        for (final i in vals) {
          final meta = i.metadata as Map<String, dynamic>? ?? {};
          if (meta['reconnect_success'] == true) reconnects++;
          if (meta['conflict_resolution'] == true) repairs++;
        }
      } catch (_) {}

      final streakDays = _calculateStreak(entries);

      snapshotNotifier.value = MetricsSnapshot(
        avgMood7d: avgMood,
        checkIns7d: last7.length,
        breathingSessions7d: breathing,
        meditationSessions7d: meditation,
        sleepAvgHours7d: sleepAvg,
        reconnects30d: reconnects,
        conflictRepairs30d: repairs,
        streakDays: streakDays,
        generatedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('MetricsAggregator error: $e');
      }
    }
  }

  int _calculateStreak(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return 0;
    final dates = entries
        .map((e) {
          final t = DateTime.tryParse(e['timestamp'] ?? '');
          return t == null ? null : DateTime(t.year, t.month, t.day);
        })
        .whereType<DateTime>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime cursor = DateTime.now();
    for (final d in dates) {
      if (d == DateTime(cursor.year, cursor.month, cursor.day)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (d.isBefore(DateTime(cursor.year, cursor.month, cursor.day))) {
        break; // gap
      }
    }
    return streak;
  }
}

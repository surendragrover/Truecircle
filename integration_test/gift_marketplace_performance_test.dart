import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show FrameTiming;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:truecircle/pages/gift_marketplace_page.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.benchmark;

  Directory? tempHiveDir;

  setUpAll(() async {
    tempHiveDir = await _prepareHiveData();
  });

  tearDownAll(() async {
    await Hive.close();
    final dir = tempHiveDir;
    if (dir != null && await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  testWidgets('Gift Marketplace renders within frame budget', (tester) async {
    final collectedTimings = <FrameTiming>[];
    void timingsCallback(List<FrameTiming> timings) {
      collectedTimings.addAll(timings);
    }

    WidgetsBinding.instance.addTimingsCallback(timingsCallback);

    await binding.watchPerformance(() async {
      await tester.pumpWidget(const MaterialApp(
        home: GiftMarketplacePage(),
      ));

      await tester.pumpAndSettle(const Duration(seconds: 2));

      final scrollableFinder = find.byType(Scrollable);
      expect(scrollableFinder, findsWidgets);

      await tester.fling(scrollableFinder.first, const Offset(0, -600), 1000);
      await tester.pumpAndSettle();
      await tester.fling(scrollableFinder.first, const Offset(0, 600), 1000);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }, reportKey: 'gift_marketplace_profile');

    WidgetsBinding.instance.removeTimingsCallback(timingsCallback);

    final buildTimes = collectedTimings
        .map((t) => t.buildDuration.inMicroseconds / 1000.0)
        .toList();
    final rasterTimes = collectedTimings
        .map((t) => t.rasterDuration.inMicroseconds / 1000.0)
        .toList();

    double averageOf(List<double> values) =>
        values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
    double maxOf(List<double> values) =>
        values.isEmpty ? 0 : values.reduce(math.max);

    final avgBuild = averageOf(buildTimes);
    final worstBuild = maxOf(buildTimes);
    final avgRaster = averageOf(rasterTimes);
    final worstRaster = maxOf(rasterTimes);

    binding.reportData = <String, dynamic>{
      'gift_marketplace_performance': {
        'avg_frame_build_millis': avgBuild,
        'worst_frame_build_millis': worstBuild,
        'avg_frame_raster_millis': avgRaster,
        'worst_frame_raster_millis': worstRaster,
      },
      'gift_marketplace_timeline_summary': {
        'frame_count': collectedTimings.length,
        'avg_frame_build_millis': avgBuild,
        'worst_frame_build_millis': worstBuild,
        'avg_frame_raster_millis': avgRaster,
        'worst_frame_raster_millis': worstRaster,
      },
    };

    debugPrint('Gift Marketplace avg build time: $avgBuild ms');
    debugPrint('Gift Marketplace worst build time: $worstBuild ms');
    debugPrint('Gift Marketplace avg raster time: $avgRaster ms');
    debugPrint('Gift Marketplace worst raster time: $worstRaster ms');

    expect(
      avgBuild,
      lessThan(40),
      reason: 'Average frame build should remain under 40ms for smooth UX.',
    );
    expect(
      worstBuild,
      lessThan(120),
      reason: 'Worst frame build should remain under 120ms to avoid jank.',
    );
  });
}

Future<Directory> _prepareHiveData() async {
  await Hive.close();
  final tempDir =
      await Directory.systemTemp.createTemp('gift_marketplace_perf');
  Hive.init(tempDir.path);

  final settingsBox = await Hive.openBox('truecircle_settings');
  await settingsBox.put('global_models_downloaded', true);
  await settingsBox.put('models_downloaded', true);
  await settingsBox.put('current_phone_number', '+919876543210');
  await settingsBox.put('current_phone_verified', true);

  final loyaltyBox = await Hive.openBox('loyalty_points');
  await loyaltyBox.put('total_points', 24);
  await loyaltyBox.put('last_login_date', '');
  await loyaltyBox.put('login_streak', 3);
  await loyaltyBox.put('points_history', <Map<String, dynamic>>[]);

  final emotionalBox = await Hive.openBox('truecircle_emotional_entries');
  final now = DateTime.now();
  await emotionalBox.put(
      'entries',
      List.generate(14, (index) {
        return {
          'timestamp': now.subtract(Duration(days: index)).toIso8601String(),
          'mood_score': 4 + (index % 4),
          'note': 'Sample mood log $index',
        };
      }));

  final purchasesBox = await Hive.openBox('virtual_gift_purchases');
  await purchasesBox.put('history', [
    {
      'id': 'vg_card_1',
      'ts': now.subtract(const Duration(days: 1)).toIso8601String(),
      'title': 'Festival Greeting Card',
      'titleHi': 'त्योहार शुभकामना कार्ड',
      'emoji': '🪔',
      'pointsUsed': 5,
      'price': 299.0,
    },
    {
      'id': 'vg_mood_boost',
      'ts': now.subtract(const Duration(days: 5)).toIso8601String(),
      'title': 'Mood Boost Ritual',
      'titleHi': 'मूड बूस्ट रिचुअल',
      'emoji': '💖',
      'pointsUsed': 3,
      'price': 199.0,
    },
  ]);

  final auxBox = await Hive.openBox('demo_aux_metrics');
  await auxBox.put('breathing_session', {
    'duration_minutes': 5,
    'completed_at': now.subtract(const Duration(days: 2)).toIso8601String(),
  });
  await auxBox.put('meditation_session', {
    'duration_minutes': 7,
    'completed_at': now.subtract(const Duration(days: 1)).toIso8601String(),
  });
  await auxBox.put('progress_tracker_snapshot', {
    'sleep_avg_hours': 6.5,
  });

  await Hive.openBox('contact_interactions');

  final aiModelStatusBox = await Hive.openBox('ai_model_status');
  await aiModelStatusBox.put(
    'downloaded_at',
    now.subtract(const Duration(days: 3)).toIso8601String(),
  );

  return tempDir;
}

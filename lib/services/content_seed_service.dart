import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ContentSeedService {
  static const int _seedVersion = 18;
  static const String _seedVersionKey = 'content_seed_version';

  static const List<String> featureJsonFiles = <String>[
    'assets/data/app_strings.json',
    'assets/data/cbt_pack.json',
    'assets/data/Cognitive_Distortions_Detector.json',
    'assets/data/Complete_Belief_Restructuring_Worksheet.json',
    'assets/data/behavioral_activation_planner.json',
    'assets/data/behavioral_activation_data.json',
    'assets/data/exposure_ladder.json',
    'assets/data/trigger_response_chain_analysis.json',
    'assets/data/cbt_dynamic_prompt_global_relationship_sa.json',
    'assets/data/relapse_prevention_plan.json',
    'assets/data/core_belief_tracker.json',
    'assets/data/weekly_cbt_progress_scorecard.json',
    'assets/data/CBT_Techniques_En.json',
    'assets/data/CBT_Thoughts_En.json',
    'assets/data/Coping_cards_En.json',
    'assets/data/communication_tracker.json',
    'assets/data/emergency_numbers.json',
    'assets/data/Emotional_Awareness.JSON',
    'assets/data/Feeling_Identification.JSON',
    'assets/data/Mood_Intensity.JSON',
    'assets/data/Action_Planning.JSON',
    'assets/data/Emotional_Recovery_Plan.JSON',
    'assets/data/emotions_entry.json',
    'assets/data/faq.json',
    'assets/data/how_it_works.json',
    'assets/data/languages.json',
    'assets/data/micro_lessons.json',
    'assets/data/Privacy_Policy.JSON',
    'assets/data/Psychology_Articles_En.json',
    'assets/data/Questions.JSON',
    'assets/data/CBT-Based GAD-7.JSON',
    'assets/data/phq9_cbt_assessment.json',
    'assets/data/Relationship_Insight_Questions.json',
    'assets/data/relationship_monitoring.json',
    'assets/data/Sleep_Tricks.json',
    'assets/data/terms_conditions.json',
    'assets/data/vocab.json',
  ];

  Future<void> seedFeatureContentIfNeeded() async {
    final Box<dynamic> appBox = Hive.box('appBox');
    final int currentVersion =
        (appBox.get(_seedVersionKey, defaultValue: 0) as int?) ?? 0;
    if (currentVersion >= _seedVersion) return;

    final Box<dynamic> contentBox = Hive.isBoxOpen('contentBox')
        ? Hive.box('contentBox')
        : await Hive.openBox('contentBox');
    final List<String> failedAssets = <String>[];
    int seededCount = 0;
    for (final String assetPath in featureJsonFiles) {
      try {
        final String key = keyFromAssetPath(assetPath);
        final String raw = await rootBundle.loadString(assetPath);
        await contentBox.put(key, _decodeJsonLenient(raw));
        seededCount += 1;
      } catch (_) {
        failedAssets.add(assetPath);
      }
    }

    // Mark as fully seeded only when all assets succeed; otherwise retry next launch.
    if (failedAssets.isEmpty && seededCount == featureJsonFiles.length) {
      await appBox.put(_seedVersionKey, _seedVersion);
      await appBox.delete('content_seed_failed_assets');
    } else {
      await appBox.put('content_seed_failed_assets', failedAssets);
    }
  }

  static String keyFromAssetPath(String path) {
    final String name = path.split('/').last;
    return name.toLowerCase().replaceAll(' ', '_');
  }

  dynamic _decodeJsonLenient(String raw) {
    final String withoutCommentLines = raw
        .split('\n')
        .where((String line) => !line.trimLeft().startsWith('//'))
        .join('\n');
    final String withoutTrailingCommas = withoutCommentLines.replaceAllMapped(
      RegExp(r',(\s*[}\]])'),
      (Match m) => m.group(1) ?? '',
    );
    return jsonDecode(withoutTrailingCommas);
  }
}

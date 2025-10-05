import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/emotion_entry.dart';
import '../models/contact.dart';
import '../models/contact_interaction.dart';
import '../models/privacy_settings.dart';
import '../models/cbt_models.dart';

class HiveInitializer {
  static bool _adaptersRegistered = false;

  static Future<void> registerAdapters() async {
    if (_adaptersRegistered) {
      debugPrint('[HiveInitializer] Adapters already registered. Skipping.');
      return;
    }
    try {
      debugPrint('[HiveInitializer] Starting adapter registration...');
      _registerAdapterSafely<EmotionEntry>(0, () => EmotionEntryAdapter());
      _registerAdapterSafely<Contact>(1, () => ContactAdapter());
      _registerAdapterSafely<ContactStatus>(2, () => ContactStatusAdapter());
      _registerAdapterSafely<ContactInteraction>(
          3, () => ContactInteractionAdapter());
      _registerAdapterSafely<InteractionType>(
          4, () => InteractionTypeAdapter());
      _registerAdapterSafely<EmotionalScore>(5, () => EmotionalScoreAdapter());
      _registerAdapterSafely<PrivacySettings>(
          6, () => PrivacySettingsAdapter());
      // CBT feature adapters (40+)
      _registerAdapterSafely<CBTAssessmentResult>(
          40, () => CBTAssessmentResultAdapter());
      _registerAdapterSafely<CBTThoughtRecord>(
          41, () => CBTThoughtRecordAdapter());
      _registerAdapterSafely<CopingCard>(42, () => CopingCardAdapter());
      _registerAdapterSafely<CBTMicroLessonProgress>(
          43, () => CBTMicroLessonProgressAdapter());
      _registerAdapterSafely<HypnotherapySessionLog>(
          44, () => HypnotherapySessionLogAdapter());
      _registerAdapterSafely<SharedArticle>(45, () => SharedArticleAdapter());
      debugPrint(
          '[HiveInitializer] All Hive adapters registered successfully.');
      _adaptersRegistered = true;
    } catch (e) {
      debugPrint(
          '❌ [HiveInitializer] CRITICAL: Failed to register adapters: $e');
      throw Exception('Failed to register Hive adapters.');
    }
  }

  static void _registerAdapterSafely<T>(
      int typeId, dynamic Function() adapterFactory) {
    try {
      if (!Hive.isAdapterRegistered(typeId)) {
        Hive.registerAdapter(adapterFactory());
        debugPrint('  ✅ Adapter $typeId (${T.toString()}) registered.');
      } else {
        debugPrint(
            '  ℹ️ Adapter $typeId (${T.toString()}) already registered.');
      }
    } catch (e) {
      debugPrint(
          '  ❌ Failed to register adapter $typeId (${T.toString()}): $e');
      rethrow;
    }
  }
}

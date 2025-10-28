import 'package:hive_flutter/hive_flutter.dart';
import '../models/emotional_awareness_selection.dart';
import '../models/communication_entry.dart';
import '../models/relationship_contact.dart';
import '../models/conversation_insight.dart';
import '../models/coin_reward.dart';
import '../models/user_coins.dart';
import '../services/app_data_preloader.dart';
import '../services/json_data_service.dart';
import '../services/dr_iris_suggestions_service.dart';
import '../services/on_device_ai_service.dart';
import '../services/instruction_based_service.dart';
import '../services/communication_tracker_service.dart';
import '../services/coin_reward_service.dart';
import 'service_locator.dart';

/// Centralized Hive initialization
class HiveInitializer {
  static Future<void> init() async {
    // Initialize Hive with Flutter
    await Hive.initFlutter();
    await registerAdapters();
    await registerServices();
  }

  /// Register all Hive adapters for TrueCircle models
  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(EAOccurrenceTypeAdapter().typeId)) {
      Hive.registerAdapter(EAOccurrenceTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(
      EmotionalAwarenessSelectionAdapter().typeId,
    )) {
      Hive.registerAdapter(EmotionalAwarenessSelectionAdapter());
    }
    if (!Hive.isAdapterRegistered(CommunicationEntryAdapter().typeId)) {
      Hive.registerAdapter(CommunicationEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(RelationshipContactAdapter().typeId)) {
      Hive.registerAdapter(RelationshipContactAdapter());
    }
    if (!Hive.isAdapterRegistered(ConversationInsightAdapter().typeId)) {
      Hive.registerAdapter(ConversationInsightAdapter());
    }

    // Coin reward models के लिए adapters
    if (!Hive.isAdapterRegistered(72)) {
      Hive.registerAdapter(CoinTransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(CoinRewardAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(UserCoinsAdapter());
    }
  }

  /// Register all services in service locator
  static Future<void> registerServices() async {
    final serviceLocator = ServiceLocator.instance;

    // Register data services
    if (!serviceLocator.isRegistered<AppDataPreloader>()) {
      serviceLocator.registerSingleton<AppDataPreloader>(
        AppDataPreloader.instance,
      );
    }

    if (!serviceLocator.isRegistered<JsonDataService>()) {
      serviceLocator.registerSingleton<JsonDataService>(
        JsonDataService.instance,
      );
    }

    // Register Dr. Iris services
    if (!serviceLocator.isRegistered<DrIrisSuggestionsService>()) {
      serviceLocator.registerSingleton<DrIrisSuggestionsService>(
        DrIrisSuggestionsService.instance,
      );
    }

    if (!serviceLocator.isRegistered<OnDeviceAIService>()) {
      serviceLocator.registerSingleton<OnDeviceAIService>(
        OnDeviceAIService.instance(),
      );
    }

    // Register Instruction-based service
    if (!serviceLocator.isRegistered<InstructionBasedService>()) {
      serviceLocator.registerSingleton<InstructionBasedService>(
        InstructionBasedService.instance,
      );
      await InstructionBasedService.instance.initialize();
    }

    // 🎉 Coin Reward Service register करते हैं
    if (!serviceLocator.isRegistered<CoinRewardService>()) {
      serviceLocator.registerSingleton<CoinRewardService>(
        CoinRewardService.instance,
      );
      await CoinRewardService.instance.initialize();
    }

    // Register Communication Tracker service
    if (!serviceLocator.isRegistered<CommunicationTrackerService>()) {
      serviceLocator.registerSingleton<CommunicationTrackerService>(
        CommunicationTrackerService(),
      );
      await CommunicationTrackerService().initialize();
    }
  }
}

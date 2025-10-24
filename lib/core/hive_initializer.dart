import 'package:hive/hive.dart';
import '../models/emotional_awareness_selection.dart';

/// Centralized Hive initialization
class HiveInitializer {
  static Future<void> init() async {
    // In TC module, assume Hive is already initialized by host app.
    // Only ensure adapters are registered.
    await registerAdapters();
  }

  /// Register all Hive adapters here.
  /// TODO: Add registrations e.g., Hive.registerAdapter(MyModelAdapter());
  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(EAOccurrenceTypeAdapter().typeId)) {
      Hive.registerAdapter(EAOccurrenceTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(
      EmotionalAwarenessSelectionAdapter().typeId,
    )) {
      Hive.registerAdapter(EmotionalAwarenessSelectionAdapter());
    }
  }
}

// TrueCircle On-Device AI Service Foundation
// This file provides the foundation for on-device AI services for TrueCircle.
// It's an abstract class that provides a common interface for all platforms (Android, iOS, etc).

abstract class OnDeviceAIService {
  /// Initialize the AI service.
  /// This will check if Gemini Nano or Core ML is available on the platform.
  Future<void> initialize();

  /// Generate AI response for chatting with Dr. Iris.
  /// This will be primarily used for 'Chat Mode' and 'Scheduled Sessions'.
  /// [prompt] is the user's input (question/emotion).
  Future<String> generateDrIrisResponse(String prompt);

  /// Analyze user emotions (Mood Journal entry) and determine stress level.
  /// This will power the 'Emotional Check-in' and 'Stress Analysis' features.
  /// Returns strings like "Low", "Medium", "High".
  Future<String> analyzeSentimentAndStress(String textEntry);

  /// Generate relationship improvement suggestions based on 'Communication Tracker' data.
  /// This will provide advice for positive steps after long conversation gaps 
  /// (Missed Call Reminder) or conflict resolution.
  Future<String> generateRelationshipTip(List<String> communicationLogSummary);

  /// A function that's important for the app but not yet connected.
  /// This will help draft personalized messages for 'Festival Reminder'.
  Future<String> draftFestivalMessage(String contactName, String relationType);

  /// Check if the current device is capable of running AI tasks offline.
  Future<bool> isAISupported();
}
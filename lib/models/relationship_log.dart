// lib/models/relationship_log.dart

import 'package:hive/hive.dart';

part 'relationship_log.g.dart';

/// Enhanced communication log for relationship analysis with offline AI support
/// 
/// Stores communication patterns while maintaining privacy-first approach
/// Optimized for offline AI analysis and mental health correlation
/// Only metadata and statistical patterns stored, no personal content
@HiveType(typeId: 7)
class RelationshipLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String contactId; // गोपनीयता के लिए नाम नहीं, केवल ID

  @HiveField(2)
  String contactName; // प्रदर्शन के लिए केवल पहला नाम

  @HiveField(3)
  DateTime timestamp; // बातचीत का समय

  @HiveField(4)
  DateTime lastInteraction; // अंतिम बातचीत की तारीख़

  @HiveField(5)
  Duration interactionGap; // पिछली बातचीत से अंतराल (AI के लिए महत्वपूर्ण)

  @HiveField(6)
  InteractionType type; // call या message

  @HiveField(7)
  int duration; // कॉल की अवधि (seconds में)

  @HiveField(8)
  bool isIncoming;

  @HiveField(9)
  int messageLength; // मैसेज की लंबाई (character count)

  @HiveField(10)
  double callDurationAverage; // औसत कॉल अवधि

  @HiveField(11)
  int totalCallsInLastMonth; // पिछले महीने की कुल कॉल्स

  @HiveField(12)
  int totalMessagesInLastMonth; // पिछले महीने के कुल मैसेज

  @HiveField(13)
  EmotionalTone tone; // AI द्वारा विश्लेषित भावनात्मक टोन

  @HiveField(14)
  double intimacyScore; // 0.0 to 1.0 - रिश्ते की निकटता

  @HiveField(15)
  List<String> keywords; // AI-extracted keywords (no personal content)

  @HiveField(16)
  bool isPrivacyMode; // हमेशा true रहेगा production में

  @HiveField(17)
  Map<String, dynamic> metadata; // अतिरिक्त डेटा के लिए

  @HiveField(18)
  double communicationFrequency; // दैनिक संपर्क आवृत्ति

  @HiveField(19)
  RelationshipPhase currentPhase; // रिश्ते का वर्तमान चरण

  RelationshipLog({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.timestamp,
    required this.lastInteraction,
    required this.interactionGap,
    required this.type,
    this.duration = 0,
    required this.isIncoming,
    this.messageLength = 0,
    this.callDurationAverage = 0.0,
    this.totalCallsInLastMonth = 0,
    this.totalMessagesInLastMonth = 0,
    this.tone = EmotionalTone.neutral,
    this.intimacyScore = 0.5,
    this.keywords = const [],
    this.isPrivacyMode = true,
    this.metadata = const {},
    this.communicationFrequency = 0.0,
    this.currentPhase = RelationshipPhase.unknown,
  });

  /// Create from JSON data received from native platform (Enhanced)
  factory RelationshipLog.fromJson(Map<String, dynamic> json) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(
      json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
    );
    final lastInteractionMs = json['lastInteraction'] ?? timestamp.millisecondsSinceEpoch;
    final lastInteraction = DateTime.fromMillisecondsSinceEpoch(lastInteractionMs);
    final interactionGap = Duration(milliseconds: json['interactionGapMs'] ?? 0);
    
    return RelationshipLog(
      id: json['id'] ?? '',
      contactId: json['contactId'] ?? '',
      contactName: json['contactName'] ?? 'Unknown',
      timestamp: timestamp,
      lastInteraction: lastInteraction,
      interactionGap: interactionGap,
      type: InteractionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => InteractionType.unknown,
      ),
      duration: json['duration'] ?? 0,
      isIncoming: json['isIncoming'] ?? false,
      messageLength: json['messageLength'] ?? 0,
      callDurationAverage: (json['callDurationAverage'] ?? 0.0).toDouble(),
      totalCallsInLastMonth: json['totalCallsInLastMonth'] ?? 0,
      totalMessagesInLastMonth: json['totalMessagesInLastMonth'] ?? 0,
      tone: EmotionalTone.values.firstWhere(
        (e) => e.toString().split('.').last == json['tone'],
        orElse: () => EmotionalTone.neutral,
      ),
      intimacyScore: (json['intimacyScore'] ?? 0.5).toDouble(),
      keywords: List<String>.from(json['keywords'] ?? []),
      isPrivacyMode: json['isPrivacyMode'] ?? true,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      communicationFrequency: (json['communicationFrequency'] ?? 0.0).toDouble(),
      currentPhase: RelationshipPhase.values.firstWhere(
        (e) => e.toString().split('.').last == json['currentPhase'],
        orElse: () => RelationshipPhase.unknown,
      ),
    );
  }

  /// Convert to JSON for native platform (Enhanced)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactId': contactId,
      'contactName': contactName,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'lastInteraction': lastInteraction.millisecondsSinceEpoch,
      'interactionGapMs': interactionGap.inMilliseconds,
      'type': type.toString().split('.').last,
      'duration': duration,
      'isIncoming': isIncoming,
      'messageLength': messageLength,
      'callDurationAverage': callDurationAverage,
      'totalCallsInLastMonth': totalCallsInLastMonth,
      'totalMessagesInLastMonth': totalMessagesInLastMonth,
      'tone': tone.toString().split('.').last,
      'intimacyScore': intimacyScore,
      'keywords': keywords,
      'isPrivacyMode': isPrivacyMode,
      'metadata': metadata,
      'communicationFrequency': communicationFrequency,
      'currentPhase': currentPhase.toString().split('.').last,
    };
  }

  /// AI के लिए सारांश स्ट्रिंग (Enhanced for Offline AI Analysis)
  String toSummaryString() {
    // AI के लिए optimized summary जैसा कि आपने माँगा था
    return "Contact: $contactName. Last talk: ${interactionGap.inDays} days ago. "
           "Avg call: ${callDurationAverage.toStringAsFixed(1)}s. "
           "Calls/month: $totalCallsInLastMonth, Messages/month: $totalMessagesInLastMonth. "
           "Frequency: ${communicationFrequency.toStringAsFixed(1)}/day. "
           "Phase: ${currentPhase.name}. Intimacy: ${(intimacyScore * 100).toStringAsFixed(0)}%.";
  }

  /// Generate detailed privacy-safe summary for comprehensive AI analysis
  String toDetailedSummaryString() {
    final buffer = StringBuffer();
    
    // Contact और समय की जानकारी
    buffer.write('Contact: $contactName (ID: $contactId)\n');
    buffer.write('Last interaction: ${interactionGap.inDays} days ago\n');
    buffer.write('Communication pattern: ${communicationFrequency.toStringAsFixed(1)} interactions/day\n');
    
    // रिश्ते का चरण और निकटता
    buffer.write('Relationship phase: ${currentPhase.name}\n');
    buffer.write('Intimacy score: ${(intimacyScore * 100).toStringAsFixed(0)}%\n');
    
    // संपर्क के आंकड़े
    buffer.write('Monthly stats: $totalCallsInLastMonth calls, $totalMessagesInLastMonth messages\n');
    buffer.write('Average call duration: ${callDurationAverage.toStringAsFixed(1)} seconds\n');
    
    // भावनात्मक संदर्भ
    if (tone != EmotionalTone.neutral) {
      buffer.write('Recent emotional tone: ${tone.name}\n');
    }
    
    // Keywords (privacy-safe)
    if (keywords.isNotEmpty) {
      buffer.write('Communication themes: ${keywords.join(', ')}\n');
    }
    
    // Recent interaction details
    buffer.write('Latest ${type.name} ${isIncoming ? 'received' : 'sent'}');
    if (type == InteractionType.call && duration > 0) {
      buffer.write(' (${duration}s duration)');
    }
    if ((type == InteractionType.message || type == InteractionType.chatApp) && messageLength > 0) {
      buffer.write(' ($messageLength characters)');
    }
    
    return buffer.toString();
  }

  /// Generate sample data for privacy mode (formerly generateDemoData)
  static List<RelationshipLog> generateSampleData(String contactId, String contactName) {
    final now = DateTime.now();
    
    return [
      RelationshipLog(
  id: 'sample_1_$contactId',
        contactId: contactId,
        contactName: contactName,
        timestamp: now.subtract(const Duration(hours: 2)),
        lastInteraction: now.subtract(const Duration(hours: 6)),
        interactionGap: const Duration(hours: 4),
        type: InteractionType.message,
        isIncoming: false,
        messageLength: 45,
        callDurationAverage: 180.0, // 3 minutes average
        totalCallsInLastMonth: 25,
        totalMessagesInLastMonth: 120,
        tone: EmotionalTone.positive,
        intimacyScore: 0.8,
        keywords: ['love', 'miss', 'excited'],
        isPrivacyMode: true,
  // 'demo' flag migrated to 'sample' to align with Privacy Mode terminology
  metadata: {'sample': true, 'category': 'affectionate'},
        communicationFrequency: 4.2, // 4.2 interactions per day
        currentPhase: RelationshipPhase.deepening,
      ),
      RelationshipLog(
  id: 'sample_2_$contactId',
        contactId: contactId,
        contactName: contactName,
        timestamp: now.subtract(const Duration(hours: 6)),
        lastInteraction: now.subtract(const Duration(hours: 12)),
        interactionGap: const Duration(hours: 6),
        type: InteractionType.call,
        isIncoming: true,
        duration: 420, // 7 minutes
        callDurationAverage: 180.0,
        totalCallsInLastMonth: 25,
        totalMessagesInLastMonth: 120,
        tone: EmotionalTone.neutral,
        intimacyScore: 0.6,
        keywords: ['plans', 'meeting', 'dinner'],
        isPrivacyMode: true,
  // Updated legacy 'demo' -> 'sample'
  metadata: {'sample': true, 'category': 'planning'},
        communicationFrequency: 4.2,
        currentPhase: RelationshipPhase.stable,
      ),
      RelationshipLog(
  id: 'sample_3_$contactId',
        contactId: contactId,
        contactName: contactName,
        timestamp: now.subtract(const Duration(days: 1)),
        lastInteraction: now.subtract(const Duration(days: 1, hours: 8)),
        interactionGap: const Duration(hours: 8),
        type: InteractionType.message,
        isIncoming: true,
        messageLength: 28,
        callDurationAverage: 180.0,
        totalCallsInLastMonth: 25,
        totalMessagesInLastMonth: 120,
        tone: EmotionalTone.concern,
        intimacyScore: 0.7,
        keywords: ['worried', 'safe', 'care'],
        isPrivacyMode: true,
  metadata: {'sample': true, 'category': 'caring'},
        communicationFrequency: 4.2,
        currentPhase: RelationshipPhase.deepening,
      ),
    ];
  }

  /// Deprecated: use generateSampleData
  @Deprecated('Use generateSampleData instead')
  static List<RelationshipLog> generateDemoData(String contactId, String contactName) =>
      generateSampleData(contactId, contactName);

  @override
  String toString() {
    return 'RelationshipLog(id: $id, contact: $contactName, type: $type, time: $timestamp)';
  }
}

/// Types of communication tracked (Enhanced for offline AI)
@HiveType(typeId: 8)
enum InteractionType {
  @HiveField(0)
  call,
  
  @HiveField(1)
  message,
  
  @HiveField(2)
  chatApp, // WhatsApp, Telegram etc.
  
  @HiveField(3)
  videoCall,
  
  @HiveField(4)
  voiceMessage,
  
  @HiveField(5)
  unknown,
}

/// Communication type (kept for backward compatibility)
@HiveType(typeId: 21)
enum CommunicationType {
  @HiveField(0)
  call,
  
  @HiveField(1)
  message,
  
  @HiveField(2)
  videoCall,
  
  @HiveField(3)
  voiceMessage,
  
  @HiveField(4)
  unknown,
}

/// Relationship phases for deeper AI analysis
@HiveType(typeId: 20)
enum RelationshipPhase {
  @HiveField(0)
  initial, // नया रिश्ता, अधिक संपर्क
  
  @HiveField(1)
  building, // रिश्ता बनता जा रहा है
  
  @HiveField(2)
  stable, // स्थिर रिश्ता
  
  @HiveField(3)
  deepening, // गहरा होता रिश्ता
  
  @HiveField(4)
  distant, // दूरी बढ़ रही है
  
  @HiveField(5)
  reconnecting, // दोबारा जुड़ाव
  
  @HiveField(6)
  unknown,
}

/// Emotional tone of communication (AI-analyzed)
@HiveType(typeId: 9)
enum EmotionalTone {
  @HiveField(0)
  positive,
  
  @HiveField(1)
  negative,
  
  @HiveField(2)
  neutral,
  
  @HiveField(3)
  concern,
  
  @HiveField(4)
  excitement,
  
  @HiveField(5)
  sadness,
  
  @HiveField(6)
  anger,
  
  @HiveField(7)
  love,
  
  @HiveField(8)
  unknown,
}

/// Communication statistics for relationship analysis
@HiveType(typeId: 10)
class CommunicationStats extends HiveObject {
  @HiveField(0)
  String contactId;

  @HiveField(1)
  DateTime periodStart;

  @HiveField(2)
  DateTime periodEnd;

  @HiveField(3)
  int totalCalls;

  @HiveField(4)
  int totalMessages;

  @HiveField(5)
  int totalCallDuration; // in seconds

  @HiveField(6)
  double averageIntimacyScore;

  @HiveField(7)
  Map<EmotionalTone, int> emotionalToneDistribution;

  @HiveField(8)
  double communicationFrequency; // interactions per day

  @HiveField(9)
  Map<String, int> topKeywords;

  @HiveField(10)
  bool isPrivacyMode;

  CommunicationStats({
    required this.contactId,
    required this.periodStart,
    required this.periodEnd,
    this.totalCalls = 0,
    this.totalMessages = 0,
    this.totalCallDuration = 0,
    this.averageIntimacyScore = 0.5,
    this.emotionalToneDistribution = const {},
    this.communicationFrequency = 0.0,
    this.topKeywords = const {},
    this.isPrivacyMode = true,
  });

  /// Calculate stats from relationship logs
  factory CommunicationStats.fromLogs(
    String contactId,
    List<RelationshipLog> logs,
    DateTime periodStart,
    DateTime periodEnd,
  ) {
    final calls = logs.where((log) => log.type == InteractionType.call).length;
    final messages = logs.where((log) => log.type == InteractionType.message || log.type == InteractionType.chatApp).length;
    final totalDuration = logs
        .where((log) => log.type == InteractionType.call || log.type == InteractionType.videoCall)
        .fold(0, (sum, log) => sum + log.duration);
    
    final averageIntimacy = logs.isEmpty 
        ? 0.5 
        : logs.fold(0.0, (sum, log) => sum + log.intimacyScore) / logs.length;
    
    final toneDistribution = <EmotionalTone, int>{};
    for (final log in logs) {
      toneDistribution[log.tone] = (toneDistribution[log.tone] ?? 0) + 1;
    }
    
    final days = periodEnd.difference(periodStart).inDays;
    final frequency = days > 0 ? logs.length / days : 0.0;
    
    final allKeywords = logs.expand((log) => log.keywords).toList();
    final keywordCounts = <String, int>{};
    for (final keyword in allKeywords) {
      keywordCounts[keyword] = (keywordCounts[keyword] ?? 0) + 1;
    }
    
    return CommunicationStats(
      contactId: contactId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalCalls: calls,
      totalMessages: messages,
      totalCallDuration: totalDuration,
      averageIntimacyScore: averageIntimacy,
      emotionalToneDistribution: toneDistribution,
      communicationFrequency: frequency,
      topKeywords: keywordCounts,
      isPrivacyMode: logs.isNotEmpty ? logs.first.isPrivacyMode : true,
    );
  }

  /// Generate privacy-safe summary for AI analysis
  String toAnalysisString() {
    final buffer = StringBuffer();
    
    buffer.writeln('Communication Summary:');
    buffer.writeln('- Calls: $totalCalls (${totalCallDuration}s total)');
    buffer.writeln('- Messages: $totalMessages');
    buffer.writeln('- Frequency: ${communicationFrequency.toStringAsFixed(1)} per day');
    buffer.writeln('- Intimacy Level: ${(averageIntimacyScore * 100).toStringAsFixed(0)}%');
    
    if (emotionalToneDistribution.isNotEmpty) {
      buffer.writeln('- Emotional Tones:');
      emotionalToneDistribution.forEach((tone, count) {
        buffer.writeln('  ${tone.name}: $count');
      });
    }
    
    if (topKeywords.isNotEmpty) {
      final sortedKeywords = topKeywords.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      buffer.writeln('- Top Keywords: ${sortedKeywords.take(5).map((e) => e.key).join(', ')}');
    }
    
    return buffer.toString();
  }
}
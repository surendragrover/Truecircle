// lib/models/mood_entry.dart

import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

/// Enhanced MoodEntry model for offline AI sentiment analysis
///
/// Captures user's daily emotions and thoughts for NLP processing
/// Integrates with analyzeSentimentAndStress for offline analysis
/// Privacy-first design with local processing only
@HiveType(typeId: 29)
class MoodEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String userText; // यूज़र द्वारा दर्ज की गई विस्तृत भावना

  @HiveField(3)
  String identifiedMood; // AI द्वारा पहचाना गया मूड (जैसे: Angry, Calm)

  @HiveField(4)
  String stressLevel; // AI द्वारा निर्धारित तनाव स्तर (जैसे: Low, High)

  @HiveField(5)
  String relatedContactId; // यदि यह एंट्री किसी खास रिश्ते से जुड़ी हो

  @HiveField(6)
  MoodCategory category; // Categorized mood for better analysis

  @HiveField(7)
  double sentimentScore; // -1.0 (negative) to 1.0 (positive)

  @HiveField(8)
  double stressScore; // 0.0 (no stress) to 1.0 (high stress)

  @HiveField(9)
  List<String> extractedKeywords; // NLP-extracted keywords

  @HiveField(10)
  List<EmotionIntensity> detectedEmotions; // Multiple emotions with intensity

  @HiveField(11)
  bool isPrivacyMode; // Privacy protection flag

  @HiveField(12)
  Map<String, dynamic> nlpMetadata; // NLP analysis metadata

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime? lastAnalyzed; // When NLP analysis was last performed

  MoodEntry({
    required this.id,
    required this.date,
    required this.userText,
    required this.identifiedMood,
    required this.stressLevel,
    this.relatedContactId = '',
    this.category = MoodCategory.neutral,
    this.sentimentScore = 0.0,
    this.stressScore = 0.5,
    this.extractedKeywords = const [],
    this.detectedEmotions = const [],
    this.isPrivacyMode = true,
    this.nlpMetadata = const {},
    DateTime? createdAt,
    this.lastAnalyzed,
  }) : createdAt = createdAt ?? DateTime.now();

  /// JSON से मॉडल बनाने के लिए फ़ैक्टरी (Factory) - Enhanced
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.parse(json['date']),
      userText: json['userText'] ?? '',
      identifiedMood: json['identifiedMood'] ?? 'unknown',
      stressLevel: json['stressLevel'] ?? 'medium',
      relatedContactId: json['relatedContactId'] ?? '',
      category: MoodCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => MoodCategory.neutral,
      ),
      sentimentScore: (json['sentimentScore'] ?? 0.0).toDouble(),
      stressScore: (json['stressScore'] ?? 0.5).toDouble(),
      extractedKeywords: List<String>.from(json['extractedKeywords'] ?? []),
      detectedEmotions: (json['detectedEmotions'] as List<dynamic>?)
              ?.map((e) => EmotionIntensity.fromJson(e))
              .toList() ??
          [],
      isPrivacyMode: json['isPrivacyMode'] ?? true,
      nlpMetadata: Map<String, dynamic>.from(json['nlpMetadata'] ?? {}),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastAnalyzed: json['lastAnalyzed'] != null
          ? DateTime.parse(json['lastAnalyzed'])
          : null,
    );
  }

  /// Convert to JSON for storage and analysis
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'userText': userText,
      'identifiedMood': identifiedMood,
      'stressLevel': stressLevel,
      'relatedContactId': relatedContactId,
      'category': category.toString().split('.').last,
      'sentimentScore': sentimentScore,
      'stressScore': stressScore,
      'extractedKeywords': extractedKeywords,
      'detectedEmotions': detectedEmotions.map((e) => e.toJson()).toList(),
      'isPrivacyMode': isPrivacyMode,
      'nlpMetadata': nlpMetadata,
      'createdAt': createdAt.toIso8601String(),
      'lastAnalyzed': lastAnalyzed?.toIso8601String(),
    };
  }

  /// Enhanced factory for offline NLP analysis integration
  factory MoodEntry.createForAnalysis({
    required String userText,
    String? relatedContactId,
    DateTime? date,
  }) {
    return MoodEntry(
      id: 'mood_${DateTime.now().millisecondsSinceEpoch}',
      date: date ?? DateTime.now(),
      userText: userText,
      identifiedMood: 'pending_analysis', // Will be updated by NLP
      stressLevel: 'pending_analysis', // Will be updated by NLP
      relatedContactId: relatedContactId ?? '',
      category: MoodCategory.pending,
      isPrivacyMode: true,
    );
  }

  /// Update with NLP analysis results from analyzeSentimentAndStress
  MoodEntry updateWithNLPAnalysis({
    required String identifiedMood,
    required String stressLevel,
    required double sentimentScore,
    required double stressScore,
    required List<String> extractedKeywords,
    required List<EmotionIntensity> detectedEmotions,
    Map<String, dynamic>? nlpMetadata,
  }) {
    return MoodEntry(
      id: id,
      date: date,
      userText: userText,
      identifiedMood: identifiedMood,
      stressLevel: stressLevel,
      relatedContactId: relatedContactId,
      category: _categorizeMood(identifiedMood),
      sentimentScore: sentimentScore,
      stressScore: stressScore,
      extractedKeywords: extractedKeywords,
      detectedEmotions: detectedEmotions,
      isPrivacyMode: isPrivacyMode,
      nlpMetadata: nlpMetadata ?? this.nlpMetadata,
      createdAt: createdAt,
      lastAnalyzed: DateTime.now(),
    );
  }

  /// Categorize mood based on identified mood string
  static MoodCategory _categorizeMood(String mood) {
    final moodLower = mood.toLowerCase();

    if (['happy', 'joy', 'excited', 'grateful', 'content', 'calm']
        .any(moodLower.contains)) {
      return MoodCategory.positive;
    } else if (['angry', 'frustrated', 'annoyed', 'irritated']
        .any(moodLower.contains)) {
      return MoodCategory.angry;
    } else if (['sad', 'depressed', 'lonely', 'disappointed']
        .any(moodLower.contains)) {
      return MoodCategory.sad;
    } else if (['anxious', 'worried', 'nervous', 'stressed']
        .any(moodLower.contains)) {
      return MoodCategory.anxious;
    } else if (['confused', 'uncertain', 'mixed'].any(moodLower.contains)) {
      return MoodCategory.confused;
    } else {
      return MoodCategory.neutral;
    }
  }

  /// Generate summary for AI analysis (privacy-safe)
  String toAISummaryString() {
    final buffer = StringBuffer();

    // Basic mood info
    buffer.write('Date: ${date.day}/${date.month}, ');
    buffer.write('Mood: $identifiedMood, ');
    buffer.write('Stress: $stressLevel, ');
    buffer.write('Sentiment: ${sentimentScore.toStringAsFixed(2)}, ');
    buffer.write('Category: ${category.name}');

    // Keywords (no personal text)
    if (extractedKeywords.isNotEmpty) {
      buffer.write(', Keywords: ${extractedKeywords.take(5).join(", ")}');
    }

    // Related contact (if any)
    if (relatedContactId.isNotEmpty) {
      buffer.write(', Related Contact: $relatedContactId');
    }

    // Detected emotions
    if (detectedEmotions.isNotEmpty) {
      final emotionSummary = detectedEmotions
          .take(3)
          .map((e) => '${e.emotion}(${e.intensity.toStringAsFixed(1)})')
          .join(', ');
      buffer.write(', Emotions: $emotionSummary');
    }

    return buffer.toString();
  }

  /// Generate detailed analysis for comprehensive insights
  String toDetailedAnalysisString() {
    final buffer = StringBuffer();

    buffer.writeln('📅 मूड एंट्री विश्लेषण');
    buffer.writeln('तारीख: ${date.day}/${date.month}/${date.year}');
    buffer.writeln('पहचाना गया मूड: $identifiedMood');
    buffer.writeln('तनाव स्तर: $stressLevel');
    buffer
        .writeln('भावना स्कोर: ${(sentimentScore * 100).toStringAsFixed(0)}%');
    buffer.writeln('तनाव स्कोर: ${(stressScore * 100).toStringAsFixed(0)}%');

    if (extractedKeywords.isNotEmpty) {
      buffer.writeln('मुख्य शब्द: ${extractedKeywords.join(", ")}');
    }

    if (detectedEmotions.isNotEmpty) {
      buffer.writeln('पहचानी गई भावनाएं:');
      for (final emotion in detectedEmotions.take(5)) {
        buffer.writeln(
            '  • ${emotion.emotion}: ${(emotion.intensity * 100).toStringAsFixed(0)}%');
      }
    }

    if (relatedContactId.isNotEmpty) {
      buffer.writeln('संबंधित व्यक्ति: $relatedContactId');
    }

    return buffer.toString();
  }

  /// Generate sample data for privacy mode (formerly generateDemoData)
  static List<MoodEntry> generateSampleData() {
    final now = DateTime.now();
    return [
      MoodEntry(
        id: 'sample_mood_1',
        date: now.subtract(const Duration(hours: 2)),
        userText: 'आज बहुत अच्छा लग रहा है, सब कुछ सही चल रहा है',
        identifiedMood: 'Happy',
        stressLevel: 'Low',
        category: MoodCategory.positive,
        sentimentScore: 0.8,
        stressScore: 0.2,
        extractedKeywords: ['अच्छा', 'सही', 'खुश'],
        detectedEmotions: [
          EmotionIntensity(emotion: 'Joy', intensity: 0.8),
          EmotionIntensity(emotion: 'Contentment', intensity: 0.7),
        ],
        isPrivacyMode: true,
        nlpMetadata: {'sample': true, 'language': 'hindi'},
      ),
      MoodEntry(
        id: 'sample_mood_2',
        date: now.subtract(const Duration(hours: 8)),
        userText: 'काम का तनाव बहुत है, चिंता हो रही है',
        identifiedMood: 'Anxious',
        stressLevel: 'High',
        category: MoodCategory.anxious,
        sentimentScore: -0.6,
        stressScore: 0.9,
        extractedKeywords: ['तनाव', 'चिंता', 'काम'],
        detectedEmotions: [
          EmotionIntensity(emotion: 'Anxiety', intensity: 0.9),
          EmotionIntensity(emotion: 'Worry', intensity: 0.8),
        ],
        isPrivacyMode: true,
        nlpMetadata: {'sample': true, 'language': 'hindi'},
      ),
      MoodEntry(
        id: 'sample_mood_3',
        date: now.subtract(const Duration(days: 1)),
        userText: 'Feeling grateful for good relationships in my life',
        identifiedMood: 'Grateful',
        stressLevel: 'Low',
        relatedContactId: 'sample_contact_1',
        category: MoodCategory.positive,
        sentimentScore: 0.7,
        stressScore: 0.3,
        extractedKeywords: ['grateful', 'relationships', 'good'],
        detectedEmotions: [
          EmotionIntensity(emotion: 'Gratitude', intensity: 0.8),
          EmotionIntensity(emotion: 'Love', intensity: 0.6),
        ],
        isPrivacyMode: true,
        nlpMetadata: {'sample': true, 'language': 'english'},
      ),
    ];
  }

  /// Deprecated: use generateSampleData
  @Deprecated('Use generateSampleData instead')
  static List<MoodEntry> generateDemoData() => generateSampleData();

  /// Check if entry needs NLP analysis
  bool needsAnalysis() {
    return identifiedMood == 'pending_analysis' ||
        stressLevel == 'pending_analysis' ||
        lastAnalyzed == null ||
        DateTime.now().difference(lastAnalyzed!).inDays > 7;
  }

  @override
  String toString() {
    return 'MoodEntry(id: $id, date: $date, mood: $identifiedMood, stress: $stressLevel)';
  }
}

/// Mood categories for better classification
@HiveType(typeId: 30)
enum MoodCategory {
  @HiveField(0)
  positive,

  @HiveField(1)
  negative,

  @HiveField(2)
  neutral,

  @HiveField(3)
  angry,

  @HiveField(4)
  sad,

  @HiveField(5)
  anxious,

  @HiveField(6)
  confused,

  @HiveField(7)
  pending, // For entries awaiting analysis
}

/// Emotion with intensity level for detailed analysis
@HiveType(typeId: 31)
class EmotionIntensity extends HiveObject {
  @HiveField(0)
  String emotion;

  @HiveField(1)
  double intensity; // 0.0 to 1.0

  @HiveField(2)
  DateTime detectedAt;

  EmotionIntensity({
    required this.emotion,
    required this.intensity,
    DateTime? detectedAt,
  }) : detectedAt = detectedAt ?? DateTime.now();

  factory EmotionIntensity.fromJson(Map<String, dynamic> json) {
    return EmotionIntensity(
      emotion: json['emotion'] ?? '',
      intensity: (json['intensity'] ?? 0.0).toDouble(),
      detectedAt: json['detectedAt'] != null
          ? DateTime.parse(json['detectedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emotion': emotion,
      'intensity': intensity,
      'detectedAt': detectedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '$emotion: ${(intensity * 100).toStringAsFixed(0)}%';
  }
}

/// NLP Analysis service integration for MoodEntry
class MoodEntryNLPService {
  /// Analyze mood entry using offline NLP (analyzeSentimentAndStress)
  static Future<MoodEntry> analyzeEntry(MoodEntry entry) async {
    try {
      // This would integrate with your analyzeSentimentAndStress function
      final analysisResult = await _performOfflineNLPAnalysis(entry.userText);

      return entry.updateWithNLPAnalysis(
        identifiedMood: analysisResult['mood'] ?? 'neutral',
        stressLevel: analysisResult['stressLevel'] ?? 'medium',
        sentimentScore: analysisResult['sentimentScore'] ?? 0.0,
        stressScore: analysisResult['stressScore'] ?? 0.5,
        extractedKeywords: List<String>.from(analysisResult['keywords'] ?? []),
        detectedEmotions: (analysisResult['emotions'] as List<dynamic>?)
                ?.map((e) => EmotionIntensity.fromJson(e))
                .toList() ??
            [],
        nlpMetadata: analysisResult['metadata'] ?? {},
      );
    } catch (e) {
      // Fallback analysis if NLP fails
      return entry.updateWithNLPAnalysis(
        identifiedMood: 'neutral',
        stressLevel: 'medium',
        sentimentScore: 0.0,
        stressScore: 0.5,
        extractedKeywords: [],
        detectedEmotions: [],
        nlpMetadata: {'error': e.toString(), 'fallback': true},
      );
    }
  }

  /// Mock implementation of offline NLP analysis
  /// Replace this with your actual analyzeSentimentAndStress implementation
  static Future<Map<String, dynamic>> _performOfflineNLPAnalysis(
      String text) async {
    // Simulate NLP processing time
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock analysis results - replace with actual NLP implementation
    final textLower = text.toLowerCase();

    // Simple sentiment analysis
    double sentimentScore = 0.0;
    if (textLower
        .contains(RegExp(r'(अच्छा|खुश|happy|good|great|excellent|grateful)'))) {
      sentimentScore = 0.7;
    } else if (textLower
        .contains(RegExp(r'(बुरा|गुस्सा|sad|angry|bad|terrible|awful)'))) {
      sentimentScore = -0.7;
    } else if (textLower
        .contains(RegExp(r'(तनाव|चिंता|stress|anxiety|worried|nervous)'))) {
      sentimentScore = -0.4;
    }

    // Simple stress analysis
    double stressScore = 0.5;
    String stressLevel = 'Medium';
    if (textLower.contains(RegExp(r'(तनाव|चिंता|stress|anxiety|pressure)'))) {
      stressScore = 0.8;
      stressLevel = 'High';
    } else if (textLower
        .contains(RegExp(r'(शांत|आराम|calm|relaxed|peaceful)'))) {
      stressScore = 0.2;
      stressLevel = 'Low';
    }

    // Simple mood identification
    String mood = 'Neutral';
    if (sentimentScore > 0.5) {
      mood = 'Happy';
    } else if (sentimentScore < -0.5) {
      mood = 'Sad';
    } else if (stressScore > 0.7) {
      mood = 'Anxious';
    }

    // Simple keyword extraction
    final keywords = <String>[];
    final words = text.split(' ');
    for (final word in words) {
      if (word.length > 3 && !keywords.contains(word)) {
        keywords.add(word);
        if (keywords.length >= 5) break;
      }
    }

    // Mock emotion detection
    final emotions = <Map<String, dynamic>>[];
    if (sentimentScore > 0.5) {
      emotions.add({'emotion': 'Joy', 'intensity': sentimentScore});
    } else if (sentimentScore < -0.5) {
      emotions.add({'emotion': 'Sadness', 'intensity': -sentimentScore});
    }
    if (stressScore > 0.7) {
      emotions.add({'emotion': 'Anxiety', 'intensity': stressScore});
    }

    return {
      'mood': mood,
      'stressLevel': stressLevel,
      'sentimentScore': sentimentScore,
      'stressScore': stressScore,
      'keywords': keywords.take(5).toList(),
      'emotions': emotions,
      'metadata': {
        'processedAt': DateTime.now().toIso8601String(),
        'textLength': text.length,
        'language': _detectLanguage(text),
        'version': '1.0.0',
      },
    };
  }

  /// Simple language detection
  static String _detectLanguage(String text) {
    if (text.contains(RegExp(r'[अ-ह]'))) {
      return 'hindi';
    } else {
      return 'english';
    }
  }
}

// lib/services/mood_entry_service.dart

import '../models/mood_entry.dart';
import 'privacy_service.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

/// MoodEntry service for managing mood tracking and NLP analysis
/// 
/// Integrates with offline AI for sentiment and stress analysis
/// Privacy-first approach with local processing only
class MoodEntryService {
  static const String _boxName = 'mood_entries';
  late Box<MoodEntry> _moodBox;
  final PrivacyService _privacyService = PrivacyService();

  /// Initialize Hive box for mood entries
  Future<void> initialize() async {
    try {
      _moodBox = await Hive.openBox<MoodEntry>(_boxName);
      debugPrint('✅ MoodEntry service initialized');
    } catch (e) {
      debugPrint('❌ MoodEntry service initialization failed: $e');
      rethrow;
    }
  }

  /// Create new mood entry with immediate NLP analysis
  Future<MoodEntry> createMoodEntry({
    required String userText,
    String? relatedContactId,
    DateTime? date,
    bool performImmediateAnalysis = true,
  }) async {
    try {
      // Create initial entry
      final entry = MoodEntry.createForAnalysis(
        userText: userText,
        relatedContactId: relatedContactId,
        date: date,
      );

      // Perform NLP analysis if requested
      MoodEntry analyzedEntry = entry;
  if (performImmediateAnalysis && !_privacyService.isPrivacyMode()) {
        analyzedEntry = await MoodEntryNLPService.analyzeEntry(entry);
  } else if (_privacyService.isPrivacyMode()) {
    // Use sample analysis for privacy mode (formerly demo)
    analyzedEntry = _generateSampleAnalysis(entry);
      }

      // Store in Hive
      final key = analyzedEntry.id;
      await _moodBox.put(key, analyzedEntry);

      debugPrint('✅ Mood entry created and analyzed: ${analyzedEntry.identifiedMood}');
      return analyzedEntry;
    } catch (e) {
      debugPrint('❌ Failed to create mood entry: $e');
      rethrow;
    }
  }

  /// Generate sample analysis for privacy mode (renamed from demo)
  MoodEntry _generateSampleAnalysis(MoodEntry entry) {
    final textLower = entry.userText.toLowerCase();
    
  // Simple sample analysis
    String mood = 'Neutral';
    String stress = 'Medium';
    double sentiment = 0.0;
    double stressScore = 0.5;
    
    if (textLower.contains(RegExp(r'(अच्छा|खुश|happy|good)'))) {
      mood = 'Happy';
      stress = 'Low';
      sentiment = 0.7;
      stressScore = 0.3;
    } else if (textLower.contains(RegExp(r'(तनाव|चिंता|stress|worry)'))) {
      mood = 'Anxious';
      stress = 'High';
      sentiment = -0.4;
      stressScore = 0.8;
    }

    return entry.updateWithNLPAnalysis(
      identifiedMood: mood,
      stressLevel: stress,
      sentimentScore: sentiment,
      stressScore: stressScore,
      extractedKeywords: _extractSimpleKeywords(entry.userText),
      detectedEmotions: [
        EmotionIntensity(emotion: mood, intensity: 0.7),
      ],
  nlpMetadata: {'sample': true, 'processed_at': DateTime.now().toIso8601String()},
    );
  }

  /// Simple keyword extraction for sample/privacy mode
  List<String> _extractSimpleKeywords(String text) {
    final words = text.split(RegExp(r'\s+'));
    final keywords = <String>[];
    
    for (final word in words) {
      if (word.length > 3 && !keywords.contains(word.toLowerCase())) {
        keywords.add(word.toLowerCase());
        if (keywords.length >= 5) break;
      }
    }
    
    return keywords;
  }

  /// Get all mood entries for a date range
  Future<List<MoodEntry>> getMoodEntries({
    DateTime? startDate,
    DateTime? endDate,
    String? relatedContactId,
  }) async {
    try {
      final allEntries = _moodBox.values.toList();
      
      // Apply filters
      var filteredEntries = allEntries.where((entry) {
        bool matchesDate = true;
        bool matchesContact = true;
        
        if (startDate != null) {
          matchesDate = matchesDate && entry.date.isAfter(startDate.subtract(const Duration(days: 1)));
        }
        if (endDate != null) {
          matchesDate = matchesDate && entry.date.isBefore(endDate.add(const Duration(days: 1)));
        }
        if (relatedContactId != null && relatedContactId.isNotEmpty) {
          matchesContact = entry.relatedContactId == relatedContactId;
        }
        
        return matchesDate && matchesContact;
      }).toList();
      
      // Sort by date (newest first)
      filteredEntries.sort((a, b) => b.date.compareTo(a.date));
      
      return filteredEntries;
    } catch (e) {
      debugPrint('❌ Failed to get mood entries: $e');
      return [];
    }
  }

  /// Get recent mood entries (last 7 days)
  Future<List<MoodEntry>> getRecentMoodEntries({int days = 7}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    return getMoodEntries(startDate: startDate);
  }

  /// Get mood entries for specific contact
  Future<List<MoodEntry>> getMoodEntriesForContact(String contactId) async {
    return getMoodEntries(relatedContactId: contactId);
  }

  /// Update existing mood entry
  Future<MoodEntry?> updateMoodEntry(String entryId, {
    String? userText,
    String? relatedContactId,
    bool reanalyzeMood = false,
  }) async {
    try {
      final entry = _moodBox.get(entryId);
      if (entry == null) return null;

      // Create updated entry
      final updatedEntry = MoodEntry(
        id: entry.id,
        date: entry.date,
        userText: userText ?? entry.userText,
        identifiedMood: reanalyzeMood ? 'pending_analysis' : entry.identifiedMood,
        stressLevel: reanalyzeMood ? 'pending_analysis' : entry.stressLevel,
        relatedContactId: relatedContactId ?? entry.relatedContactId,
        category: entry.category,
        sentimentScore: entry.sentimentScore,
        stressScore: entry.stressScore,
        extractedKeywords: entry.extractedKeywords,
        detectedEmotions: entry.detectedEmotions,
        isPrivacyMode: entry.isPrivacyMode,
        nlpMetadata: entry.nlpMetadata,
        createdAt: entry.createdAt,
        lastAnalyzed: entry.lastAnalyzed,
      );

      // Reanalyze if requested
      MoodEntry finalEntry = updatedEntry;
      if (reanalyzeMood) {
  if (!_privacyService.isPrivacyMode()) {
          finalEntry = await MoodEntryNLPService.analyzeEntry(updatedEntry);
        } else {
          finalEntry = _generateSampleAnalysis(updatedEntry);
        }
      }

      // Update in Hive
      await _moodBox.put(entryId, finalEntry);
      
      debugPrint('✅ Mood entry updated: $entryId');
      return finalEntry;
    } catch (e) {
      debugPrint('❌ Failed to update mood entry: $e');
      return null;
    }
  }

  /// Delete mood entry
  Future<bool> deleteMoodEntry(String entryId) async {
    try {
      await _moodBox.delete(entryId);
      debugPrint('✅ Mood entry deleted: $entryId');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to delete mood entry: $e');
      return false;
    }
  }

  /// Analyze pending entries (for batch processing)
  Future<List<MoodEntry>> analyzePendingEntries() async {
    try {
      final pendingEntries = _moodBox.values
          .where((entry) => entry.needsAnalysis())
          .toList();

      final analyzedEntries = <MoodEntry>[];
      
      for (final entry in pendingEntries) {
        try {
          MoodEntry analyzed;
          if (!_privacyService.isPrivacyMode()) {
            analyzed = await MoodEntryNLPService.analyzeEntry(entry);
          } else {
            analyzed = _generateSampleAnalysis(entry);
          }
          
          await _moodBox.put(entry.id, analyzed);
          analyzedEntries.add(analyzed);
        } catch (e) {
          debugPrint('❌ Failed to analyze entry ${entry.id}: $e');
        }
      }

      debugPrint('✅ Analyzed ${analyzedEntries.length} pending entries');
      return analyzedEntries;
    } catch (e) {
      debugPrint('❌ Failed to analyze pending entries: $e');
      return [];
    }
  }

  /// Get mood statistics for analytics
  Future<MoodStatistics> getMoodStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String? relatedContactId,
  }) async {
    final entries = await getMoodEntries(
      startDate: startDate,
      endDate: endDate,
      relatedContactId: relatedContactId,
    );

    return MoodStatistics.fromEntries(entries);
  }

  /// Get sample data for privacy mode (replaces getDemoData)
  Future<List<MoodEntry>> getSampleData() async {
    return MoodEntry.generateSampleData();
  }

  // Removed deprecated: getDemoData (use getSampleData)

  /// Clear all mood entries (use with caution)
  Future<void> clearAllEntries() async {
    try {
      await _moodBox.clear();
      debugPrint('✅ All mood entries cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear mood entries: $e');
    }
  }

  /// Close service
  Future<void> dispose() async {
    try {
      await _moodBox.close();
      debugPrint('✅ MoodEntry service disposed');
    } catch (e) {
      debugPrint('❌ Failed to dispose MoodEntry service: $e');
    }
  }
}

/// Mood statistics for analytics and insights
class MoodStatistics {
  final int totalEntries;
  final Map<String, int> moodDistribution;
  final Map<String, int> stressDistribution;
  final double averageSentiment;
  final double averageStress;
  final List<String> topKeywords;
  final Map<String, int> emotionFrequency;
  final DateTime? mostRecentEntry;
  final DateTime? oldestEntry;

  MoodStatistics({
    required this.totalEntries,
    required this.moodDistribution,
    required this.stressDistribution,
    required this.averageSentiment,
    required this.averageStress,
    required this.topKeywords,
    required this.emotionFrequency,
    this.mostRecentEntry,
    this.oldestEntry,
  });

  factory MoodStatistics.fromEntries(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return MoodStatistics(
        totalEntries: 0,
        moodDistribution: {},
        stressDistribution: {},
        averageSentiment: 0.0,
        averageStress: 0.5,
        topKeywords: [],
        emotionFrequency: {},
      );
    }

    // Mood distribution
    final moodDist = <String, int>{};
    final stressDist = <String, int>{};
    for (final entry in entries) {
      moodDist[entry.identifiedMood] = (moodDist[entry.identifiedMood] ?? 0) + 1;
      stressDist[entry.stressLevel] = (stressDist[entry.stressLevel] ?? 0) + 1;
    }

    // Average sentiment and stress
    final avgSentiment = entries.fold(0.0, (sum, entry) => sum + entry.sentimentScore) / entries.length;
    final avgStress = entries.fold(0.0, (sum, entry) => sum + entry.stressScore) / entries.length;

    // Top keywords
    final allKeywords = entries.expand((entry) => entry.extractedKeywords).toList();
    final keywordCounts = <String, int>{};
    for (final keyword in allKeywords) {
      keywordCounts[keyword] = (keywordCounts[keyword] ?? 0) + 1;
    }
    final topKeywords = keywordCounts.entries
        .where((entry) => entry.value >= 2)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Emotion frequency
    final allEmotions = entries.expand((entry) => entry.detectedEmotions).toList();
    final emotionCounts = <String, int>{};
    for (final emotion in allEmotions) {
      emotionCounts[emotion.emotion] = (emotionCounts[emotion.emotion] ?? 0) + 1;
    }

    // Date range
    entries.sort((a, b) => a.date.compareTo(b.date));
    final oldest = entries.first.date;
    final newest = entries.last.date;

    return MoodStatistics(
      totalEntries: entries.length,
      moodDistribution: moodDist,
      stressDistribution: stressDist,
      averageSentiment: avgSentiment,
      averageStress: avgStress,
      topKeywords: topKeywords.take(10).map((e) => e.key).toList(),
      emotionFrequency: emotionCounts,
      mostRecentEntry: newest,
      oldestEntry: oldest,
    );
  }

  /// Generate summary string for display
  String toSummaryString() {
    final buffer = StringBuffer();
    
    buffer.writeln('📊 मूड विश्लेषण सारांश');
    buffer.writeln('कुल एंट्रीज: $totalEntries');
    buffer.writeln('औसत भावना: ${(averageSentiment * 100).toStringAsFixed(0)}%');
    buffer.writeln('औसत तनाव: ${(averageStress * 100).toStringAsFixed(0)}%');
    
    if (moodDistribution.isNotEmpty) {
      final topMood = moodDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      buffer.writeln('मुख्य मूड: ${topMood.key} (${topMood.value} बार)');
    }
    
    if (topKeywords.isNotEmpty) {
      buffer.writeln('मुख्य शब्द: ${topKeywords.take(5).join(", ")}');
    }
    
    return buffer.toString();
  }
}
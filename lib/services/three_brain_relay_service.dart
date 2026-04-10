import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/content_repository.dart';
import 'app_language_service.dart';
import 'onnx_three_brain_inference.dart';
import 'reward_service.dart';
import 'sos_service.dart';

enum BrainPhase { idle, brainA, brain1, brain2 }

class RelayChatMessage {
  const RelayChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;
}

class RelayResponse {
  const RelayResponse({
    required this.replyText,
    required this.emotionalScore,
    required this.stabilityScore,
    required this.patternSummary,
  });

  final String replyText;
  final double emotionalScore;
  final double stabilityScore;
  final String patternSummary;
}

class RelayUsageLimitException implements Exception {
  const RelayUsageLimitException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _BrainAReport {
  const _BrainAReport({
    required this.emotion,
    required this.intensity,
    required this.intent,
    required this.topEmotions,
    required this.detectionConfidence,
    required this.ambiguous,
    required this.summary,
  });

  final String emotion;
  final double intensity;
  final String intent;
  final List<String> topEmotions;
  final double detectionConfidence;
  final bool ambiguous;
  final String summary;
}

class _Brain1Pattern {
  const _Brain1Pattern({
    required this.emotionalScore,
    required this.stabilityScore,
    required this.primaryNeed,
    required this.primaryEmotion,
    required this.patternSummary,
  });

  final double emotionalScore;
  final double stabilityScore;
  final String primaryNeed;
  final String primaryEmotion;
  final String patternSummary;
}

class _Brain2Draft {
  const _Brain2Draft({
    required this.replyText,
    required this.source,
  });

  final String replyText;
  final String source;
}

class _ReplyAudit {
  const _ReplyAudit({
    required this.replyText,
    required this.aligned,
    required this.corrected,
    required this.alignmentScore,
    this.reason,
  });

  final String replyText;
  final bool aligned;
  final bool corrected;
  final double alignmentScore;
  final String? reason;
}

class _SosAssessment {
  const _SosAssessment({
    required this.triggered,
    required this.replyText,
    required this.riskLevel,
    required this.matchedSignals,
  });

  final bool triggered;
  final String replyText;
  final String riskLevel;
  final List<String> matchedSignals;
}

class _SrsReport {
  const _SrsReport({
    required this.score,
    required this.passed,
    required this.hasEmotionReflection,
    required this.hasNeedStep,
    required this.hasActionCue,
    required this.semanticAlignment,
    required this.corrected,
  });

  final int score;
  final bool passed;
  final bool hasEmotionReflection;
  final bool hasNeedStep;
  final bool hasActionCue;
  final double semanticAlignment;
  final bool corrected;
}

class _EmotionDetectionResult {
  const _EmotionDetectionResult({
    required this.primaryEmotion,
    required this.topEmotions,
    required this.topScore,
    required this.totalHits,
    required this.confidence,
    required this.ambiguous,
  });

  final String primaryEmotion;
  final List<String> topEmotions;
  final int topScore;
  final int totalHits;
  final double confidence;
  final bool ambiguous;
}

class ThreeBrainRelayService {
  ThreeBrainRelayService._();

  static final ThreeBrainRelayService instance = ThreeBrainRelayService._();
  static const int _maxEmotionEntries = 15;
  static const String _dynamicPromptDatasetAsset =
      'assets/data/cbt_dynamic_prompt_global_relationship_sa.json';

  static const String _chatKey = 'relay_chat_history';
  static const String _entriesKey = 'user_entries';
  static const String _feedbackKey = 'relay_feedback_memory';
  static const String _sosEventsKey = 'relay_sos_events';
  static const String _srsEventsKey = 'relay_srs_events';
  static const String _quarantineKey = 'quarantined_snippets';
  static const String _tierUsageDateKey = 'relay_tier_usage_date';
  static const String _tierDailyTurnsUsedKey = 'relay_tier_daily_turns_used';

  final ValueNotifier<BrainPhase> activePhase =
      ValueNotifier<BrainPhase>(BrainPhase.idle);
  final ValueNotifier<Map<String, bool>> activeBrainState =
      ValueNotifier<Map<String, bool>>(
    <String, bool>{'brainA': false, 'brain1': false, 'brain2': false},
  );
  final ValueNotifier<Map<String, dynamic>> debugState =
      ValueNotifier<Map<String, dynamic>>(<String, dynamic>{
    'emotion': 'n/a',
    'confidence': 0.0,
    'ambiguous': false,
    'primary_need': 'n/a',
    'alignment_score': 0.0,
    'corrected': false,
    'srs_score': 0,
    'srs_passed': false,
  });

  bool _busy = false;

  final OnnxThreeBrainInference _onnx = OnnxThreeBrainInference();
  final RewardService _rewardService = RewardService();

  bool _modelsReady = false;
  List<Map<String, dynamic>>? _dynamicPromptUnitsCache;

  static const List<String> _emotionPriority = <String>[
    'anger',
    'anxiety',
    'sadness',
    'fear',
    'disgust',
    'guilt',
    'shame',
    'jealousy',
    'envy',
    'horror',
    'pain',
    'empathetic_pain',
    'awkwardness',
    'confusion',
    'joy',
    'happiness',
    'love',
    'adoration',
    'romance',
    'excitement',
    'anticipation',
    'surprise',
    'trust',
    'relief',
    'satisfaction',
    'triumph',
    'pride',
    'admiration',
    'nostalgia',
    'longing',
    'desire',
    'craving',
    'calmness',
    'realization',
    'awe',
    'wonder',
    'amusement',
    'interest',
    'sympathy',
    'compassion',
    'hope',
    'gratitude',
  ];

  static const Map<String, List<String>> _emotionKeywords =
      <String, List<String>>{
    'anger': <String>[
      'angry',
      'mad',
      'furious',
      'rage',
      'irritated',
      'annoyed'
    ],
    'anxiety': <String>[
      'anxious',
      'anxiety',
      'panic',
      'worried',
      'uneasy',
      'nervous'
    ],
    'sadness': <String>['sad', 'down', 'low', 'depressed', 'blue', 'empty'],
    'fear': <String>['fear', 'afraid', 'scared', 'terrified', 'frightened'],
    'disgust': <String>['disgusted', 'gross', 'repulsed', 'revolted'],
    'guilt': <String>['guilty', 'my fault', 'blame myself', 'regret'],
    'shame': <String>[
      'ashamed',
      'humiliated',
      'embarrassed of myself',
      'worthless'
    ],
    'jealousy': <String>['jealous', 'insecure in relationship', 'possessive'],
    'envy': <String>['envious', 'why not me', 'others have more'],
    'horror': <String>[
      'horrified',
      'horror',
      'shocked to the core',
      'nightmare'
    ],
    'pain': <String>['pain', 'hurting', 'ache', 'suffering'],
    'empathetic_pain': <String>[
      'their pain hurts me',
      'feel others pain',
      'vicarious pain'
    ],
    'awkwardness': <String>[
      'awkward',
      'cringe',
      'socially odd',
      'uncomfortable'
    ],
    'confusion': <String>['confused', 'unclear', 'lost', 'mixed up'],
    'joy': <String>['joy', 'joyful', 'delighted'],
    'happiness': <String>['happy', 'content', 'pleased'],
    'love': <String>['love', 'deeply care', 'affection'],
    'adoration': <String>['adore', 'adore them', 'admire deeply'],
    'romance': <String>['romantic', 'in love', 'dating feelings'],
    'excitement': <String>['excited', 'thrilled', 'pumped'],
    'anticipation': <String>['looking forward', 'anticipating', 'cant wait'],
    'surprise': <String>['surprised', 'unexpected', 'did not expect'],
    'trust': <String>['trust', 'safe with', 'can rely'],
    'relief': <String>['relieved', 'thank god', 'weight off'],
    'satisfaction': <String>['satisfied', 'fulfilled', 'good enough'],
    'triumph': <String>['triumph', 'won', 'victory'],
    'pride': <String>['proud', 'achievement', 'accomplished'],
    'admiration': <String>['admire', 'look up to', 'inspired by'],
    'nostalgia': <String>['nostalgic', 'old memories', 'miss those days'],
    'longing': <String>['longing', 'yearning', 'miss deeply'],
    'desire': <String>['desire', 'want strongly', 'wish for'],
    'craving': <String>['craving', 'urge', 'cant resist'],
    'calmness': <String>['calm', 'peaceful', 'settled', 'steady'],
    'realization': <String>['realized', 'it clicked', 'now i understand'],
    'awe': <String>['awe', 'in awe', 'majestic'],
    'wonder': <String>['wonder', 'amazed', 'curious amazement'],
    'amusement': <String>['amused', 'funny', 'laughed'],
    'interest': <String>['interested', 'curious', 'engaged'],
    'sympathy': <String>['sympathy', 'feel sorry for', 'poor thing'],
    'compassion': <String>['compassion', 'kindness', 'care for suffering'],
    'hope': <String>['hope', 'optimistic', 'maybe it will improve'],
    'gratitude': <String>['grateful', 'thankful', 'appreciate'],
  };

  ValueNotifier<Map<String, String>> get resolvedModelPaths =>
      _onnx.resolvedModelPaths;

  Future<ModelCompatibilityReport> runModelCompatibilityCheck() =>
      _onnx.runCompatibilityCheck();

  /* ---------------------------------------------------------------------- */
  /*                               PUBLIC API                               */
  /* ---------------------------------------------------------------------- */

  Future<List<RelayChatMessage>> getHistory() async {
    final Box<dynamic> box = Hive.box('userBox');
    final List<dynamic> raw =
        (box.get(_chatKey, defaultValue: <dynamic>[]) as List<dynamic>?) ??
            <dynamic>[];

    return raw.map((dynamic e) {
      final Map<dynamic, dynamic> map = e as Map<dynamic, dynamic>;
      return RelayChatMessage(
        text: (map['text'] as String?) ?? '',
        isUser: (map['isUser'] as bool?) ?? false,
        timestamp: DateTime.tryParse((map['ts'] as String?) ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
    }).toList(growable: false);
  }

  Future<void> replaceHistory(List<RelayChatMessage> messages) async {
    final Box<dynamic> box = Hive.box('userBox');
    final List<Map<String, dynamic>> raw = messages
        .map(
          (RelayChatMessage m) => <String, dynamic>{
            'text': m.text,
            'isUser': m.isUser,
            'ts': m.timestamp.toIso8601String(),
          },
        )
        .toList(growable: false);
    await box.put(_chatKey, raw);
  }

  Future<void> clearHistory() async {
    final Box<dynamic> box = Hive.box('userBox');
    await box.put(_chatKey, <dynamic>[]);
  }

  Future<void> addEntry({
    required String source,
    required double mood,
    String note = '',
  }) async {
    final Box<dynamic> box = Hive.box('userBox');
    final List<dynamic> entries =
        (box.get(_entriesKey, defaultValue: <dynamic>[]) as List<dynamic>?) ??
            <dynamic>[];

    entries.add(
      <String, dynamic>{
        'source': source,
        'mood': mood,
        'note': note,
        'ts': DateTime.now().toIso8601String(),
      },
    );

    if (entries.length > _maxEmotionEntries) {
      entries.removeRange(0, entries.length - _maxEmotionEntries);
    }

    await box.put(_entriesKey, entries);
  }

  Future<RelayResponse> processTurn({
    required String userText,
    String? audioTranscript,
  }) async {
    if (_busy) {
      throw StateError('Relay is processing another turn.');
    }

    _busy = true;
    try {
      // 🔒 ENSURE MODELS READY ON FIRST TURN
      if (!_modelsReady) {
        await _onnx.runCompatibilityCheck();
        _modelsReady = true;
      }

      final Box<dynamic> box = Hive.box('userBox');
      await _assertTierTurnQuota(box);
      final List<RelayChatMessage> history = await getHistory();
      final List<dynamic> entries =
          (box.get(_entriesKey, defaultValue: <dynamic>[]) as List<dynamic>?) ??
              <dynamic>[];
      final String formScoresSummary = _buildFormScoresSummary(box);

      final _SosAssessment sos = await _runSOS(userText);
      if (sos.triggered) {
        debugState.value = <String, dynamic>{
          ...debugState.value,
          'sos_triggered': true,
          'risk': sos.riskLevel,
          'signals': sos.matchedSignals.join('|'),
        };
        await _recordSosEvent(sos);
        await _saveTurn(userText: userText, reply: sos.replyText);
        await _incrementTierUsage(box);
        return RelayResponse(
          replyText: sos.replyText,
          emotionalScore: 5.0,
          stabilityScore: 1.0,
          patternSummary:
              'sos_override:risk=${sos.riskLevel},signals=${sos.matchedSignals.join("|")}',
        );
      }

      final _BrainAReport reportA = await _runInBrainPhase<_BrainAReport>(
        BrainPhase.brainA,
        () => _runBrainA(
          text: userText,
          audioTranscript: audioTranscript ?? userText,
        ),
      );

      final _Brain1Pattern pattern = await _runInBrainPhase<_Brain1Pattern>(
        BrainPhase.brain1,
        () => _runBrain1(
          report: reportA,
          userText: userText,
          history: history,
          entries: entries,
          formScoresSummary: formScoresSummary,
        ),
      );

      final _Brain2Draft draft = await _runInBrainPhase<_Brain2Draft>(
        BrainPhase.brain2,
        () => _runBrain2(
          pattern: pattern,
          userText: userText,
          turnIndex: history.length,
        ),
      );

      final _ReplyAudit audit = await _enforceReplyAlignment(
        pattern: pattern,
        userText: userText,
        draft: draft,
        recentAssistantReply: _latestAssistantReply(history),
      );

      final _SrsReport srs = _runSRS(
        reply: audit.replyText,
        primaryEmotion: pattern.primaryEmotion,
        primaryNeed: pattern.primaryNeed,
        userText: userText,
        corrected: audit.corrected,
      );
      await _recordSrsEvent(
        pattern: pattern,
        audit: audit,
        report: srs,
      );

      debugState.value = <String, dynamic>{
        'emotion': reportA.emotion,
        'confidence': reportA.detectionConfidence,
        'ambiguous': reportA.ambiguous,
        'primary_need': pattern.primaryNeed,
        'alignment_score': audit.alignmentScore,
        'corrected': audit.corrected,
        'srs_score': srs.score,
        'srs_passed': srs.passed,
        'form_scores': formScoresSummary,
        'sos_triggered': false,
      };

      await _saveTurn(userText: userText, reply: audit.replyText);
      await _incrementTierUsage(box);

      return RelayResponse(
        replyText: audit.replyText,
        emotionalScore: pattern.emotionalScore,
        stabilityScore: pattern.stabilityScore,
        patternSummary: pattern.patternSummary,
      );
    } finally {
      activePhase.value = BrainPhase.idle;
      _busy = false;
    }
  }

  Future<void> _assertTierTurnQuota(Box<dynamic> box) async {
    final DateTime now = DateTime.now();
    final String today = '${now.year}-${now.month}-${now.day}';
    final String storedDate =
        (box.get(_tierUsageDateKey, defaultValue: '') as String?) ?? '';

    if (storedDate != today) {
      await box.put(_tierUsageDateKey, today);
      await box.put(_tierDailyTurnsUsedKey, 0);
    }

    final String tier = await _rewardService.currentMembershipTier();
    final int limit = _rewardService.dailyChatLimitForTier(tier);
    final int used =
        (box.get(_tierDailyTurnsUsedKey, defaultValue: 0) as int?) ?? 0;
    if (used >= limit) {
      final String tierTitle = _rewardService.tierTitle(tier);
      throw RelayUsageLimitException(
        '$tierTitle daily limit reached ($limit chats). Upgrade plan or try again tomorrow.',
      );
    }
  }

  Future<void> _incrementTierUsage(Box<dynamic> box) async {
    final int used =
        (box.get(_tierDailyTurnsUsedKey, defaultValue: 0) as int?) ?? 0;
    await box.put(_tierDailyTurnsUsedKey, used + 1);
  }

  /* ---------------------------------------------------------------------- */
  /*                               BRAINS                                   */
  /* ---------------------------------------------------------------------- */

  Future<_BrainAReport> _runBrainA({
    required String text,
    required String audioTranscript,
  }) async {
    final String normalized = '$text $audioTranscript'.toLowerCase();

    final _EmotionDetectionResult detection = _detectEmotions(normalized);
    final String emotion = detection.primaryEmotion;
    final List<String> topEmotions = detection.topEmotions;

    double intensity = (0.35 + detection.totalHits * 0.09).clamp(0.35, 0.9);
    final String intent =
        detection.ambiguous ? 'reflect' : _intentFromEmotion(emotion);

    if (normalized.contains('!')) {
      intensity = min(1.0, intensity + 0.08);
    }

    final String? onnxOutput = await _onnx.inferBrainA(
      text: text,
      audioTranscript: audioTranscript,
    );

    return _BrainAReport(
      emotion: emotion,
      intensity: intensity,
      intent: intent,
      topEmotions: topEmotions,
      detectionConfidence: detection.confidence,
      ambiguous: detection.ambiguous,
      summary:
          'Emotion=$emotion, top=${topEmotions.isEmpty ? emotion : topEmotions.join("|")}, confidence=${detection.confidence.toStringAsFixed(2)}, ambiguous=${detection.ambiguous}, intensity=${intensity.toStringAsFixed(2)}, intent=$intent'
          '${onnxOutput == null ? '' : ', onnx=$onnxOutput'}',
    );
  }

  Future<_Brain1Pattern> _runBrain1({
    required _BrainAReport report,
    required String userText,
    required List<RelayChatMessage> history,
    required List<dynamic> entries,
    required String formScoresSummary,
  }) async {
    final String normalized = userText.toLowerCase();

    final List<double> moods = <double>[];
    for (final dynamic e in entries) {
      if (e is Map && e['mood'] is num) {
        moods.add((e['mood'] as num).toDouble());
      }
    }

    final double avgMood = moods.isEmpty
        ? 3.0
        : moods.reduce((double a, double b) => a + b) / moods.length;

    final double emotionalScore = (6 - avgMood).clamp(1.0, 5.0);

    double stability = 5.0 - report.intensity * 2.2;

    if (_containsAny(normalized, <String>[
      'not sleeping',
      'cant sleep',
      'overthinking',
      'helpless',
    ])) {
      stability -= 0.7;
    }

    if (_containsAny(normalized, <String>[
      'better',
      'improving',
      'calm',
    ])) {
      stability += 0.5;
    }

    stability = stability.clamp(1.0, 5.0);

    String primaryNeed = switch (report.intent) {
      'safety' => 'grounding_and_safety',
      'support' => 'emotional_validation',
      'release' => 'calm_expression',
      'celebrate' => 'strengthen_and_savor',
      _ => 'gentle_reflection',
    };

    if (report.ambiguous || report.detectionConfidence < 0.42) {
      primaryNeed = 'gentle_reflection';
    }

    if (!report.ambiguous && report.detectionConfidence >= 0.55) {
      final String? learnedNeed = await _learnedNeedOverride(report.emotion);
      if (learnedNeed != null && learnedNeed.trim().isNotEmpty) {
        primaryNeed = learnedNeed;
      }
    }

    final String entriesSummary = moods.isEmpty
        ? 'no_entries'
        : 'entries=${moods.length}, avgMood=${avgMood.toStringAsFixed(2)}';

    final String historySummary =
        'userTurns=${history.where((RelayChatMessage m) => m.isUser).length}';

    final String summary =
        'avgMood=${avgMood.toStringAsFixed(2)}, primaryEmotion=${report.emotion}, ${report.summary}, need=$primaryNeed, formScores=$formScoresSummary';

    final String? onnxPattern = await _onnx.inferBrain1(
      brainAReport: report.summary,
      userText: userText,
      entriesSummary: entriesSummary,
      historySummary: historySummary,
      formScoresSummary: formScoresSummary,
    );

    return _Brain1Pattern(
      emotionalScore: emotionalScore,
      stabilityScore: stability,
      primaryNeed: primaryNeed,
      primaryEmotion: report.emotion,
      patternSummary:
          onnxPattern == null ? summary : '$summary, onnx=$onnxPattern',
    );
  }

  Future<_Brain2Draft> _runBrain2({
    required _Brain1Pattern pattern,
    required String userText,
    required int turnIndex,
  }) async {
    final String datasetGuidance = await _dynamicPromptGuidance(
      userText: userText,
      primaryEmotion: pattern.primaryEmotion,
      primaryNeed: pattern.primaryNeed,
      turnIndex: turnIndex,
    );
    final String enrichedPattern = datasetGuidance.isEmpty
        ? pattern.patternSummary
        : '${pattern.patternSummary}, dataset=$datasetGuidance';

    final String? onnxReply = await _onnx.inferBrain2(
      patternSummary: enrichedPattern,
    );

    if (!_isHindiSelected() &&
        onnxReply != null &&
        onnxReply.trim().isNotEmpty) {
      return _Brain2Draft(
        replyText: onnxReply.trim(),
        source: 'onnx',
      );
    }

    final String emotionReflection = _emotionReflection(pattern.primaryEmotion);
    final String seedBase =
        '${pattern.primaryEmotion}|${pattern.primaryNeed}|$userText|$turnIndex';

    final String empathy = _pickVariant(
      _empathyVariantsForNeed(pattern.primaryNeed),
      '$seedBase|empathy',
    );
    final String cbtStep = _pickVariant(
      _cbtStepVariantsForNeed(pattern.primaryNeed),
      '$seedBase|step',
    );
    final String actionableStep = _isHindiSelected()
        ? cbtStep
        : (datasetGuidance.isNotEmpty ? datasetGuidance : cbtStep);
    final String closing = _pickVariant(
      _closingVariants(),
      '$seedBase|closing',
    );
    final String anchor = _contextAnchor(userText);

    return _Brain2Draft(
      replyText:
          '$emotionReflection\n\n$anchor\n\n$empathy\n\n$actionableStep\n\n$closing',
      source: 'fallback',
    );
  }

  /* ---------------------------------------------------------------------- */

  Future<void> _saveTurn({
    required String userText,
    required String reply,
  }) async {
    final Box<dynamic> box = Hive.box('userBox');
    final List<dynamic> raw =
        (box.get(_chatKey, defaultValue: <dynamic>[]) as List<dynamic>?) ??
            <dynamic>[];

    raw.add(
      <String, dynamic>{
        'text': userText,
        'isUser': true,
        'ts': DateTime.now().toIso8601String(),
      },
    );

    raw.add(
      <String, dynamic>{
        'text': reply,
        'isUser': false,
        'ts': DateTime.now().toIso8601String(),
      },
    );

    if (raw.length > 300) {
      raw.removeRange(0, raw.length - 300);
    }

    await box.put(_chatKey, raw);
  }

  bool _containsAny(String text, List<String> keywords) {
    for (final String k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  String _buildFormScoresSummary(Box<dynamic> box) {
    final Map<String, dynamic> allEntries = Map<String, dynamic>.from(
      (box.get('form_entries', defaultValue: <String, dynamic>{}) as Map?) ??
          <String, dynamic>{},
    );
    if (allEntries.isEmpty) {
      return 'no_form_scores';
    }

    final List<String> parts = <String>[];
    allEntries.forEach((String assetPath, dynamic value) {
      final List<dynamic> entries =
          List<dynamic>.from((value as List?) ?? <dynamic>[]);
      if (entries.isEmpty) return;
      final dynamic latest = entries.last;
      if (latest is! Map) return;
      final Map<dynamic, dynamic> latestMap =
          Map<dynamic, dynamic>.from(latest);
      if (latestMap['score'] is! Map) return;
      final Map<dynamic, dynamic> scoreMap =
          Map<dynamic, dynamic>.from(latestMap['score'] as Map);
      final int percent = ((scoreMap['percent'] as num?) ?? 0).toInt();
      final int raw = ((scoreMap['raw'] as num?) ?? 0).toInt();
      final int max = ((scoreMap['max'] as num?) ?? 0).toInt();
      final String label = (scoreMap['label'] as String?) ?? '';
      final String shortAsset = assetPath.split('/').last;
      parts.add('$shortAsset:$percent%($raw/$max)[$label]');
    });

    if (parts.isEmpty) return 'no_form_scores';
    parts.sort();
    return parts.join(' | ');
  }

  Future<T> _runInBrainPhase<T>(
    BrainPhase phase,
    Future<T> Function() action,
  ) async {
    _activateOnly(phase);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    try {
      return await action();
    } finally {
      _deactivate(phase);
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }
  }

  void _activateOnly(BrainPhase phase) {
    activeBrainState.value = <String, bool>{
      'brainA': phase == BrainPhase.brainA,
      'brain1': phase == BrainPhase.brain1,
      'brain2': phase == BrainPhase.brain2,
    };
    activePhase.value = phase;
  }

  void _deactivate(BrainPhase phase) {
    activeBrainState.value = <String, bool>{
      'brainA': false,
      'brain1': false,
      'brain2': false,
    };
    if (activePhase.value == phase) {
      activePhase.value = BrainPhase.idle;
    }
  }

  Future<_SosAssessment> _runSOS(String userText) async {
    final String t = userText.toLowerCase();
    final Map<String, List<String>> signals = <String, List<String>>{
      'suicide': <String>[
        'suicide',
        'kill myself',
        'end my life',
        'want to die'
      ],
      'self_harm': <String>['self harm', 'cut myself', 'hurt myself'],
      'harm_others': <String>[
        'kill him',
        'kill her',
        'hurt someone',
        'harm others'
      ],
      'psychosis_risk': <String>[
        'hearing voices',
        'voices telling me',
        'people are after me'
      ],
    };

    final List<String> matched = <String>[];
    signals.forEach((String k, List<String> kws) {
      if (_containsAny(t, kws)) {
        matched.add(k);
      }
    });

    if (matched.isEmpty) {
      return const _SosAssessment(
        triggered: false,
        replyText: '',
        riskLevel: 'none',
        matchedSignals: <String>[],
      );
    }

    final Map<String, dynamic> profile = await SOSService.getSafetyProfile();
    final bool allowTrusted =
        (profile['allow_call_trusted_contact'] as bool?) ?? false;
    final bool allowEmergency =
        (profile['allow_call_country_emergency'] as bool?) ?? false;
    final String contactName =
        (profile['trusted_contact_name'] as String?)?.trim() ?? '';
    final String contactNumber =
        (profile['trusted_contact_number'] as String?)?.trim() ?? '';
    final String countryCode = (profile['country_code'] as String?) ??
        await SOSService.getSavedCountryCode();
    final Map<String, List<String>> emergency =
        SOSService.emergencyNumbersFor(countryCode);
    final String emergencyNumber = (emergency['medical']?.isNotEmpty ?? false)
        ? emergency['medical']!.first
        : '112';

    String reply;
    if (allowTrusted || allowEmergency) {
      final String trustedLine = allowTrusted && contactNumber.isNotEmpty
          ? 'Trusted contact: ${contactName.isEmpty ? "Saved Contact" : contactName} ($contactNumber).'
          : 'Trusted contact calling is currently not enabled.';
      final String emergencyLine = allowEmergency
          ? 'Country emergency line ($countryCode): $emergencyNumber.'
          : 'Country emergency calling is currently not enabled.';
      reply =
          'Your safety comes first. SOS mode is active. $trustedLine $emergencyLine If there is immediate danger, call emergency services now and do not stay alone.';
    } else {
      reply =
          'Your safety comes first. If there is immediate risk, call your country emergency number now and contact a trusted person. Once you are stable, set SOS permissions in the Safety Backup form so Dr Iris can better organize trusted-contact and emergency-calling support during crises.';
    }

    final String risk =
        matched.contains('suicide') || matched.contains('self_harm')
            ? 'high'
            : 'elevated';

    return _SosAssessment(
      triggered: true,
      replyText: reply,
      riskLevel: risk,
      matchedSignals: matched,
    );
  }

  Future<void> _recordSosEvent(_SosAssessment sos) async {
    final Box<dynamic> box = Hive.box('userBox');
    final List<dynamic> events =
        (box.get(_sosEventsKey, defaultValue: <dynamic>[]) as List<dynamic>?) ??
            <dynamic>[];
    events.add(<String, dynamic>{
      'ts': DateTime.now().toIso8601String(),
      'risk': sos.riskLevel,
      'signals': sos.matchedSignals,
    });
    if (events.length > 100) {
      events.removeRange(0, events.length - 100);
    }
    await box.put(_sosEventsKey, events);
  }

  _SrsReport _runSRS({
    required String reply,
    required String primaryEmotion,
    required String primaryNeed,
    required String userText,
    required bool corrected,
  }) {
    final String lower = reply.toLowerCase();
    final bool hasEmotionReflection =
        _containsAny(lower, _emotionAlignmentKeywords(primaryEmotion));
    final bool hasNeedStep =
        _containsAny(lower, _needAlignmentKeywords(primaryNeed));
    final bool hasActionCue = _containsAny(
        lower, <String>['can we', 'let us', "let's", 'would you', 'try']);
    final double semanticAlignment = _alignmentScore(
      reply: reply,
      primaryEmotion: primaryEmotion,
      primaryNeed: primaryNeed,
      userText: userText,
    );

    int score = 0;
    if (hasEmotionReflection) score += 35;
    if (hasNeedStep) score += 35;
    if (hasActionCue) score += 20;
    score += (semanticAlignment * 10).round();
    if (!corrected) score += 5;
    final bool passed = score >= 70;

    return _SrsReport(
      score: score,
      passed: passed,
      hasEmotionReflection: hasEmotionReflection,
      hasNeedStep: hasNeedStep,
      hasActionCue: hasActionCue,
      semanticAlignment: semanticAlignment,
      corrected: corrected,
    );
  }

  Future<void> _recordSrsEvent({
    required _Brain1Pattern pattern,
    required _ReplyAudit audit,
    required _SrsReport report,
  }) async {
    final Box<dynamic> box = Hive.box('userBox');
    final List<dynamic> events =
        (box.get(_srsEventsKey, defaultValue: <dynamic>[]) as List<dynamic>?) ??
            <dynamic>[];
    events.add(<String, dynamic>{
      'ts': DateTime.now().toIso8601String(),
      'primary_emotion': pattern.primaryEmotion,
      'primary_need': pattern.primaryNeed,
      'score': report.score,
      'passed': report.passed,
      'semantic_alignment': report.semanticAlignment,
      'corrected': report.corrected,
      'aligned': audit.aligned,
      'reason': audit.reason,
    });
    if (events.length > 300) {
      events.removeRange(0, events.length - 300);
    }
    await box.put(_srsEventsKey, events);
  }

  Future<_ReplyAudit> _enforceReplyAlignment({
    required _Brain1Pattern pattern,
    required String userText,
    required _Brain2Draft draft,
    required String recentAssistantReply,
  }) async {
    final double alignment = _alignmentScore(
      reply: draft.replyText,
      primaryEmotion: pattern.primaryEmotion,
      primaryNeed: pattern.primaryNeed,
      userText: userText,
    );
    final bool aligned = alignment >= 0.62;

    if (aligned) {
      await _learnFromAcceptedReply(
        emotion: pattern.primaryEmotion,
        need: pattern.primaryNeed,
        reply: draft.replyText,
      );
      return _ReplyAudit(
        replyText: draft.replyText,
        aligned: true,
        corrected: false,
        alignmentScore: alignment,
      );
    }

    await _recordMismatch(
      emotion: pattern.primaryEmotion,
      need: pattern.primaryNeed,
      source: draft.source,
      reply: draft.replyText,
    );

    final String corrected = await _buildStrictCorrectedReply(
      pattern: pattern,
      userText: userText,
      recentAssistantReply: recentAssistantReply,
    );

    await _learnFromAcceptedReply(
      emotion: pattern.primaryEmotion,
      need: pattern.primaryNeed,
      reply: corrected,
    );

    return _ReplyAudit(
      replyText: corrected,
      aligned: false,
      corrected: true,
      alignmentScore: alignment,
      reason: 'blocked_misaligned_reply(score=${alignment.toStringAsFixed(2)})',
    );
  }

  double _alignmentScore({
    required String reply,
    required String primaryEmotion,
    required String primaryNeed,
    required String userText,
  }) {
    final bool isHindi = _isHindiSelected();
    final String lower = reply.toLowerCase();
    final bool hasEmotionSignal = _containsAny(
      lower,
      _emotionAlignmentKeywords(primaryEmotion),
    );
    final bool hasNeedSignal = _containsAny(
      lower,
      _needAlignmentKeywords(primaryNeed),
    );
    final bool hasActionCue = _containsAny(
      lower,
      isHindi
          ? <String>['क्या हम', 'चलिए', 'कोशिश', 'कदम', 'धीरे', 'आज']
          : <String>['can we', 'let us', "let's", 'would you', 'try', 'step'],
    );

    final List<String> userTokens = isHindi
        ? userText
            .toLowerCase()
            .split(RegExp(r'\s+'))
            .map((String t) => t.trim())
            .where((String t) => t.length >= 2)
            .take(12)
            .toList(growable: false)
        : userText
            .toLowerCase()
            .split(RegExp(r'[^a-z0-9]+'))
            .where((String t) => t.length >= 4)
            .take(12)
            .toList(growable: false);

    int overlapCount = 0;
    for (final String token in userTokens) {
      if (lower.contains(token)) {
        overlapCount += 1;
      }
    }
    final double userContextSignal = userTokens.isEmpty
        ? 0.0
        : (overlapCount / userTokens.length).clamp(0.0, 1.0);

    double score = 0.0;
    if (hasEmotionSignal) score += 0.35;
    if (hasNeedSignal) score += 0.35;
    if (hasActionCue) score += 0.20;
    score += userContextSignal * 0.10;
    return score.clamp(0.0, 1.0);
  }

  List<String> _emotionAlignmentKeywords(String emotion) {
    if (_isHindiSelected()) {
      switch (emotion) {
        case 'anger':
          return <String>['गुस्सा', 'क्रोध', 'सीमा', 'अन्याय'];
        case 'anxiety':
          return <String>['चिंता', 'बेचैनी', 'घबराहट', 'अनिश्चित'];
        case 'sadness':
          return <String>['उदासी', 'भारी', 'खोया', 'दुख'];
        case 'fear':
          return <String>['डर', 'भय', 'सतर्क', 'असुरक्षित'];
        case 'guilt':
        case 'shame':
          return <String>['आत्म-दोष', 'गलती', 'शर्म', 'करुणा'];
        case 'gratitude':
        case 'hope':
        case 'relief':
          return <String>['आशा', 'कृतज्ञ', 'राहत', 'सकारात्मक'];
        default:
          return <String>['भावना', 'महसूस', 'संकेत'];
      }
    }
    switch (emotion) {
      case 'anger':
        return <String>['anger', 'angry', 'frustrat', 'boundary', 'unfair'];
      case 'anxiety':
        return <String>['anxiety', 'anxious', 'worry', 'uncertain', 'panic'];
      case 'sadness':
        return <String>['sad', 'heavy', 'loss', 'down'];
      case 'fear':
        return <String>['fear', 'afraid', 'alert', 'unsafe'];
      case 'guilt':
      case 'shame':
        return <String>['self-blame', 'guilt', 'shame', 'kind', 'compassion'];
      case 'gratitude':
      case 'hope':
      case 'relief':
        return <String>['grateful', 'hope', 'relief', 'build on', 'meaningful'];
      default:
        return <String>[emotion.replaceAll('_', ' '), 'feel', 'emotion'];
    }
  }

  List<String> _needAlignmentKeywords(String need) {
    if (_isHindiSelected()) {
      switch (need) {
        case 'grounding_and_safety':
          return <String>['सुरक्षा', 'सांस', 'धीरे', 'स्थिर', 'वर्तमान'];
        case 'emotional_validation':
          return <String>['वैध', 'भावना', 'सहारा', 'समझ'];
        case 'calm_expression':
          return <String>['रिहाई', 'विचार', 'शरीर', 'घटना', 'शांत'];
        case 'strengthen_and_savor':
          return <String>['मजबूत', 'दोहराएं', 'प्रगति', 'कल', 'आदत'];
        default:
          return <String>['कदम', 'कार्य', 'मददगार'];
      }
    }
    switch (need) {
      case 'grounding_and_safety':
        return <String>['ground', 'breath', 'safety', 'slow', 'present'];
      case 'emotional_validation':
        return <String>['valid', 'makes sense', 'feeling', 'support'];
      case 'calm_expression':
        return <String>['release', 'describe', 'body', 'thought', 'event'];
      case 'strengthen_and_savor':
        return <String>['build', 'repeat', 'savor', 'keep', 'tomorrow'];
      default:
        return <String>['step', 'action', 'helpful'];
    }
  }

  Future<String> _buildStrictCorrectedReply({
    required _Brain1Pattern pattern,
    required String userText,
    required String recentAssistantReply,
  }) async {
    final Map<String, dynamic> memory = await _loadFeedbackMemory();
    final bool isHindi = _isHindiSelected();
    final String seedBase =
        '${pattern.primaryEmotion}|${pattern.primaryNeed}|$userText|strict';
    final String learnedOpening = isHindi
        ? ''
        : _pickLearnedSnippet(
            memory: memory,
            emotion: pattern.primaryEmotion,
            need: pattern.primaryNeed,
            key: 'opening',
          );
    final String learnedStep = isHindi
        ? ''
        : _pickLearnedSnippet(
            memory: memory,
            emotion: pattern.primaryEmotion,
            need: pattern.primaryNeed,
            key: 'step',
          );

    final String opening = learnedOpening.isNotEmpty
        ? learnedOpening
        : _emotionReflection(pattern.primaryEmotion);
    final String strictNeedLine = _pickVariant(
      _strictNeedVariants(pattern.primaryNeed),
      '$seedBase|strict_step',
    );
    final String step = learnedStep.isNotEmpty ? learnedStep : strictNeedLine;
    final String anchor = _contextAnchor(userText);
    final List<String> checkInOptions = _checkInVariants();
    String checkIn = _pickVariant(
      checkInOptions,
      '$seedBase|checkin',
    );
    if (recentAssistantReply.contains(checkIn)) {
      checkIn = _pickAlternateVariant(checkInOptions, '$seedBase|checkin_alt');
    }

    String reply = '$opening\n\n$anchor\n\n$step\n\n$checkIn';
    if (_normalizeSnippet(reply) == _normalizeSnippet(recentAssistantReply)) {
      final String alternateStep = _pickAlternateVariant(
        _strictNeedVariants(pattern.primaryNeed),
        '$seedBase|strict_step_alt',
      );
      reply = '$opening\n\n$anchor\n\n$alternateStep\n\n$checkIn';
    }
    return reply;
  }

  String _latestAssistantReply(List<RelayChatMessage> history) {
    for (int i = history.length - 1; i >= 0; i--) {
      if (!history[i].isUser) {
        return history[i].text;
      }
    }
    return '';
  }

  bool _isHindiSelected() {
    return AppLanguageService.currentLanguageCode() == 'hi';
  }

  List<String> _empathyVariantsForNeed(String need) {
    final bool isHindi = _isHindiSelected();
    switch (need) {
      case 'grounding_and_safety':
        return isHindi
            ? <String>[
                'मैं महसूस कर सकती हूं कि अभी यह बहुत भारी लग रहा है, और आप इस पल में अकेले नहीं हैं।',
                'अभी आपका मन और शरीर बहुत दबाव में लग रहे हैं; हम एक-एक सांस के साथ फिर से सुरक्षा महसूस कर सकते हैं।',
                'यह पल बहुत तीव्र लग रहा है, और ऐसा महसूस होना स्वाभाविक है। हम इसे धीरे-धीरे स्थिर और सुरक्षित रखेंगे।',
              ]
            : <String>[
                'I can feel this is heavy right now, and you are not alone in this moment.',
                'Your body sounds overloaded right now; we can bring safety back one breath at a time.',
                'This feels intense, and it makes sense. We will keep this moment steady and safe.',
              ];
      case 'emotional_validation':
        return isHindi
            ? <String>[
                'इतनी ईमानदारी से साझा करने के लिए धन्यवाद। आपकी भावनाएं बिल्कुल मायने रखती हैं।',
                'इस तरह महसूस करना बिल्कुल वैध है; आप यहां जरूरत से ज्यादा प्रतिक्रिया नहीं दे रहे हैं।',
                'मैं इस बात का भार महसूस कर रही हूं। जो आप महसूस कर रहे हैं वह महत्वपूर्ण है।',
              ]
            : <String>[
                'Thank you for sharing this honestly. Your feelings make sense.',
                'It is valid to feel this way; you are not overreacting here.',
                'I hear the weight in this. What you are feeling matters.',
              ];
      case 'calm_expression':
        return isHindi
            ? <String>[
                'यह सच में बहुत ज्यादा लग रहा है। मेरे साथ इसे धीरे करना बिल्कुल ठीक है।',
                'इस पल के अंदर बहुत कुछ चल रहा है; हम इसे नरमी से एक-एक करके खोल सकते हैं।',
                'आपको यह सब एक साथ उठाने की जरूरत नहीं है; हम इसे शांति से सुलझा सकते हैं।',
              ]
            : <String>[
                'It sounds really overwhelming. It is okay to slow this down with me.',
                'There is a lot inside this moment; we can unpack it gently.',
                'You do not have to hold all of this at once; we can sort it calmly.',
              ];
      case 'strengthen_and_savor':
        return isHindi
            ? <String>[
                'मैं महसूस कर सकती हूं कि आपके लिए कुछ सार्थक काम कर रहा है। चलिए इसे सोच-समझकर आगे बढ़ाते हैं।',
                'यहां प्रगति दिख रही है; हम एक छोटा दोहराया जा सकने वाला कदम लेकर इसे स्थिर रख सकते हैं।',
                'यह एक उपयोगी बदलाव है। चलिए इसे आगे भी निभाना आसान बनाते हैं।',
              ]
            : <String>[
                'I can feel something meaningful is working for you. Let us build on it intentionally.',
                'There is progress here; we can protect it with one small repeatable step.',
                'This is a useful shift. Let us make it easier to carry forward.',
              ];
      default:
        return isHindi
            ? <String>[
                'मैं आपकी बात सुन रही हूं, और इस पल में बहुत नरमी से आपके साथ हूं।',
                'मैं यहीं आपके साथ हूं, और हम एक-एक छोटा कदम लेकर आगे बढ़ सकते हैं।',
                'इतनी साफ़ तरह से कहने के लिए धन्यवाद। चलिए इस पल को मिलकर थोड़ा हल्का करते हैं।',
              ]
            : <String>[
                'I hear you, and I am with you gently in this.',
                'I am here with you, and we can move one small step at a time.',
                'Thanks for saying this clearly. Let us make this moment lighter together.',
              ];
    }
  }

  List<String> _cbtStepVariantsForNeed(String need) {
    final bool isHindi = _isHindiSelected();
    switch (need) {
      case 'grounding_and_safety':
        return isHindi
            ? <String>[
                'क्या हम अभी एक grounding अभ्यास करें: सामने दिख रही 5 चीजें नाम लें, फिर 3 धीमी सांसें लें?',
                'अभी यह कोशिश करें: पैर ज़मीन पर रखें, आसपास देखें, 3 आवाज़ें पहचानें, फिर 4 गिनती में सांस लें और 6 गिनती में छोड़ें।',
                'पहले शरीर को स्थिर करें: कोई ठंडी चीज पकड़ें, 3 लंबी सांस छोड़ें, और कंधों को ढीला होने दें।',
              ]
            : <String>[
                'Can we do one grounding step: name 5 things you can see, then take 3 slow breaths?',
                'Try this now: feet on floor, look around, name 3 sounds, then breathe in for 4 and out for 6.',
                'Let us stabilize first: hold something cool, take 3 slow exhales, and notice your shoulders soften.',
              ];
      case 'emotional_validation':
        return isHindi
            ? <String>[
                'क्या आप इस भावना के पीछे का एक मुख्य विचार लिखना चाहेंगे, फिर उसका थोड़ा दयालु विकल्प देखेंगे?',
                'क्या हम सबसे कठिन विचार को एक पंक्ति में लिखकर उसे निष्पक्ष और करुणापूर्ण भाषा में दोबारा लिखें?',
                'चलिए एक विश्वास को नरमी से जांचते हैं: उसके पक्ष में क्या प्रमाण हैं और उसके विरुद्ध क्या प्रमाण हैं?',
              ]
            : <String>[
                'Would you like to note one thought behind this feeling, then check if there is a kinder alternative thought?',
                'Can we write the hardest thought in one line, then rewrite it in a fair and compassionate way?',
                'Let us test one belief gently: what is the evidence for it, and what evidence goes against it?',
              ];
      case 'calm_expression':
        return isHindi
            ? <String>[
                'चलिए दबाव को धीरे से कम करते हैं: घटना, विचार और शरीर की अनुभूति को एक-एक पंक्ति में लिखें।',
                '3 पंक्तियों में लिखें: क्या हुआ, आपने उसका क्या अर्थ निकाला, और शरीर ने क्या महसूस किया।',
                'क्या हम इसे तथ्य, व्याख्या और भावना में अलग करें ताकि मन को थोड़ी जगह मिल सके?',
              ]
            : <String>[
                'Let us release pressure softly: describe the event, your thought, and your body sensation in one line each.',
                'Try a 3-line dump: what happened, what it meant to you, and what your body felt.',
                'Can we separate this into facts, interpretation, and feeling so your mind gets some space?',
              ];
      case 'strengthen_and_savor':
        return isHindi
            ? <String>[
                'क्या हम इसे स्थिर करने के लिए एक मददगार चीज और उसे कल दोहराने का एक कदम तय करें?',
                'आज जो एक काम सहायक रहा, उसे अगले 24 घंटों में फिर से करने का समय तय करें।',
                'चलिए इस छोटी जीत को दिनचर्या बनाते हैं: एक संकेत, एक क्रिया, और एक छोटा इनाम।',
              ]
            : <String>[
                'Can we lock this in by naming one thing that helped and one step to repeat it tomorrow?',
                'Pick one action that worked today and schedule it again in the next 24 hours.',
                'Let us convert this win into routine: one cue, one action, one reward.',
              ];
      default:
        return isHindi
            ? <String>[
                'अगले 10 मिनट के लिए एक छोटा और मददगार कदम चुनते हैं।',
                'परफेक्ट नहीं, बस अगली 10 मिनट में होने वाला सबसे छोटा संभव कदम चुनें।',
                'फिलहाल ऐसा आसान कदम चुनें जो दबाव को थोड़ा भी कम कर दे।',
              ]
            : <String>[
                'Let us pick one tiny helpful action for the next 10 minutes.',
                'Choose the smallest doable step for the next 10 minutes, not the perfect step.',
                'For now, pick one low-effort action that reduces pressure by even 5%.',
              ];
    }
  }

  List<String> _strictNeedVariants(String need) {
    final bool isHindi = _isHindiSelected();
    switch (need) {
      case 'grounding_and_safety':
        return isHindi
            ? <String>[
                'सुरक्षा और grounding के लिए, क्या हम 3 धीमी सांस लें और अभी दिख रही 5 चीजों के नाम लें?',
                'पहले grounding करें: पैर ज़मीन पर रखें, जबड़ा ढीला छोड़ें, और 4 में सांस लेकर 6 में छोड़ने का चक्र 3 बार करें।',
                'अभी सुरक्षा पहले: कमरे में देखें, जो वास्तविक है उसे नाम दें, और सांस छोड़ने को थोड़ा लंबा रखें।',
              ]
            : <String>[
                'For safety and grounding, can we do 3 slow breaths and name 5 things you can see right now?',
                'Let us ground first: feet on floor, relax jaw, and do a slow 4-in / 6-out breath cycle three times.',
                'Right now, safety first: look around, name what is real in this room, and lengthen your exhale.',
              ];
      case 'emotional_validation':
        return isHindi
            ? <String>[
                'आपकी भावना वैध है। क्या हम इसके पीछे एक विचार लिखें और फिर उसका थोड़ा दयालु विकल्प जांचें?',
                'चलिए इस भावना का सम्मान करें और कठोर विचार को अधिक संतुलित वाक्य से चुनौती दें।',
                'क्या हम मूल विचार पकड़कर उसे सच और कम कठोर भाषा में दोबारा ढालें?',
              ]
            : <String>[
                'Your feeling is valid. Can we write one thought behind it and then test one kinder alternative?',
                'Let us honor this feeling and challenge the harsh thought with a more balanced sentence.',
                'Can we capture the core thought, then reframe it in a way that is true and less punishing?',
              ];
      case 'calm_expression':
        return isHindi
            ? <String>[
                'दबाव को संरचना में निकालते हैं: एक पंक्ति घटना, एक विचार, और एक शरीर अनुभूति के लिए लिखें।',
                'इसे अभी तीन पंक्तियों में बांटें: ट्रिगर, अर्थ/व्याख्या, और शरीर की प्रतिक्रिया।',
                'क्या हम इसे जल्दी से स्थिति, भावना और अगले छोटे कदम के रूप में मैप करें?',
              ]
            : <String>[
                'Let us release pressure in structure: one line for event, one for thought, one for body sensation.',
                'Break it into three lines now: trigger, interpretation, and body response.',
                'Can we map this quickly as situation, emotion, and next small response?',
              ];
      case 'strengthen_and_savor':
        return isHindi
            ? <String>[
                'इस प्रगति को स्थिर करते हैं: एक मददगार बात और अगले 24 घंटों में दोहराने वाला एक स्पष्ट कदम तय करें।',
                'आपके पास momentum है; कल के लिए एक दोहराया जा सकने वाला काम चुनें और रिमाइंडर लगाएं।',
                'इस सुधार को आदत बनाते हैं: ट्रिगर पहचानें और अगली सटीक क्रिया तय करें।',
              ]
            : <String>[
                'Let us lock this progress: name one thing that helped and one concrete step to repeat in the next 24 hours.',
                'You have momentum here; choose one repeatable action for tomorrow and set a reminder.',
                'Convert this improvement into habit: identify the trigger and the exact next action.',
              ];
      default:
        return isHindi
            ? <String>[
                'अगले 10 मिनट के लिए एक छोटा कदम चुनें और देखें कि आपकी अवस्था में क्या बदलाव आता है।',
                'अभी एक हल्का 10-मिनट कदम चुनें, फिर बताएं कि आपको भीतर क्या बदलाव महसूस हुआ।',
                'अभी एक छोटा व्यावहारिक कदम लें; उसके बाद हम असर साथ में देखेंगे।',
              ]
            : <String>[
                'Let us pick one tiny action for the next 10 minutes and check how it changes your state.',
                'Choose one gentle 10-minute action now and rate your shift after it.',
                'Take one small practical step right now; we will review impact immediately after.',
              ];
    }
  }

  List<String> _closingVariants() {
    if (_isHindiSelected()) {
      return const <String>[
        'हम एक-एक कदम चलेंगे। मैं बिना जजमेंट के पूरे सहारे के साथ आपके साथ हूं।',
        'कोई जल्दी नहीं है। हम धीरे-धीरे आगे बढ़ेंगे और मैं पूरे समय आपके साथ रहूंगी।',
        'अभी सब कुछ ठीक करना जरूरी नहीं; इस पल के लिए एक शांत छोटा कदम ही काफी है।',
      ];
    }
    return const <String>[
      'We can go step by step. I will stay non-judgmental and supportive with you.',
      'No rush. We will take one step at a time, and I will stay with you throughout.',
      'You do not need to fix everything now; one calm step is enough for this moment.',
    ];
  }

  List<String> _checkInVariants() {
    if (_isHindiSelected()) {
      return const <String>[
        'यह कदम करने के बाद अभी आपकी तीव्रता कैसी है: बहुत कम, कम, मध्यम, ज्यादा या बहुत ज्यादा?',
        'अभी आप अपनी अवस्था किस शब्द में बताएंगे: हल्की, संभालने योग्य, भारी, या बहुत भारी?',
        'इस कोशिश के बाद भीतर की स्थिति क्या लग रही है: शांत, थोड़ी बेचैनी, ज्यादा बेचैनी, या बहुत ज्यादा बेचैनी?',
      ];
    }
    return const <String>[
      'On a 0-10 scale, where are you right now after this step?',
      'After trying this, what number from 0-10 best fits your current intensity?',
      'When you do this step, tell me your intensity from 0 to 10 so we can adjust.',
    ];
  }

  String _contextAnchor(String userText) {
    final String trimmed = userText.trim();
    if (trimmed.isEmpty) {
      return _isHindiSelected()
          ? 'मैं आपकी मौजूदा स्थिति के साथ ध्यान से बनी हुई हूं।'
          : 'I am staying with your current signal carefully.';
    }
    final List<String> words = trimmed.split(RegExp(r'\s+'));
    final String short = words.take(8).join(' ');
    if (_isHindiSelected()) {
      return 'आपने कहा: "$short${words.length > 8 ? '...' : ''}"।';
    }
    return 'You said: "$short${words.length > 8 ? '...' : ''}".';
  }

  Future<String> _dynamicPromptGuidance({
    required String userText,
    required String primaryEmotion,
    required String primaryNeed,
    required int turnIndex,
  }) async {
    final List<Map<String, dynamic>> units = await _loadDynamicPromptUnits();
    if (units.isEmpty) return '';

    final String region = _detectRegion(userText);
    final String domain = _detectDomain(userText);
    final String emotion = primaryEmotion.toLowerCase().trim();
    final String need = primaryNeed.toLowerCase().trim();

    final List<Map<String, dynamic>> scoped =
        units.where((Map<String, dynamic> u) {
      final String r = (u['region'] ?? '').toString().toLowerCase();
      final String d = (u['domain'] ?? '').toString().toLowerCase();
      final String e = (u['emotion'] ?? '').toString().toLowerCase();
      final String n = (u['primary_need'] ?? '').toString().toLowerCase();
      return r == region && d == domain && e == emotion && n == need;
    }).toList();

    final List<Map<String, dynamic>> pool = scoped.isNotEmpty
        ? scoped
        : units.where((Map<String, dynamic> u) {
            final String r = (u['region'] ?? '').toString().toLowerCase();
            final String e = (u['emotion'] ?? '').toString().toLowerCase();
            final String n = (u['primary_need'] ?? '').toString().toLowerCase();
            return r == region && e == emotion && n == need;
          }).toList();
    if (pool.isEmpty) return '';

    final String seed = '$region|$domain|$emotion|$need|$turnIndex|$userText';
    final Map<String, dynamic> selected =
        pool[seed.hashCode.abs() % pool.length];
    final String validation =
        (selected['validation_line'] ?? '').toString().trim();
    final String action = (selected['action_line'] ?? '').toString().trim();
    final String reframe = (selected['reframe_line'] ?? '').toString().trim();
    final String cultural = region == 'south_asia'
        ? (selected['south_asia_guidance'] ?? '').toString().trim()
        : '';

    final List<String> parts = <String>[
      if (validation.isNotEmpty) validation,
      if (action.isNotEmpty) action,
      if (reframe.isNotEmpty) reframe,
      if (cultural.isNotEmpty) cultural,
    ];
    return parts.join(' ');
  }

  Future<List<Map<String, dynamic>>> _loadDynamicPromptUnits() async {
    if (_dynamicPromptUnitsCache != null) return _dynamicPromptUnitsCache!;
    final dynamic raw =
        await ContentRepository.instance.getByAsset(_dynamicPromptDatasetAsset);
    if (raw is! Map || raw['prompt_units'] is! List) {
      _dynamicPromptUnitsCache = <Map<String, dynamic>>[];
      return _dynamicPromptUnitsCache!;
    }
    final List<Map<String, dynamic>> units = <Map<String, dynamic>>[];
    for (final dynamic item
        in List<dynamic>.from(raw['prompt_units'] as List)) {
      if (item is Map) {
        units.add(Map<String, dynamic>.from(item));
      }
    }
    _dynamicPromptUnitsCache = units;
    return units;
  }

  String _detectRegion(String userText) {
    final String t = userText.toLowerCase();
    final List<String> southAsiaCues = <String>[
      'india',
      'pakistan',
      'bangladesh',
      'nepal',
      'sri lanka',
      'bhutan',
      'maldives',
      'desi',
      'in-laws',
      'arranged marriage',
      'joint family',
    ];
    for (final String cue in southAsiaCues) {
      if (t.contains(cue)) return 'south_asia';
    }
    return 'global';
  }

  String _detectDomain(String userText) {
    final String t = userText.toLowerCase();
    if (_containsAny(t, <String>['wife', 'husband', 'marriage'])) {
      return 'marriage';
    }
    if (_containsAny(
        t, <String>['girlfriend', 'boyfriend', 'partner', 'date'])) {
      return 'romantic';
    }
    if (_containsAny(
        t, <String>['mother', 'father', 'family', 'brother', 'sister'])) {
      return 'family';
    }
    if (_containsAny(t, <String>['friend', 'friendship'])) {
      return 'friendship';
    }
    if (_containsAny(
        t, <String>['boss', 'manager', 'office', 'colleague', 'work'])) {
      return 'workplace';
    }
    return 'romantic';
  }

  String _pickVariant(List<String> options, String seed) {
    if (options.isEmpty) return '';
    final int idx = seed.hashCode.abs() % options.length;
    return options[idx];
  }

  String _pickAlternateVariant(List<String> options, String seed) {
    if (options.isEmpty) return '';
    if (options.length == 1) return options.first;
    final int idx = (seed.hashCode.abs() % options.length + 1) % options.length;
    return options[idx];
  }

  Future<Map<String, dynamic>> _loadFeedbackMemory() async {
    final Box<dynamic> box = Hive.box('userBox');
    final dynamic raw =
        box.get(_feedbackKey, defaultValue: <String, dynamic>{});
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  Future<void> _saveFeedbackMemory(Map<String, dynamic> memory) async {
    final Box<dynamic> box = Hive.box('userBox');
    await box.put(_feedbackKey, memory);
  }

  Future<void> _recordMismatch({
    required String emotion,
    required String need,
    required String source,
    required String reply,
  }) async {
    final Map<String, dynamic> memory = await _loadFeedbackMemory();
    final Map<String, dynamic> mismatch = Map<String, dynamic>.from(
        (memory['mismatch_counts'] as Map?) ?? <String, dynamic>{});
    final int prev = ((mismatch[emotion] as num?) ?? 0).toInt();
    mismatch[emotion] = prev + 1;
    memory['mismatch_counts'] = mismatch;

    final List<dynamic> log =
        List<dynamic>.from((memory['mismatch_log'] as List?) ?? <dynamic>[]);
    log.add(<String, dynamic>{
      'emotion': emotion,
      'need': need,
      'source': source,
      'ts': DateTime.now().toIso8601String(),
    });
    if (log.length > 120) {
      log.removeRange(0, log.length - 120);
    }
    memory['mismatch_log'] = log;

    final List<dynamic> quarantine =
        List<dynamic>.from((memory[_quarantineKey] as List?) ?? <dynamic>[]);
    quarantine.add(<String, dynamic>{
      'emotion': emotion,
      'need': need,
      'source': source,
      'snippet': _normalizeSnippet(reply),
      'ts': DateTime.now().toIso8601String(),
    });
    if (quarantine.length > 260) {
      quarantine.removeRange(0, quarantine.length - 260);
    }
    memory[_quarantineKey] = quarantine;
    await _saveFeedbackMemory(memory);
  }

  Future<void> _learnFromAcceptedReply({
    required String emotion,
    required String need,
    required String reply,
  }) async {
    final Map<String, dynamic> memory = await _loadFeedbackMemory();
    final List<String> blocks = reply
        .split(RegExp(r'\n\s*\n'))
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    final String opening = blocks.isNotEmpty ? blocks.first : reply.trim();
    final String step = blocks.length > 1 ? blocks[1] : reply.trim();
    if (_isQuarantinedSnippet(memory, opening) ||
        _isQuarantinedSnippet(memory, step)) {
      return;
    }

    final List<dynamic> accepted = List<dynamic>.from(
        (memory['accepted_snippets'] as List?) ?? <dynamic>[]);
    accepted.add(<String, dynamic>{
      'emotion': emotion,
      'need': need,
      'opening': opening,
      'step': step,
      'ts': DateTime.now().toIso8601String(),
    });
    if (accepted.length > 220) {
      accepted.removeRange(0, accepted.length - 220);
    }
    memory['accepted_snippets'] = accepted;

    final Map<String, dynamic> byEmotion = Map<String, dynamic>.from(
        (memory['need_success'] as Map?) ?? <String, dynamic>{});
    final Map<String, dynamic> needMap = Map<String, dynamic>.from(
        (byEmotion[emotion] as Map?) ?? <String, dynamic>{});
    final int prev = ((needMap[need] as num?) ?? 0).toInt();
    needMap[need] = prev + 1;
    byEmotion[emotion] = needMap;
    memory['need_success'] = byEmotion;

    await _saveFeedbackMemory(memory);
  }

  String _pickLearnedSnippet({
    required Map<String, dynamic> memory,
    required String emotion,
    required String need,
    required String key,
  }) {
    final List<dynamic> accepted = List<dynamic>.from(
        (memory['accepted_snippets'] as List?) ?? <dynamic>[]);
    for (int i = accepted.length - 1; i >= 0; i--) {
      final dynamic item = accepted[i];
      if (item is! Map) continue;
      final String e = (item['emotion'] as String?) ?? '';
      final String n = (item['need'] as String?) ?? '';
      if (e == emotion && n == need) {
        final String v = (item[key] as String?) ?? '';
        if (v.trim().isNotEmpty && !_isQuarantinedSnippet(memory, v)) {
          return v.trim();
        }
      }
    }
    return '';
  }

  String _normalizeSnippet(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .trim();
  }

  bool _isQuarantinedSnippet(Map<String, dynamic> memory, String snippet) {
    final String norm = _normalizeSnippet(snippet);
    if (norm.isEmpty) return false;
    final List<dynamic> quarantine =
        List<dynamic>.from((memory[_quarantineKey] as List?) ?? <dynamic>[]);
    for (final dynamic item in quarantine) {
      if (item is! Map) continue;
      final String s = (item['snippet'] as String?) ?? '';
      if (s == norm) return true;
    }
    return false;
  }

  Future<String?> _learnedNeedOverride(String emotion) async {
    final Map<String, dynamic> memory = await _loadFeedbackMemory();
    final Map<String, dynamic> byEmotion = Map<String, dynamic>.from(
        (memory['need_success'] as Map?) ?? <String, dynamic>{});
    final Map<String, dynamic> needMap = Map<String, dynamic>.from(
        (byEmotion[emotion] as Map?) ?? <String, dynamic>{});
    if (needMap.isEmpty) return null;

    String bestNeed = '';
    int bestScore = 0;
    needMap.forEach((String k, dynamic v) {
      final int score = (v as num?)?.toInt() ?? 0;
      if (score > bestScore) {
        bestScore = score;
        bestNeed = k;
      }
    });

    return bestScore >= 3 ? bestNeed : null;
  }

  _EmotionDetectionResult _detectEmotions(String text) {
    final Map<String, int> emotionScores = _scoreEmotions(text);
    final List<MapEntry<String, int>> ranked = emotionScores.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) {
        if (b.value != a.value) {
          return b.value.compareTo(a.value);
        }
        return _emotionPriority.indexOf(a.key).compareTo(
              _emotionPriority.indexOf(b.key),
            );
      });

    final int topScore = ranked.isEmpty ? 0 : ranked.first.value;
    final int secondScore = ranked.length > 1 ? ranked[1].value : 0;
    final int totalHits = ranked
        .where((MapEntry<String, int> e) => e.value > 0)
        .fold(0, (int s, MapEntry<String, int> e) => s + e.value);

    final String primaryEmotion = topScore > 0 ? ranked.first.key : 'calmness';
    final List<String> topEmotions = ranked
        .where((MapEntry<String, int> e) => e.value > 0)
        .take(3)
        .map((MapEntry<String, int> e) => e.key)
        .toList(growable: false);

    final double confidence =
        totalHits <= 0 ? 0.30 : (topScore / totalHits).clamp(0.0, 1.0);
    final bool ambiguous =
        topScore == 0 || secondScore == topScore || confidence < 0.45;

    return _EmotionDetectionResult(
      primaryEmotion: primaryEmotion,
      topEmotions: topEmotions,
      topScore: topScore,
      totalHits: totalHits,
      confidence: confidence,
      ambiguous: ambiguous,
    );
  }

  Map<String, int> _scoreEmotions(String text) {
    final Map<String, int> scores = <String, int>{};
    for (final String emotion in _emotionPriority) {
      scores[emotion] = 0;
      final List<String> kws = _emotionKeywords[emotion] ?? <String>[];
      for (final String kw in kws) {
        if (text.contains(kw)) {
          scores[emotion] = (scores[emotion] ?? 0) + 1;
        }
      }
    }
    return scores;
  }

  String _intentFromEmotion(String emotion) {
    switch (emotion) {
      case 'anxiety':
      case 'fear':
      case 'horror':
      case 'pain':
      case 'empathetic_pain':
        return 'safety';
      case 'sadness':
      case 'guilt':
      case 'shame':
      case 'longing':
      case 'nostalgia':
        return 'support';
      case 'anger':
      case 'disgust':
      case 'jealousy':
      case 'envy':
      case 'awkwardness':
      case 'confusion':
      case 'craving':
        return 'release';
      case 'joy':
      case 'happiness':
      case 'love':
      case 'adoration':
      case 'romance':
      case 'excitement':
      case 'anticipation':
      case 'surprise':
      case 'trust':
      case 'relief':
      case 'satisfaction':
      case 'triumph':
      case 'pride':
      case 'admiration':
      case 'desire':
      case 'calmness':
      case 'realization':
      case 'awe':
      case 'wonder':
      case 'amusement':
      case 'interest':
      case 'sympathy':
      case 'compassion':
      case 'hope':
      case 'gratitude':
        return 'celebrate';
      default:
        return 'reflect';
    }
  }

  String _emotionReflection(String emotion) {
    final bool isHindi = _isHindiSelected();
    switch (emotion) {
      case 'anger':
        return isHindi
            ? 'मैं इसमें गुस्सा महसूस कर सकती हूं, और यह अक्सर किसी ऐसी बात की ओर इशारा करता है जो अन्यायपूर्ण लगी हो या किसी सीमा का उल्लंघन हुआ हो।'
            : 'I can sense anger in this, and that usually points to something that felt unfair or crossing a boundary.';
      case 'anxiety':
        return isHindi
            ? 'मुझे यहां चिंता महसूस हो रही है, जैसे आपका मन और शरीर आपको अनिश्चितता से बचाने की पूरी कोशिश कर रहे हों।'
            : 'I can sense anxiety here, like your system is trying hard to protect you from uncertainty.';
      case 'sadness':
        return isHindi
            ? 'मैं उदासी महसूस कर सकती हूं, और इसका मतलब अक्सर यह होता है कि आपके लिए कुछ महत्वपूर्ण अभी खोया हुआ या बहुत भारी लग रहा है।'
            : 'I can sense sadness, and that often means something important to you feels lost or heavy right now.';
      case 'fear':
        return isHindi
            ? 'इस पल में मुझे डर महसूस हो रहा है, और यह स्वाभाविक है कि आपका शरीर सतर्क अवस्था में हो।'
            : 'I can sense fear in this moment, and it makes sense your body is on alert.';
      case 'guilt':
      case 'shame':
        return isHindi
            ? 'मैं इसमें आत्म-दोष की भावना सुन पा रही हूं, और हम जिम्मेदारी स्वीकार कर सकते हैं बिना आपको एक व्यक्ति के रूप में कठोरता से आंकें।'
            : 'I can hear self-blame in this, and we can hold accountability without attacking you as a person.';
      case 'hope':
      case 'gratitude':
      case 'relief':
        return isHindi
            ? 'मैं इसमें एक अर्थपूर्ण सकारात्मक संकेत भी सुन रही हूं, और इसे इरादे के साथ मजबूत करना मूल्यवान रहेगा।'
            : 'I can also hear a meaningful positive signal in this, and it is worth strengthening intentionally.';
      default:
        return isHindi
            ? 'मैं आपके भावनात्मक संकेत को ध्यान से समझ रही हूं, और हम इस पर कदम-दर-कदम काम कर सकते हैं।'
            : 'I am tracking your emotional signal carefully, and we can work with it step by step.';
    }
  }
}

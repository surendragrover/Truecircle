import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/content_repository.dart';
import '../../services/app_language_service.dart';
import '../../services/privacy_nudge_service.dart';
import '../../services/reward_service.dart';
import '../app/app_shell.dart';
import '../safety/sos_consent_form_screen.dart';

class JsonContentScreen extends StatefulWidget {
  const JsonContentScreen({
    super.key,
    required this.title,
    required this.assetPath,
    this.formSectionKey,
    this.markFirstCheckInDoneOnSubmit = false,
    this.navigateToDashboardOnSubmit = false,
  });

  final String title;
  final String assetPath;
  final String? formSectionKey;
  final bool markFirstCheckInDoneOnSubmit;
  final bool navigateToDashboardOnSubmit;

  @override
  State<JsonContentScreen> createState() => _JsonContentScreenState();
}

class _JsonContentScreenState extends State<JsonContentScreen> {
  static Map<String, String>? _hindiDatasetMapCache;
  final RewardService _rewardService = RewardService();
  final PrivacyNudgeService _privacyNudgeService = PrivacyNudgeService();
  dynamic _data;
  _FormSpec? _formSpec;
  bool _loading = true;
  bool _submitting = false;
  final Map<String, dynamic> _answers = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _privacyNudgeService.maybeShow(context, source: 'json_content');
    });
  }

  Future<void> _load() async {
    final String resolvedAssetPath =
        await _resolveAssetPathForLanguage(widget.assetPath);
    dynamic data = await ContentRepository.instance.getByAsset(resolvedAssetPath);
    data ??= await _loadDirectFromAsset(resolvedAssetPath);
    if (data == null && resolvedAssetPath != widget.assetPath) {
      data = await ContentRepository.instance.getByAsset(widget.assetPath);
      data ??= await _loadDirectFromAsset(widget.assetPath);
    }
    if (!mounted) return;
    setState(() {
      _data = data;
      _formSpec = _extractFormSpec(data);
      _loading = false;
    });
  }

  Future<String> _resolveAssetPathForLanguage(String baseAssetPath) async {
    final String languageCode = AppLanguageService.currentLanguageCode();
    if (languageCode != 'hi') return baseAssetPath;
    final Map<String, String> map = await _loadHindiDatasetMap();
    return map[baseAssetPath] ?? baseAssetPath;
  }

  Future<Map<String, String>> _loadHindiDatasetMap() async {
    if (_hindiDatasetMapCache != null) return _hindiDatasetMapCache!;
    try {
      final String raw = await rootBundle.loadString(
        'assets/data_hi/dataset_map_hi.json',
      );
      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map || decoded['datasets'] is! Map) {
        _hindiDatasetMapCache = <String, String>{};
        return _hindiDatasetMapCache!;
      }
      final Map<String, dynamic> datasets =
          Map<String, dynamic>.from(decoded['datasets'] as Map);
      _hindiDatasetMapCache = datasets.map<String, String>(
        (String key, dynamic value) =>
            MapEntry<String, String>(key, value.toString()),
      );
      return _hindiDatasetMapCache!;
    } catch (_) {
      _hindiDatasetMapCache = <String, String>{};
      return _hindiDatasetMapCache!;
    }
  }

  Future<dynamic> _loadDirectFromAsset(String assetPath) async {
    try {
      final String raw = await rootBundle.loadString(assetPath);
      final String withoutCommentLines = raw
          .split('\n')
          .where((String line) => !line.trimLeft().startsWith('//'))
          .join('\n');
      final String withoutTrailingCommas = withoutCommentLines.replaceAllMapped(
        RegExp(r',(\s*[}\]])'),
        (Match m) => m.group(1) ?? '',
      );
      return jsonDecode(withoutTrailingCommas);
    } catch (_) {
      return null;
    }
  }

  _FormSpec? _extractFormSpec(dynamic data) {
    if (data is! Map) return null;
    final Map<String, dynamic> map = Map<String, dynamic>.from(data);
    final List<_FormQuestion> questions = <_FormQuestion>[];

    if (map['en'] is Map && (map['en'] as Map)['daily_questions'] is List) {
      final Map<String, dynamic> en =
          Map<String, dynamic>.from(map['en'] as Map);
      for (final MapEntry<String, dynamic> entry in en.entries) {
        if (!entry.key.endsWith('_questions') || entry.value is! List) continue;
        if (widget.formSectionKey != null &&
            widget.formSectionKey != entry.key) {
          continue;
        }
        final List<dynamic> list = List<dynamic>.from(entry.value as List);
        for (final dynamic item in list) {
          if (item is Map) {
            final _FormQuestion? q = _questionFromMap(
              Map<String, dynamic>.from(item),
              prefix: entry.key,
            );
            if (q != null) questions.add(q);
          }
        }
      }
    }

    if (map['sections'] is Map) {
      final Map<String, dynamic> sections =
          Map<String, dynamic>.from(map['sections'] as Map);
      for (final MapEntry<String, dynamic> section in sections.entries) {
        if (widget.formSectionKey != null &&
            widget.formSectionKey != section.key) {
          continue;
        }
        if (section.value is! List) continue;
        for (final dynamic item in List<dynamic>.from(section.value as List)) {
          if (item is Map) {
            final _FormQuestion? q = _questionFromMap(
              Map<String, dynamic>.from(item),
              prefix: section.key,
            );
            if (q != null) questions.add(q);
          }
        }
      }
    }

    if (map['questions'] is List) {
      for (final dynamic item in List<dynamic>.from(map['questions'] as List)) {
        if (item is Map) {
          final _FormQuestion? q =
              _questionFromMap(Map<String, dynamic>.from(item));
          if (q != null) questions.add(q);
        }
      }
    }

    if (map['categories'] is List) {
      for (final dynamic categoryRaw
          in List<dynamic>.from(map['categories'] as List)) {
        if (categoryRaw is! Map) continue;
        final Map<String, dynamic> category =
            Map<String, dynamic>.from(categoryRaw);
        final String prefix =
            (category['id'] ?? category['title'] ?? 'category').toString();
        final dynamic categoryQuestions = category['questions'];
        if (categoryQuestions is List) {
          for (int i = 0; i < categoryQuestions.length; i++) {
            final dynamic qRaw = categoryQuestions[i];
            if (qRaw is String && qRaw.trim().isNotEmpty) {
              questions.add(
                _FormQuestion(
                  id: '${prefix}_$i',
                  question: qRaw.trim(),
                  type: _FormQuestionType.text,
                  options: const <String>[],
                ),
              );
            }
          }
        }
      }
    }

    if (questions.isEmpty) return null;
    return _FormSpec(
      id: widget.assetPath,
      title: widget.title,
      questions: questions,
    );
  }

  _FormQuestion? _questionFromMap(
    Map<String, dynamic> raw, {
    String prefix = '',
  }) {
    final String questionText = (raw['question'] ??
            raw['question_english'] ??
            raw['question_hindi'] ??
            '')
        .toString()
        .trim();
    if (questionText.isEmpty) return null;

    final String rawId =
        (raw['id'] ?? raw['entry_id'] ?? questionText).toString();
    final String id = prefix.isEmpty ? rawId : '${prefix}_$rawId';

    final String rawType =
        (raw['type'] ?? raw['answer_format'] ?? '').toString().toLowerCase();
    final List<String> options = _extractOptions(raw['options']);

    _FormQuestionType type = _FormQuestionType.text;
    if (rawType.contains('multi')) {
      type = _FormQuestionType.multi;
    } else if (rawType == 'text') {
      type = _FormQuestionType.text;
    } else if (options.isNotEmpty) {
      type = _FormQuestionType.single;
    }

    return _FormQuestion(
      id: id,
      question: questionText,
      type: type,
      options: options,
      placeholder: (raw['placeholder'] ?? '').toString(),
    );
  }

  List<String> _extractOptions(dynamic rawOptions) {
    if (rawOptions is! List) return const <String>[];
    final List<String> out = <String>[];
    for (final dynamic item in rawOptions) {
      if (item is String) {
        if (item.trim().isNotEmpty) out.add(item.trim());
        continue;
      }
      if (item is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final String value = (map['text'] ??
                map['label_english'] ??
                map['label_hindi'] ??
                map['label'] ??
                map['value'] ??
                '')
            .toString()
            .trim();
        if (value.isNotEmpty) out.add(value);
      }
    }
    return out;
  }

  bool _isAnswered(_FormQuestion q) {
    final dynamic answer = _answers[q.id];
    if (q.type == _FormQuestionType.multi) {
      return answer is Set<String> && answer.isNotEmpty;
    }
    return answer != null && answer.toString().trim().isNotEmpty;
  }

  Future<void> _submitForm() async {
    if (_formSpec == null || _submitting) return;
    final List<_FormQuestion> missing = _formSpec!.questions
        .where((q) => !_isAnswered(q))
        .toList(growable: false);
    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all fields before submit.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final Box<dynamic> userBox = Hive.box('userBox');
    final Map<String, dynamic> allEntries = Map<String, dynamic>.from(
      (userBox.get('form_entries', defaultValue: <String, dynamic>{})
              as Map?) ??
          <String, dynamic>{},
    );
    final List<dynamic> entriesForForm = List<dynamic>.from(
      (allEntries[widget.assetPath] as List?) ?? <dynamic>[],
    );
    final _FormScore formScore = _calculateFormScore(_formSpec!);
    final _RelationshipRiskAssessment? relationshipRisk =
        _buildRelationshipRiskAssessmentIfApplicable();
    entriesForForm.add(
      <String, dynamic>{
        'submitted_at': DateTime.now().toIso8601String(),
        'title': widget.title,
        'answers': _answers.map<String, dynamic>((String key, dynamic value) {
          if (value is Set<String>) {
            return MapEntry<String, dynamic>(key, value.toList());
          }
          return MapEntry<String, dynamic>(key, value);
        }),
        'score': <String, dynamic>{
          'raw': formScore.raw,
          'max': formScore.max,
          'percent': formScore.percent,
          'label': formScore.label,
        },
        if (relationshipRisk != null)
          'relationship_risk': <String, dynamic>{
            'level': relationshipRisk.level.name,
            'title': relationshipRisk.title,
            'summary': relationshipRisk.summary,
            'advice': relationshipRisk.advice,
            'urgent': relationshipRisk.urgent,
          },
      },
    );
    allEntries[widget.assetPath] = entriesForForm;
    await userBox.put('form_entries', allEntries);

    final RewardGrantResult reward = await _rewardService.grantEntryFormCoin(
      formId: '${widget.assetPath}|${widget.formSectionKey ?? "all"}',
    );
    if (widget.markFirstCheckInDoneOnSubmit && Hive.isBoxOpen('appBox')) {
      await Hive.box('appBox').put('first_checkin_done', true);
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
    });
    final String scoreLabel =
        formScore.label.isEmpty ? '' : ' (${formScore.label})';
    final String scoreText =
        'Score: ${formScore.raw}/${formScore.max} | ${formScore.percent}%$scoreLabel';
    final String relationshipText = relationshipRisk == null
        ? ''
        : ' | Relationship risk: ${relationshipRisk.title}';
    final String message = reward.granted
        ? 'Submitted successfully. $scoreText$relationshipText. +1 coin earned. Wallet: ${reward.balance}'
        : 'Submitted successfully. $scoreText$relationshipText. ${reward.reason}';
    await _maybeShowRelationshipRiskAlert(relationshipRisk);
    if (!mounted) return;
    if (widget.navigateToDashboardOnSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AppShell()),
        (Route<dynamic> route) => false,
      );
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  _RelationshipRiskAssessment? _buildRelationshipRiskAssessmentIfApplicable() {
    final String normalized = widget.assetPath.toLowerCase();
    if (!normalized.contains('relationship_monitoring')) {
      return null;
    }

    int riskPoints = 0;
    bool urgent = false;

    final String safety =
        (_answers['relationship_monitoring_questions_emotional_safety'] ?? '')
            .toString()
            .toLowerCase();
    if (safety == 'no') {
      riskPoints += 6;
      urgent = true;
    } else if (safety == 'rarely') {
      riskPoints += 4;
    } else if (safety == 'sometimes') {
      riskPoints += 2;
    }

    final String trustRaw =
        (_answers['relationship_monitoring_questions_trust_level'] ?? '')
            .toString();
    final int trustScore = int.tryParse(trustRaw.trim()) ?? -1;
    if (trustScore >= 0 && trustScore <= 3) {
      riskPoints += 4;
    } else if (trustScore <= 6) {
      riskPoints += 2;
    }

    final String conflict =
        (_answers['relationship_monitoring_questions_recent_conflict'] ?? '')
            .toString()
            .toLowerCase();
    if (conflict.contains('severe')) {
      riskPoints += 5;
      urgent = true;
    } else if (conflict.contains('moderate')) {
      riskPoints += 3;
    } else if (conflict.contains('minor')) {
      riskPoints += 1;
    }

    final Set<String> stressPatterns = _answerAsSet(
      _answers['relationship_monitoring_questions_stress_patterns'],
    );
    if (stressPatterns
        .any((String v) => v.toLowerCase().contains('control behavior'))) {
      riskPoints += 4;
      urgent = true;
    }
    if (stressPatterns
        .any((String v) => v.toLowerCase().contains('boundary violations'))) {
      riskPoints += 4;
      urgent = true;
    }
    if (stressPatterns
        .any((String v) => v.toLowerCase().contains('blame/criticism'))) {
      riskPoints += 2;
    }
    if (stressPatterns
        .any((String v) => v.toLowerCase().contains('silent treatment'))) {
      riskPoints += 2;
    }
    if (stressPatterns
        .any((String v) => v.toLowerCase().contains('harsh tone'))) {
      riskPoints += 2;
    }

    final Set<String> feelings = _answerAsSet(
      _answers['relationship_monitoring_questions_after_interaction_feeling'],
    );
    if (feelings.any((String v) => v.toLowerCase() == 'drained')) {
      riskPoints += 2;
    }
    if (feelings.any((String v) => v.toLowerCase() == 'anxious')) {
      riskPoints += 2;
    }
    if (feelings.any((String v) => v.toLowerCase() == 'sad')) {
      riskPoints += 1;
    }
    if (feelings.any((String v) => v.toLowerCase() == 'angry')) {
      riskPoints += 1;
    }

    final Set<String> reactions = _answerAsSet(
      _answers['relationship_monitoring_questions_my_reaction_pattern'],
    );
    if (reactions.any((String v) => v.toLowerCase().contains('raised voice'))) {
      riskPoints += 2;
    }
    if (reactions
        .any((String v) => v.toLowerCase().contains('withdrew/silent'))) {
      riskPoints += 2;
    }
    if (reactions
        .any((String v) => v.toLowerCase().contains('cried/panicked'))) {
      riskPoints += 2;
    }

    final String repair =
        (_answers['relationship_monitoring_questions_repair_attempt'] ?? '')
            .toString()
            .toLowerCase();
    if (repair == 'no') riskPoints += 2;

    final String stressRaw =
        (_answers['relationship_monitoring_questions_stress_intensity'] ?? '')
            .toString();
    final int stressIntensity = int.tryParse(stressRaw.trim()) ?? -1;
    if (stressIntensity >= 8) {
      riskPoints += 4;
    } else if (stressIntensity >= 5) {
      riskPoints += 2;
    }

    if (urgent || riskPoints >= 14) {
      return const _RelationshipRiskAssessment(
        level: _RelationshipRiskLevel.high,
        title: 'High Risk',
        summary:
            'Danger signals are present in this relationship. A calm boundary and safety-focused action are needed immediately.',
        advice:
            '1) Schedule a blame-free calm conversation within 24 hours.\n2) Write and share clear boundaries.\n3) If control or abuse signals appear, contact trusted support or a counselor immediately.',
        urgent: true,
      );
    }
    if (riskPoints >= 8) {
      return const _RelationshipRiskAssessment(
        level: _RelationshipRiskLevel.watch,
        title: 'Watch Closely',
        summary:
            'Stress patterns are building in this relationship. Early repair can help keep it stable.',
        advice:
            '1) Set a fixed time for conversation.\n2) Use "I feel" statements and avoid blame.\n3) Do short check-ins for the next 3 days to track the stress trend.',
        urgent: false,
      );
    }
    return const _RelationshipRiskAssessment(
      level: _RelationshipRiskLevel.stable,
      title: 'Stable',
      summary:
          'No major danger signals detected right now. Continue healthy communication.',
      advice:
          '1) Note positive interactions.\n2) Review boundaries and expectations weekly.\n3) Take an early pause if stress starts rising.',
      urgent: false,
    );
  }

  Set<String> _answerAsSet(dynamic answer) {
    if (answer is Set<String>) return Set<String>.from(answer);
    if (answer is List) return Set<String>.from(answer);
    return <String>{};
  }

  Future<void> _maybeShowRelationshipRiskAlert(
    _RelationshipRiskAssessment? assessment,
  ) async {
    if (!mounted || assessment == null) return;
    if (assessment.level == _RelationshipRiskLevel.stable) return;
    final String? action = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Relationship Alert: ${assessment.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(assessment.summary),
              const SizedBox(height: 10),
              const Text(
                'Suggested Next Steps',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(assessment.advice),
            ],
          ),
          actions: <Widget>[
            if (assessment.urgent)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop('open_sos');
                },
                child: const Text('SOS / Trusted Contact'),
              ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop('ok'),
              child: const Text('Understood, I Will Act'),
            ),
          ],
        );
      },
    );
    if (!mounted || action != 'open_sos') return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SosConsentFormScreen(),
      ),
    );
  }

  _FormScore _calculateFormScore(_FormSpec form) {
    double raw = 0;
    double max = 0;
    for (final _FormQuestion q in form.questions) {
      final dynamic answer = _answers[q.id];
      if (q.type == _FormQuestionType.text) {
        max += 1;
        final int len = (answer ?? '').toString().trim().length;
        raw += (len / 60).clamp(0, 1);
        continue;
      }
      if (q.type == _FormQuestionType.single) {
        final int localMax = q.options.length > 1 ? q.options.length - 1 : 1;
        max += localMax;
        final String selected = (answer ?? '').toString();
        final int selectedIndex = q.options.indexOf(selected);
        raw += selectedIndex < 0 ? 0 : selectedIndex.clamp(0, localMax);
        continue;
      }
      final Set<String> selected = answer is Set<String>
          ? Set<String>.from(answer)
          : (answer is List ? Set<String>.from(answer) : <String>{});
      final int localMax = q.options.isEmpty ? 1 : q.options.length;
      max += localMax;
      raw += selected.length.clamp(0, localMax);
    }

    final int safeMax = max <= 0 ? 1 : max.round();
    final int rawInt = raw.round().clamp(0, safeMax);
    final int percent = ((rawInt / safeMax) * 100).round();
    final String label = _scoreLabelForAsset(
      assetPath: widget.assetPath,
      rawScore: rawInt,
      maxScore: safeMax,
    );
    return _FormScore(
        raw: rawInt, max: safeMax, percent: percent, label: label);
  }

  String _scoreLabelForAsset({
    required String assetPath,
    required int rawScore,
    required int maxScore,
  }) {
    final String normalized = assetPath.toLowerCase();
    if (normalized.contains('phq9')) {
      if (rawScore <= 4) return 'Minimal';
      if (rawScore <= 9) return 'Mild';
      if (rawScore <= 14) return 'Moderate';
      if (rawScore <= 19) return 'Moderately Severe';
      return 'Severe';
    }
    if (normalized.contains('gad-7')) {
      if (maxScore >= 100) {
        if (rawScore <= 27) return 'Minimal';
        if (rawScore <= 54) return 'Mild';
        if (rawScore <= 81) return 'Moderate';
        if (rawScore <= 108) return 'Moderately Severe';
        return 'Severe';
      }
      if (rawScore <= 4) return 'Minimal';
      if (rawScore <= 9) return 'Mild';
      if (rawScore <= 14) return 'Moderate';
      return 'Severe';
    }
    return 'Progress';
  }

  Future<void> _skipForm() async {
    if (widget.markFirstCheckInDoneOnSubmit && Hive.isBoxOpen('appBox')) {
      await Hive.box('appBox').put('first_checkin_done', true);
    }
    if (!mounted) return;
    if (widget.navigateToDashboardOnSubmit) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AppShell()),
        (Route<dynamic> route) => false,
      );
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          if (!_loading && _formSpec != null)
            TextButton(
              onPressed: _submitting ? null : _skipForm,
              child: const Text('Skip'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_data == null
              ? const Center(child: Text('No content found for this feature.'))
              : (_formSpec != null ? _buildForm() : _buildReadableContent())),
    );
  }

  Widget _buildForm() {
    final _FormSpec form = _formSpec!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          form.title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text('Fill all entries and submit to save your responses.'),
        const SizedBox(height: 14),
        for (final _FormQuestion q in form.questions) ...<Widget>[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(q.question,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildQuestionInput(q),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        FilledButton(
          onPressed: _submitting ? null : _submitForm,
          child: Text(_submitting ? 'Submitting...' : 'Submit Entry'),
        ),
        if (widget.markFirstCheckInDoneOnSubmit ||
            widget.navigateToDashboardOnSubmit) ...<Widget>[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _submitting ? null : _skipForm,
            child: const Text('Skip for now'),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildQuestionInput(_FormQuestion q) {
    if (q.type == _FormQuestionType.text) {
      return TextFormField(
        key: ValueKey<String>('text_${q.id}'),
        initialValue: (_answers[q.id] ?? '').toString(),
        minLines: 1,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: q.placeholder.isNotEmpty
              ? q.placeholder
              : 'Write your response...',
          border: const OutlineInputBorder(),
        ),
        onChanged: (String value) {
          _answers[q.id] = value;
        },
      );
    }

    if (q.type == _FormQuestionType.single) {
      final String selected = (_answers[q.id] ?? '').toString();
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: q.options.map((String option) {
          return ChoiceChip(
            label: Text(option),
            selected: selected == option,
            onSelected: (_) {
              setState(() {
                _answers[q.id] = option;
              });
            },
          );
        }).toList(growable: false),
      );
    }

    final Set<String> selected = (_answers[q.id] is Set<String>)
        ? Set<String>.from(_answers[q.id] as Set<String>)
        : <String>{};
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: q.options.map((String option) {
        return FilterChip(
          label: Text(option),
          selected: selected.contains(option),
          onSelected: (bool value) {
            setState(() {
              final Set<String> next = Set<String>.from(selected);
              if (value) {
                next.add(option);
              } else {
                next.remove(option);
              }
              _answers[q.id] = next;
            });
          },
        );
      }).toList(growable: false),
    );
  }

  Widget _buildReadableContent() {
    final String normalizedPath = widget.assetPath.toLowerCase();
    if (normalizedPath.contains('coping_cards') && _data is List) {
      final List<dynamic> items = List<dynamic>.from(_data as List);
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                widget.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            );
          }
          final String text = items[index - 1].toString();
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showCopingCard(index: index, content: text),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFF7F0FF), Color(0xFFEDE1FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD6C4F5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A1B9A).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (normalizedPath.contains('micro_lessons') && _data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(_data as Map);
      final List<dynamic> lessonsRaw = (map['lessons'] is List)
          ? List<dynamic>.from(map['lessons'] as List)
          : <dynamic>[];
      final List<Map<String, dynamic>> lessons = lessonsRaw
          .whereType<Map>()
          .map((Map<dynamic, dynamic> e) => e.map(
                (dynamic key, dynamic value) =>
                    MapEntry<String, dynamic>(key.toString(), value),
              ))
          .toList(growable: false);

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                widget.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            );
          }

          final Map<String, dynamic> lesson = lessons[index - 1];
          final String topic = (lesson['topic'] ?? 'Micro Lesson').toString();
          final String goal = (lesson['goal'] ?? '').toString();
          final int mins = int.tryParse(
                (lesson['duration_minutes'] ?? '').toString(),
              ) ??
              0;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _showMicroLessonCard(index: index, lesson: lesson),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFE7F7FF), Color(0xFFD7EEFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFB9DFFF)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D5A8B),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          topic,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (goal.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            goal,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                        if (mins > 0) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(
                            '$mins min',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF0D5A8B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (widget.assetPath.toLowerCase().contains('vocab') && _data is Map) {
      final int tokenCount = (_data as Map).length;
      return ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            widget.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text('Vocabulary loaded successfully. Total tokens: $tokenCount'),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          widget.title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        _buildNode(_data, depth: 0),
      ],
    );
  }

  Widget _buildNode(dynamic node, {required int depth}) {
    if (node is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(node);
      final List<MapEntry<String, dynamic>> visibleEntries = map.entries
          .where((MapEntry<String, dynamic> entry) =>
              entry.key.toLowerCase() != 'id')
          .toList(growable: false);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: visibleEntries.map((MapEntry<String, dynamic> entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.key.replaceAll('_', ' '),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                _buildNode(entry.value, depth: depth + 1),
              ],
            ),
          );
        }).toList(growable: false),
      );
    }

    if (node is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: node.asMap().entries.map((MapEntry<int, dynamic> item) {
          final dynamic value = item.value;
          if (value is Map || value is List) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildNode(value, depth: depth + 1),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('${item.key + 1}. ${value.toString()}'),
          );
        }).toList(growable: false),
      );
    }

    return Text(node?.toString() ?? '-');
  }

  Future<void> _showCopingCard({
    required int index,
    required String content,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFFFF3D8), Color(0xFFFFE0B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF2C27D), width: 1.2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC46D),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: Color(0xFF4A2A08),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Coping Card $index',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4A2A08),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD8A7)),
                  ),
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3B2A1A),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.done_rounded),
                    label: const Text('Close Card'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6A3A0C),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMicroLessonCard({
    required int index,
    required Map<String, dynamic> lesson,
  }) async {
    final String topic = (lesson['topic'] ?? 'Micro Lesson').toString();
    final String goal = (lesson['goal'] ?? '').toString();
    final String action = (lesson['micro_action'] ?? '').toString();
    final String reflection = (lesson['reflection_prompt'] ?? '').toString();
    final int mins = int.tryParse(
          (lesson['duration_minutes'] ?? '').toString(),
        ) ??
        0;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFE8F4FF), Color(0xFFD8EBFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFB9DFFF), width: 1.2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D5A8B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$index',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        topic,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0B3D63),
                        ),
                      ),
                    ),
                    if (mins > 0)
                      Text(
                        '$mins min',
                        style: const TextStyle(
                          color: Color(0xFF0D5A8B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                if (goal.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  _lessonSection(
                    title: 'Goal',
                    body: goal,
                    accent: const Color(0xFF145B8A),
                  ),
                ],
                if (action.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  _lessonSection(
                    title: 'Micro Action',
                    body: action,
                    accent: const Color(0xFF0B7A66),
                  ),
                ],
                if (reflection.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  _lessonSection(
                    title: 'Reflection Prompt',
                    body: reflection,
                    accent: const Color(0xFF7A4B08),
                  ),
                ],
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.done_rounded),
                    label: const Text('Close Lesson'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0D5A8B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _lessonSection({
    required String title,
    required String body,
    required Color accent,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2A35),
            ),
          ),
        ],
      ),
    );
  }
}

enum _FormQuestionType { text, single, multi }

class _FormQuestion {
  const _FormQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    this.placeholder = '',
  });

  final String id;
  final String question;
  final _FormQuestionType type;
  final List<String> options;
  final String placeholder;
}

class _FormSpec {
  const _FormSpec({
    required this.id,
    required this.title,
    required this.questions,
  });

  final String id;
  final String title;
  final List<_FormQuestion> questions;
}

class _FormScore {
  const _FormScore({
    required this.raw,
    required this.max,
    required this.percent,
    required this.label,
  });

  final int raw;
  final int max;
  final int percent;
  final String label;
}

enum _RelationshipRiskLevel { stable, watch, high }

class _RelationshipRiskAssessment {
  const _RelationshipRiskAssessment({
    required this.level,
    required this.title,
    required this.summary,
    required this.advice,
    required this.urgent,
  });

  final _RelationshipRiskLevel level;
  final String title;
  final String summary;
  final String advice;
  final bool urgent;
}

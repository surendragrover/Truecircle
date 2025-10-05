import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/cbt_service.dart';
import '../models/cbt_models.dart';
import '../services/cbt_education_content.dart';
import '../services/article_share_service.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../services/psych_study_articles.dart';
import '../services/ai_orchestrator_service.dart';
import '../theme/coral_theme.dart';
import '../services/offline_dictionary_translator.dart';

class CBTCenterPage extends StatefulWidget {
  const CBTCenterPage({super.key});
  @override
  State<CBTCenterPage> createState() => _CBTCenterPageState();
}

class _CBTCenterPageState extends State<CBTCenterPage> {
  bool _init = false;
  final _uuid = const Uuid();
  String _articleQuery = '';
  String _importedSearch = '';
  bool _sortFavoritesFirst = false;
  bool _showHindiArticle = false;

  @override
  void initState() {
    super.initState();
    _ensure();
  }

  Future<void> _ensure() async {
    await CBTService.instance.init();
    // load article language pref
    final prefs = await Hive.openBox('truecircle_settings');
    _showHindiArticle =
        prefs.get('articles_show_hindi', defaultValue: false) as bool;
    if (mounted) setState(() => _init = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CBT Center')),
      body: !_init
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Screening Tests'),
                  _cardButton('PHQ‑9 Depression (Demo)',
                      Icons.sentiment_very_dissatisfied, _runPhq9Demo),
                  _cardButton('GAD‑7 Anxiety (Demo)', Icons.sentiment_neutral,
                      _runGad7Demo),
                  const SizedBox(height: 24),
                  _sectionTitle('CBT Thought Diary'),
                  _cardButton(
                      'Add Thought Record', Icons.note_add, _addThoughtRecord),
                  _buildThoughtRecordsList(),
                  const SizedBox(height: 24),
                  _sectionTitle('Coping Cards'),
                  _cardButton('Add Coping Card', Icons.style, _addCopingCard),
                  _buildCopingCardsList(),
                  const SizedBox(height: 24),
                  _sectionTitle('Micro Lessons'),
                  _buildLessonChips(),
                  const SizedBox(height: 24),
                  _sectionTitle('Learn CBT Techniques'),
                  _buildEducationSection(),
                  const SizedBox(height: 24),
                  _sectionTitle('Study Psychology Articles'),
                  _buildArticlesSection(),
                  const SizedBox(height: 24),
                  _sectionTitle('Import Shared Articles (P2P Token)'),
                  _buildArticleShareSection(),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(t,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      );

  Widget _cardButton(String label, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF00796B), Color(0xFF00897B)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: CoralTheme.glowShadow(0.12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }

  Future<void> _runPhq9Demo() async {
    final answers = {
      for (int i = 1; i <= 9; i++) 'q$i': (i % 4)
    }; // mock rotating scores
    final total = answers.values.reduce((a, b) => a + b);
    final band = CBTScoring.phq9Band(total);
    final r = CBTAssessmentResult(
      id: 'phq9_${DateTime.now().toIso8601String()}',
      assessmentKey: 'phq9',
      answers: answers.map((k, v) => MapEntry(k, v)),
      totalScore: total,
      timestamp: DateTime.now(),
      severityBand: band,
      localizedSummaryEn:
          'PHQ‑9 Score $total ($band). Practice a grounding exercise & track mood.',
      localizedSummaryHi:
          'PHQ‑9 स्कोर $total ($band). ग्राउंडिंग अभ्यास करें और मूड ट्रैक करें।',
    );
    await CBTService.instance.saveAssessment(r);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _runGad7Demo() async {
    final answers = {for (int i = 1; i <= 7; i++) 'q$i': ((i + 1) % 4)};
    final total = answers.values.reduce((a, b) => a + b);
    final band = CBTScoring.gad7Band(total);
    final r = CBTAssessmentResult(
      id: 'gad7_${DateTime.now().toIso8601String()}',
      assessmentKey: 'gad7',
      answers: answers.map((k, v) => MapEntry(k, v)),
      totalScore: total,
      timestamp: DateTime.now(),
      severityBand: band,
      localizedSummaryEn:
          'GAD‑7 Score $total ($band). Try a breathing session & reframe worry.',
      localizedSummaryHi:
          'GAD‑7 स्कोर $total ($band). एक श्वास सत्र करें और चिंता को रिफ्रेम करें।',
    );
    await CBTService.instance.saveAssessment(r);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _addThoughtRecord() async {
    // Immutable lists can be marked const for analyzer preference.
    const distortions = CBTEducationContent.cognitiveDistortions;
    const techniques = CBTEducationContent.cognitiveTechniques;
    final situationCtrl = TextEditingController();
    final thoughtCtrl = TextEditingController();
    final emotionCtrl = TextEditingController();
    final rationalCtrl = TextEditingController();
    int intensityBefore = 50;
    int intensityAfter = 30;
    Map<String, String>? selectedDistortion;

    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: StatefulBuilder(
              builder: (ctx, setM) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                              child: Text('New Thought Record',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold))),
                          IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(ctx))
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: situationCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Situation / Context'),
                      ),
                      TextField(
                        controller: thoughtCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Automatic Thought'),
                      ),
                      TextField(
                        controller: emotionCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Primary Emotion (e.g., Sad, Anxious)'),
                      ),
                      const SizedBox(height: 12),
                      Text('Intensity Before: $intensityBefore%',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      Slider(
                        value: intensityBefore.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        onChanged: (v) {
                          setM(() => intensityBefore = v.round());
                        },
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<Map<String, String>>(
                        initialValue: selectedDistortion,
                        decoration: const InputDecoration(
                            labelText: 'Cognitive Distortion'),
                        items: distortions
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d['title']!),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setM(() => selectedDistortion = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: techniques
                            .map((t) => ActionChip(
                                  label: Text(t['title']!,
                                      style: const TextStyle(fontSize: 11)),
                                  onPressed: () {
                                    final snippet = '\nReframe: ${t['en']}';
                                    rationalCtrl.text += snippet;
                                    setM(() {});
                                  },
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: rationalCtrl,
                        maxLines: 4,
                        decoration: const InputDecoration(
                            labelText: 'Rational / Balanced Response'),
                      ),
                      const SizedBox(height: 12),
                      Text('Intensity After: $intensityAfter%',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      Slider(
                        value: intensityAfter.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        onChanged: (v) {
                          setM(() => intensityAfter = v.round());
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save),
                              label: const Text('Save Record'),
                              onPressed: () async {
                                if (thoughtCtrl.text.trim().isEmpty ||
                                    emotionCtrl.text.trim().isEmpty ||
                                    selectedDistortion == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please fill thought, emotion & distortion.')));
                                  return;
                                }
                                final tr = CBTThoughtRecord(
                                  id: DateTime.now().toIso8601String(),
                                  createdAt: DateTime.now(),
                                  situation: situationCtrl.text.trim(),
                                  automaticThought: thoughtCtrl.text.trim(),
                                  emotion: emotionCtrl.text.trim(),
                                  emotionIntensityBefore: intensityBefore,
                                  cognitiveDistortion:
                                      selectedDistortion!['title']!,
                                  rationalResponse:
                                      rationalCtrl.text.trim().isEmpty
                                          ? '—'
                                          : rationalCtrl.text.trim(),
                                  emotionIntensityAfter: intensityAfter,
                                );
                                await CBTService.instance.addThoughtRecord(tr);
                                if (mounted) setState(() {});
                                if (context.mounted) Navigator.pop(ctx);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                          'Tip: Use technique chips to scaffold a balanced response.',
                          style: TextStyle(
                              fontSize: 11, fontStyle: FontStyle.italic)),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  Future<void> _addCopingCard() async {
    final c = CopingCard(
      id: _uuid.v4(),
      unhelpfulBelief: 'If I\'m not perfect, I\'m a failure.',
      adaptiveBelief:
          'Progress over perfection – partial success still moves me forward.',
      evidenceFor: ['I sometimes miss small details'],
      evidenceAgainst: ['I complete important tasks', 'Peers value my input'],
      createdAt: DateTime.now(),
    );
    await CBTService.instance.addCopingCard(c);
    if (!mounted) return;
    setState(() {});
  }

  Widget _buildThoughtRecordsList() {
    final list = CBTService.instance.listThoughtRecords();
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      children: list
          .take(5)
          .map((tr) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.note, size: 20),
                title: Text(tr.automaticThought,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                    '${tr.emotion} ${tr.emotionIntensityBefore}%→${tr.emotionIntensityAfter}%',
                    style: const TextStyle(fontSize: 11)),
              ))
          .toList(),
    );
  }

  Widget _buildCopingCardsList() {
    final list = CBTService.instance.listCopingCards();
    if (list.isEmpty) return const SizedBox.shrink();
    return Column(
      children: list
          .take(5)
          .map((c) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.memory, size: 20),
                title: Text(c.unhelpfulBelief,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(c.adaptiveBelief,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11)),
              ))
          .toList(),
    );
  }

  Widget _buildLessonChips() {
    const lessons = [
      {'id': 'intro_cbt', 'title': 'CBT Basics'},
      {'id': 'cognitive_distortions', 'title': 'Cognitive Distortions'},
      {'id': 'behavioral_activation', 'title': 'Behavioral Activation'},
    ];
    final progress = CBTService.instance.lessonProgress();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: lessons.map((l) {
        final done = progress.any((p) => p.lessonId == l['id'] && p.completed);
        return ActionChip(
          label: Text(l['title']! + (done ? ' ✅' : '')),
          onPressed: () async {
            await CBTService.instance.setLessonCompleted(l['id']!, true);
            if (mounted) setState(() {});
          },
        );
      }).toList(),
    );
  }

  Widget _buildEducationSection() {
    // Use simple ExpansionTiles for categories.
    const distortions = CBTEducationContent.cognitiveDistortions;
    const cognitive = CBTEducationContent.cognitiveTechniques;
    const behavioral = CBTEducationContent.behavioralTechniques;
    return Column(
      children: [
        ExpansionTile(
          leading: const Icon(Icons.psychology_alt),
          title: const Text('Cognitive Techniques'),
          children: cognitive
              .map((m) => ListTile(
                    title: Text(m['title']!),
                    subtitle: Text(m['en']!,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () =>
                        _showDetailSheet(m['title']!, m['en']!, m['hi']!),
                  ))
              .toList(),
        ),
        ExpansionTile(
          leading: const Icon(Icons.fitness_center),
          title: const Text('Behavioral Techniques'),
          children: behavioral
              .map((m) => ListTile(
                    title: Text(m['title']!),
                    subtitle: Text(m['en']!,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () =>
                        _showDetailSheet(m['title']!, m['en']!, m['hi']!),
                  ))
              .toList(),
        ),
        ExpansionTile(
          leading: const Icon(Icons.grid_view),
          title: const Text('Cognitive Distortions'),
          children: distortions
              .map((m) => ListTile(
                    title: Text(m['title']!),
                    subtitle: Text(m['en']!,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () =>
                        _showDetailSheet(m['title']!, m['en']!, m['hi']!),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _showDetailSheet(String title, String en, String hi) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context))
              ],
            ),
            const SizedBox(height: 8),
            Text(en, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(12),
              child: Text(hi,
                  style: const TextStyle(
                      fontSize: 13, fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text('Got it'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildArticlesSection() {
    const all = PsychStudyArticles.articles;
    final filtered = _articleQuery.trim().isEmpty
        ? all
        : all.where((a) {
            final q = _articleQuery.toLowerCase();
            return a['title']!.toLowerCase().contains(q) ||
                a['summary']!.toLowerCase().contains(q) ||
                a['body']!.toLowerCase().contains(q);
          }).toList();
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search articles (title, summary, body)',
            filled: true,
            fillColor: Colors.teal.withValues(alpha: 0.05),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          ),
          onChanged: (v) => setState(() => _articleQuery = v),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          const Text('No matches',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
        ...filtered.map((a) => Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: Text(a['title']!,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(a['summary']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12)),
                onTap: () => _showArticle(a),
              ),
            ))
      ],
    );
  }

  void _showArticle(Map<String, String> a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        initialChildSize: 0.75,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            controller: scroll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(a['title']!,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx))
                  ],
                ),
                Text(a['author']!,
                    style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.teal)),
                const SizedBox(height: 12),
                Text(a['body']!,
                    style: const TextStyle(fontSize: 14, height: 1.35)),
                const SizedBox(height: 20),
                _articleTechniquesSection(a),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Close'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleShareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_box_outlined),
              label: const Text('Create & Tokenize Article'),
              onPressed: _promptCreateArticle,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Redeem Article Token'),
              onPressed: _promptRedeemArticleToken,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.playlist_add),
              label: const Text('Batch Redeem'),
              onPressed: _promptBatchRedeem,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_sync),
              label: const Text('Inject Insights'),
              onPressed: () async {
                final stats = await ArticleShareService.instance.stats();
                final orchestrator = AIOrchestratorService();
                if (orchestrator.isStarted) {
                  final existing = Map<String, String>.from(
                      orchestrator.featureInsights.value);
                  existing['articles'] =
                      'Articles: ${stats['total']} (Fav ${stats['favorites']})';
                  orchestrator.featureInsights.value = existing;
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Article stats injected into insights')));
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Orchestrator not started yet')));
                  }
                }
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.library_add),
              label: const Text('Migrate Static'),
              onPressed: () async {
                await ArticleShareService.instance
                    .migrateStaticArticlesIfNeeded();
                if (mounted) setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Static articles migrated (if any).')));
                }
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.system_update_alt),
              label: const Text('Sync Versions'),
              onPressed: () async {
                await ArticleShareService.instance.syncStaticArticleVersions();
                if (mounted) setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Static article versions synced.')));
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildInsightTimestamp(),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _importedSearch.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _importedSearch = ''))
                : null,
            hintText: 'Search imported articles',
            filled: true,
            fillColor: Colors.teal.withValues(alpha: 0.05),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          ),
          onChanged: (v) => setState(() => _importedSearch = v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Switch(
                    value: _sortFavoritesFirst,
                    onChanged: (v) => setState(() => _sortFavoritesFirst = v),
                  ),
                  const Flexible(
                      child: Text('Fav first', style: TextStyle(fontSize: 11)))
                ],
              ),
            ),
          ],
        ),
        FutureBuilder(
          future: _importedSearch.isEmpty
              ? ArticleShareService.instance.listArticles()
              : ArticleShareService.instance.searchArticles(_importedSearch),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(minHeight: 3));
            }
            var list = snap.data ?? [];
            if (_sortFavoritesFirst) {
              list.sort((a, b) {
                if (a.favorite == b.favorite) {
                  return b.createdAt.compareTo(a.createdAt);
                }
                return a.favorite ? -1 : 1;
              });
            }
            if (list.isEmpty) {
              return const Text('No matching imported articles.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic));
            }
            return Column(
              children: list
                  .map((a) => ListTile(
                        leading: Icon(
                            a.favorite ? Icons.star : Icons.star_border,
                            color: a.favorite ? Colors.amber : null),
                        title: Text(a.title,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${a.author}  •  ${a.sourceEmail}',
                                style: const TextStyle(fontSize: 11)),
                            if (a.tags.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: -6,
                                  children: a.tags
                                      .take(6)
                                      .map((t) => Chip(
                                          label: Text(t,
                                              style: const TextStyle(
                                                  fontSize: 10)),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap))
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                              a.favorite
                                  ? Icons.bookmark_remove
                                  : Icons.bookmark_add_outlined,
                              size: 20),
                          onPressed: () async {
                            await ArticleShareService.instance
                                .toggleFavorite(a.id);
                            if (mounted) setState(() {});
                          },
                        ),
                        onTap: () => _showImportedArticle(a),
                        onLongPress: () => _showArticleActions(a),
                      ))
                  .toList(),
            );
          },
        )
      ],
    );
  }

  void _promptRedeemArticleToken() {
    final ctrl = TextEditingController();
    final navigator = Navigator.of(context); // capture early
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Redeem Token'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Enter 7-char token'),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final token = ctrl.text.trim().toUpperCase();
              if (token.length < 5) return; // basic sanity
              final article = await ArticleShareService.instance.redeem(token);
              if (!mounted) return;
              if (article == null) {
                messenger.showSnackBar(
                    const SnackBar(content: Text('Invalid or used token')));
              } else {
                messenger.showSnackBar(
                    SnackBar(content: Text('Imported: ${article.title}')));
                setState(() {});
              }
              navigator.pop();
            },
            child: const Text('Import'),
          )
        ],
      ),
    );
  }

  void _promptBatchRedeem() {
    final ctrl = TextEditingController();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batch Redeem Tokens'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
              hintText: 'Enter tokens separated by space or newline'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final raw = ctrl.text.trim();
              if (raw.isEmpty) return;
              final parts = raw
                  .split(RegExp(r'[\s,]+'))
                  .where((e) => e.isNotEmpty)
                  .toList();
              final imported =
                  await ArticleShareService.instance.batchRedeem(parts);
              if (!mounted) return;
              navigator.pop();
              setState(() {});
              messenger.showSnackBar(SnackBar(
                  content: Text(
                      'Imported ${imported.length} / ${parts.length} tokens')));
            },
            child: const Text('Import All'),
          )
        ],
      ),
    );
  }

  Future<void> _promptCreateArticle() async {
    // Capture context-dependent objects BEFORE any await to satisfy analyzer.
    final capturedNavigator = Navigator.of(context);
    final capturedMessenger = ScaffoldMessenger.of(context);
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController(text: 'Anonymous');
    final emailCtrl = TextEditingController(text: 'surendragrover@gmail.com');
    final bodyCtrl = TextEditingController();
    final bodyHiCtrl = TextEditingController();
    // Open settings box after UI builds using a microtask to avoid async gap lints.
    Box<dynamic>? settingsBox;
    bool autoHindi = false;
    Future<void> loadPrefs(StateSetter setM) async {
      settingsBox = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      autoHindi = settingsBox!
          .get('auto_hindi_translate_articles', defaultValue: false) as bool;
      if (mounted) setM(() {});
    }

    bool translating = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => Padding(
        // Use MediaQuery from the bottom sheet's own context later via LayoutBuilder
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
        child: StatefulBuilder(
          builder: (ctx, setM) {
            if (settingsBox == null) {
              loadPrefs(setM);
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Expanded(
                        child: Text('New Article',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop())
                  ]),
                  TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title')),
                  TextField(
                      controller: authorCtrl,
                      decoration: const InputDecoration(labelText: 'Author')),
                  TextField(
                      controller: emailCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Source Email')),
                  const SizedBox(height: 8),
                  TextField(
                      controller: bodyCtrl,
                      maxLines: 6,
                      decoration: const InputDecoration(
                          labelText: 'Body / Content (English)')),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: TextField(
                              controller: bodyHiCtrl,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                  labelText: 'Body (Hindi Optional / Auto)'))),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          Switch(
                            value: autoHindi,
                            onChanged: (v) async {
                              setM(() => autoHindi = v);
                              if (settingsBox != null) {
                                settingsBox!
                                    .put('auto_hindi_translate_articles', v);
                              }
                              if (v) {
                                // attempt immediate translation if Hindi empty
                                if (bodyHiCtrl.text.trim().isEmpty &&
                                    bodyCtrl.text.trim().isNotEmpty) {
                                  setM(() => translating = true);
                                  final t = await OfflineArticleAutoTranslator
                                      .englishToHindi(bodyCtrl.text.trim());
                                  if (t != null) bodyHiCtrl.text = t;
                                  if (ctx.mounted) {
                                    setM(() => translating = false);
                                  }
                                }
                              }
                            },
                          ),
                          const Text('Auto HI', style: TextStyle(fontSize: 10))
                        ],
                      )
                    ],
                  ),
                  if (translating)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: LinearProgressIndicator(minHeight: 3),
                    ),
                  if (autoHindi)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                          'Offline dictionary translation – may be partial.',
                          style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.teal.shade700)),
                    ),
                  const SizedBox(height: 6),
                  if (autoHindi)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        icon: const Icon(Icons.translate, size: 16),
                        label: const Text('Re-Translate',
                            style: TextStyle(fontSize: 12)),
                        onPressed: () async {
                          if (bodyCtrl.text.trim().isEmpty) return;
                          setM(() => translating = true);
                          final t =
                              await OfflineArticleAutoTranslator.englishToHindi(
                                  bodyCtrl.text.trim());
                          if (t != null) bodyHiCtrl.text = t;
                          if (ctx.mounted) setM(() => translating = false);
                        },
                      ),
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.token),
                      label: const Text('Generate Token'),
                      onPressed: () async {
                        final navigator =
                            capturedNavigator; // pre-captured before await
                        final messenger = capturedMessenger;
                        if (titleCtrl.text.trim().isEmpty ||
                            bodyCtrl.text.trim().length < 10) {
                          if (!mounted) return;
                          messenger.showSnackBar(const SnackBar(
                              content: Text('Title & longer body required')));
                          return;
                        }
                        // If autoHindi on and no manual Hindi provided, attempt translation once more.
                        if (autoHindi && bodyHiCtrl.text.trim().isEmpty) {
                          setM(() => translating = true);
                          final t =
                              await OfflineArticleAutoTranslator.englishToHindi(
                                  bodyCtrl.text.trim());
                          if (t != null) bodyHiCtrl.text = t;
                          if (ctx.mounted) setM(() => translating = false);
                        }
                        final token = await ArticleShareService.instance
                            .createArticleToken(
                          title: titleCtrl.text.trim(),
                          author: authorCtrl.text.trim(),
                          body: bodyCtrl.text.trim(),
                          sourceEmail: emailCtrl.text.trim(),
                          bodyHi: bodyHiCtrl.text.trim().isEmpty
                              ? null
                              : bodyHiCtrl.text.trim(),
                        );
                        if (!mounted) return;
                        navigator.pop();
                        _showTokenDisplay(token, titleCtrl.text.trim());
                      },
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showTokenDisplay(String token, String title) {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Article Token Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: $title', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 4),
            SelectableText('Token: $token',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 8),
            const Text(
                'Share this token manually (email / message). Recipient can redeem locally. ',
                style: TextStyle(fontSize: 11)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: token));
              navigator.pop();
              messenger.showSnackBar(
                  const SnackBar(content: Text('Token copied to clipboard')));
            },
            child: const Text('Copy'),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _showImportedArticle(SharedArticle a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
            controller: scroll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(a.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))),
                    IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx))
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: Text('Source: ${a.sourceEmail}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.teal))),
                    TextButton(
                      onPressed: () async {
                        setState(() => _showHindiArticle = !_showHindiArticle);
                        final prefs = await Hive.openBox('truecircle_settings');
                        prefs.put('articles_show_hindi', _showHindiArticle);
                      },
                      child: Text(_showHindiArticle ? 'EN' : 'HI',
                          style: const TextStyle(fontSize: 12)),
                    ),
                    IconButton(
                      tooltip: 'Export',
                      icon: const Icon(Icons.upload_file, size: 20),
                      onPressed: () {
                        final serialized = ArticleShareService.instance
                            .serializeForExport(a,
                                includeHindi: _showHindiArticle);
                        Clipboard.setData(ClipboardData(text: serialized));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Article copied for export')));
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(_showHindiArticle ? (a.bodyHi ?? a.body) : a.body,
                    style: const TextStyle(fontSize: 14, height: 1.35)),
                const SizedBox(height: 18),
                _articleTechniquesSection(
                    {'title': a.title, 'en': a.body, 'hi': a.bodyHi ?? a.body}),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _articleTechniquesSection(Map<String, String> article) {
    // Simple heuristic: always show a small curated list; could extend with keyword scanning.
    final cognitive = CBTEducationContent.cognitiveTechniques.take(2).toList();
    final behavioral =
        CBTEducationContent.behavioralTechniques.take(2).toList();
    final combined = [...cognitive, ...behavioral];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Related CBT Techniques',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: combined
              .map((t) => FilterChip(
                    label:
                        Text(t['title']!, style: const TextStyle(fontSize: 11)),
                    selected: false,
                    onSelected: (_) =>
                        _showDetailSheet(t['title']!, t['en']!, t['hi']!),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInsightTimestamp() {
    final ts = ArticleShareService.instance.lastInsightsUpdatedAt;
    if (ts == null) return const SizedBox.shrink();
    return Text('Insights updated: ${ts.toLocal().toIso8601String()}',
        style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic));
  }

  void _showArticleActions(SharedArticle a) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Article'),
              onTap: () async {
                Navigator.pop(context);
                final backup = a; // shallow reference
                await ArticleShareService.instance.deleteArticle(a.id);
                if (mounted) setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Article deleted'),
                      action: SnackBarAction(
                          label: 'UNDO',
                          onPressed: () async {
                            // Recreate from backup snapshot
                            final box = await Hive.openBox<SharedArticle>(
                                'shared_articles');
                            await box.put(backup.id, backup);
                            if (mounted) setState(() {});
                          }),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive (Remove)'),
              onTap: () async {
                Navigator.pop(context);
                await ArticleShareService.instance.archiveArticle(a.id);
                if (mounted) setState(() {});
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Article archived')));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

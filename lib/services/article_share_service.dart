import 'dart:math';
import 'package:hive/hive.dart';
import '../models/cbt_models.dart';
import 'ai_orchestrator_service.dart';
import 'psych_study_articles.dart';

/// Offline P2P style Article Share Service
/// Concept: An originating device (e.g. surendragrover@gmail.com context) drafts an article
/// and produces a short token. Recipient types token locally (similar to gift sharing) and
/// the body gets stored as a SharedArticle inside Hive. No network / email fetch performed here;
/// email act is external manual step; this service just standardizes token + local storage.
class ArticleShareService {
  static const _boxTokens = 'article_share_tokens';
  static const _boxArticles = 'shared_articles';
  static ArticleShareService? _instance;
  static ArticleShareService get instance =>
      _instance ??= ArticleShareService._();
  ArticleShareService._();

  DateTime? lastInsightsUpdatedAt;

  Future<Box> _openTokens() async => Hive.openBox(_boxTokens);
  Future<Box<SharedArticle>> _openArticles() async =>
      Hive.openBox<SharedArticle>(_boxArticles);

  String _generateToken() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(7, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Create a token referencing an article draft. Stores the draft in token box until redeemed.
  Future<String> createArticleToken({
    required String title,
    required String author,
    required String body,
    required String sourceEmail,
    String? bodyHi,
  }) async {
    final box = await _openTokens();
    String token;
    do {
      token = _generateToken();
    } while (box.containsKey(token));
    await box.put(token, {
      'title': title,
      'author': author,
      'body': body,
      if (bodyHi != null) 'bodyHi': bodyHi,
      'createdAt': DateTime.now().toIso8601String(),
      'sourceEmail': sourceEmail,
      'tags': _extractTags('$title\n$body'),
    });
    return token;
  }

  /// Redeem a token: moves article into persistent SharedArticle Hive box and removes token entry.
  Future<SharedArticle?> redeem(String token) async {
    final tBox = await _openTokens();
    if (!tBox.containsKey(token)) return null;
    final map = Map<String, dynamic>.from(tBox.get(token));
    final aBox = await _openArticles();
    final article = SharedArticle(
      id: token,
      title: map['title'] as String,
      author: map['author'] as String,
      body: map['body'] as String,
      createdAt:
          DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now(),
      imported: true,
      sourceEmail: map['sourceEmail'] as String? ?? 'unknown',
      bodyHi: map['bodyHi'] as String?,
      tags: (map['tags'] as List?)?.cast<String>(),
    );
    await aBox.put(article.id, article);
    await tBox.delete(token);
    _maybeUpdateInsights();
    return article;
  }

  /// List locally imported shared articles.
  Future<List<SharedArticle>> listArticles() async {
    final aBox = await _openArticles();
    return aBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> toggleFavorite(String id) async {
    final aBox = await _openArticles();
    final art = aBox.get(id);
    if (art != null) {
      art.favorite = !art.favorite;
      await art.save();
    }
  }

  Future<List<SharedArticle>> searchArticles(String query) async {
    final q = query.toLowerCase();
    final list = await listArticles();
    return list
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.body.toLowerCase().contains(q) ||
            a.author.toLowerCase().contains(q))
        .toList();
  }

  Future<SharedArticle?> getArticle(String id) async {
    final aBox = await _openArticles();
    return aBox.get(id);
  }

  Future<List<SharedArticle>> batchRedeem(List<String> tokens) async {
    final imported = <SharedArticle>[];
    for (final t in tokens) {
      final a = await redeem(t.trim());
      if (a != null) imported.add(a);
    }
    _maybeUpdateInsights();
    return imported;
  }

  Future<Map<String, int>> stats() async {
    final list = await listArticles();
    final fav = list.where((a) => a.favorite).length;
    return {
      'total': list.length,
      'favorites': fav,
    };
  }

  List<String> _extractTags(String content) {
    final lower = content.toLowerCase();
    final candidates = <String>[
      'cognition',
      'brain',
      'memory',
      'learning',
      'anxiety',
      'depression',
      'behavior',
      'ethics',
      'methodology',
      'statistics',
      'design',
      'culture',
      'research',
      'validity',
      'reliability'
    ];
    final found = <String>{};
    for (final c in candidates) {
      if (lower.contains(c)) found.add(c);
    }
    return found.take(6).toList();
  }

  /// Export article content joined as plain text for saving externally.
  String serializeForExport(SharedArticle a, {bool includeHindi = false}) {
    final buffer = StringBuffer()
      ..writeln(a.title)
      ..writeln('Author: ${a.author}')
      ..writeln('Source: ${a.sourceEmail}')
      ..writeln('Created: ${a.createdAt.toIso8601String()}')
      ..writeln('\n--- EN ---\n')
      ..writeln(a.body);
    if (includeHindi && (a.bodyHi?.isNotEmpty ?? false)) {
      buffer
        ..writeln('\n--- HI ---\n')
        ..writeln(a.bodyHi);
    }
    return buffer.toString();
  }

  /// Migrate static bundled articles (from PsychStudyArticles) into Hive so they behave like imported ones.
  /// Idempotent: skips if already present.
  Future<void> migrateStaticArticlesIfNeeded() async {
    final box = await _openArticles();
    bool added = false;
    for (final raw in PsychStudyArticles.articles) {
      final id = raw['id']!;
      if (box.containsKey(id)) continue; // already migrated
      final body = raw['body'] ?? '';
      final bodyHi = raw['body_hi'] ?? raw['bodyHi'];
      final article = SharedArticle(
        id: id,
        title: raw['title'] ?? 'Untitled',
        author: raw['author'] ?? 'Unknown',
        body: body,
        bodyHi: bodyHi?.isNotEmpty == true ? bodyHi : null,
        createdAt: DateTime.now(),
        imported: true,
        sourceEmail: 'static@truecircle',
        tags: _extractTags('${raw['title']}\n$body'),
      );
      await box.put(id, article);
      added = true;
    }
    if (added) {
      _maybeUpdateInsights();
    }
  }

  Future<void> _maybeUpdateInsights() async {
    final orchestrator = AIOrchestratorService();
    if (!orchestrator.isStarted) return;
    try {
      final stat = await stats();
      final map = Map<String, String>.from(orchestrator.featureInsights.value);
      map['articles'] = 'Articles: ${stat['total']} (Fav ${stat['favorites']})';
      orchestrator.featureInsights.value = map;
      lastInsightsUpdatedAt = DateTime.now();
    } catch (_) {}
  }

  Future<void> deleteArticle(String id) async {
    final box = await _openArticles();
    if (box.containsKey(id)) {
      await box.delete(id);
      _maybeUpdateInsights();
    }
  }

  Future<void> archiveArticle(String id) async {
    // Simple: prefix id or add tag 'archived' -> create minimal metadata; for now just remove.
    await deleteArticle(id);
  }

  Future<void> syncStaticArticleVersions() async {
    final box = await _openArticles();
    bool changed = false;
    for (final raw in PsychStudyArticles.articles) {
      final id = raw['id']!;
      final newVersion = raw['version'] ?? '1';
      final existing = box.get(id);
      final versionKey = 'static_version_$id';
      final metaBox = await Hive.openBox('article_meta');
      final storedVersion =
          metaBox.get(versionKey, defaultValue: '0') as String;
      if (existing == null || storedVersion != newVersion) {
        final body = raw['body'] ?? '';
        final bodyHi = raw['body_hi'] ?? raw['bodyHi'];
        final article = SharedArticle(
          id: id,
          title: raw['title'] ?? 'Untitled',
          author: raw['author'] ?? 'Unknown',
          body: body,
          bodyHi: bodyHi?.isNotEmpty == true ? bodyHi : null,
          createdAt: DateTime.now(),
          imported: true,
          sourceEmail: 'static@truecircle',
          tags: _extractTags('${raw['title']}\n$body'),
        );
        await box.put(id, article);
        await metaBox.put(versionKey, newVersion);
        changed = true;
      }
    }
    if (changed) {
      _maybeUpdateInsights();
    }
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';

/// Lightweight offline dictionary-based translator (EN <-> HI) for short CBT / article text.
/// Not a full grammar-aware model: performs token replacement and leaves unknown words intact.
/// Strategy:
/// 1. Load a small JSON map (lowercase english -> hindi) from assets.
/// 2. For Hindi->English, build reverse map in memory.
/// 3. Tokenize by splitting on whitespace + punctuation boundaries.
/// 4. Replace tokens case-insensitively; preserve original capitalization pattern (Title, UPPER, lower).
/// 5. Reconstruct string keeping original separators.
class OfflineDictionaryTranslator {
  OfflineDictionaryTranslator._();
  static final OfflineDictionaryTranslator instance = OfflineDictionaryTranslator._();

  bool _loaded = false;
  Map<String,String> _enHi = {};
  Map<String,String> _hiEn = {};

  bool get isReady => _loaded;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final raw = await rootBundle.loadString('assets/translation/mini_en_hi.json');
      final Map<String,dynamic> data = json.decode(raw);
      _enHi = data.map((k,v)=> MapEntry(k.toLowerCase().trim(), (v as String).trim()));
      _hiEn = { for (final e in _enHi.entries) e.value: e.key };
      _loaded = true;
    } catch (e) {
      // Fallback: mark as loaded with empty maps (graceful degradation)
      _loaded = true;
    }
  }

  /// Translate a (possibly multi‑sentence) text heuristically. If direction cannot be inferred,
  /// returns original. This is intentionally conservative.
  Future<String> translate(String text, {String? from, String? to}) async {
    if (text.trim().isEmpty) return text;
    await ensureLoaded();
    final detected = from ?? _detect(text);
    final target = to ?? (detected == 'en' ? 'hi' : 'en');
    if (detected == target) return text; // nothing to do

    final map = detected == 'en' && target == 'hi' ? _enHi : _hiEn;
    if (map.isEmpty) return text;

  final buffer = StringBuffer();
  // Tokenize while preserving whitespace & punctuation
  final tokens = _splitPreserve(text);
    for (final t in tokens) {
      if (t.isEmpty) continue;
      if (_isWord(t)) {
        final lower = t.toLowerCase();
        final repl = map[lower];
        if (repl != null) {
          buffer.write(_matchCasing(t, repl));
        } else {
          buffer.write(t); // unknown word unchanged
        }
      } else {
        buffer.write(t); // punctuation / whitespace
      }
    }
    return buffer.toString();
  }

  String _detect(String text) {
    final hindi = RegExp(r'[\u0900-\u097F]');
    return hindi.hasMatch(text) ? 'hi' : 'en';
  }

  bool _isWord(String s) {
    return RegExp(r"^[A-Za-z\u0900-\u097F']+").hasMatch(s);
  }

  List<String> _splitPreserve(String input) {
    final result = <String>[];
    final pattern = RegExp(r"([A-Za-z\u0900-\u097F']+)|([^A-Za-z\u0900-\u097F']+)");
    for (final m in pattern.allMatches(input)) {
      result.add(m.group(0)!);
    }
    return result;
  }

  String _matchCasing(String original, String repl) {
    if (original.toUpperCase() == original) {
      return repl.toUpperCase();
    }
    if (original.length > 1 && original[0].toUpperCase() == original[0] && original.substring(1).toLowerCase() == original.substring(1)) {
      // Title case
      // For Hindi this concept is moot; just return repl as-is.
      return repl;
    }
    return repl;
  }
}

/// Convenience facade used by article creation to opportunistically populate Hindi body.
class OfflineArticleAutoTranslator {
  static Future<String?> englishToHindi(String englishBody) async {
    if (englishBody.trim().isEmpty) return null;
    final translated = await OfflineDictionaryTranslator.instance.translate(englishBody, from: 'en', to: 'hi');
    // If translation ends up identical (no replacements), treat as null to avoid misleading copy.
    if (_normalized(englishBody) == _normalized(translated)) return null;
    return translated;
  }

  static String _normalized(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DrIrisSuggestionsService {
  DrIrisSuggestionsService._();
  static final instance = DrIrisSuggestionsService._();

  List<String>? _cache;

  Future<List<String>> getSuggestions() async {
    if (_cache != null) return _cache!;
    try {
      final raw = await rootBundle.loadString(
        'assets/ai/dr_iris_suggestions.json',
      );
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final list = (decoded['questions'] as List?)?.cast<String>() ?? const [];
      _cache = List<String>.unmodifiable(list);
      return _cache!;
    } catch (_) {
      return const [];
    }
  }
}

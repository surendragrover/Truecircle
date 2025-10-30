import 'package:flutter/material.dart';
import '../services/json_data_service.dart';
import '../services/festival_data_service.dart';
import '../core/service_locator.dart';
import '../core/truecircle_app_bar.dart';

class FestivalsPage extends StatelessWidget {
  const FestivalsPage({super.key});

  // Helper method to check if string contains non-Latin scripts (Hindi, Arabic, Chinese, etc.)
  bool _containsNonLatinScript(String text) {
    // Check for common non-Latin script ranges
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      // Devanagari (Hindi): 0x0900-0x097F
      // Arabic: 0x0600-0x06FF
      // Chinese: 0x4E00-0x9FFF
      // Korean: 0xAC00-0xD7AF
      // Japanese Hiragana/Katakana: 0x3040-0x30FF
      if ((codeUnit >= 0x0900 && codeUnit <= 0x097F) || // Hindi
          (codeUnit >= 0x0600 && codeUnit <= 0x06FF) || // Arabic
          (codeUnit >= 0x4E00 && codeUnit <= 0x9FFF) || // Chinese
          (codeUnit >= 0xAC00 && codeUnit <= 0xD7AF) || // Korean
          (codeUnit >= 0x3040 && codeUnit <= 0x30FF)) {
        // Japanese
        return true;
      }
    }
    return false;
  }

  // Load festivals from both old and new services
  Future<List<Map<String, dynamic>>> _loadAllFestivals() async {
    try {
      final festivalService = ServiceLocator.instance
          .get<FestivalDataService>();

      // Get random festivals from different categories
      final List<Map<String, dynamic>> allFestivals = [];

      // Add some global festivals
      final categories = await festivalService.getFestivalCategories();
      for (final category in categories.take(3)) {
        final categoryFestivals = await festivalService.getFestivalsByCategory(
          category,
        );
        allFestivals.addAll(categoryFestivals.take(2));
      }

      // Add some unique festivals
      final uniqueFestivals = await festivalService.getUniqueFestivals();
      final uniqueFood =
          uniqueFestivals['uniqueAndMinorFestivals']?['FoodFestivals']
              as List? ??
          [];
      allFestivals.addAll(uniqueFood.whereType<Map<String, dynamic>>().take(2));

      return allFestivals;
    } catch (e) {
      // Fallback to old service
      final oldFestivals = await JsonDataService.instance.getFestivalsList();
      return oldFestivals.map((f) => Map<String, dynamic>.from(f)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'Global Festivals'),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadAllFestivals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const _EmptyMsg();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final name = e['name']?.toString() ?? 'Festival';

              // Extract month information
              String month = '';
              if (e['monthsObserved'] is List) {
                final monthsList = e['monthsObserved'] as List;
                month = monthsList.map((m) => m.toString()).join(', ');
              } else {
                month = e['month']?.toString() ?? '';
              }

              final type =
                  e['type']?.toString() ?? e['category']?.toString() ?? '';

              // Extract countries (English names only)
              String countries = '';
              if (e['countries'] is List) {
                final countryList = e['countries'] as List;
                countries = countryList.map((c) => c.toString()).join(', ');
              } else {
                countries = e['country']?.toString() ?? '';
              }

              final description = e['description']?.toString() ?? '';
              // Extract English-only greetings
              String greetings = '';
              if (e['greetingMessages'] is Map) {
                final greetingMap = e['greetingMessages'] as Map;
                // Try to get casual English greeting first, then formal
                greetings =
                    greetingMap['casual']?.toString() ??
                    greetingMap['formal']?.toString() ??
                    '';
              } else if (e['greetings'] is List) {
                final greetingList = e['greetings'] as List;
                // Find English greeting (first non-Hindi/non-local script entry)
                for (final greeting in greetingList) {
                  final greetingStr = greeting.toString();
                  // Skip if contains Hindi/Devanagari script or local scripts
                  if (!_containsNonLatinScript(greetingStr)) {
                    greetings = greetingStr;
                    break;
                  }
                }
                // Fallback to first if no Latin script found
                if (greetings.isEmpty && greetingList.isNotEmpty) {
                  greetings = greetingList.first.toString();
                }
              }

              // Clean up greetings - keep only English text, remove excessive emojis
              if (greetings.isNotEmpty) {
                // If still contains non-Latin script, extract English part
                if (_containsNonLatinScript(greetings)) {
                  // Try to extract English parts from mixed text
                  final words = greetings.split(' ');
                  final englishWords = words
                      .where((word) => !_containsNonLatinScript(word))
                      .toList();
                  if (englishWords.isNotEmpty) {
                    greetings = englishWords.join(' ');
                  }
                }
              }
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.celebration_outlined,
                    color: Colors.orange,
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (month.isNotEmpty) Text('📅 $month'),
                      if (type.isNotEmpty) Text('🎭 $type'),
                      if (countries.isNotEmpty) Text('🌍 $countries'),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (greetings.isNotEmpty)
                        Text(
                          '💬 $greetings',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyMsg extends StatelessWidget {
  const _EmptyMsg();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Global Festivals Database',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading 850+ festivals from 190+ countries...\nCelebrating cultures worldwide! 🌍',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

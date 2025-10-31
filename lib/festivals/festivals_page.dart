import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/json_data_service.dart';
import '../services/festival_data_service.dart';
import '../services/geo_service.dart';
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

  // Map month names to month index (1-12)
  int? _monthToInt(String m) {
    final s = m.trim().toLowerCase();
    const names = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    final idx = names.indexOf(s);
    if (idx >= 0) return idx + 1;
    // Support short forms like Jan, Feb, etc.
    const short = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    final idx2 = short.indexOf(s.length >= 3 ? s.substring(0, 3) : s);
    if (idx2 >= 0) return idx2 + 1;
    // Numeric strings
    final n = int.tryParse(s);
    if (n != null && n >= 1 && n <= 12) return n;
    return null;
  }

  // Compute how soon (in months) the festival occurs from now (0 = this month, 1 = next month, etc.)
  int _nextMonthOffset(Map<String, dynamic> e) {
    final nowMonth = DateTime.now().month;
    // Prefer explicit monthsObserved list
    if (e['monthsObserved'] is List) {
      final months = (e['monthsObserved'] as List)
          .map((m) => m?.toString() ?? '')
          .map(_monthToInt)
          .whereType<int>()
          .toList();
      if (months.isNotEmpty) {
        final offsets = months.map((m) => (m - nowMonth + 12) % 12).toList();
        offsets.sort();
        return offsets.first;
      }
    }
    // Fallback to single month field
    final m = _monthToInt(e['month']?.toString() ?? '');
    if (m != null) return (m - nowMonth + 12) % 12;
    // Unknown timing -> send to end
    return 999;
  }

  // Extract message suggestions (greetings) in English or simple text
  List<String> _extractMessageSuggestions(Map<String, dynamic> e) {
    final suggestions = <String>[];
    // Structured greetings map
    if (e['greetingMessages'] is Map) {
      final gm = (e['greetingMessages'] as Map).cast<String, dynamic>();
      for (final key in gm.keys) {
        final v = gm[key]?.toString() ?? '';
        if (v.isNotEmpty && !_containsNonLatinScript(v)) suggestions.add(v);
      }
    }
    // Fallback list of greetings
    if (suggestions.isEmpty && e['greetings'] is List) {
      for (final g in (e['greetings'] as List)) {
        final s = g?.toString() ?? '';
        if (s.isNotEmpty && !_containsNonLatinScript(s)) suggestions.add(s);
        if (suggestions.length >= 5) break;
      }
    }
    // Final fallback simple template if still empty
    if (suggestions.isEmpty) {
      final name = e['name']?.toString() ?? 'the festival';
      suggestions.addAll([
        'Wishing you a joyful $name! May your day be filled with happiness.',
        'Happy $name! Sending you peace, love, and good health.',
        'Warm wishes on $name to you and your family!',
      ]);
    }
    // Deduplicate and cap
    final unique = <String>{};
    final result = <String>[];
    for (final s in suggestions) {
      if (unique.add(s)) result.add(s);
      if (result.length >= 5) break;
    }
    return result;
  }

  void _showMessageIdeas(BuildContext context, Map<String, dynamic> e) {
    final ideas = _extractMessageSuggestions(e);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Message ideas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...ideas.map(
                (msg) => Card(
                  child: ListTile(
                    title: Text(msg),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: msg));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Message copied!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      tooltip: 'Copy',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Load festivals from both old and new services
  Future<List<Map<String, dynamic>>> _loadAllFestivals() async {
    try {
      final festivalService = ServiceLocator.instance
          .get<FestivalDataService>();
      // Try to show festivals for detected user country first
      final detected = await GeoService.instance.getStoredCountry();
      if (detected != null && detected.isNotEmpty) {
        final countryFestivals = await festivalService.getFestivalsByCountry(
          detected,
        );
        if (countryFestivals.isNotEmpty) return countryFestivals;
      }

      // Fallback: Get some representative festivals across categories
      final List<Map<String, dynamic>> allFestivals = [];
      final categories = await festivalService.getFestivalCategories();
      for (final category in categories.take(4)) {
        final categoryFestivals = await festivalService.getFestivalsByCategory(
          category,
        );
        allFestivals.addAll(categoryFestivals.take(3));
      }

      // Also add some unique festivals as variety
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

  Future<String?> _getDetectedCountry() async {
    final c = await GeoService.instance.getStoredCountry();
    return c;
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
          // Sort by next occurrence so upcoming festivals appear first
          final sortedItems = [...items];
          sortedItems.sort(
            (a, b) => _nextMonthOffset(a).compareTo(_nextMonthOffset(b)),
          );
          if (items.isEmpty) {
            return const _EmptyMsg();
          }
          return Column(
            children: [
              // Header with detected country and category filter
              FutureBuilder<String?>(
                future: _getDetectedCountry(),
                builder: (context, csnap) {
                  final country = csnap.data;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            country != null
                                ? 'Festivals near you: $country'
                                : 'Global Festivals',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Show category selector (and allow exploring other countries)
                            final festivalService = ServiceLocator.instance
                                .get<FestivalDataService>();
                            final categories = await festivalService
                                .getFestivalCategories();
                            if (!context.mounted) return;
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) => _CategoryCountryExplorer(
                                categories: categories,
                              ),
                            );
                          },
                          child: const Text('Explore by category'),
                        ),
                      ],
                    ),
                  );
                },
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: sortedItems.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final e = sortedItems[i];
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
                        e['type']?.toString() ??
                        e['category']?.toString() ??
                        '';

                    // Extract countries (English names only)
                    String countries = '';
                    if (e['countries'] is List) {
                      final countryList = e['countries'] as List;
                      countries = countryList
                          .map((c) => c.toString())
                          .join(', ');
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
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => _showMessageIdeas(context, e),
                                icon: const Icon(
                                  Icons.tips_and_updates_outlined,
                                  size: 18,
                                ),
                                label: const Text('Message ideas'),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
            ],
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

/// Bottom-sheet helper: shows categories and allows exploring countries that
/// have festivals in that category. Selecting a country opens a country-specific
/// festivals page.
class _CategoryCountryExplorer extends StatelessWidget {
  final List<String> categories;
  const _CategoryCountryExplorer({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Choose a category to explore',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(
            height: 320,
            child: ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final cat = categories[i];
                return ListTile(
                  title: Text(cat),
                  onTap: () async {
                    // Find countries that have festivals in this category
                    final festivalService = ServiceLocator.instance
                        .get<FestivalDataService>();
                    final festivals = await festivalService
                        .getFestivalsByCategory(cat);
                    final countries = <String>{};
                    for (final f in festivals) {
                      if (f['countries'] is List) {
                        for (final c in (f['countries'] as List)) {
                          countries.add(c.toString());
                        }
                      } else if (f['country'] != null) {
                        countries.add(f['country'].toString());
                      }
                    }
                    if (!context.mounted) return;
                    // Show countries in another bottom sheet
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'Countries with $cat',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            SizedBox(
                              height: 320,
                              child: ListView.separated(
                                itemCount: countries.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (ctx, idx) {
                                  final country = countries.elementAt(idx);
                                  return ListTile(
                                    title: Text(country),
                                    onTap: () {
                                      Navigator.of(
                                        context,
                                      ).pop(); // close countries sheet
                                      Navigator.of(
                                        context,
                                      ).pop(); // close categories sheet
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => _CountryFestivalsPage(
                                            country: country,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryFestivalsPage extends StatelessWidget {
  final String country;
  const _CountryFestivalsPage({required this.country});

  Future<List<Map<String, dynamic>>> _load() async {
    final service = ServiceLocator.instance.get<FestivalDataService>();
    final list = await service.getFestivalsByCountry(country);
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Festivals in $country')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _load(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No festivals found'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = items[i];
              final name = e['name']?.toString() ?? 'Festival';
              final desc = e['description']?.toString() ?? '';
              return ListTile(
                leading: const Icon(
                  Icons.celebration_outlined,
                  color: Colors.orange,
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: desc.isNotEmpty
                    ? Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

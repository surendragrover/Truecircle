import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service for loading and managing global festival data
///
/// This service provides access to comprehensive festival databases covering
/// 190+ countries with 850+ festivals organized by categories and regions.
class FestivalDataService {
  static final FestivalDataService _instance = FestivalDataService._internal();
  factory FestivalDataService() => _instance;
  FestivalDataService._internal();

  // Cached festival data
  Map<String, dynamic>? _globalFestivals;
  Map<String, dynamic>? _regionalFestivals;
  Map<String, dynamic>? _uniqueFestivals;
  Map<String, dynamic>? _seasonalFestivals;
  Map<String, dynamic>? _databaseIndex;

  /// Load main global festivals database
  Future<Map<String, dynamic>> getGlobalFestivals() async {
    if (_globalFestivals != null) return _globalFestivals!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/festivals/Global_Festivals_Database.json',
      );
      _globalFestivals = json.decode(jsonString);
      return _globalFestivals!;
    } catch (e) {
      debugPrint('Error loading global festivals: $e');
      return {};
    }
  }

  /// Load regional festivals breakdown by continents
  Future<Map<String, dynamic>> getRegionalFestivals() async {
    if (_regionalFestivals != null) return _regionalFestivals!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/festivals/Regional_Festivals_Extended.json',
      );
      _regionalFestivals = json.decode(jsonString);
      return _regionalFestivals!;
    } catch (e) {
      debugPrint('Error loading regional festivals: $e');
      return {};
    }
  }

  /// Load unique and minor festivals collection
  Future<Map<String, dynamic>> getUniqueFestivals() async {
    if (_uniqueFestivals != null) return _uniqueFestivals!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/festivals/Unique_Minor_Festivals.json',
      );
      _uniqueFestivals = json.decode(jsonString);
      return _uniqueFestivals!;
    } catch (e) {
      debugPrint('Error loading unique festivals: $e');
      return {};
    }
  }

  /// Load seasonal and special occasion festivals
  Future<Map<String, dynamic>> getSeasonalFestivals() async {
    if (_seasonalFestivals != null) return _seasonalFestivals!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/festivals/Seasonal_Special_Festivals.json',
      );
      _seasonalFestivals = json.decode(jsonString);
      return _seasonalFestivals!;
    } catch (e) {
      debugPrint('Error loading seasonal festivals: $e');
      return {};
    }
  }

  /// Load database index and metadata
  Future<Map<String, dynamic>> getDatabaseIndex() async {
    if (_databaseIndex != null) return _databaseIndex!;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/festivals/Festival_Database_Index.json',
      );
      _databaseIndex = json.decode(jsonString);
      return _databaseIndex!;
    } catch (e) {
      debugPrint('Error loading database index: $e');
      return {};
    }
  }

  /// Search festivals by country
  Future<List<Map<String, dynamic>>> getFestivalsByCountry(
    String country,
  ) async {
    final List<Map<String, dynamic>> results = [];

    try {
      // Search in global festivals
      final global = await getGlobalFestivals();
      final categories =
          global['globalFestivals'] as Map<String, dynamic>? ?? {};

      for (final categoryData in categories.values) {
        if (categoryData is List) {
          for (final festival in categoryData) {
            if (festival is Map<String, dynamic>) {
              final countries = festival['countries'] as List? ?? [];
              if (countries.any(
                (c) =>
                    c.toString().toLowerCase().contains(country.toLowerCase()),
              )) {
                results.add(festival);
              }
            }
          }
        }
      }

      // Search in regional festivals
      final regional = await getRegionalFestivals();
      final continents =
          regional['continentWiseFestivals'] as Map<String, dynamic>? ?? {};

      for (final continentData in continents.values) {
        if (continentData is Map<String, dynamic>) {
          for (final regionData in continentData.values) {
            if (regionData is Map<String, dynamic>) {
              final countryFestivals = regionData[country] as List? ?? [];
              for (final festival in countryFestivals) {
                if (festival is Map<String, dynamic>) {
                  results.add(festival);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching festivals by country: $e');
    }

    return results;
  }

  /// Search festivals by month
  Future<List<Map<String, dynamic>>> getFestivalsByMonth(String month) async {
    final List<Map<String, dynamic>> results = [];

    try {
      // Search in seasonal festivals
      final seasonal = await getSeasonalFestivals();
      final monthlyData =
          seasonal['seasonalAndSpecialFestivals']?['MonthlySpecialOccasions']
              as Map<String, dynamic>? ??
          {};

      final monthFestivals = monthlyData[month] as List? ?? [];
      for (final festival in monthFestivals) {
        if (festival is Map<String, dynamic>) {
          results.add(festival);
        }
      }

      // Also search other databases for month matches
      final global = await getGlobalFestivals();
      final categories =
          global['globalFestivals'] as Map<String, dynamic>? ?? {};

      for (final categoryData in categories.values) {
        if (categoryData is List) {
          for (final festival in categoryData) {
            if (festival is Map<String, dynamic>) {
              final festivalMonth =
                  festival['month']?.toString().toLowerCase() ?? '';
              if (festivalMonth.contains(month.toLowerCase())) {
                results.add(festival);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error searching festivals by month: $e');
    }

    return results;
  }

  /// Get festival categories from global database
  Future<List<String>> getFestivalCategories() async {
    try {
      final global = await getGlobalFestivals();
      final categories =
          global['globalFestivals'] as Map<String, dynamic>? ?? {};
      return categories.keys.toList();
    } catch (e) {
      debugPrint('Error getting festival categories: $e');
      return [];
    }
  }

  /// Get festivals by category
  Future<List<Map<String, dynamic>>> getFestivalsByCategory(
    String category,
  ) async {
    try {
      final global = await getGlobalFestivals();
      final categories =
          global['globalFestivals'] as Map<String, dynamic>? ?? {};
      final categoryData = categories[category] as List? ?? [];

      return categoryData.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error getting festivals by category: $e');
      return [];
    }
  }

  /// Get random festival suggestion
  Future<Map<String, dynamic>?> getRandomFestival() async {
    try {
      final global = await getGlobalFestivals();
      final categories =
          global['globalFestivals'] as Map<String, dynamic>? ?? {};

      final allFestivals = <Map<String, dynamic>>[];
      for (final categoryData in categories.values) {
        if (categoryData is List) {
          for (final festival in categoryData) {
            if (festival is Map<String, dynamic>) {
              allFestivals.add(festival);
            }
          }
        }
      }

      if (allFestivals.isNotEmpty) {
        allFestivals.shuffle();
        return allFestivals.first;
      }
    } catch (e) {
      debugPrint('Error getting random festival: $e');
    }

    return null;
  }

  /// Get conversation starters for festivals
  Future<List<String>> getFestivalConversationStarters() async {
    try {
      final seasonal = await getSeasonalFestivals();
      final conversationData =
          seasonal['seasonalAndSpecialFestivals']?['ConversationStarters']
              as Map<String, dynamic>? ??
          {};

      final List<String> starters = [];
      for (final categoryQuestions in conversationData.values) {
        if (categoryQuestions is List) {
          starters.addAll(categoryQuestions.cast<String>());
        }
      }

      return starters;
    } catch (e) {
      debugPrint('Error getting conversation starters: $e');
      return [];
    }
  }

  /// Clear cached data (useful for refreshing)
  void clearCache() {
    _globalFestivals = null;
    _regionalFestivals = null;
    _uniqueFestivals = null;
    _seasonalFestivals = null;
    _databaseIndex = null;
  }
}

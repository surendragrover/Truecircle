import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

/// Festival Data Service using TrueCircle_Festivals_Data.json
/// Loads complete festival information from demo data
class FestivalDataService extends ChangeNotifier {
  static FestivalDataService? _instance;
  static FestivalDataService get instance =>
      _instance ??= FestivalDataService._();

  FestivalDataService._();

  Box? _festivalBox;
  List<Festival> _festivals = [];
  Map<String, dynamic> _metadata = {};
  bool _isInitialized = false;

  List<Festival> get festivals => _festivals;
  Map<String, dynamic> get metadata => _metadata;
  bool get isInitialized => _isInitialized;

  /// Initialize the festival service with JSON data
  Future<void> initialize() async {
    try {
      _festivalBox = await Hive.openBox('festivals_data');

      // Load from JSON file
      await _loadFestivalsFromJson();

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Festival service initialization failed: $e');
    }
  }

  /// Load festivals from TrueCircle_Festivals_Data.json
  Future<void> _loadFestivalsFromJson() async {
    try {
      final jsonString = await rootBundle
          .loadString('Demo_data/TrueCircle_Festivals_Data.json');
      final jsonData = json.decode(jsonString);

      _metadata = jsonData['metadata'] ?? {};

      final festivalsJson = jsonData['festivals'] as List;
      _festivals = festivalsJson
          .map((festivalJson) => Festival.fromJson(festivalJson))
          .toList();

      // Cache festivals
      await _cacheFestivals();

      debugPrint('🎉 Loaded ${_festivals.length} festivals from JSON data');
    } catch (e) {
      debugPrint('Failed to load festivals from JSON: $e');
      // Load cached data as fallback
      await _loadCachedFestivals();
    }
  }

  /// Cache festivals to local storage
  Future<void> _cacheFestivals() async {
    try {
      final festivalsMap = _festivals.map((f) => f.toJson()).toList();
      await _festivalBox?.put('cached_festivals', festivalsMap);
      await _festivalBox?.put('cached_metadata', _metadata);
    } catch (e) {
      debugPrint('Failed to cache festivals: $e');
    }
  }

  /// Load cached festivals
  Future<void> _loadCachedFestivals() async {
    try {
      final cachedFestivals = _festivalBox?.get('cached_festivals');
      final cachedMetadata = _festivalBox?.get('cached_metadata');

      if (cachedFestivals != null) {
        _festivals = (cachedFestivals as List)
            .map((festivalJson) => Festival.fromJson(festivalJson))
            .toList();
      }

      if (cachedMetadata != null) {
        _metadata = Map<String, dynamic>.from(cachedMetadata);
      }

      debugPrint('📦 Loaded ${_festivals.length} cached festivals');
    } catch (e) {
      debugPrint('Failed to load cached festivals: $e');
    }
  }

  /// Get festivals by month
  List<Festival> getFestivalsByMonth(String month) {
    return _festivals
        .where((festival) =>
            festival.month.toLowerCase().contains(month.toLowerCase()))
        .toList();
  }

  /// Get festivals by region
  List<Festival> getFestivalsByRegion(String region) {
    return _festivals
        .where((festival) => festival.regions
            .any((r) => r.toLowerCase().contains(region.toLowerCase())))
        .toList();
  }

  /// Get festivals by type (major/minor)
  List<Festival> getFestivalsByType(String type) {
    return _festivals
        .where((festival) => festival.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  /// Get upcoming festivals (mock data for demo)
  List<Festival> getUpcomingFestivals() {
    final currentMonth = DateTime.now().month;
    final monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // Get festivals for current and next 2 months
    final upcomingFestivals = <Festival>[];

    for (int i = 0; i < 3; i++) {
      final monthIndex = (currentMonth + i - 1) % 12 + 1;
      final monthName = monthNames[monthIndex];
      upcomingFestivals.addAll(getFestivalsByMonth(monthName));
    }

    return upcomingFestivals.take(5).toList();
  }

  /// Search festivals by name
  List<Festival> searchFestivals(String query) {
    if (query.isEmpty) return _festivals;

    return _festivals
        .where((festival) =>
            festival.name.toLowerCase().contains(query.toLowerCase()) ||
            festival.hindiName.toLowerCase().contains(query.toLowerCase()) ||
            festival.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get festival by ID
  Festival? getFestivalById(String id) {
    try {
      return _festivals.firstWhere((festival) => festival.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get major festivals
  List<Festival> getMajorFestivals() {
    return getFestivalsByType('major');
  }

  /// Get minor festivals
  List<Festival> getMinorFestivals() {
    return getFestivalsByType('minor');
  }

  /// Get cultural tips for a festival
  List<String> getCulturalTips(String festivalId) {
    final festival = getFestivalById(festivalId);
    return festival?.culturalTips ?? [];
  }

  /// Get conversation starters for a festival
  List<String> getConversationStarters(String festivalId) {
    final festival = getFestivalById(festivalId);
    return festival?.conversationStarters ?? [];
  }

  /// Get greeting messages for a festival
  Map<String, String> getGreetingMessages(String festivalId) {
    final festival = getFestivalById(festivalId);
    return festival?.greetingMessages ?? {};
  }

  /// Clear cached data
  Future<void> clearCache() async {
    await _festivalBox?.delete('cached_festivals');
    await _festivalBox?.delete('cached_metadata');
    _festivals.clear();
    _metadata.clear();
    notifyListeners();
  }

  /// Refresh data from JSON
  Future<void> refresh() async {
    await _loadFestivalsFromJson();
    notifyListeners();
  }
}

/// Festival model class
class Festival {
  final String id;
  final String name;
  final String hindiName;
  final String type;
  final List<String> regions;
  final String month;
  final String description;
  final Map<String, String> greetingMessages;
  final List<String> culturalTips;
  final List<String> conversationStarters;

  Festival({
    required this.id,
    required this.name,
    required this.hindiName,
    required this.type,
    required this.regions,
    required this.month,
    required this.description,
    required this.greetingMessages,
    required this.culturalTips,
    required this.conversationStarters,
  });

  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      hindiName: json['hindiName'] ?? '',
      type: json['type'] ?? 'minor',
      regions: List<String>.from(json['regions'] ?? []),
      month: json['month'] ?? '',
      description: json['description'] ?? '',
      greetingMessages:
          Map<String, String>.from(json['greetingMessages'] ?? {}),
      culturalTips: List<String>.from(json['culturalTips'] ?? []),
      conversationStarters:
          List<String>.from(json['conversationStarters'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hindiName': hindiName,
      'type': type,
      'regions': regions,
      'month': month,
      'description': description,
      'greetingMessages': greetingMessages,
      'culturalTips': culturalTips,
      'conversationStarters': conversationStarters,
    };
  }

  /// Get emoji for festival (basic mapping)
  String get emoji {
    switch (id.toLowerCase()) {
      case 'diwali':
        return '🪔';
      case 'holi':
        return '🌈';
      case 'navratri':
        return '💃';
      case 'ganesh_chaturthi':
        return '🐘';
      case 'janmashtami':
        return '🦚';
      case 'raksha_bandhan':
        return '🎀';
      case 'dussehra':
        return '🏹';
      case 'eid_ul_fitr':
        return '🌙';
      case 'christmas':
        return '🎄';
      case 'independence_day':
        return '🇮🇳';
      case 'republic_day':
        return '🇮🇳';
      case 'makar_sankranti':
        return '🪁';
      case 'maha_shivratri':
        return '🕉️';
      case 'ram_navami':
        return '🙏';
      case 'karva_chauth':
        return '🌙';
      case 'lohri':
        return '🔥';
      case 'pongal':
        return '🌾';
      case 'ugadi':
        return '🌸';
      case 'gudi_padwa':
        return '🎏';
      case 'vasant_panchami':
        return '📚';
      default:
        return '🎉';
    }
  }

  /// Get color for festival
  Color get color {
    switch (type.toLowerCase()) {
      case 'major':
        return Colors.orange;
      case 'minor':
        return Colors.blue;
      default:
        return Colors.purple;
    }
  }

  /// Get days remaining (mock calculation)
  int get daysRemaining {
    // Mock calculation based on month
    final monthMap = {
      'January': 120,
      'February': 150,
      'March': 180,
      'April': 210,
      'May': 240,
      'June': 270,
      'July': 300,
      'August': 30,
      'September': 60,
      'October': 45,
      'November': 15,
      'December': 85
    };

    return monthMap[month] ?? 90;
  }

  /// Get formatted date string
  String get formattedDate {
    switch (id) {
      case 'diwali':
        return 'Nov 12, 2025';
      case 'holi':
        return 'Mar 14, 2026';
      case 'navratri':
        return 'Oct 3, 2025';
      case 'ganesh_chaturthi':
        return 'Sep 7, 2025';
      case 'janmashtami':
        return 'Aug 26, 2025';
      case 'raksha_bandhan':
        return 'Aug 19, 2025';
      case 'independence_day':
        return 'Aug 15, 2025';
      case 'dussehra':
        return 'Oct 12, 2025';
      case 'eid_ul_fitr':
        return 'Variable';
      case 'christmas':
        return 'Dec 25, 2025';
      default:
        return month;
    }
  }

  /// Check if festival is today (mock)
  bool get isToday {
    return id == 'diwali'; // Mock for demo
  }

  /// Check if festival is upcoming (within 30 days)
  bool get isUpcoming {
    return daysRemaining <= 30;
  }
}

/// Festival category enumeration
enum FestivalCategory {
  major,
  minor,
  regional,
  religious,
  cultural,
}

/// Festival region enumeration
enum FestivalRegion {
  panIndia,
  northIndia,
  southIndia,
  eastIndia,
  westIndia,
  punjab,
  maharashtra,
  gujarat,
  tamilNadu,
  andhraPradesh,
  bengal,
  kerala,
}

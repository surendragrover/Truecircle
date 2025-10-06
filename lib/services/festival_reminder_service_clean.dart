import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/festival_reminder.dart';

/// Festival Reminder Service - Clean Implementation
class FestivalReminderService extends ChangeNotifier {
  static final FestivalReminderService _instance =
      FestivalReminderService._internal();
  factory FestivalReminderService() => _instance;
  FestivalReminderService._internal();

  static FestivalReminderService get instance => _instance;

  List<FestivalReminder> _activeReminders = [];
  Box<FestivalReminder>? _reminderBox;
  bool _isInitialized = false;

  List<FestivalReminder> get activeReminders => _activeReminders;

  /// Initialize the service
  Future<void> _initializeService() async {
    if (_isInitialized) return;

    try {
      _reminderBox = await Hive.openBox<FestivalReminder>('festival_reminders');
      _activeReminders = _reminderBox!.values.toList();
      _isInitialized = true;
      debugPrint('✅ Festival Reminder Service initialized');
    } catch (e) {
      debugPrint('❌ Festival Reminder Service initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Create a festival reminder
  Future<void> createReminder({
    required String festivalName,
    required String festivalNameHindi,
    required DateTime date,
    required String description,
  }) async {
    if (!_isInitialized) await _initializeService();

    final reminder = FestivalReminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      festivalName: festivalName,
      festivalNameHindi: festivalNameHindi,
      date: date,
      description: description,
      culturalSignificance:
          "Traditional Indian festival with deep cultural roots",
      traditions: [
        "Prayer",
        "Family gathering",
        "Traditional food",
        "Decorations"
      ],
      isEnabled: true,
      emoji: '🎊',
      region: 'All India',
      priority: 2,
    );

    _activeReminders.add(reminder);
    await _saveReminders();

    notifyListeners();
    debugPrint('✅ Festival reminder created for $festivalName');
  }

  /// Save reminders to Hive
  Future<void> _saveReminders() async {
    if (_reminderBox == null) return;

    try {
      await _reminderBox!.clear();
      for (final reminder in _activeReminders) {
        await _reminderBox!.add(reminder);
      }
    } catch (e) {
      debugPrint('❌ Failed to save reminders: $e');
    }
  }

  /// Get upcoming festivals (next 30 days)
  List<FestivalReminder> getUpcomingFestivals() {
    return _activeReminders.where((reminder) => reminder.isUpcoming).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get today's festivals
  List<FestivalReminder> getTodaysFestivals() {
    return _activeReminders.where((reminder) => reminder.isToday).toList();
  }

  /// Toggle reminder enabled/disabled
  Future<void> toggleReminder(String id) async {
    final index = _activeReminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _activeReminders[index] = _activeReminders[index].copyWith(
        isEnabled: !_activeReminders[index].isEnabled,
      );
      await _saveReminders();
      notifyListeners();
    }
  }

  /// Delete reminder
  Future<void> deleteReminder(String id) async {
    _activeReminders.removeWhere((r) => r.id == id);
    await _saveReminders();
    notifyListeners();
  }

  /// Load default festivals
  Future<void> loadDefaultFestivals() async {
    if (!_isInitialized) await _initializeService();

    final defaultFestivals = [
      {
        'name': 'Diwali',
        'nameHi': 'दीवाली',
        'date': DateTime(2025, 11, 1),
        'description':
            'Festival of lights celebrating the victory of light over darkness',
      },
      {
        'name': 'Holi',
        'nameHi': 'होली',
        'date': DateTime(2025, 3, 13),
        'description':
            'Festival of colors celebrating spring and new beginnings',
      },
      {
        'name': 'Eid ul-Fitr',
        'nameHi': 'ईद उल-फितर',
        'date': DateTime(2025, 4, 10),
        'description':
            'Festival of breaking the fast, celebrating the end of Ramadan',
      },
    ];

    for (final festival in defaultFestivals) {
      await createReminder(
        festivalName: festival['name'] as String,
        festivalNameHindi: festival['nameHi'] as String,
        date: festival['date'] as DateTime,
        description: festival['description'] as String,
      );
    }
  }
}

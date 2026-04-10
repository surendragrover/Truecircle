import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PrivacyNudgeService {
  static const String _visitCountKey = 'privacy_nudge_visit_count';
  static const String _lastShownAtKey = 'privacy_nudge_last_shown_at';
  static const String _lastSourceKey = 'privacy_nudge_last_source';
  static const int _showEveryNVisits = 3;
  static const Duration _cooldown = Duration(hours: 6);

  Future<void> maybeShow(BuildContext context, {required String source}) async {
    if (!Hive.isBoxOpen('appBox')) return;
    final Box<dynamic> appBox = Hive.box('appBox');
    final int currentCount =
        (appBox.get(_visitCountKey, defaultValue: 0) as int?) ?? 0;
    final int nextCount = currentCount + 1;
    await appBox.put(_visitCountKey, nextCount);

    final String lastShownIso =
        (appBox.get(_lastShownAtKey, defaultValue: '') as String?) ?? '';
    final DateTime? lastShownAt = DateTime.tryParse(lastShownIso);
    final DateTime now = DateTime.now();
    final bool passedCooldown =
        lastShownAt == null ? true : now.difference(lastShownAt) >= _cooldown;
    final bool isIntervalHit = nextCount % _showEveryNVisits == 0;

    if (!passedCooldown || !isIntervalHit || !context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Privacy Reminder'),
          content: const Text(
            'Your data stays under your control. This app uses local/offline storage, so no one can view it without your permission.',
          ),
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Got It'),
            ),
          ],
        );
      },
    );

    await appBox.put(_lastShownAtKey, now.toIso8601String());
    await appBox.put(_lastSourceKey, source);
  }
}

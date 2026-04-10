import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../services/reward_service.dart';
import '../../services/three_brain_relay_service.dart';
import '../../widgets/coin_reward_celebration.dart';

class SleepTrackerFormScreen extends StatefulWidget {
  const SleepTrackerFormScreen({super.key});

  @override
  State<SleepTrackerFormScreen> createState() => _SleepTrackerFormScreenState();
}

class _SleepTrackerFormScreenState extends State<SleepTrackerFormScreen> {
  final RewardService _rewardService = RewardService();
  final ThreeBrainRelayService _relay = ThreeBrainRelayService.instance;
  final TextEditingController _bedtimeController = TextEditingController();
  final TextEditingController _wakeTimeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  double _sleepHours = 7;
  double _sleepQuality = 3;
  int _nightAwakenings = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _bedtimeController.dispose();
    _wakeTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (_bedtimeController.text.trim().isEmpty ||
        _wakeTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter bedtime and wake-up time.')),
      );
      return;
    }

    setState(() {
      _submitting = true;
    });

    final Box<dynamic> userBox = Hive.box('userBox');
    final Map<String, dynamic> allEntries = Map<String, dynamic>.from(
      (userBox.get('form_entries', defaultValue: <String, dynamic>{}) as Map?) ??
          <String, dynamic>{},
    );
    final List<dynamic> sleepEntries = List<dynamic>.from(
      (allEntries['sleep_tracker'] as List?) ?? <dynamic>[],
    );
    final Map<String, dynamic> payload = <String, dynamic>{
      'submitted_at': DateTime.now().toIso8601String(),
      'bedtime': _bedtimeController.text.trim(),
      'wake_time': _wakeTimeController.text.trim(),
      'sleep_hours': _sleepHours.toStringAsFixed(1),
      'sleep_quality': _sleepQuality.round(),
      'night_awakenings': _nightAwakenings,
      'notes': _notesController.text.trim(),
    };
    sleepEntries.add(payload);
    allEntries['sleep_tracker'] = sleepEntries;
    await userBox.put('form_entries', allEntries);

    final RewardGrantResult reward =
        await _rewardService.grantEntryFormCoin(formId: 'sleep_tracker');

    final double moodProxy = (_sleepQuality).clamp(1, 5).toDouble();
    await _relay.addEntry(
      source: 'sleep_tracker',
      mood: moodProxy,
      note:
          'Sleep ${_sleepHours.toStringAsFixed(1)}h, quality ${_sleepQuality.round()}, wakeups $_nightAwakenings',
    );

    if (!mounted) return;
    if (reward.granted) {
      await CoinRewardCelebration.show(
        context,
        message: 'Coin Earned! +1 for sleep entry. Wallet: ${reward.balance}',
      );
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reward.granted ? 'Sleep entry saved' : reward.reason,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Tracker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Daily Sleep Entry',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bedtimeController,
            decoration: const InputDecoration(
              labelText: 'Bedtime',
              hintText: 'e.g. 11:15 PM',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _wakeTimeController,
            decoration: const InputDecoration(
              labelText: 'Wake-up Time',
              hintText: 'e.g. 6:30 AM',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Text('Sleep hours: ${_sleepHours.toStringAsFixed(1)}'),
          Slider(
            value: _sleepHours,
            min: 2,
            max: 12,
            divisions: 20,
            label: _sleepHours.toStringAsFixed(1),
            onChanged: (double value) {
              setState(() {
                _sleepHours = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Text('Sleep quality (1-5): ${_sleepQuality.round()}'),
          Slider(
            value: _sleepQuality,
            min: 1,
            max: 5,
            divisions: 4,
            label: _sleepQuality.round().toString(),
            onChanged: (double value) {
              setState(() {
                _sleepQuality = value;
              });
            },
          ),
          const SizedBox(height: 8),
          Text('Night awakenings: $_nightAwakenings'),
          Slider(
            value: _nightAwakenings.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: _nightAwakenings.toString(),
            onChanged: (double value) {
              setState(() {
                _nightAwakenings = value.round();
              });
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes (stress, dreams, interruptions)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? 'Saving...' : 'Save Sleep Entry'),
          ),
        ],
      ),
    );
  }
}

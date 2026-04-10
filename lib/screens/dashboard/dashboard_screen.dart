import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_strings.dart';
import '../../services/privacy_nudge_service.dart';
import '../../services/reward_service.dart';
import '../chat/dr_iris_chat_screen.dart';
import '../content/json_content_screen.dart';
import '../safety/sos_consent_form_screen.dart';
import '../sleep/sleep_tracker_form_screen.dart';
import '../settings/settings_screen.dart';
import 'cbt_hub_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static final Uri _clipboardHelpUri = Uri.parse(
    'https://support.google.com/android/answer/9592256',
  );
  final RewardService _rewardService = RewardService();
  final PrivacyNudgeService _privacyNudgeService = PrivacyNudgeService();
  late Future<_DashboardScore> _scoreFuture;

  static const List<_TrackedForm> _trackedForms = <_TrackedForm>[
    _TrackedForm(
      assetPath: 'assets/data/Feeling_Identification.JSON',
    ),
    _TrackedForm(
      assetPath: 'assets/data/Mood_Intensity.JSON',
    ),
    _TrackedForm(
      assetPath: 'assets/data/Action_Planning.JSON',
    ),
    _TrackedForm(
      assetPath: 'assets/data/phq9_cbt_assessment.json',
    ),
    _TrackedForm(
      assetPath: 'assets/data/CBT-Based GAD-7.JSON',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scoreFuture = _loadDashboardScore();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _privacyNudgeService.maybeShow(context, source: 'dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        _FeatureTile(
          title: 'Dr Iris',
          subtitle: AppStrings.t(context, 'dr_iris_subtitle'),
          icon: Icons.psychology_alt_outlined,
          leading: const CircleAvatar(
            radius: 12,
            backgroundImage: AssetImage('assets/images/dr_iris_avatar.png'),
          ),
          fullWidth: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(kToolbarHeight),
                    child: _DrIrisChatAppBar(),
                  ),
                  body: DrIrisChatScreen(),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildScoreMeterCard(),
        const SizedBox(height: 12),
        _FeatureTile(
          title: AppStrings.t(context, 'upgrade_subscription'),
          subtitle: AppStrings.t(context, 'upgrade_subscription_subtitle'),
          icon: Icons.workspace_premium_outlined,
          fullWidth: true,
          onTap: _openUpgradeSubscriptionInfoDialog,
        ),
        const SizedBox(height: 12),
        _buildDailyMeditationTipCard(),
        const SizedBox(height: 12),
        _FeatureTile(
          title: AppStrings.t(context, 'emotional_checkin'),
          subtitle: AppStrings.t(context, 'emotional_checkin_subtitle'),
          icon: Icons.favorite_outline,
          fullWidth: true,
          onTap: _openEmotionalCheckInParts,
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          title: AppStrings.t(context, 'mood_journal'),
          subtitle: AppStrings.t(context, 'mood_journal_subtitle'),
          icon: Icons.edit_calendar_outlined,
          fullWidth: true,
          onTap: () => _openJson(
            AppStrings.t(context, 'mood_journal'),
            'assets/data/emotions_entry.json',
            formSectionKey: 'daily_questions',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _FeatureTile(
                title: AppStrings.t(context, 'breathing_exercises'),
                subtitle: AppStrings.t(context, 'breathing_subtitle'),
                icon: Icons.air,
                onTap: () => _openJson(
                  AppStrings.t(context, 'breathing_exercises'),
                  'assets/data/how_it_works.json',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureTile(
                title: AppStrings.t(context, 'sleep_tricks'),
                subtitle: AppStrings.t(context, 'sleep_tricks_subtitle'),
                icon: Icons.self_improvement_outlined,
                onTap: () => _openJson(
                  AppStrings.t(context, 'sleep_tricks'),
                  'assets/data/Sleep_Tricks.json',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _FeatureTile(
                title: AppStrings.t(context, 'sleep_tracker'),
                subtitle: AppStrings.t(context, 'sleep_tracker_subtitle'),
                icon: Icons.nightlight_round,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SleepTrackerFormScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          title: 'CBT Hub',
          subtitle: AppStrings.t(context, 'cbt_hub_subtitle'),
          icon: Icons.hub_outlined,
          fullWidth: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CbtHubScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _FeatureTile(
                title: AppStrings.t(context, 'screening_tests'),
                subtitle: AppStrings.t(context, 'screening_tests_subtitle'),
                icon: Icons.assignment_outlined,
                onTap: _openScreeningTests,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureTile(
                title: AppStrings.t(context, 'psychology_articles'),
                subtitle: AppStrings.t(context, 'psychology_articles_subtitle'),
                icon: Icons.article_outlined,
                onTap: () => _openJson(
                  AppStrings.t(context, 'psychology_articles'),
                  'assets/data/Psychology_Articles_En.json',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _FeatureTile(
                title: AppStrings.t(context, 'relationship_monitoring'),
                subtitle:
                    AppStrings.t(context, 'relationship_monitoring_subtitle'),
                icon: Icons.diversity_2_outlined,
                onTap: () => _openJson(
                  AppStrings.t(context, 'relationship_monitoring'),
                  'assets/data/relationship_monitoring.json',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureTile(
                title: AppStrings.t(context, 'communication_tracker'),
                subtitle:
                    AppStrings.t(context, 'communication_tracker_subtitle'),
                icon: Icons.forum_outlined,
                onTap: () => _openJson(
                  AppStrings.t(context, 'communication_tracker'),
                  'assets/data/communication_tracker.json',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _FeatureTile(
                title: AppStrings.t(context, 'rewards_points'),
                subtitle: AppStrings.t(context, 'rewards_points_subtitle'),
                icon: Icons.stars_outlined,
                onTap: _openWalletDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureTile(
                title: AppStrings.t(context, 'relationship_insight'),
                subtitle:
                    AppStrings.t(context, 'relationship_insight_subtitle'),
                icon: Icons.link_outlined,
                onTap: () => _openJson(
                  AppStrings.t(context, 'relationship_insight'),
                  'assets/data/Relationship_Insight_Questions.json',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          title: AppStrings.t(context, 'export_clipboard'),
          subtitle: AppStrings.t(context, 'export_clipboard_subtitle'),
          icon: Icons.content_copy_outlined,
          fullWidth: true,
          onTap: () async {
            final String summary = AppStrings.t(context, 'clipboard_summary');
            await Clipboard.setData(ClipboardData(text: summary));
            if (!context.mounted) return;
            await _showClipboardExportInfo(summary);
          },
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          title: AppStrings.t(context, 'delete_my_data'),
          subtitle: AppStrings.t(context, 'delete_my_data_subtitle'),
          icon: Icons.delete_outline,
          fullWidth: true,
          onTap: _confirmDeleteData,
        ),
        const SizedBox(height: 12),
        _FeatureTile(
          title: AppStrings.t(context, 'safety_backup_sos'),
          subtitle: AppStrings.t(context, 'safety_backup_sos_subtitle'),
          icon: Icons.health_and_safety_outlined,
          fullWidth: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SosConsentFormScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _openJson(
    String title,
    String assetPath, {
    bool asText = false,
    String? formSectionKey,
  }) async {
    if (asText) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _TextAssetScreen(title: title, assetPath: assetPath),
        ),
      );
      if (!mounted) return;
      setState(() {
        _scoreFuture = _loadDashboardScore();
      });
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JsonContentScreen(
          title: title,
          assetPath: assetPath,
          formSectionKey: formSectionKey,
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _scoreFuture = _loadDashboardScore();
    });
  }

  Future<void> _openUpgradeSubscriptionInfoDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.t(context, 'upgrade_subscription')),
          content: Text(AppStrings.t(context, 'upgrade_subscription_info')),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppStrings.t(context, 'close')),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
              child: Text(AppStrings.t(context, 'open_subscription')),
            ),
          ],
        );
      },
    );
  }

  void _openScreeningTests() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.t(context, 'select_screening_test'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.checklist_rtl_outlined),
                  title: Text(AppStrings.t(context, 'gad7_anxiety_screening')),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openJson(
                      AppStrings.t(context, 'gad7_screening'),
                      'assets/data/CBT-Based GAD-7.JSON',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.fact_check_outlined),
                  title:
                      Text(AppStrings.t(context, 'phq9_depression_screening')),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openJson(
                      AppStrings.t(context, 'phq9_screening'),
                      'assets/data/phq9_cbt_assessment.json',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openEmotionalCheckInParts() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.t(context, 'select_checkin_part'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.mood_outlined),
                  title: Text(AppStrings.t(context, 'part1_snapshot')),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openJson(
                      AppStrings.t(context, 'checkin_snapshot_title'),
                      'assets/data/Feeling_Identification.JSON',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.tune_outlined),
                  title: Text(AppStrings.t(context, 'part2_intensity')),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openJson(
                      AppStrings.t(context, 'checkin_intensity_title'),
                      'assets/data/Mood_Intensity.JSON',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.hub_outlined),
                  title: Text(AppStrings.t(context, 'part3_trigger')),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openJson(
                      AppStrings.t(context, 'checkin_trigger_title'),
                      'assets/data/Action_Planning.JSON',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.task_alt_outlined),
                  title: Text(AppStrings.t(context, 'part4_recovery')),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openJson(
                      AppStrings.t(context, 'checkin_recovery_title'),
                      'assets/data/Emotional_Recovery_Plan.JSON',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreMeterCard() {
    return FutureBuilder<_DashboardScore>(
      future: _scoreFuture,
      builder: (BuildContext context, AsyncSnapshot<_DashboardScore> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 96,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final _DashboardScore score = snapshot.data ?? _DashboardScore.empty();
        final double progress = (score.percent / 100).clamp(0, 1).toDouble();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.t(context, 'entry_score_meter'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                AppStrings.t(
                  context,
                  'completed_forms',
                  args: <String, String>{
                    'percent': score.percent.toString(),
                    'completed': score.completed.toString(),
                    'total': score.total.toString(),
                  },
                ),
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 112,
                    height: 112,
                    child: CustomPaint(
                      painter: _ScoreRingPainter(progress: progress),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '${score.percent}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              AppStrings.t(context, 'score'),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      progress >= 0.8
                          ? AppStrings.t(context, 'score_msg_excellent')
                          : progress >= 0.5
                              ? AppStrings.t(context, 'score_msg_good')
                              : AppStrings.t(context, 'score_msg_start'),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyMeditationTipCard() {
    final _DailyYogaTip tip = _todayYogaTip();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppStrings.t(context, 'daily_meditation_tip'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            tip.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            tip.shortDescription,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Icon(Icons.schedule, size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                tip.duration,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openYogaTipDetails(tip),
                icon: const Icon(Icons.self_improvement_outlined, size: 16),
                label: Text(AppStrings.t(context, 'view_details')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _DailyYogaTip _todayYogaTip() {
    final DateTime now = DateTime.now();
    final DateTime startOfYear = DateTime(now.year, 1, 1);
    final int dayIndex = now.difference(startOfYear).inDays;
    return _dailyYogaTips[dayIndex % _dailyYogaTips.length];
  }

  Future<void> _openYogaTipDetails(_DailyYogaTip tip) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.76,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tip.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${tip.duration} • ${tip.goal}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tip.shortDescription,
                    style: const TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.t(context, 'steps'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tip.steps.length,
                      itemBuilder: (_, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('${index + 1}. ${tip.steps[index]}'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.t(
                      context,
                      'benefit',
                      args: <String, String>{'text': tip.benefit},
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.t(
                      context,
                      'safety',
                      args: <String, String>{'text': tip.safetyNote},
                    ),
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<_DashboardScore> _loadDashboardScore() async {
    if (!Hive.isBoxOpen('userBox')) {
      return _DashboardScore.empty(total: _trackedForms.length);
    }
    final Box<dynamic> userBox = Hive.box('userBox');
    final Map<String, dynamic> allEntries = Map<String, dynamic>.from(
      (userBox.get('form_entries', defaultValue: <String, dynamic>{})
              as Map?) ??
          <String, dynamic>{},
    );

    int completed = 0;
    double scoreSum = 0;
    for (final _TrackedForm tracked in _trackedForms) {
      final List<dynamic> entries = List<dynamic>.from(
          (allEntries[tracked.assetPath] as List?) ?? <dynamic>[]);
      if (entries.isEmpty) continue;
      completed += 1;
      final dynamic latest = entries.last;
      if (latest is Map && latest['score'] is Map) {
        final Map<dynamic, dynamic> scoreMap = Map<dynamic, dynamic>.from(
          latest['score'] as Map,
        );
        final num? percentNum = scoreMap['percent'] as num?;
        if (percentNum != null) {
          scoreSum += percentNum.toDouble();
          continue;
        }
      }
      scoreSum += 100;
    }

    final int percent = completed == 0 ? 0 : (scoreSum / completed).round();
    return _DashboardScore(
      completed: completed,
      total: _trackedForms.length,
      percent: percent,
    );
  }

  Future<void> _openWalletDialog() async {
    final RewardWalletState state = await _rewardService.walletState();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.t(context, 'wallet')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.t(
                  context,
                  'wallet_coins',
                  args: <String, String>{'coins': state.balance.toString()},
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.t(
                  context,
                  'wallet_membership',
                  args: <String, String>{'tier': state.membershipTier},
                ),
              ),
              if (state.freeUpgradeUntilIso.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  AppStrings.t(
                    context,
                    'wallet_free_upgrade_until',
                    args: <String, String>{'time': state.freeUpgradeUntilIso},
                  ),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final result = await _rewardService.redeemMembershipDiscount();
                if (!mounted) return;
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              },
              child: Text(AppStrings.t(context, 'use_coins')),
            ),
            FilledButton(
              onPressed: () async {
                final result = await _rewardService.activateFreeUpgrade();
                if (!mounted) return;
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
              },
              child: Text(AppStrings.t(context, 'free_upgrade')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showClipboardExportInfo(String copiedText) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.t(context, 'export_complete')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(AppStrings.t(context, 'clipboard_export_desc')),
              const SizedBox(height: 10),
              Text(
                AppStrings.t(
                  context,
                  'copied_text',
                  args: <String, String>{'text': copiedText},
                ),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final bool launched = await launchUrl(
                  _clipboardHelpUri,
                  mode: LaunchMode.externalApplication,
                );
                if (!launched && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(''),
                    ),
                  );
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppStrings.t(context, 'could_not_open_clipboard_help'),
                      ),
                    ),
                  );
                }
              },
              child: Text(AppStrings.t(context, 'clipboard_help_link')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppStrings.t(context, 'ok')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteData() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.t(context, 'delete_local_data')),
          content: Text(AppStrings.t(context, 'delete_local_data_desc')),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppStrings.t(context, 'cancel')),
            ),
            OutlinedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteFormEntriesOnly();
              },
              child: Text(AppStrings.t(context, 'delete_entries')),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteAllLocalUserData();
              },
              child: Text(AppStrings.t(context, 'delete_all')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFormEntriesOnly() async {
    if (!Hive.isBoxOpen('userBox')) return;
    final Box<dynamic> userBox = Hive.box('userBox');
    await userBox.delete('form_entries');
    if (!mounted) return;
    setState(() {
      _scoreFuture = _loadDashboardScore();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.t(context, 'saved_entries_deleted'))),
    );
  }

  Future<void> _deleteAllLocalUserData() async {
    if (Hive.isBoxOpen('userBox')) {
      await Hive.box('userBox').clear();
    }
    if (Hive.isBoxOpen('appBox')) {
      final Box<dynamic> appBox = Hive.box('appBox');
      await appBox.delete('first_checkin_done');
      await appBox.delete('dr_iris_intro_complete');
    }
    if (!mounted) return;
    setState(() {
      _scoreFuture = _loadDashboardScore();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.t(context, 'local_data_deleted'))),
    );
  }
}

class _TrackedForm {
  const _TrackedForm({
    required this.assetPath,
  });

  final String assetPath;
}

class _DailyYogaTip {
  const _DailyYogaTip({
    required this.title,
    required this.shortDescription,
    required this.duration,
    required this.goal,
    required this.steps,
    required this.benefit,
    required this.safetyNote,
  });

  final String title;
  final String shortDescription;
  final String duration;
  final String goal;
  final List<String> steps;
  final String benefit;
  final String safetyNote;
}

const List<_DailyYogaTip> _dailyYogaTips = <_DailyYogaTip>[
  _DailyYogaTip(
    title: 'Box Breathing + Gentle Neck Release',
    shortDescription:
        'Use 4-4-4-4 breathing with a light neck release to calm your mind.',
    duration: '7 min',
    goal: 'Stress calming and focus reset',
    steps: <String>[
      'Sit upright and relax your shoulders.',
      'Inhale for 4, hold for 4, exhale for 4, hold for 4; repeat for 8 rounds.',
      'Rotate your neck gently left and right, 20 seconds per side.',
      'For the final 1 minute, breathe normally and observe body sensations.',
    ],
    benefit: 'Reduces anxiety intensity and muscle tightness.',
    safetyNote:
        'If you feel dizzy, skip the hold phase and continue with normal deep breathing.',
  ),
  _DailyYogaTip(
    title: 'Cat-Cow Flow with Belly Breathing',
    shortDescription:
        'A gentle movement flow to improve spine mobility and release emotional heaviness.',
    duration: '10 min',
    goal: 'Back tension relief and emotional grounding',
    steps: <String>[
      'Come into tabletop position (hands under shoulders, knees under hips).',
      'Open the chest on inhale (Cow), round the spine on exhale (Cat).',
      'Do 12 to 16 slow rounds, syncing breath with movement.',
      'Rest in Child\'s Pose for 1 minute with belly breathing.',
    ],
    benefit: 'Improves mind-body sync and reduces irritability.',
    safetyNote: 'If you have lower-back pain, keep the movement range small.',
  ),
  _DailyYogaTip(
    title: 'Alternate Nostril Breathing (Anulom Vilom)',
    shortDescription:
        'Rhythmic nostril breathing to balance the nervous system.',
    duration: '8 min',
    goal: 'Mental clarity and mood balance',
    steps: <String>[
      'Sit upright in a comfortable position.',
      'Close the right nostril with your right thumb and inhale through the left.',
      'Close the left nostril with your ring finger, release right, and exhale through the right.',
      'Inhale through the right, switch, and exhale through the left; repeat for 20 slow rounds.',
    ],
    benefit: 'Reduces overthinking and improves focus stability.',
    safetyNote: 'Do not force the breath; keep it gentle and smooth.',
  ),
  _DailyYogaTip(
    title: 'Legs-Up-the-Wall Recovery',
    shortDescription:
        'A restorative pose to slow down fatigue and racing thoughts after a long day.',
    duration: '12 min',
    goal: 'Deep relaxation and sleep readiness',
    steps: <String>[
      'Sit sideways near a wall and bring your legs up against it.',
      'Settle your back on the floor and keep your arms open and relaxed.',
      'Inhale through the nose for 4 counts and exhale for 6 counts for 5 minutes.',
      'Close your eyes and do a body scan from feet to head.',
    ],
    benefit:
        'Helps down-regulate the nervous system and supports sleep quality.',
    safetyNote:
        'If you have glaucoma or severe neck issues, keep the pose duration shorter.',
  ),
  _DailyYogaTip(
    title: 'Seated Forward Fold + Gratitude Pause',
    shortDescription:
        'A mindful fold that combines body release with emotional softness.',
    duration: '9 min',
    goal: 'Emotional release and inner calm',
    steps: <String>[
      'Sit on the floor with legs extended and a long spine.',
      'Lengthen on inhale, then fold from the hips on exhale within comfort.',
      'Do 3 rounds, taking 6 deep breaths each round.',
      'End with a 1-minute gratitude reflection: recall one good thing from today.',
    ],
    benefit: 'Reduces nervous agitation and improves emotional stability.',
    safetyNote: 'If hamstrings feel tight, keep your knees slightly bent.',
  ),
  _DailyYogaTip(
    title: '5-4-3-2-1 Grounding with Breath',
    shortDescription:
        'An immediate grounding technique for panic or overwhelm moments.',
    duration: '6 min',
    goal: 'Present-moment anchoring',
    steps: <String>[
      'Notice 5 things you can see, 4 you can touch, 3 sounds, 2 smells, and 1 taste.',
      'After each step, take one slow inhale-exhale cycle.',
      'At the end, place both palms on your chest and say: "I am safe right now."',
    ],
    benefit: 'Interrupts panic loops and brings attention back to the present.',
    safetyNote: 'If the trigger feels intense, reach out to a trusted contact.',
  ),
  _DailyYogaTip(
    title: 'Evening Wind-Down Stretch Flow',
    shortDescription:
        'A nighttime routine to slow the body down and prepare for sleep.',
    duration: '11 min',
    goal: 'Sleep transition support',
    steps: <String>[
      'Standing side stretch 30-30 sec each side.',
      'Forward fold with 6 deep breaths.',
      'Supine spinal twist right-left 45 sec each.',
      'Final 2 minutes diaphragmatic breathing with long exhale.',
    ],
    benefit: 'Reduces physical arousal and promotes a calmer bedtime state.',
    safetyNote: 'Stop any stretch immediately if you feel sharp pain.',
  ),
];

class _DashboardScore {
  const _DashboardScore({
    required this.completed,
    required this.total,
    required this.percent,
  });

  factory _DashboardScore.empty({int total = 0}) {
    return _DashboardScore(completed: 0, total: total, percent: 0);
  }

  final int completed;
  final int total;
  final int percent;
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 12;
    const double startAngle = -math.pi / 2;
    final Rect rect = Offset.zero & size;
    final Rect arcRect = rect.deflate(strokeWidth / 2);

    final Paint backgroundPaint = Paint()
      ..color = const Color(0xFFECECEC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: <Color>[
          Color(0xFFE53935),
          Color(0xFFFB8C00),
          Color(0xFFFDD835),
          Color(0xFF43A047),
          Color(0xFF1E88E5),
        ],
        stops: <double>[0, 0.25, 0.5, 0.75, 1],
        transform: GradientRotation(startAngle),
      ).createShader(rect);

    canvas.drawArc(arcRect, 0, math.pi * 2, false, backgroundPaint);
    canvas.drawArc(
      arcRect,
      startAngle,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.leading,
    this.fullWidth = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? leading;
  final bool fullWidth;

  static const List<List<Color>> _joyPalettes = <List<Color>>[
    <Color>[Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    <Color>[Color(0xFFFFD166), Color(0xFFFFA62B)],
    <Color>[Color(0xFF06D6A0), Color(0xFF2EC4B6)],
    <Color>[Color(0xFF4D96FF), Color(0xFF6C63FF)],
    <Color>[Color(0xFFFF4D9D), Color(0xFFC77DFF)],
    <Color>[Color(0xFF22C55E), Color(0xFF14B8A6)],
  ];

  List<Color> _paletteForTile() {
    final int seed = (title.hashCode ^ icon.codePoint).abs();
    return _joyPalettes[seed % _joyPalettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> palette = _paletteForTile();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: fullWidth ? 94 : 126),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: palette,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: palette.last.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  if (leading != null) ...<Widget>[
                    const SizedBox(width: 8),
                    leading!,
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextAssetScreen extends StatelessWidget {
  const _TextAssetScreen({
    required this.title,
    required this.assetPath,
  });

  final String title;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<String>(
        future: rootBundle.loadString(assetPath),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No content found.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                snapshot.data!,
                style: const TextStyle(fontFamily: 'Lato', height: 1.4),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DrIrisChatAppBar extends StatelessWidget {
  const _DrIrisChatAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircleAvatar(
            radius: 12,
            backgroundImage: AssetImage('assets/images/dr_iris_avatar.png'),
          ),
          SizedBox(width: 8),
          Text('Dr Iris'),
        ],
      ),
      centerTitle: false,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/json_data_service.dart';
import '../core/permission_manager.dart';
import '../safety/immediate_help_page.dart';
import '../safety/safety_plan_page.dart';
import '../cbt/cbt_hub_page.dart';
import '../marketplace/marketplace_page.dart';
import '../rewards/rewards_page.dart';
import '../cbt/breathing_exercises_page.dart';
import '../festivals/festivals_page.dart';
import '../iris/dr_iris_welcome_page.dart';
import '../auth/phone_verification_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, String>? _festival;

  @override
  void initState() {
    super.initState();
    // Defer any I/O until after first frame to keep opening snappy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prewarm();
      _loadFestival();
    });
  }

  Future<void> _loadFestival() async {
    final brief = await JsonDataService.instance.getNextFestivalBrief(
      DateTime.now(),
    );
    if (!mounted) return;
    setState(() => _festival = brief);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Image.asset('assets/images/truecircle_logo.png', height: 24),
        ),
        titleSpacing: 0,
        title: const Text('TrueCircle'),
        actions: [
          IconButton(
            tooltip: 'Immediate Help',
            icon: const Icon(Icons.emergency_share_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ImmediateHelpPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PermissionManager.buildSampleModeBanner(),
              const SizedBox(height: 8),
              // Brand header with logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/truecircle_logo.png', height: 40),
                  const SizedBox(width: 10),
                  const Text(
                    'TrueCircle',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              if (_festival != null) ...[
                const SizedBox(height: 12),
                _FestivalBanner(brief: _festival!),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _startGuidedJourney,
                    icon: const Icon(Icons.route_outlined),
                    label: const Text('Start Journey'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DrIrisWelcomePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.psychology_alt_outlined),
                    label: const Text('Dr. Iris'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ImmediateHelpPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.health_and_safety_outlined),
                    label: const Text('Immediate Help'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SafetyPlanPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fact_check_outlined),
                    label: const Text('Safety Plan'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EmotionalCheckinPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    label: const Text('Emotional Check‑in'),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Explore more from the More tab',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CBT Hub',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CBTHubPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.hub_outlined),
                            label: const Text('Open CBT Hub'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Coming soon: Assessments (PHQ-9, GAD-7), Journaling',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Marketplace section (after CBT Hub)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Marketplace',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MarketplacePage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.storefront_outlined),
                        label: const Text('Open Marketplace'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Rewards section (after Marketplace)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rewards',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RewardsPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.emoji_events_outlined),
                        label: const Text('View Rewards'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on _HomePageState {
  Future<void> _prewarm() async {
    // Pre-open lightweight Hive box to reduce first-use latency
    try {
      await Hive.openBox('app_prefs');
    } catch (_) {
      // ignore
    }
  }

  Future<void> _startGuidedJourney() async {
    // 1) Ensure phone verification (offline sample). If not verified, ask and wait.
    final box = await Hive.openBox('app_prefs');
    final verified = box.get('phone_verified', defaultValue: false) as bool;
    if (!verified) {
      if (!mounted) return;
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const PhoneVerificationPage(returnResult: true),
        ),
      );
      if (ok != true) return; // user backed out
    }

    // 2) Go to Dr. Iris Welcome with auto check-in, then it will return to Home
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const DrIrisWelcomePage(isFirstTime: true),
      ),
    );
  }
}

class _FestivalBanner extends StatelessWidget {
  final Map<String, String> brief;
  const _FestivalBanner({required this.brief});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = brief['name'] ?? 'Festival';
    final month = brief['month'] ?? '';
    final type = brief['type'] ?? '';
    return Card(
      color: scheme.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.celebration_outlined, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming: $name',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  Text('$month • $type'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FestivalsPage()),
                );
              },
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }
}

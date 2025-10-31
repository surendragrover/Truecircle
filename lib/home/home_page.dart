import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import '../core/data_visualizations.dart';
import '../core/spacing.dart';
import '../core/loading_animations.dart';
import '../models/user_profile.dart';
import '../services/integration_service.dart';
import '../services/coin_reward_service.dart';
import 'widgets/welcome_header_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/feature_cards_widget.dart';
import 'widgets/daily_stats_widget.dart';
import 'widgets/mood_tracker_widget.dart';
import 'widgets/inspirational_quote_widget.dart';
import 'widgets/cbt_hub_widget.dart';
import 'widgets/sleep_tracker_widget.dart';
import 'widgets/festival_reminder_widget.dart';
import 'widgets/breathing_exercises_widget.dart';
import 'widgets/psychology_articles_widget.dart';
import 'widgets/mood_journal_widget.dart';
import 'widgets/meditation_guide_widget.dart';
import 'widgets/personalized_features_widget.dart';
import 'widgets/relationship_insights_widget.dart';
import 'widgets/communication_tracker_widget.dart';
import 'widgets/relationship_behavior_widget.dart';
import '../iris/dr_iris_assistant_widget.dart';
import '../more/more_page.dart';
import '../legal/privacy_policy_page.dart';
import '../legal/terms_conditions_page.dart';
import '../learn/faq_page.dart';
import '../how_truecircle_works_page.dart';
import '../widgets/coin_display_widget.dart';
import '../widgets/rotating_coin.dart';

/// Main Home Page - Ultimate Professional Dashboard with Analytics
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TrueCircleIntegrationService _integrationService =
      TrueCircleIntegrationService.instance;
  DashboardData? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final data = await _integrationService.getUltimateDashboardData(
        userId: 'demo_user', // Will be replaced with actual user ID
      );
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Settings & More',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSettingsTile(
                    context,
                    'How TrueCircle Works',
                    Icons.info_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HowTrueCircleWorksPage(),
                      ),
                    ),
                  ),
                  _buildSettingsTile(
                    context,
                    'FAQ',
                    Icons.help_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FaqPage()),
                    ),
                  ),
                  _buildSettingsTile(
                    context,
                    'Privacy Policy',
                    Icons.privacy_tip_outlined,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    ),
                  ),
                  _buildSettingsTile(
                    context,
                    'Terms & Conditions',
                    Icons.description_outlined,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsConditionsPage(),
                      ),
                    ),
                  ),
                  const Divider(),
                  _buildSettingsTile(
                    context,
                    'All Features',
                    Icons.apps,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MorePage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TrueCircleAppBar(
        title: 'TrueCircle',
        showCoins:
            false, // Avoid duplicate coin/reward menu; we show Wallet below
        actions: [
          // User Wallet - Coin Display
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: InkWell(
              onTap: () => _showWallet(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/TrueCircle_Coin.png',
                    width: 18,
                    height: 18,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 18,
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  FutureBuilder<int>(
                    future: CoinRewardService.instance.getUserCoinsCount(),
                    builder: (context, snapshot) {
                      final coins = snapshot.data ?? 0;
                      return Text(
                        '$coins',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showSettingsMenu(context),
            icon: const Icon(Icons.more_vert),
            color: Colors.white,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoadingState() : _buildDashboard(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TrueCircleLoadings.breathingLoader(),
          const SizedBox(height: 24),
          const Text(
            'Loading your wellness dashboard...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        // Keep generous top/side padding, no bottom padding to avoid gap
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Marquee moved into the global AppBar (TrueCircleAppBar)
            // Welcome Header with animations (kept directly under AppBar)
            const WelcomeHeaderWidget(),
            const SizedBox(height: AppGaps.section),

            // Dr. Iris AI Assistant just below the TrueCircle header
            DrIrisAssistantWidget(
              wellnessScore: _dashboardData?.wellnessScore ?? 78,
              trend: _dashboardData?.wellnessTrend ?? 'Improving',
            ),
            const SizedBox(height: AppGaps.section),
            // (Removed session-language chip to avoid any language mentions in default UI)

            // Relationship feature cards under Dr. Iris
            const RelationshipInsightsHomeWidget(),
            const SizedBox(height: AppGaps.section),
            const CommunicationTrackerHomeWidget(),
            const SizedBox(height: AppGaps.section),
            const RelationshipBehaviorHomeWidget(),
            const SizedBox(height: AppGaps.section),

            // Quick Actions
            const QuickActionsWidget(),
            const SizedBox(height: AppGaps.section),

            // Daily Stats
            const DailyStatsWidget(),
            const SizedBox(height: AppGaps.section),

            // Mood Tracker
            const MoodTrackerWidget(),
            const SizedBox(height: AppGaps.section),

            // Mood Frequency Chart - Professional analytics with responsive height
            LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = MediaQuery.of(context).size.height;
                final chartHeight = (screenHeight * 0.15).clamp(120.0, 140.0);

                // Demo emotion frequency data
                final emotionFrequency =
                    _dashboardData?.emotionFrequency ??
                    {
                      'Happy': 35.0,
                      'Calm': 25.0,
                      'Anxious': 15.0,
                      'Sad': 10.0,
                      'Excited': 15.0,
                    };

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    height: chartHeight,
                    padding: const EdgeInsets.all(8),
                    child: TrueCircleVisualizations.moodFrequencyChart(
                      emotionFrequency: emotionFrequency,
                      height: chartHeight - 16, // Account for padding
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppGaps.section),

            // Sleep Tracker - Moved to Top for Better Visibility
            const SleepTrackerWidget(),
            const SizedBox(height: AppGaps.section),

            // Mood Journal (moved above CBT Hub)
            const MoodJournalWidget(),
            const SizedBox(height: AppGaps.section),

            // CBT Hub - All CBT features in one place (WITHOUT sleep tracker)
            const CBTHubWidget(),
            const SizedBox(height: AppGaps.section),

            // Meditation Guide
            const MeditationGuideWidget(),
            const SizedBox(height: AppGaps.section),

            // Breathing Exercises
            const BreathingExercisesWidget(),
            const SizedBox(height: AppGaps.small),

            // Psychology Articles
            const PsychologyArticlesWidget(),
            const SizedBox(height: AppGaps.section),

            // Weekly Trend Graph
            TrueCircleVisualizations.weeklyTrendGraph(
              weeklyTrends:
                  _dashboardData?.weeklyTrends ??
                  {
                    'Mon': 72.0,
                    'Tue': 75.0,
                    'Wed': 73.0,
                    'Thu': 78.0,
                    'Fri': 80.0,
                    'Sat': 77.0,
                    'Sun': 78.0,
                  },
              height: 150,
            ),
            const SizedBox(height: AppGaps.section),

            // Inspirational Quote
            const InspirationalQuoteWidget(),
            const SizedBox(height: AppGaps.section),

            // Feature Usage Stats - Professional insights
            if (_dashboardData != null)
              TrueCircleVisualizations.featureUsageStats(
                featureUsage: _dashboardData!.featureUsage,
              ),
            const SizedBox(height: 24),

            // AI Insights List
            if (_dashboardData != null && _dashboardData!.insights.isNotEmpty)
              TrueCircleVisualizations.insightsList(
                insights: _dashboardData!.insights,
                onInsightTap: _handleInsightTap,
              ),
            const SizedBox(height: 24),

            // Feature Cards
            const FeatureCardsWidget(),
            const SizedBox(height: AppGaps.section),
            // Personalized features grid (6 items) showing recent user entries
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: const PersonalizedFeaturesWidget(),
            ),

            // Move Festivals & Rewards widgets to the bottom
            const SizedBox(height: AppGaps.section),
            // Festival Reminders (moved to bottom as requested)
            const FestivalReminderWidget(),
            const SizedBox(height: AppGaps.section),
            // Rewards summary widget near the bottom
            const CoinDisplayWidget(userId: 'demo_user', showHistory: false),

            // Bottom padding to prevent overflow
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
    );
  }

  void _showWallet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const RotatingCoin(size: 32, tint: Colors.amber),
                  const SizedBox(width: 12),
                  const Text(
                    'My Wallet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Current Balance
            Container(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<int>(
                future: CoinRewardService.instance.getUserCoinsCount(),
                builder: (context, snapshot) {
                  final coins = snapshot.data ?? 0;
                  return Column(
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/TrueCircle_Coin.png',
                            width: 28,
                            height: 28,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.monetization_on,
                                color: Colors.amber,
                                size: 28,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$coins Coins',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            // Information Sections
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWalletInfoSection('💰 How to Earn Coins', [
                      'Daily login: 1 coin per day',
                      'Complete a full entry: 1 coin',
                      'Note: No rewards for chatting with Dr. Iris',
                    ]),
                    const SizedBox(height: 20),
                    _buildWalletInfoSection('🛍️ How to Spend Coins', [
                      '1 Coin = ₹1 shopping discount',
                      'Use at marketplace for premium features',
                      'Redeem for exclusive content',
                      'Save up for special rewards',
                    ]),
                    const SizedBox(height: 20),
                    _buildWalletInfoSection('📊 Coin Types', [
                      'Available coins: ready to spend',
                      'Total coins: lifetime earnings',
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletInfoSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                Expanded(child: Text(point)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleInsightTap(WellnessInsight insight) {
    // Will implement insight detail page navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening insight: ${insight.title}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

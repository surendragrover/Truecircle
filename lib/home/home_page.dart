import 'package:flutter/material.dart';
import '../core/truecircle_app_bar.dart';
import '../core/data_visualizations.dart';
import '../core/loading_animations.dart';
import '../models/user_profile.dart';
import '../services/integration_service.dart';
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
import 'widgets/dr_iris_assistant_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TrueCircleAppBar(title: 'TrueCircle'),
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
            // Welcome Header with animations
            const WelcomeHeaderWidget(),
            const SizedBox(height: 12),
            // (Removed session-language chip to avoid any language mentions in default UI)

            // Wellness Score Card - Ultimate professional design
            if (_dashboardData != null)
              TrueCircleVisualizations.wellnessScoreCard(
                score: _dashboardData!.wellnessScore,
                trend: _dashboardData!.wellnessTrend,
                primaryColor: Theme.of(context).colorScheme.primary,
              ),
            const SizedBox(height: 24),

            // Quick Actions
            const QuickActionsWidget(),
            const SizedBox(height: 24),

            // Daily Stats
            const DailyStatsWidget(),
            const SizedBox(height: 24),

            // Mood Tracker
            const MoodTrackerWidget(),
            const SizedBox(height: 24),

            // Mood Frequency Chart - Professional analytics with responsive height
            if (_dashboardData != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final chartHeight = (screenHeight * 0.15).clamp(120.0, 140.0);

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      height: chartHeight,
                      padding: const EdgeInsets.all(8),
                      child: TrueCircleVisualizations.moodFrequencyChart(
                        emotionFrequency: _dashboardData!.emotionFrequency,
                        height: chartHeight - 16, // Account for padding
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),

            // Dr. Iris AI Assistant - Top Priority
            const DrIrisAssistantWidget(),
            const SizedBox(height: 16),

            // CBT Hub - All CBT features in one place (WITHOUT sleep tracker)
            const CBTHubWidget(),
            const SizedBox(height: 16),

            // Mood Journal
            const MoodJournalWidget(),
            const SizedBox(height: 16),

            // Meditation Guide
            const MeditationGuideWidget(),
            const SizedBox(height: 16),

            // Breathing Exercises
            const BreathingExercisesWidget(),
            const SizedBox(height: 16),

            // Sleep Tracker (Separate from CBT)
            const SleepTrackerWidget(),
            const SizedBox(height: 8),

            // Psychology Articles
            const PsychologyArticlesWidget(),
            const SizedBox(height: 24),

            // Weekly Trend Graph
            if (_dashboardData != null)
              TrueCircleVisualizations.weeklyTrendGraph(
                weeklyTrends: _dashboardData!.weeklyTrends,
                height: 150,
              ),
            const SizedBox(height: 24),

            // Festival Reminders
            const FestivalReminderWidget(),
            const SizedBox(height: 24),

            // Inspirational Quote
            const InspirationalQuoteWidget(),
            const SizedBox(height: 24),

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

            // Bottom padding to prevent overflow
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
          ],
        ),
      ),
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

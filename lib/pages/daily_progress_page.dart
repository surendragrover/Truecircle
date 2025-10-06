import 'package:flutter/material.dart';
import '../models/daily_progress.dart';
import '../services/daily_progress_service.dart';

/// DailyProgressPage - sample data support (formerly Demo)
/// 
/// Features:
/// - Today's progress overview with all integrated metrics
/// - Weekly progress charts and analytics
/// - Achievement system with badges
/// - Progress trends and insights
/// - Goal completion tracking
/// - Privacy-first design with sample data
class DailyProgressPage extends StatefulWidget {
  const DailyProgressPage({super.key});

  @override
  State<DailyProgressPage> createState() => _DailyProgressPageState();
}

class _DailyProgressPageState extends State<DailyProgressPage>
    with TickerProviderStateMixin {
  
  final DailyProgressService _progressService = DailyProgressService.instance;
  
  late TabController _tabController;
  
  bool _isLoading = true;
  bool _isServiceInitialized = false;
  
  DailyProgress? _todayProgress;
  List<DailyProgress> _weeklyProgress = [];
  WeeklyProgressSummary? _weeklySummary;
  ProgressAnalytics? _analytics;
  
  final TextEditingController _reflectionController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _meditationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reflectionController.dispose();
    _sleepController.dispose();
    _meditationController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    setState(() => _isLoading = true);
    
    try {
      await _progressService.initialize();
      setState(() => _isServiceInitialized = true);
      await _loadProgressData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service initialization failed: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProgressData() async {
    if (!_isServiceInitialized) return;
    
    setState(() => _isLoading = true);
    
    try {
      final today = DateTime.now();
      
      // Load today's progress
      _todayProgress = await _progressService.getDailyProgress(today);
      
      // Load weekly progress
      _weeklyProgress = await _progressService.getRecentProgress(days: 7);
      
      // Load weekly summary
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      _weeklySummary = await _progressService.getWeeklySummary(weekStart);
      
      // Load analytics
      _analytics = await _progressService.getProgressAnalytics(days: 30);
      
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load progress data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTodayProgress() async {
    if (!_isServiceInitialized) return;

    setState(() => _isLoading = true);

    try {
      final sleepHours = int.tryParse(_sleepController.text) ?? _todayProgress?.sleepHours;
      final meditationMinutes = int.tryParse(_meditationController.text) ?? _todayProgress?.meditationMinutes;
      final reflection = _reflectionController.text.trim().isNotEmpty 
          ? _reflectionController.text.trim() 
          : _todayProgress?.dailyReflection;

      _todayProgress = await _progressService.updateDailyProgress(
        sleepHours: sleepHours,
        meditationMinutes: meditationMinutes,
        dailyReflection: reflection,
        forceRecalculate: true,
      );

      _sleepController.clear();
      _meditationController.clear();
      _reflectionController.clear();

      await _loadProgressData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ आज की प्रगति successfully updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update progress: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSampleData() async {
    setState(() => _isLoading = true);

    try {
  final demoEntries = await _progressService.getSampleData();
      
  // Clear existing data and add sample data
      await _progressService.clearAllData();
      
      for (final entry in demoEntries) {
        await _progressService.updateDailyProgress(
          date: entry.date,
          pointsEarned: entry.pointsEarned,
          sleepHours: entry.sleepHours,
          sleepQuality: entry.sleepQuality,
          meditationMinutes: entry.meditationMinutes,
          exerciseMinutes: entry.exerciseMinutes,
          dailyReflection: entry.dailyReflection,
          newAchievements: entry.achievementBadges,
        );
      }

      await _loadProgressData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Sample data loaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load sample data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 दैनिक प्रगति (Daily Progress)'),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProgressData,
            tooltip: 'Refresh Data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(),
                _buildTrendsTab(),
                _buildAnalyticsTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  Widget _buildTodayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Overview Card
          _buildTodayOverviewCard(),
          const SizedBox(height: 16),
          
          // Quick Update Section
          _buildQuickUpdateSection(),
          const SizedBox(height: 16),
          
          // Achievements Section
          _buildAchievementsSection(),
          const SizedBox(height: 16),
          
          // Today's Metrics
          _buildTodayMetrics(),
        ],
      ),
    );
  }

  Widget _buildTodayOverviewCard() {
    final progress = _todayProgress;
    final score = progress?.overallDailyScore ?? 0.0;
    final category = progress?.wellnessCategory ?? WellnessCategory.needsImprovement;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'आज की स्थिति (Today\'s Status)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(int.parse('0xFF${category.colorHex.substring(1)}')),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${score.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              category.motivationalMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress Indicators
            Row(
              children: [
                Expanded(
                  child: _buildScoreIndicator(
                    'Wellness',
                    progress?.wellnessScore ?? 0,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildScoreIndicator(
                    'Relationships',
                    progress?.overallRelationshipScore ?? 0,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(String label, double score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 2),
        Text(
          '${score.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickUpdateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Quick Update',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sleepController,
                    decoration: const InputDecoration(
                      labelText: 'Sleep Hours (नींद घंटे)',
                      hintText: '7',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.bedtime),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _meditationController,
                    decoration: const InputDecoration(
                      labelText: 'Meditation (मेडिटेशन)',
                      hintText: '15 min',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.self_improvement),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _reflectionController,
              decoration: const InputDecoration(
                labelText: 'Daily Reflection (दैनिक चिंतन)',
                hintText: 'आज का दिन कैसा रहा...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _updateTodayProgress,
                icon: const Icon(Icons.update),
                label: const Text('Update Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = _todayProgress?.achievementBadges ?? [];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Today\'s Achievements',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            if (achievements.isEmpty)
              const Text(
                'No achievements yet today. Keep going! 💪',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: achievements.map((achievement) => Chip(
                  label: Text(achievement),
                  backgroundColor: Colors.amber.shade100,
                  avatar: const Icon(Icons.star, size: 18),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayMetrics() {
    final progress = _todayProgress;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Today\'s Metrics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildMetricRow('😴 Sleep', '${progress?.sleepHours ?? 0} hours'),
            _buildMetricRow('🧘 Meditation', '${progress?.meditationMinutes ?? 0} minutes'),
            _buildMetricRow('💬 Conversations', '${progress?.conversationCount ?? 0}'),
            _buildMetricRow('🎯 Goals', '${progress?.goalCompletionRate.toStringAsFixed(1) ?? "0"}%'),
            _buildMetricRow('⭐ Points', '${progress?.pointsEarned ?? 0}'),
            
            if (progress?.dailyReflection?.isNotEmpty == true) ...[
              const Divider(),
              const Text(
                '📝 Reflection:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                progress!.dailyReflection!,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Weekly Progress Chart
          _buildWeeklySummaryCard(),
          const SizedBox(height: 16),
          
          // Progress Timeline
          _buildProgressTimeline(),
        ],
      ),
    );
  }

  Widget _buildWeeklySummaryCard() {
    final summary = _weeklySummary;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📅 Weekly Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (summary != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    'Wellness',
                    '${summary.averageWellnessScore.toStringAsFixed(1)}%',
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    'Relationships',
                    '${summary.averageRelationshipScore.toStringAsFixed(1)}%',
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    'Consistency',
                    '${summary.consistencyScore.toStringAsFixed(0)}%',
                    Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildMetricRow('Total Sleep', '${summary.totalSleepHours} hours'),
              _buildMetricRow('Total Meditation', '${summary.totalMeditationMinutes} minutes'),
              _buildMetricRow('Total Points', '${summary.totalPointsEarned}'),
              _buildMetricRow('Active Days', '${summary.dailyEntries.length}/7'),
            ] else
              const Text('No weekly data available yet.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildProgressTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Progress Timeline (Last 7 Days)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (_weeklyProgress.isNotEmpty)
              ...(_weeklyProgress.reversed.take(7).map((progress) => 
                _buildTimelineItem(progress)
              ))
            else
              const Text('No progress data available.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(DailyProgress progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 4,
            color: Color(int.parse('0xFF${progress.wellnessCategory.colorHex.substring(1)}')),
          ),
        ),
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progress.formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Score: ${progress.overallDailyScore.toStringAsFixed(1)}% - ${progress.wellnessCategory.displayName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '😴 ${progress.sleepHours}h',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '🧘 ${progress.meditationMinutes}m',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final analytics = _analytics;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (analytics != null) ...[
            _buildAnalyticsOverview(analytics),
            const SizedBox(height: 16),
            _buildTopAchievements(analytics),
          ] else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No analytics data available yet.'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsOverview(ProgressAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 30-Day Analytics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildMetricRow('Active Days', '${analytics.totalDays}'),
            _buildMetricRow('Consistency Rate', '${analytics.consistencyRate.toStringAsFixed(1)}%'),
            _buildMetricRow('Avg Overall Score', '${analytics.averageOverallScore.toStringAsFixed(1)}%'),
            _buildMetricRow('Avg Wellness', '${analytics.averageWellnessScore.toStringAsFixed(1)}%'),
            _buildMetricRow('Avg Relationships', '${analytics.averageRelationshipScore.toStringAsFixed(1)}%'),
            _buildMetricRow('Avg Sleep/Day', '${analytics.averageSleepHours.toStringAsFixed(1)}h'),
            _buildMetricRow('Avg Meditation/Day', '${analytics.averageMeditationMinutes.toStringAsFixed(1)}m'),
            _buildMetricRow('Total Points', '${analytics.totalPointsEarned}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAchievements(ProgressAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Top Achievements (30 Days)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (analytics.topAchievements.isNotEmpty)
              ...analytics.topAchievements.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(entry.key)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${entry.value}x',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Text('No achievements unlocked yet.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚙️ Settings & Sample Data',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loadSampleData,
                      icon: const Icon(Icons.data_usage),
                      label: const Text('Load Sample Data'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear All Data'),
                            content: const Text('This will permanently delete all progress data. Continue?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirmed == true) {
                          await _progressService.clearAllData();
                          await _loadProgressData();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All data cleared')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Clear All Data'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Service Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔍 System Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildStatusRow('Service Initialized', _isServiceInitialized),
                  _buildStatusRow('Today\'s Data', _todayProgress != null),
                  _buildStatusRow('Weekly Data', _weeklyProgress.isNotEmpty),
                  _buildStatusRow('Analytics', _analytics != null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}
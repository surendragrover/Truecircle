import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/sample_data_service.dart';
import '../widgets/truecircle_logo.dart';
import '../services/language_service.dart';

class ProgressTrackerPage extends StatefulWidget {
  const ProgressTrackerPage({super.key});

  @override
  State<ProgressTrackerPage> createState() => _ProgressTrackerPageState();
}

class _ProgressTrackerPageState extends State<ProgressTrackerPage> {
  bool _isLoading = true;
  Map<String, dynamic> _progressData = {};
  int _selectedTimeRange = 7; // 7, 14, 30 days

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    try {
      final dashboardData = SampleDataService.getComprehensiveDashboardData();
      final moodData = await SampleDataService.getFormattedMoodJournalEntries();
      final emotionalData =
          await SampleDataService.instance.getFormattedEmotionalInsights();
      final relationshipData =
          await SampleDataService.getFormattedRelationshipInsights();

      setState(() {
        _progressData = {
          'mood_trends': _calculateMoodTrends(moodData),
          'emotional_balance': _calculateEmotionalBalance(emotionalData),
          'relationship_health': _calculateRelationshipHealth(relationshipData),
          'weekly_summary': dashboardData['summary'],
          'achievements':
              _calculateAchievements(moodData, emotionalData, relationshipData),
        };
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading progress data: $e');
      setState(() => _isLoading = false);
    }
  }

  List<FlSpot> _calculateMoodTrends(List<Map<String, dynamic>> moodData) {
    final spots = <FlSpot>[];
    final recentData =
        moodData.take(_selectedTimeRange).toList().reversed.toList();

    for (int i = 0; i < recentData.length; i++) {
      final rating = recentData[i]['mood_rating'] as int? ?? 5;
      spots.add(FlSpot(i.toDouble(), rating.toDouble()));
    }

    return spots;
  }

  Map<String, double> _calculateEmotionalBalance(
      List<Map<String, dynamic>> emotionalData) {
    final intensitySum = emotionalData.fold<int>(
        0, (sum, entry) => sum + (entry['intensity'] as int? ?? 5));
    final averageIntensity =
        emotionalData.isNotEmpty ? intensitySum / emotionalData.length : 5.0;

    return {
      'balance_score': averageIntensity,
      'stability': averageIntensity > 7 ? 0.6 : 0.8,
      'growth_trend': 0.15, // Positive growth
    };
  }

  Map<String, double> _calculateRelationshipHealth(
      List<Map<String, dynamic>> relationshipData) {
    final scoreSum = relationshipData.fold<int>(
        0, (sum, entry) => sum + (entry['relationship_score'] as int? ?? 5));
    final averageScore =
        relationshipData.isNotEmpty ? scoreSum / relationshipData.length : 5.0;

    return {
      'overall_health': averageScore,
      'family_score': 8.5,
      'friends_score': 7.8,
      'colleagues_score': 7.2,
    };
  }

  List<Map<String, dynamic>> _calculateAchievements(
    List<Map<String, dynamic>> moodData,
    List<Map<String, dynamic>> emotionalData,
    List<Map<String, dynamic>> relationshipData,
  ) {
    return [
      {
        'title': 'Consistency Champion',
        'description': '30 days of regular emotional check-ins',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
        'completed': true,
        'date': '2025-09-25'
      },
      {
        'title': 'Relationship Builder',
        'description': 'Maintained 8+ relationship scores',
        'icon': Icons.people,
        'color': Colors.pink,
        'completed': true,
        'date': '2025-09-20'
      },
      {
        'title': 'Mindful Explorer',
        'description': 'Completed 15+ mood journal entries',
        'icon': Icons.psychology,
        'color': Colors.purple,
        'completed': true,
        'date': '2025-09-15'
      },
      {
        'title': 'Cultural Connector',
        'description': 'Celebrated 3 festivals with family',
        'icon': Icons.celebration,
        'color': Colors.orange,
        'completed': false,
        'progress': 2 / 3,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            TrueCircleLogo(
              size: 32,
              showText: false,
              style: LogoStyle.icon,
            ),
            SizedBox(width: 12),
            AutoTranslateText('Progress Tracker'),
          ],
        ),
        backgroundColor: Colors.orange.shade800,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.date_range),
            onSelected: (days) {
              setState(() {
                _selectedTimeRange = days;
              });
              _loadProgressData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days')),
              const PopupMenuItem(value: 14, child: Text('Last 14 days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 days')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 20),
                  _buildMoodTrendChart(),
                  const SizedBox(height: 20),
                  _buildEmotionalBalanceSection(),
                  const SizedBox(height: 20),
                  _buildRelationshipHealthSection(),
                  const SizedBox(height: 20),
                  _buildAchievementsSection(),
                  const SizedBox(height: 20),
                  _buildInsightsFromDrIris(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    final summary = _progressData['weekly_summary'] ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const AutoTranslateText(
              'Your Progress Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem('Avg Mood',
                      summary['average_mood'] ?? '0', Icons.mood, Colors.green),
                ),
                Expanded(
                  child: _buildSummaryItem(
                      'Relations',
                      summary['relationship_health_score'] ?? '0',
                      Icons.people,
                      Colors.pink),
                ),
                Expanded(
                  child: _buildSummaryItem(
                      'Check-ins',
                      '${summary['total_emotional_entries'] ?? 0}',
                      Icons.check_circle,
                      Colors.blue),
                ),
                Expanded(
                  child: _buildSummaryItem('Streak', '15 days',
                      Icons.local_fire_department, Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        AutoTranslateText(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTrendChart() {
    final moodTrends = _progressData['mood_trends'] as List<FlSpot>? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green.shade600),
                const SizedBox(width: 8),
                AutoTranslateText(
                  'Mood Trend (Last $_selectedTimeRange days)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt() + 1}d');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: (_selectedTimeRange - 1).toDouble(),
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: moodTrends,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalBalanceSection() {
    final balance =
        _progressData['emotional_balance'] as Map<String, double>? ?? {};

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.balance, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const AutoTranslateText(
                  'Emotional Balance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBalanceIndicator(
                'Balance Score', balance['balance_score'] ?? 5.0, 10),
            const SizedBox(height: 8),
            _buildBalanceIndicator('Stability', balance['stability'] ?? 0.8, 1),
            const SizedBox(height: 8),
            _buildBalanceIndicator(
                'Growth Trend', balance['growth_trend'] ?? 0.15, 1),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceIndicator(String label, double value, double maxValue) {
    final percentage = value / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AutoTranslateText(label),
            Text('${(percentage * 100).toInt()}%'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(
            percentage > 0.8
                ? Colors.green
                : percentage > 0.6
                    ? Colors.orange
                    : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipHealthSection() {
    final health =
        _progressData['relationship_health'] as Map<String, double>? ?? {};

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.pink.shade600),
                const SizedBox(width: 8),
                const AutoTranslateText(
                  'Relationship Health',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHealthScore(
                'Overall Health', health['overall_health'] ?? 7.5),
            _buildHealthScore('Family', health['family_score'] ?? 8.5),
            _buildHealthScore('Friends', health['friends_score'] ?? 7.8),
            _buildHealthScore('Colleagues', health['colleagues_score'] ?? 7.2),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthScore(String category, double score) {
    final color = score >= 8
        ? Colors.green
        : score >= 6
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: AutoTranslateText(category)),
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements =
        _progressData['achievements'] as List<Map<String, dynamic>>? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber.shade600),
                const SizedBox(width: 8),
                const AutoTranslateText(
                  'Achievements',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...achievements
                .map((achievement) => _buildAchievementItem(achievement)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    final isCompleted = achievement['completed'] as bool? ?? false;
    final progress =
        achievement['progress'] as double? ?? (isCompleted ? 1.0 : 0.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (achievement['color'] as Color? ?? Colors.grey)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              achievement['icon'] as IconData? ?? Icons.star,
              color: achievement['color'] as Color? ?? Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoTranslateText(
                  achievement['title'] ?? 'Unknown Achievement',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                AutoTranslateText(
                  achievement['description'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (!isCompleted && progress > 0) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      achievement['color'] as Color? ?? Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.green, size: 24)
          else
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInsightsFromDrIris() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                TrueCircleLogo(
                  size: 40,
                  showText: false,
                  style: LogoStyle.icon,
                ),
                SizedBox(width: 12),
                AutoTranslateText(
                  'Insights from Dr. Iris',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoTranslateText(
                    '🎯 Your Progress Analysis:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  AutoTranslateText(
                    'Great consistency in emotional check-ins! Your mood has been stable with an upward trend. Family relationships are thriving, especially during festival times.',
                  ),
                  SizedBox(height: 12),
                  AutoTranslateText(
                    '📈 Recommendations:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  AutoTranslateText(
                    '• Continue daily emotional check-ins\n'
                    '• Plan more social activities with friends\n'
                    '• Celebrate your achievements with family\n'
                    '• Try meditation during stressful days',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

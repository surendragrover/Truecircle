import 'package:flutter/material.dart';
import '../services/comprehensive_sample_data_service.dart';
import '../widgets/truecircle_logo.dart';
import '../theme/coral_theme.dart';

/// Mood Journal Page - Display 30-day mood tracking data
class MoodJournalPage extends StatefulWidget {
  const MoodJournalPage({super.key});

  @override
  State<MoodJournalPage> createState() => _MoodJournalPageState();
}

class _MoodJournalPageState extends State<MoodJournalPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _moodData = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMoodData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMoodData() async {
    try {
      final data =
          await ComprehensiveSampleDataService.loadFeatureData('mood_journal');
      final analytics = ComprehensiveSampleDataService.calculateAnalytics(
          data, 'mood_journal');

      setState(() {
        _moodData = data;
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading mood data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TrueCircleLogo(size: 24),
            SizedBox(width: 8),
            Icon(Icons.mood, color: Colors.orange),
            SizedBox(width: 8),
            Text('😊 Mood Journal'),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: CoralTheme.appBarGradient),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: 'Journal'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.psychology), text: 'Insights'),
          ],
        ),
      ),
      body: Container(
        decoration: CoralTheme.background,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildJournalTab(),
                  _buildAnalyticsTab(),
                  _buildInsightsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildJournalTab() {
    if (_moodData.isEmpty) {
      return const Center(
        child: Text(
          'No mood journal data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _moodData.length,
      itemBuilder: (context, index) {
        final mood = _moodData[index];
        final moodDate = DateTime.now().subtract(Duration(days: index));

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Day ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDate(moodDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _getMoodIcon(mood['mood_score']?.toInt() ?? 5),
                  ],
                ),
                const SizedBox(height: 16),

                // Mood Score and Emotion
                Row(
                  children: [
                    Expanded(
                      child: _buildMoodMetric(
                        '📊 Mood Score',
                        '${mood['mood_score'] ?? 0}/10',
                        _getMoodColor(mood['mood_score']?.toInt() ?? 5),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEmotionChip(
                        mood['emotion'] ?? 'Neutral',
                        mood['emotion_hindi'] ?? 'सामान्य',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Activities and Triggers
                if (mood['activities'] != null) ...[
                  const Text(
                    'Activities:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: (mood['activities'] as List<dynamic>)
                        .map((activity) =>
                            _buildActivityChip(activity.toString()))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Notes
                if (mood['note'] != null &&
                    mood['note'].toString().isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.note,
                                size: 16, color: Colors.amber[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Journal Entry:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mood['note'].toString(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],

                // Weather and Sleep (if available)
                if (mood['weather'] != null || mood['sleep_hours'] != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (mood['weather'] != null) ...[
                        Icon(Icons.wb_sunny, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          mood['weather'].toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (mood['weather'] != null &&
                          mood['sleep_hours'] != null)
                        const SizedBox(width: 16),
                      if (mood['sleep_hours'] != null) ...[
                        Icon(Icons.bedtime, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${mood['sleep_hours']}h sleep',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    if (_analytics.isEmpty) {
      return const Center(
        child: Text(
          'No analytics data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 30-Day Mood Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  '📝 Total Entries',
                  '${_analytics['totalEntries'] ?? 0}',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  '📈 Avg Mood',
                  '${(_analytics['avgMoodScore'] ?? 0.0).toStringAsFixed(1)}/10',
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  '😊 Positive Days',
                  '${_analytics['positiveEntries'] ?? 0}',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  '🎯 Positive %',
                  '${(_analytics['positivePercentage'] ?? 0.0).toStringAsFixed(0)}%',
                  Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Mood Trend Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📈 Mood Trend (Last 7 Days)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Simple trend visualization
                  SizedBox(
                    height: 120,
                    child: Row(
                      children: List.generate(7, (index) {
                        final moodScore = index < _moodData.length
                            ? (_moodData[index]['mood_score']?.toDouble() ??
                                5.0)
                            : 5.0;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  moodScore.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  height: (moodScore / 10) * 80,
                                  decoration: BoxDecoration(
                                    color: _getMoodColor(moodScore.toInt()),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Day ${index + 1}',
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Mood Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎭 Mood Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMoodDistribution('Excellent (9-10)', Colors.green, 15),
                  const SizedBox(height: 8),
                  _buildMoodDistribution('Good (7-8)', Colors.lightGreen, 35),
                  const SizedBox(height: 8),
                  _buildMoodDistribution('Neutral (5-6)', Colors.amber, 30),
                  const SizedBox(height: 8),
                  _buildMoodDistribution('Low (3-4)', Colors.orange, 15),
                  const SizedBox(height: 8),
                  _buildMoodDistribution('Poor (1-2)', Colors.red, 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Mood Insights & Tips',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Personal Insights
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎯 Your Mood Patterns',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInsightItem(
                    '📊',
                    'Your average mood score is ${(_analytics['avgMoodScore'] ?? 0.0).toStringAsFixed(1)}/10',
                  ),
                  _buildInsightItem(
                    '😊',
                    '${(_analytics['positivePercentage'] ?? 0.0).toStringAsFixed(0)}% of your days were positive (7+ mood score)',
                  ),
                  _buildInsightItem(
                    '📈',
                    'You\'ve completed ${_analytics['totalEntries'] ?? 0} mood journal entries',
                  ),
                  _buildInsightItem(
                    '🏆',
                    'Consistent tracking helps identify patterns and triggers',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mood Improvement Tips
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌟 Mood Boosting Tips',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTipCard(
                    '🏃‍♀️ Physical Activity',
                    'Regular exercise releases endorphins and improves mood',
                    Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _buildTipCard(
                    '🧘‍♀️ Mindfulness & Meditation',
                    'Daily meditation can reduce stress and increase happiness',
                    Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  _buildTipCard(
                    '👥 Social Connection',
                    'Spending time with loved ones boosts emotional well-being',
                    Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildTipCard(
                    '🌱 Gratitude Practice',
                    'Writing down 3 things you\'re grateful for daily improves mood',
                    Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  _buildTipCard(
                    '😴 Quality Sleep',
                    'Getting 7-9 hours of sleep is crucial for emotional regulation',
                    Colors.indigo,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // When to Seek Help
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.health_and_safety, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Text(
                        'When to Seek Professional Help',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildHelpItem('Persistent low mood for more than 2 weeks'),
                  _buildHelpItem(
                      'Loss of interest in activities you usually enjoy'),
                  _buildHelpItem('Significant changes in sleep or appetite'),
                  _buildHelpItem(
                      'Difficulty concentrating or making decisions'),
                  _buildHelpItem('Thoughts of self-harm or suicide'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Remember: Seeking help is a sign of strength, not weakness. Mental health professionals can provide valuable support and treatment.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[800],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getMoodIcon(int moodScore) {
    if (moodScore >= 9) return const Text('😄', style: TextStyle(fontSize: 24));
    if (moodScore >= 7) return const Text('😊', style: TextStyle(fontSize: 24));
    if (moodScore >= 5) return const Text('😐', style: TextStyle(fontSize: 24));
    if (moodScore >= 3) return const Text('😞', style: TextStyle(fontSize: 24));
    return const Text('😢', style: TextStyle(fontSize: 24));
  }

  Color _getMoodColor(int moodScore) {
    if (moodScore >= 8) return Colors.green;
    if (moodScore >= 6) return Colors.lightGreen;
    if (moodScore >= 4) return Colors.amber;
    if (moodScore >= 2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildMoodMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionChip(String emotion, String emotionHi) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        children: [
          Text(
            emotion,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            emotionHi,
            style: TextStyle(
              fontSize: 11,
              color: Colors.purple[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChip(String activity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        activity,
        style: TextStyle(
          fontSize: 11,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistribution(String label, Color color, int percentage) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.red[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
  }
}

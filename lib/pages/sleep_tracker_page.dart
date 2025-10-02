import 'package:flutter/material.dart';
import '../services/comprehensive_demo_data_service.dart';
import '../widgets/truecircle_logo.dart';

/// Sleep Tracker Page - Display 30-day sleep tracking data
class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({super.key});

  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _sleepData = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSleepData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSleepData() async {
    try {
      final data = await ComprehensiveSampleDataService.loadFeatureData('sleep_tracker');
      final analytics = ComprehensiveSampleDataService.calculateAnalytics(data, 'sleep_tracker');
      
      setState(() {
        _sleepData = data;
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading sleep data: $e');
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
            Icon(Icons.bedtime, color: Colors.indigo),
            SizedBox(width: 8),
            Text('😴 Sleep Tracker'),
          ],
        ),
        backgroundColor: Colors.indigo[50],
        foregroundColor: Colors.indigo[800],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo[800],
          unselectedLabelColor: Colors.indigo[400],
          tabs: const [
            Tab(icon: Icon(Icons.nights_stay), text: 'Sleep Log'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.tips_and_updates), text: 'Sleep Tips'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[50]!,
              Colors.purple[50]!,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildSleepLogTab(),
                  _buildAnalyticsTab(),
                  _buildSleepTipsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildSleepLogTab() {
    if (_sleepData.isEmpty) {
      return const Center(
        child: Text(
          'No sleep tracking data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sleepData.length,
      itemBuilder: (context, index) {
        final sleep = _sleepData[index];
        final sleepDate = DateTime.now().subtract(Duration(days: index));
        
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
                        color: Colors.indigo[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Night ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _formatDate(sleepDate),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _getSleepQualityIcon(sleep['quality']?.toInt() ?? 5),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Sleep Duration and Quality
                Row(
                  children: [
                    Expanded(
                      child: _buildSleepMetric(
                        '⏰ Duration',
                        sleep['duration'] ?? '0h 0m',
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSleepMetric(
                        '⭐ Quality',
                        '${sleep['quality'] ?? 0}/10',
                        Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Sleep and Wake Times
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeMetric(
                        '🌙 Bedtime',
                        sleep['bedtime'] ?? '22:00',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeMetric(
                        '☀️ Wake Time',
                        sleep['wakeup_time'] ?? '06:00',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Sleep Stages
                if (sleep['deep_sleep_percentage'] != null) ...[
                  const Text(
                    'Sleep Stages:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSleepStage(
                          'Deep',
                          '${sleep['deep_sleep_percentage']}%',
                          Colors.indigo,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSleepStage(
                          'REM',
                          '${sleep['rem_sleep_percentage']}%',
                          Colors.purple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSleepStage(
                          'Light',
                          '${sleep['light_sleep_percentage']}%',
                          Colors.cyan,
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (sleep['notes'] != null && sleep['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '💭 ${sleep['notes']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
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
            '📊 30-Day Sleep Analytics',
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
                  '🛌 Total Nights',
                  '${_analytics['totalNights'] ?? 0}',
                  Colors.indigo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  '⏰ Avg Duration',
                  _analytics['avgDuration'] ?? '0h 0m',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  '⭐ Avg Quality',
                  '${(_analytics['avgQuality'] ?? 0.0).toStringAsFixed(1)}/10',
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  '🎯 Sleep Goal',
                  '8h 0m',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Weekly Sleep Pattern
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📈 Weekly Sleep Pattern',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Week days with mock data
                  for (int i = 0; i < 7; i++) ...[
                    _buildWeekdayBar(
                      _getWeekdayName(i),
                      7.5 + (i * 0.2) - 0.5, // Mock duration data
                      8.0,
                    ),
                    if (i < 6) const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Sleep Quality Insights
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Sleep Insights',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInsightItem(
                    '🎯',
                    'Your average sleep quality is ${(_analytics['avgQuality'] ?? 0.0).toStringAsFixed(1)}/10',
                  ),
                  _buildInsightItem(
                    '⏰',
                    'Average sleep duration: ${_analytics['avgDuration'] ?? '0h 0m'}',
                  ),
                  _buildInsightItem(
                    '📈',
                    'You\'ve tracked ${_analytics['totalNights'] ?? 0} nights of sleep',
                  ),
                  _buildInsightItem(
                    '🏆',
                    'Maintain consistent sleep schedule for better quality',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTipsTab() {
    final tips = [
      {
        'title': 'Consistent Sleep Schedule',
        'titleHi': 'नियमित नींद का समय',
        'description': 'Go to bed and wake up at the same time every day',
        'icon': '⏰',
        'category': 'Schedule',
      },
      {
        'title': 'Create Sleep Environment',
        'titleHi': 'नींद का माहौल बनाएं',
        'description': 'Keep bedroom dark, quiet, and cool for better sleep',
        'icon': '🌙',
        'category': 'Environment',
      },
      {
        'title': 'Limit Screen Time',
        'titleHi': 'स्क्रीन टाइम सीमित करें',
        'description': 'Avoid screens 1 hour before bedtime',
        'icon': '📱',
        'category': 'Habits',
      },
      {
        'title': 'Regular Exercise',
        'titleHi': 'नियमित व्यायाम',
        'description': 'Exercise regularly but not close to bedtime',
        'icon': '🏃‍♀️',
        'category': 'Lifestyle',
      },
      {
        'title': 'Avoid Caffeine',
        'titleHi': 'कैफीन से बचें',
        'description': 'No caffeine 6 hours before sleep',
        'icon': '☕',
        'category': 'Diet',
      },
      {
        'title': 'Relaxation Techniques',
        'titleHi': 'आराम की तकनीकें',
        'description': 'Try meditation, deep breathing, or gentle stretching',
        'icon': '🧘‍♀️',
        'category': 'Relaxation',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tip['icon'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tip['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tip['category'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.indigo[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['titleHi'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tip['description'] as String,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getSleepQualityIcon(int quality) {
    if (quality >= 8) return const Text('😴', style: TextStyle(fontSize: 24));
    if (quality >= 6) return const Text('😊', style: TextStyle(fontSize: 24));
    if (quality >= 4) return const Text('😐', style: TextStyle(fontSize: 24));
    return const Text('😞', style: TextStyle(fontSize: 24));
  }

  Widget _buildSleepMetric(String label, String value, Color color) {
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

  Widget _buildTimeMetric(String label, String time) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepStage(String stage, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            percentage,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            stage,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

  Widget _buildWeekdayBar(String day, double duration, double target) {
    final percentage = duration / target;
    
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            day,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage > 1.0 ? 1.0 : percentage,
                child: Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: percentage >= 1.0 ? Colors.green : Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '${duration.toStringAsFixed(1)}h',
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

  String _formatDate(DateTime date) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
  }

  String _getWeekdayName(int index) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[index];
  }
}
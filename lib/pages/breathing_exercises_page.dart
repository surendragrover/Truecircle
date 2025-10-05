import 'package:flutter/material.dart';
import '../services/json_data_service.dart';
import '../widgets/truecircle_logo.dart';

/// Breathing Exercises Page - Daily breathing techniques and tips
class BreathingExercisesPage extends StatefulWidget {
  const BreathingExercisesPage({super.key});

  @override
  State<BreathingExercisesPage> createState() => _BreathingExercisesPageState();
}

class _BreathingExercisesPageState extends State<BreathingExercisesPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _breathingData = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBreathingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBreathingData() async {
    debugPrint('🔄 Loading breathing exercises data...');
    try {
      final jsonService = JsonDataService.instance;
      final data = await jsonService.getBreathingData();

      // Simple analytics calculation
      final analytics = {
        'total_sessions': data.length,
        'avg_effectiveness': data.isNotEmpty
            ? data.map((e) => e['effectiveness'] ?? 0).reduce((a, b) => a + b) /
                data.length
            : 0,
        'most_used_technique':
            data.isNotEmpty ? data.first['technique'] ?? 'Unknown' : 'No data'
      };

      debugPrint('✅ Loaded ${data.length} breathing sessions');
      debugPrint('📊 Analytics: $analytics');

      setState(() {
        _breathingData = data;
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading breathing data: $e');
      setState(() {
        _isLoading = false;
      });
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load data: $e')),
        );
      }
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
            Icon(Icons.air, color: Colors.teal),
            SizedBox(width: 8),
            Text('🫁 Breathing Exercises'),
          ],
        ),
        backgroundColor: Colors.teal[50],
        foregroundColor: Colors.teal[800],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.teal[800],
          unselectedLabelColor: Colors.teal[400],
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Today\'s Tip'),
            Tab(icon: Icon(Icons.timeline), text: 'Sessions'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.tips_and_updates), text: 'Techniques'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal[50]!,
              Colors.cyan[50]!,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTodaysTipTab(),
                  _buildSessionsTab(),
                  _buildAnalyticsTab(),
                  _buildTechniquesTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildTodaysTipTab() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: JsonDataService.instance.getTodaysBreathingTip(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.air, size: 80, color: Colors.teal[300]),
                const SizedBox(height: 16),
                Text(
                  'No breathing tip available',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.teal[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final tip = snapshot.data!;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Date
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[400]!, Colors.teal[600]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'आज का श्वास अभ्यास',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Today\'s Breathing Practice',
                      style: TextStyle(
                        color: Colors.teal[100],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateTime.now().toString().split(' ')[0],
                      style: TextStyle(
                        color: Colors.teal[100],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Technique Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                              color: Colors.teal[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.air,
                                color: Colors.teal[600], size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip['technique_hindi'] ??
                                      tip['technique'] ??
                                      'Unknown',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  tip['technique'] ?? '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Duration
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${tip['duration_minutes']} मिनट • ${tip['duration_minutes']} minutes',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Benefits
                      if (tip['physical_sensation'] != null) ...[
                        Text(
                          'शारीरिक अनुभव • Physical Sensation',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.teal[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tip['physical_sensation_hindi'] ?? '',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['physical_sensation'] ?? '',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.5),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (tip['mental_clarity'] != null) ...[
                        Text(
                          'मानसिक स्पष्टता • Mental Clarity',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.teal[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tip['mental_clarity_hindi'] ?? '',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['mental_clarity'] ?? '',
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.5),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Effectiveness Rating
                      if (tip['effectiveness'] != null) ...[
                        Row(
                          children: [
                            Text(
                              'प्रभावशीलता • Effectiveness: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.teal[700],
                              ),
                            ),
                            ...List.generate(5, (index) {
                              return Icon(
                                index < (tip['effectiveness'] ?? 0)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber[600],
                                size: 20,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              '${tip['effectiveness']}/5',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionsTab() {
    if (_breathingData.isEmpty) {
      return const Center(
        child: Text(
          'No breathing exercise data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _breathingData.length,
      itemBuilder: (context, index) {
        final session = _breathingData[index];
        final sessionDate = DateTime.now().subtract(Duration(days: index));

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
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Day ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session['technique'] ?? 'Unknown Technique',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            session['technique_hindi'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDate(sessionDate),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Duration and Effectiveness
                Row(
                  children: [
                    _buildInfoChip(
                      '⏱️ ${session['duration_minutes']}m',
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      '⭐ ${session['effectiveness']}/10',
                      Colors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Stress Levels
                Row(
                  children: [
                    Expanded(
                      child: _buildStressIndicator(
                        'Before',
                        session['stress_before']?.toDouble() ?? 0.0,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStressIndicator(
                        'After',
                        session['stress_after']?.toDouble() ?? 0.0,
                        Colors.green,
                      ),
                    ),
                  ],
                ),

                if (session['notes'] != null &&
                    session['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '💭 ${session['notes']}',
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
            '📊 30-Day Breathing Analytics',
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
                  '🏃‍♂️ Total Sessions',
                  '${_analytics['totalSessions'] ?? 0}',
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  '⏰ Total Minutes',
                  '${_analytics['totalMinutes'] ?? 0}',
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
                  '📈 Avg Effectiveness',
                  '${(_analytics['avgEffectiveness'] ?? 0.0).toStringAsFixed(1)}/10',
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnalyticsCard(
                  '📉 Stress Reduction',
                  '${(_analytics['stressReduction'] ?? 0.0).toStringAsFixed(1)}',
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stress Levels Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Average Stress Levels',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStressComparison(
                    'Before Exercise',
                    _analytics['avgStressBefore']?.toDouble() ?? 0.0,
                    Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _buildStressComparison(
                    'After Exercise',
                    _analytics['avgStressAfter']?.toDouble() ?? 0.0,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Insights
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Insights & Recommendations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInsightItem(
                    '🎯',
                    'Your breathing exercises reduced stress by ${(_analytics['stressReduction'] ?? 0.0).toStringAsFixed(1)} points on average',
                  ),
                  _buildInsightItem(
                    '⏰',
                    'You\'ve spent ${_analytics['totalMinutes'] ?? 0} minutes on breathing exercises',
                  ),
                  _buildInsightItem(
                    '📈',
                    'Average effectiveness rating: ${(_analytics['avgEffectiveness'] ?? 0.0).toStringAsFixed(1)}/10',
                  ),
                  _buildInsightItem(
                    '🏆',
                    'Keep practicing! Consistency improves results over time',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniquesTab() {
    final techniques = [
      {
        'name': 'Anulom-Vilom',
        'nameHi': 'अनुलोम-विलोम',
        'description': 'Alternate nostril breathing for balance and calm',
        'duration': '5-15 minutes',
        'benefits': [
          'Reduces stress',
          'Improves focus',
          'Balances nervous system'
        ],
        'icon': '🧘‍♀️',
      },
      {
        'name': '4-7-8 Breathing',
        'nameHi': '4-7-8 सांस तकनीक',
        'description': 'Inhale 4, hold 7, exhale 8 counts for relaxation',
        'duration': '4-8 cycles',
        'benefits': ['Better sleep', 'Anxiety relief', 'Quick relaxation'],
        'icon': '😴',
      },
      {
        'name': 'Box Breathing',
        'nameHi': 'बॉक्स ब्रीदिंग',
        'description': 'Equal counts for inhale, hold, exhale, hold',
        'duration': '5-10 minutes',
        'benefits': [
          'Mental clarity',
          'Stress management',
          'Focus improvement'
        ],
        'icon': '📦',
      },
      {
        'name': 'Deep Belly Breathing',
        'nameHi': 'गहरी पेट की सांस',
        'description': 'Diaphragmatic breathing for relaxation',
        'duration': '10-20 minutes',
        'benefits': [
          'Lower blood pressure',
          'Reduced anxiety',
          'Better oxygen flow'
        ],
        'icon': '🫁',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: techniques.length,
      itemBuilder: (context, index) {
        final technique = techniques[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      technique['icon'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            technique['name'] as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            technique['nameHi'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  technique['description'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      technique['duration'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Benefits:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                ...((technique['benefits'] as List<String>).map(
                  (benefit) => Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: Colors.green[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            benefit,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStressIndicator(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 10.0,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 2),
        Text(
          '${value.toInt()}/10',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
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
                fontSize: 24,
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

  Widget _buildStressComparison(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}/10',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 10.0,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
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
    return '${date.day} ${months[date.month - 1]}';
  }
}

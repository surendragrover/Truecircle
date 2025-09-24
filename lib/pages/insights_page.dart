import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/emotion_entry.dart';

class InsightsPage extends StatefulWidget {
  final List<EmotionEntry> entries;

  const InsightsPage({super.key, required this.entries});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  String _selectedPeriod = '7 days';
  final List<String> _periods = ['7 days', '30 days', '90 days', 'All time'];

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _getFilteredEntries();
    final insights = _generateInsights(filteredEntries);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Insights'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text(period),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: filteredEntries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.insights, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No data available',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text('Add some mood entries to see insights'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCard(insights),
                  const SizedBox(height: 16),
                  _buildMoodPatternsCard(insights),
                  const SizedBox(height: 16),
                  _buildEmotionAnalysisCard(insights),
                  const SizedBox(height: 16),
                  _buildRecommendationsCard(insights),
                  const SizedBox(height: 16),
                  _buildMoodCalendar(filteredEntries),
                ],
              ),
            ),
    );
  }

  List<EmotionEntry> _getFilteredEntries() {
    if (_selectedPeriod == 'All time') return widget.entries;

    final now = DateTime.now();
    final days = _selectedPeriod == '7 days'
        ? 7
        : _selectedPeriod == '30 days'
            ? 30
            : 90;
    final cutoff = now.subtract(Duration(days: days));

    return widget.entries
        .where((entry) => entry.timestamp.isAfter(cutoff))
        .toList();
  }

  Map<String, dynamic> _generateInsights(List<EmotionEntry> entries) {
    if (entries.isEmpty) return {};

    // Calculate average intensity
    final avgIntensity =
        entries.map((e) => e.intensity).reduce((a, b) => a + b) /
            entries.length;

    // Find most common emotion
    final emotionCounts = <String, int>{};
    for (final entry in entries) {
      emotionCounts[entry.emotion.toLowerCase()] =
          (emotionCounts[entry.emotion.toLowerCase()] ?? 0) + 1;
    }
    final mostCommonEmotion =
        emotionCounts.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Calculate mood trend
    final recentEntries = entries.take(7).toList();
    final olderEntries = entries.skip(7).take(7).toList();
    double trend = 0;
    if (olderEntries.isNotEmpty) {
      final recentAvg =
          recentEntries.map((e) => e.intensity).reduce((a, b) => a + b) /
              recentEntries.length;
      final olderAvg =
          olderEntries.map((e) => e.intensity).reduce((a, b) => a + b) /
              olderEntries.length;
      trend = recentAvg - olderAvg;
    }

    // Find time patterns
    final hourCounts = <int, List<int>>{};
    for (final entry in entries) {
      final hour = entry.timestamp.hour;
      hourCounts[hour] = (hourCounts[hour] ?? [])..add(entry.intensity);
    }

    String bestTimeOfDay = 'Morning';
    double bestAverage = 0;
    for (final hour in hourCounts.keys) {
      final avg =
          hourCounts[hour]!.reduce((a, b) => a + b) / hourCounts[hour]!.length;
      if (avg > bestAverage) {
        bestAverage = avg;
        if (hour >= 6 && hour < 12) {
          bestTimeOfDay = 'Morning';
        } else if (hour >= 12 && hour < 18) {
          bestTimeOfDay = 'Afternoon';
        } else if (hour >= 18 && hour < 22) {
          bestTimeOfDay = 'Evening';
        } else {
          bestTimeOfDay = 'Night';
        }
      }
    }

    // Calculate consistency
    final intensities = entries.map((e) => e.intensity.toDouble()).toList();
    final variance = _calculateVariance(intensities);
    final consistency = variance < 2
        ? 'High'
        : variance < 4
            ? 'Medium'
            : 'Low';

    return {
      'avgIntensity': avgIntensity,
      'mostCommonEmotion': mostCommonEmotion.key,
      'emotionFrequency': mostCommonEmotion.value,
      'trend': trend,
      'bestTimeOfDay': bestTimeOfDay,
      'consistency': consistency,
      'totalEntries': entries.length,
      'emotionCounts': emotionCounts,
    };
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((x) => math.pow(x - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  Widget _buildOverviewCard(Map<String, dynamic> insights) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Average Mood',
                    insights['avgIntensity'].toStringAsFixed(1),
                    Icons.trending_up,
                    _getIntensityColor(insights['avgIntensity'].round()),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Entries',
                    insights['totalEntries'].toString(),
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Consistency',
                    insights['consistency'],
                    Icons.timeline,
                    insights['consistency'] == 'High'
                        ? Colors.green
                        : insights['consistency'] == 'Medium'
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Best Time',
                    insights['bestTimeOfDay'],
                    Icons.access_time,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMoodPatternsCard(Map<String, dynamic> insights) {
    if (insights.isEmpty) return const SizedBox.shrink();

    final trend = insights['trend'] as double;
    final trendText = trend > 0.5
        ? 'Improving'
        : trend < -0.5
            ? 'Declining'
            : 'Stable';
    final trendIcon = trend > 0.5
        ? Icons.trending_up
        : trend < -0.5
            ? Icons.trending_down
            : Icons.trending_flat;
    final trendColor = trend > 0.5
        ? Colors.green
        : trend < -0.5
            ? Colors.red
            : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Patterns',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(trendIcon, color: trendColor),
                const SizedBox(width: 8),
                Text(
                  'Your mood is $trendText',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: trendColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              trend > 0.5
                  ? 'Your recent mood scores are higher than before. Keep it up!'
                  : trend < -0.5
                      ? 'Your mood has been lower recently. Consider talking to someone or practicing self-care.'
                      : 'Your mood has been consistent lately.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionAnalysisCard(Map<String, dynamic> insights) {
    if (insights.isEmpty) return const SizedBox.shrink();

    final emotionCounts = insights['emotionCounts'] as Map<String, int>;
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emotion Analysis',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Most frequent: ${insights['mostCommonEmotion']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ...sortedEmotions.take(5).map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(entry.key.toUpperCase()),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: entry.value / sortedEmotions.first.value,
                          backgroundColor: Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${entry.value}'),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(Map<String, dynamic> insights) {
    if (insights.isEmpty) return const SizedBox.shrink();

    final avgIntensity = insights['avgIntensity'] as double;
    final consistency = insights['consistency'] as String;
    final trend = insights['trend'] as double;

    List<String> recommendations = [];

    if (avgIntensity < 4) {
      recommendations.add(
          '💚 Consider activities that boost your mood: exercise, nature walks, or connecting with friends.');
    } else if (avgIntensity > 7) {
      recommendations.add(
          '🧘 Your mood is generally positive! Maintain this with consistent self-care routines.');
    }

    if (consistency == 'Low') {
      recommendations.add(
          '📊 Your mood varies significantly. Try tracking triggers or patterns in your daily routine.');
    }

    if (trend < -0.5) {
      recommendations.add(
          '🤗 Recent mood decline detected. Consider speaking with a counselor or practicing mindfulness.');
    }

    recommendations.add(
        '📝 Keep tracking daily - you\'re building valuable self-awareness!');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalized Recommendations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(rec)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCalendar(List<EmotionEntry> entries) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood Calendar',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemCount: 28, // 4 weeks
                itemBuilder: (context, index) {
                  final date =
                      DateTime.now().subtract(Duration(days: 27 - index));
                  final dayEntries = entries
                      .where((e) =>
                          e.timestamp.year == date.year &&
                          e.timestamp.month == date.month &&
                          e.timestamp.day == date.day)
                      .toList();

                  Color color = Colors.grey[300]!;
                  if (dayEntries.isNotEmpty) {
                    final avgIntensity = dayEntries
                            .map((e) => e.intensity)
                            .reduce((a, b) => a + b) /
                        dayEntries.length;
                    color = _getIntensityColor(avgIntensity.round());
                  }

                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: dayEntries.isEmpty
                              ? Colors.black54
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('Low', Colors.green),
                _buildLegendItem('Medium', Colors.orange),
                _buildLegendItem('High', Colors.red),
                _buildLegendItem('No data', Colors.grey[300]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Color _getIntensityColor(int intensity) {
    if (intensity <= 3) return Colors.green;
    if (intensity <= 6) return Colors.orange;
    return Colors.red;
  }
}

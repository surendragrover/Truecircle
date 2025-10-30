import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../core/loading_animations.dart';

/// Professional Data Visualization - Ultimate Analytics Dashboard
/// The visualizations users have been waiting for years
class TrueCircleVisualizations {
  /// Wellness Score Card - Professional design
  static Widget wellnessScoreCard({
    required double score,
    required String trend,
    Color? primaryColor,
  }) {
    return _WellnessScoreCard(
      score: score,
      trend: trend,
      primaryColor: primaryColor ?? const Color(0xFF6366F1),
    );
  }

  /// Mood Frequency Chart - Beautiful visualization
  static Widget moodFrequencyChart({
    required Map<String, double> emotionFrequency,
    double height = 200,
  }) {
    return _MoodFrequencyChart(
      emotionFrequency: emotionFrequency,
      height: height,
    );
  }

  /// Weekly Trend Graph - Professional analytics
  static Widget weeklyTrendGraph({
    required Map<String, double> weeklyTrends,
    double height = 150,
  }) {
    return _WeeklyTrendGraph(weeklyTrends: weeklyTrends, height: height);
  }

  /// Feature Usage Stats - Interactive cards
  static Widget featureUsageStats({required Map<String, int> featureUsage}) {
    return _FeatureUsageStats(featureUsage: featureUsage);
  }

  /// Insights List - Professional layout
  static Widget insightsList({
    required List<WellnessInsight> insights,
    Function(WellnessInsight)? onInsightTap,
  }) {
    return _InsightsList(insights: insights, onInsightTap: onInsightTap);
  }
}

/// Wellness Score Card - Premium design with animations
class _WellnessScoreCard extends StatefulWidget {
  final double score;
  final String trend;
  final Color primaryColor;

  const _WellnessScoreCard({
    required this.score,
    required this.trend,
    required this.primaryColor,
  });

  @override
  State<_WellnessScoreCard> createState() => _WellnessScoreCardState();
}

class _WellnessScoreCardState extends State<_WellnessScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.score,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.primaryColor,
            widget.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Wellness Score',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              _buildTrendIndicator(),
            ],
          ),
          const SizedBox(height: 20),

          // Animated Score Display
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_scoreAnimation.value.toInt()}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Progress Bar
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _scoreAnimation.value / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getScoreDescription(_scoreAnimation.value),
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  // Weekly Goal Progress
                  Row(
                    children: [
                      const Icon(
                        Icons.flag_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Weekly Goal: ${_getWeeklyGoal(_scoreAnimation.value)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator() {
    IconData icon;
    Color color;

    switch (widget.trend.toLowerCase()) {
      case 'improving':
        icon = Icons.trending_up_rounded;
        color = Colors.green;
        break;
      case 'declining':
        icon = Icons.trending_down_rounded;
        color = Colors.orange;
        break;
      default:
        icon = Icons.trending_flat_rounded;
        color = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            widget.trend,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreDescription(double score) {
    if (score >= 80) return 'Excellent emotional wellness! 🌟';
    if (score >= 60) return 'Good progress, keep it up! 💪';
    if (score >= 40) return 'You\'re on the right track 🌱';
    return 'Focus on self-care today 💚';
  }

  String _getWeeklyGoal(double currentScore) {
    if (currentScore >= 90) return 'Maintain excellence';
    if (currentScore >= 75) return 'Reach 85+ points';
    if (currentScore >= 60) return 'Achieve 75+ points';
    return 'Build to 60+ points';
  }
}

/// Mood Frequency Chart - Beautiful bar visualization
class _MoodFrequencyChart extends StatelessWidget {
  final Map<String, double> emotionFrequency;
  final double height;

  const _MoodFrequencyChart({
    required this.emotionFrequency,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (emotionFrequency.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TrueCircleLoadings.floatingDotsLoader(size: 30),
              const SizedBox(height: 16),
              Text(
                'Building your mood insights...',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    final sortedEmotions = emotionFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Frequency',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: sortedEmotions.map((entry) {
                final percentage = entry.value / sortedEmotions.first.value;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Bar chart with constrained height
                        Expanded(
                          flex: (percentage * 5).round().clamp(1, 5),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  _getMoodColor(entry.key),
                                  _getMoodColor(
                                    entry.key,
                                  ).withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Compact bottom labels with flexible height
                        SizedBox(
                          height: 24,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${entry.value.toInt()}',
                                style: const TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getMoodEmoji(entry.key),
                                      style: const TextStyle(fontSize: 8),
                                    ),
                                    const SizedBox(width: 1),
                                    Flexible(
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    final colors = {
      'happy': const Color(0xFFF4AB37),
      'sad': const Color(0xFF8B5CF6),
      'anxious': const Color(0xFFEC407A),
      'calm': const Color(0xFF14B8A6),
      'angry': const Color(0xFFFF8A65),
      'excited': const Color(0xFF42A5F5),
      'tired': const Color(0xFF66BB6A),
    };
    return colors[mood.toLowerCase()] ?? const Color(0xFF64748B);
  }

  String _getMoodEmoji(String mood) {
    final emojis = {
      'happy': '😊',
      'sad': '😔',
      'anxious': '😰',
      'calm': '😌',
      'angry': '😠',
      'excited': '🤩',
      'tired': '😴',
    };
    return emojis[mood.toLowerCase()] ?? '😐';
  }
}

/// Weekly Trend Graph - Simple line chart
class _WeeklyTrendGraph extends StatelessWidget {
  final Map<String, double> weeklyTrends;
  final double height;

  const _WeeklyTrendGraph({required this.weeklyTrends, required this.height});

  @override
  Widget build(BuildContext context) {
    if (weeklyTrends.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No trend data available yet')),
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Trend',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _TrendLinePainter(weeklyTrends),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Painter for Trend Line
class _TrendLinePainter extends CustomPainter {
  final Map<String, double> data;

  _TrendLinePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final points = <Offset>[];
    final values = data.values.toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final normalizedValue = (values[i] - minValue) / (maxValue - minValue);
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    // Draw line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Feature Usage Stats
class _FeatureUsageStats extends StatelessWidget {
  final Map<String, int> featureUsage;

  const _FeatureUsageStats({required this.featureUsage});

  @override
  Widget build(BuildContext context) {
    if (featureUsage.isEmpty) {
      return const Center(child: Text('No usage data available'));
    }

    final sortedFeatures = featureUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Feature Usage',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...sortedFeatures.take(5).map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getFeatureIcon(entry.key),
                    color: const Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFeatureName(entry.key),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${entry.value} times used',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  IconData _getFeatureIcon(String feature) {
    final icons = {
      'mood_check': Icons.favorite_rounded,
      'cbt_session': Icons.psychology_rounded,
      'meditation': Icons.self_improvement_rounded,
      'dr_iris': Icons.smart_toy_rounded,
      'emotional_awareness': Icons.mood_rounded,
    };
    return icons[feature] ?? Icons.star_rounded;
  }

  String _getFeatureName(String feature) {
    final names = {
      'mood_check': 'Mood Check-in',
      'cbt_session': 'CBT Session',
      'meditation': 'Meditation',
      'dr_iris': 'Dr. Iris Chat',
      'emotional_awareness': 'Emotional Awareness',
    };
    return names[feature] ?? feature;
  }
}

/// Insights List
class _InsightsList extends StatelessWidget {
  final List<WellnessInsight> insights;
  final Function(WellnessInsight)? onInsightTap;

  const _InsightsList({required this.insights, this.onInsightTap});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return const Center(child: Text('No insights available yet'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Insights',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getInsightColor(insight.type).withValues(alpha: 0.2),
              ),
            ),
            child: InkWell(
              onTap: () => onInsightTap?.call(insight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getInsightColor(insight.type),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          insight.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!insight.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insight.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getInsightColor(InsightType type) {
    final colors = {
      InsightType.progressCelebration: const Color(0xFF10B981),
      InsightType.concernAlert: const Color(0xFFEF4444),
      InsightType.moodPattern: const Color(0xFF6366F1),
      InsightType.streak: const Color(0xFFF59E0B),
      InsightType.recommendation: const Color(0xFF8B5CF6),
      InsightType.milestone: const Color(0xFF14B8A6),
    };
    return colors[type] ?? const Color(0xFF64748B);
  }
}

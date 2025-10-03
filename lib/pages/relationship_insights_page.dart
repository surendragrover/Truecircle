import 'package:flutter/material.dart';
import '../theme/coral_theme.dart';

class RelationshipInsightsPage extends StatelessWidget {
  final bool isFullMode;

  const RelationshipInsightsPage({super.key, required this.isFullMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: CoralTheme.appBarGradient),
        ),
        title: const Text('Relationship Insights', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: CoralTheme.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, size: 90, color: Colors.white),
                const SizedBox(height: 24),
                Text(
                  'Relationship Insights',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  isFullMode
                      ? 'In-depth relationship analysis activated. Personalized patterns and emotional connection metrics will appear here.'
                      : 'Sample mode: showing placeholder relationship metrics. Upgrade to full mode for deeper insights.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 32),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildInsightChip(Icons.trending_up, 'Growth', 'Positive Trends'),
                    _buildInsightChip(Icons.chat_bubble_outline, 'Communication', 'Healthy'),
                    _buildInsightChip(Icons.favorite_outline, 'Emotional Bond', 'Strong'),
                    _buildInsightChip(Icons.schedule, 'Consistency', 'Improving'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

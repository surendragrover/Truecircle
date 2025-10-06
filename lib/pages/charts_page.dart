import 'package:flutter/material.dart';
import '../models/emotion_entry.dart';

class ChartsPage extends StatelessWidget {
  final List<EmotionEntry> entries;

  const ChartsPage({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Emotion Charts'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No data to display',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Add some emotions to see charts!',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final sortedEntries = List<EmotionEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Charts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Stats Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Summary Statistics',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Total Entries',
                          entries.length.toString(),
                          Icons.analytics,
                          Colors.blue,
                        ),
                        _buildStatItem(
                          'Average Intensity',
                          _calculateAverageIntensity().toStringAsFixed(1),
                          Icons.trending_up,
                          Colors.green,
                        ),
                        _buildStatItem(
                          'Unique Emotions',
                          _getUniqueEmotions().length.toString(),
                          Icons.emoji_emotions,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Intensity Trend Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intensity Trend',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildIntensityTrendChart(sortedEntries),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Emotion Distribution Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emotion Distribution',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildEmotionDistributionChart(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Intensity Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intensity Distribution',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildIntensityDistributionChart(),
                  ],
                ),
              ),
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
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIntensityTrendChart(List<EmotionEntry> sortedEntries) {
    const maxIntensity = 10.0;
    const minIntensity = 1.0;

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: IntensityTrendPainter(
        entries: sortedEntries,
        maxIntensity: maxIntensity,
        minIntensity: minIntensity,
      ),
    );
  }

  Widget _buildEmotionDistributionChart() {
    final emotionCounts = <String, int>{};
    for (final entry in entries) {
      emotionCounts[entry.emotion] = (emotionCounts[entry.emotion] ?? 0) + 1;
    }

    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maxCount = sortedEmotions.isNotEmpty ? sortedEmotions.first.value : 1;

    return Column(
      children: sortedEmotions.map((entry) {
        final percentage = (entry.value / entries.length * 100);
        final barWidth = (entry.value / maxCount);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: barWidth,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation(_getEmotionColor(entry.key)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIntensityDistributionChart() {
    final intensityCounts = <int, int>{};
    for (int i = 1; i <= 10; i++) {
      intensityCounts[i] = 0;
    }

    for (final entry in entries) {
      intensityCounts[entry.intensity] =
          (intensityCounts[entry.intensity] ?? 0) + 1;
    }

    final maxCount = intensityCounts.values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(10, (index) {
          final intensity = index + 1;
          final count = intensityCounts[intensity] ?? 0;
          final height = maxCount > 0 ? (count / maxCount * 150) : 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                width: 20,
                height: height,
                decoration: BoxDecoration(
                  color: _getIntensityColor(intensity),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                intensity.toString(),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        }),
      ),
    );
  }

  double _calculateAverageIntensity() {
    if (entries.isEmpty) return 0.0;
    final sum = entries.map((e) => e.intensity).reduce((a, b) => a + b);
    return sum / entries.length;
  }

  Set<String> _getUniqueEmotions() {
    return entries.map((e) => e.emotion).toSet();
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.yellow[700]!;
      case 'sad':
        return Colors.blue[700]!;
      case 'angry':
        return Colors.red[700]!;
      case 'anxious':
        return Colors.purple[700]!;
      case 'excited':
        return Colors.orange[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Color _getIntensityColor(int intensity) {
    if (intensity <= 3) return Colors.green;
    if (intensity <= 6) return Colors.yellow[700]!;
    if (intensity <= 8) return Colors.orange;
    return Colors.red;
  }
}

class IntensityTrendPainter extends CustomPainter {
  final List<EmotionEntry> entries;
  final double maxIntensity;
  final double minIntensity;

  IntensityTrendPainter({
    required this.entries,
    required this.maxIntensity,
    required this.minIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < entries.length; i++) {
      final x = (i / (entries.length - 1)) * size.width;
      final normalizedIntensity =
          (entries[i].intensity - minIntensity) / (maxIntensity - minIntensity);
      final y = size.height - (normalizedIntensity * size.height);

      final point = Offset(x, y);
      points.add(point);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Horizontal grid lines (intensity levels)
    for (int i = 1; i <= 10; i++) {
      final normalizedIntensity =
          (i - minIntensity) / (maxIntensity - minIntensity);
      final y = size.height - (normalizedIntensity * size.height);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

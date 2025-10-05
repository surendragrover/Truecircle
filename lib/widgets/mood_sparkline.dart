import 'package:flutter/material.dart';

class MoodSparkline extends StatelessWidget {
  final List<int> points; // mood scores 1-10
  const MoodSparkline({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(height: 32, child: Center(child: Text('—')));
    }
    final maxVal = (points.reduce((a, b) => a > b ? a : b)).toDouble();
    final minVal = (points.reduce((a, b) => a < b ? a : b)).toDouble();
    final range = (maxVal - minVal).clamp(1, 20);
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((p) {
          final h = ((p - minVal) / range) * 32 + 6;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                height: h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.blue.withValues(alpha: 0.7),
                      Colors.purple.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

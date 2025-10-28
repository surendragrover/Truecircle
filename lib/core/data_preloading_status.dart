import 'package:flutter/material.dart';
import '../services/app_data_preloader.dart';

class DataPreloadingStatus extends StatefulWidget {
  const DataPreloadingStatus({super.key});

  @override
  State<DataPreloadingStatus> createState() => _DataPreloadingStatusState();
}

class _DataPreloadingStatusState extends State<DataPreloadingStatus> {
  Map<String, bool> _loadingStatus = {};

  @override
  void initState() {
    super.initState();
    _checkLoadingStatus();
  }

  void _checkLoadingStatus() {
    setState(() {
      _loadingStatus = AppDataPreloader.instance.getLoadingStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allLoaded = _loadingStatus.values.every((loaded) => loaded);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  allLoaded ? Icons.check_circle : Icons.hourglass_empty,
                  color: allLoaded ? Colors.green : theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Data Preloading Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_loadingStatus.isEmpty)
              const Text('No data preloading status available')
            else
              Column(
                children: _loadingStatus.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          entry.value ? Icons.check : Icons.pending,
                          size: 16,
                          color: entry.value ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getReadableName(entry.key),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        if (entry.value)
                          const Icon(Icons.done, size: 16, color: Colors.green),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),

            // Refresh button
            Center(
              child: ElevatedButton.icon(
                onPressed: _checkLoadingStatus,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Status'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReadableName(String key) {
    switch (key) {
      case 'cbt_data':
        return 'CBT Techniques & Thoughts';
      case 'emotional_awareness':
        return 'Emotional Awareness';
      case 'meditation':
        return 'Meditation Guides';
      case 'sleep':
        return 'Sleep Tracking';
      case 'psychology':
        return 'Psychology Articles';
      case 'festivals':
        return 'Festival Data';
      case 'relationships':
        return 'Relationship Insights';
      case 'mood':
        return 'Mood Journal';
      case 'breathing':
        return 'Breathing Exercises';
      case 'additional':
        return 'Additional Content';
      default:
        return key.replaceAll('_', ' ').toUpperCase();
    }
  }
}

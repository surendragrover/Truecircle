import 'package:flutter/material.dart';
import '../services/sample_data_service.dart';
import '../widgets/dr_iris_avatar.dart';
import '../services/language_service.dart';

class EmotionalCheckInPage extends StatefulWidget {
  const EmotionalCheckInPage({super.key});

  @override
  State<EmotionalCheckInPage> createState() => _EmotionalCheckInPageState();
}

class _EmotionalCheckInPageState extends State<EmotionalCheckInPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _emotionalData = [];
  int _selectedIntensity = 5;
  String _selectedEmotion = 'Happy';
  final TextEditingController _notesController = TextEditingController();

  final List<String> _emotions = [
    'Happy',
    'Sad',
    'Excited',
    'Calm',
    'Stressed',
    'Grateful',
    'Anxious',
    'Angry',
    'Confused',
    'Peaceful'
  ];

  // Commented out unused field for now
  // final List<String> _triggers = [
  //   'Work', 'Family', 'Friends', 'Health', 'Weather',
  //   'Social Events', 'Exercise', 'Sleep', 'Food', 'News'
  // ];

  @override
  void initState() {
    super.initState();
    _loadEmotionalData();
  }

  Future<void> _loadEmotionalData() async {
    try {
      final data =
          await SampleDataService.instance.getFormattedEmotionalInsights();
      setState(() {
        _emotionalData = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading emotional data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            DrIrisAvatar(size: 32, isHindi: true),
            SizedBox(width: 12),
            AutoTranslateText('Emotional Check-in'),
          ],
        ),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showNewCheckInDialog,
            tooltip: 'New Check-in',
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
                  _buildTodaysCheckIn(),
                  const SizedBox(height: 20),
                  _buildEmotionalTrends(),
                  const SizedBox(height: 20),
                  _buildRecentEntries(),
                  const SizedBox(height: 20),
                  _buildDrIrisInsights(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewCheckInDialog,
        icon: const Icon(Icons.mood),
        label: const AutoTranslateText('Check-in Now'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildTodaysCheckIn() {
    final todayEntry = _emotionalData.isNotEmpty ? _emotionalData.first : null;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const AutoTranslateText(
                  'Today\'s Check-in',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (todayEntry != null) ...[
              _buildEmotionalEntry(todayEntry, isToday: true),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(Icons.mood_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    const AutoTranslateText(
                      'No check-in today yet',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _showNewCheckInDialog,
                      child: const AutoTranslateText('Start Today\'s Check-in'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalTrends() {
    final intensities =
        _emotionalData.take(7).map((e) => e['intensity'] as int).toList();
    final avgIntensity = intensities.isNotEmpty
        ? intensities.reduce((a, b) => a + b) / intensities.length
        : 5.0;

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
                const AutoTranslateText(
                  'Weekly Emotional Trends',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTrendItem(
                    'Average Intensity',
                    avgIntensity.toStringAsFixed(1),
                    Icons.speed,
                    _getIntensityColor(avgIntensity.round()),
                  ),
                ),
                Expanded(
                  child: _buildTrendItem(
                    'Total Check-ins',
                    '${_emotionalData.length}',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildTrendItem(
                    'Streak',
                    '15 days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const AutoTranslateText(
              'Intensity Distribution (Last 7 days):',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: intensities
                  .map((intensity) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 2),
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getIntensityColor(intensity),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '$intensity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(
      String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        AutoTranslateText(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentEntries() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const AutoTranslateText(
                  'Recent Check-ins',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._emotionalData
                .take(10)
                .map((entry) => _buildEmotionalEntry(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalEntry(Map<String, dynamic> entry,
      {bool isToday = false}) {
    final emotion = entry['emotion'] as Map<String, dynamic>? ?? {};
    final intensity = entry['intensity'] as int? ?? 5;
    final notes = entry['notes'] as Map<String, dynamic>? ?? {};
    final trigger = entry['trigger'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: _getIntensityColor(intensity),
                child: Text(
                  '$intensity',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${emotion['en'] ?? 'Unknown'} / ${emotion['hi'] ?? 'अज्ञात'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (trigger['en'] != null)
                      Text(
                        'Trigger: ${trigger['en']} / ${trigger['hi'] ?? ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                entry['date'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (notes['en'] != null && notes['en'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${notes['en']}\n${notes['hi'] ?? ''}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrIrisInsights() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                DrIrisAvatar(size: 40, isHindi: true),
                SizedBox(width: 12),
                AutoTranslateText(
                  'Dr. Iris Emotional Analysis',
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
                    '🎯 Your Emotional Pattern:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  AutoTranslateText(
                    'You show remarkable emotional awareness and consistency in tracking your feelings. Your intensity levels suggest good emotional regulation with occasional stress peaks.',
                  ),
                  SizedBox(height: 12),
                  AutoTranslateText(
                    '💡 Personalized Suggestions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  AutoTranslateText(
                    '• Practice deep breathing when intensity is >7\n'
                    '• Celebrate positive emotions with gratitude\n'
                    '• Track triggers to identify patterns\n'
                    '• Share feelings with trusted family members',
                  ),
                  SizedBox(height: 12),
                  AutoTranslateText(
                    '🌟 Cultural Insight:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  AutoTranslateText(
                    'Your emotional expression aligns beautifully with Indian cultural values of mindfulness and family connection. Continue this beautiful journey!',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIntensityColor(int intensity) {
    if (intensity <= 3) return Colors.green;
    if (intensity <= 6) return Colors.orange;
    return Colors.red;
  }

  void _showNewCheckInDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const AutoTranslateText('New Emotional Check-in'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AutoTranslateText(
                  'How are you feeling right now?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedEmotion,
                  decoration: const InputDecoration(
                    labelText: 'Select Emotion',
                    border: OutlineInputBorder(),
                  ),
                  items: _emotions
                      .map((emotion) => DropdownMenuItem(
                            value: emotion,
                            child: AutoTranslateText(emotion),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedEmotion = value!);
                  },
                ),
                const SizedBox(height: 16),
                const AutoTranslateText(
                  'Intensity (1-10):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _selectedIntensity.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$_selectedIntensity',
                        onChanged: (value) {
                          setState(() => _selectedIntensity = value.round());
                        },
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getIntensityColor(_selectedIntensity),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$_selectedIntensity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'What triggered this feeling?',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const AutoTranslateText('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _saveCheckIn();
              Navigator.pop(context);
              _resetForm();
            },
            child: const AutoTranslateText('Save Check-in'),
          ),
        ],
      ),
    );
  }

  void _saveCheckIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: AutoTranslateText(
            'Check-in saved! Thank you for tracking your emotions.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetForm() {
    _selectedIntensity = 5;
    _selectedEmotion = 'Happy';
    _notesController.clear();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

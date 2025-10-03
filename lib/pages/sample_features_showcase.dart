import 'package:flutter/material.dart';
import '../services/sample_data_service.dart';
import '../services/language_service.dart';
import '../widgets/dr_iris_avatar.dart';
import '../widgets/truecircle_logo.dart';

class SampleFeaturesShowcase extends StatefulWidget {
  const SampleFeaturesShowcase({super.key});

  @override
  State<SampleFeaturesShowcase> createState() => _SampleFeaturesShowcaseState();
}

class _SampleFeaturesShowcaseState extends State<SampleFeaturesShowcase> {
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic> _dashboardData = {};

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  Future<void> _loadSampleData() async {
    try {
      final data = SampleDataService.getComprehensiveDashboardData();
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
  debugPrint('Error loading sample data: $e');
      setState(() {
        _isLoading = false;
      });
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
            AutoTranslateText('TrueCircle - Sample Features'),
          ],
        ),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Feature Tabs
                  _buildFeatureTabs(),
                  const SizedBox(height: 16),

                  // Feature Content
                  _buildFeatureContent(),

                  const SizedBox(height: 24),

                  // Dr. Iris Insights
                  _buildDrIrisInsights(),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mood),
            label: 'Emotions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Relations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bedtime),
            label: 'Sleep',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final summary = _dashboardData['summary'] ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const TrueCircleLogo(size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '30-Day Sample Data Overview',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildSummaryItem(
                        'Mood Avg', summary['average_mood'] ?? '0', '😊')),
                Expanded(
                    child: _buildSummaryItem('Relations',
                        summary['relationship_health_score'] ?? '0', '❤️')),
                Expanded(
                    child: _buildSummaryItem('Entries',
                        '${summary['total_emotional_entries'] ?? 0}', '📊')),
                Expanded(
                    child: _buildSummaryItem('Sleep',
                        '${summary['total_sleep_entries'] ?? 0}', '😴')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureTabs() {
    final tabs = ['Emotions', 'Journal', 'Relations', 'Sleep'];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentIndex;
          return GestureDetector(
            onTap: () => setState(() => _currentIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureContent() {
    switch (_currentIndex) {
      case 0:
        return _buildEmotionalInsights();
      case 1:
        return _buildMoodJournal();
      case 2:
        return _buildRelationshipInsights();
      case 3:
        return _buildSleepTracking();
      default:
        return _buildEmotionalInsights();
    }
  }

  Widget _buildEmotionalInsights() {
    final emotionalData = _dashboardData['emotional_insights'] as List? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mood, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Emotional Check-ins (7 days)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...emotionalData.map((entry) {
              final emotion = entry['emotion'] as Map<String, dynamic>? ?? {};
              final intensity = entry['intensity'] ?? 5;
              final notes = entry['notes'] as Map<String, dynamic>? ?? {};

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getIntensityColor(intensity),
                  child: Text(
                    '$intensity',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  '${emotion['en'] ?? 'Unknown'} / ${emotion['hi'] ?? 'अज्ञात'}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${notes['en'] ?? 'No notes'}\n${notes['hi'] ?? 'कोई नोट नहीं'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(entry['date'] ?? 'Unknown'),
                dense: true,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodJournal() {
    final moodData = _dashboardData['mood_journal'] as List? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.book, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Mood Journal Entries (7 days)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...moodData.map((entry) {
              final moodRating = entry['mood_rating'] ?? 5;
              final title = entry['title'] ?? 'No title';
              final detailedEntry = entry['detailed_entry'] ?? 'No entry';
              final tags = entry['tags'] as List? ?? [];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: _getMoodColor(moodRating),
                            child: Text(
                              '$moodRating',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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
                      const SizedBox(height: 8),
                      Text(
                        detailedEntry,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: tags
                              .map<Widget>((tag) => Chip(
                                    label: Text(
                                      '$tag',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor: Colors.blue.shade50,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    padding: EdgeInsets.zero,
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationshipInsights() {
    final relationshipData =
        _dashboardData['relationship_insights'] as List? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.pink),
                const SizedBox(width: 8),
                Text(
                  'Relationship Insights (10 recent)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...relationshipData.map((entry) {
              final relationshipType = entry['relationship_type'] ?? 'Unknown';
              final relationshipTypeHindi =
                  entry['relationship_type_hindi'] ?? 'अज्ञात';
              final title = entry['title'] ?? 'No title';
              final titleHindi = entry['title_hindi'] ?? 'कोई शीर्षक नहीं';
              final score = entry['relationship_score'] ?? 5;
              final moodEffect = entry['mood_effect'] ?? 'Neutral';
              final interactionDetail =
                  entry['interaction_detail'] ?? 'No details';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                _getRelationshipColor(relationshipType),
                            child: Text(
                              '$score',
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
                                  '$title / $titleHindi',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '$relationshipType / $relationshipTypeHindi',
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
                      const SizedBox(height: 8),
                      Text(
                        interactionDetail,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Mood: $moodEffect',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTracking() {
    final sleepData = _dashboardData['sleep_tracking'] as List? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bedtime, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(
                  'Sleep Tracking (7 days)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...sleepData.map((entry) {
              final sleepDuration = entry['sleep_duration'] ?? '7h 0m';
              final sleepQuality = entry['sleep_quality'] ?? 5;
              final bedtime = entry['bedtime'] ?? '22:00';
              final wakeupTime = entry['wakeup_time'] ?? '07:00';
              final deepSleep = entry['deep_sleep_percentage'] ?? 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                _getSleepQualityColor(sleepQuality),
                            child: Text(
                              '$sleepQuality',
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
                                  sleepDuration,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '$bedtime - $wakeupTime',
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Deep Sleep: $deepSleep%',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.indigo.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
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
            Row(
              children: [
                const DrIrisAvatar(size: 40, isHindi: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dr. Iris AI Insights',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎯 30-Day Summary Analysis:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on your sample data, I notice strong relationship patterns and consistent emotional well-being. Your mood journal shows cultural festivities positively impact your happiness.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '📊 Key Insights:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Family interactions consistently score 9+\n'
                    '• Monsoon season correlates with nostalgic moods\n'
                    '• Festival preparations boost relationship scores\n'
                    '• Sleep quality improves on celebration days',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '🎉 Cultural Recommendations:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Plan Diwali family video calls\n'
                    '• Send monsoon poetry to friends\n'
                    '• Schedule chai time with loved ones\n'
                    '• Practice gratitude during festivals',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
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

  Color _getMoodColor(int mood) {
    if (mood <= 3) return Colors.red;
    if (mood <= 6) return Colors.orange;
    if (mood <= 8) return Colors.lightGreen;
    return Colors.green;
  }

  Color _getRelationshipColor(String type) {
    switch (type.toLowerCase()) {
      case 'family':
        return Colors.pink;
      case 'friend':
        return Colors.blue;
      case 'colleague':
        return Colors.teal;
      case 'partner':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getSleepQualityColor(int quality) {
    if (quality <= 3) return Colors.red;
    if (quality <= 6) return Colors.orange;
    if (quality <= 8) return Colors.lightBlue;
    return Colors.indigo;
  }
}

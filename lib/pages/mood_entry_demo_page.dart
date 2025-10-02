// lib/pages/mood_entry_demo_page.dart

import 'package:flutter/material.dart';
import '../models/mood_entry.dart';
import '../services/mood_entry_service.dart';

/// Demo page for MoodEntry functionality
/// 
/// Demonstrates offline NLP analysis and mood tracking features
/// Privacy-first implementation with demo data support
class MoodEntryDemoPage extends StatefulWidget {
  const MoodEntryDemoPage({super.key});

  @override
  State<MoodEntryDemoPage> createState() => _MoodEntryDemoPageState();
}

class _MoodEntryDemoPageState extends State<MoodEntryDemoPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MoodEntryService _moodService = MoodEntryService();
  
  List<MoodEntry> _moodEntries = [];
  MoodStatistics? _statistics;
  bool _isLoading = false;
  bool _isServiceInitialized = false;
  
  final TextEditingController _moodTextController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() => _isLoading = true);
    
    try {
      await _moodService.initialize();
      setState(() => _isServiceInitialized = true);
      await _loadMoodEntries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Service initialization failed: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoodEntries() async {
    if (!_isServiceInitialized) return;
    
    setState(() => _isLoading = true);
    
    try {
      final entries = await _moodService.getRecentMoodEntries(days: 30);
      final stats = await _moodService.getMoodStatistics(
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      setState(() {
        _moodEntries = entries;
        _statistics = stats;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load entries: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addMoodEntry() async {
    if (_moodTextController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया अपनी भावना दर्ज करें')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await _moodService.createMoodEntry(
        userText: _moodTextController.text.trim(),
        relatedContactId: _contactController.text.trim().isNotEmpty 
            ? _contactController.text.trim() 
            : null,
        performImmediateAnalysis: true,
      );
      
      _moodTextController.clear();
      _contactController.clear();
      
      await _loadMoodEntries();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ मूड एंट्री successfully created और analyzed!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create mood entry: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDemoData() async {
    setState(() => _isLoading = true);
    
    try {
      final demoEntries = await _moodService.getDemoData();
      
      // Add demo entries to database
      for (final entry in demoEntries) {
        await _moodService.createMoodEntry(
          userText: entry.userText,
          relatedContactId: entry.relatedContactId,
          date: entry.date,
          performImmediateAnalysis: false, // Already analyzed in demo data
        );
      }
      
      await _loadMoodEntries();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Demo data loaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load demo data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 MoodEntry Demo - NLP Analysis'),
        backgroundColor: Colors.purple.shade100,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add), text: 'Add Entry'),
            Tab(icon: Icon(Icons.list), text: 'Entries'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAddEntryTab(),
                _buildEntriesTab(),
                _buildAnalyticsTab(),
                _buildSettingsTab(),
              ],
            ),
    );
  }

  Widget _buildAddEntryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📝 नई मूड एंट्री बनाएं',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _moodTextController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'अपनी भावना दर्ज करें',
                      hintText: 'आज मैं कैसा महसूस कर रहा हूं...',
                      border: OutlineInputBorder(),
                      helperText: 'AI आपकी भावना और तनाव का विश्लेषण करेगा',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contactController,
                    decoration: const InputDecoration(
                      labelText: 'संबंधित व्यक्ति (optional)',
                      hintText: 'Contact ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isServiceInitialized ? _addMoodEntry : null,
                    icon: const Icon(Icons.psychology),
                    label: const Text('AI विश्लेषण के साथ जोड़ें'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🤖 NLP Analysis Features',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Sentiment Analysis (भावना विश्लेषण)'),
                  const Text('• Stress Level Detection (तनाव स्तर)'),
                  const Text('• Keyword Extraction (मुख्य शब्द)'),
                  const Text('• Emotion Recognition (भावना पहचान)'),
                  const Text('• Hindi/English Support'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadDemoData,
                    icon: const Icon(Icons.download),
                    label: const Text('Demo Data Load करें'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade100,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📚 Total Entries: ${_moodEntries.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _loadMoodEntries,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        Expanded(
          child: _moodEntries.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mood, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('कोई mood entries नहीं मिलीं'),
                      Text('नई entry add करें या demo data load करें'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _moodEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _moodEntries[index];
                    return _buildMoodEntryCard(entry);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMoodEntryCard(MoodEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMoodColor(entry.identifiedMood),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.identifiedMood,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.userText,
              style: const TextStyle(fontSize: 16),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip('Stress: ${entry.stressLevel}', Icons.speed),
                const SizedBox(width: 8),
                _buildInfoChip(
                  'Sentiment: ${(entry.sentimentScore * 100).toStringAsFixed(0)}%',
                  Icons.sentiment_satisfied,
                ),
              ],
            ),
            if (entry.extractedKeywords.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: entry.extractedKeywords.take(5).map((keyword) {
                  return Chip(
                    label: Text(keyword, style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.grey.shade200,
                  );
                }).toList(),
              ),
            ],
            if (entry.detectedEmotions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Emotions: ${entry.detectedEmotions.take(3).map((e) => e.toString()).join(", ")}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            if (entry.relatedContactId.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Related: ${entry.relatedContactId}',
                style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'grateful':
        return Colors.green;
      case 'sad':
      case 'depressed':
        return Colors.blue;
      case 'angry':
      case 'frustrated':
        return Colors.red;
      case 'anxious':
      case 'worried':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Mood Analytics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_statistics != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statistics!.toSummaryString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_statistics!.moodDistribution.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mood Distribution',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._statistics!.moodDistribution.entries.map((entry) {
                        final percentage = (entry.value / _statistics!.totalEntries * 100);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(entry.key),
                              ),
                              Expanded(
                                flex: 3,
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(
                                    _getMoodColor(entry.key),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${percentage.toStringAsFixed(0)}%'),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ] else ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No analytics data available. Add some mood entries first.'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ MoodEntry Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Service Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusRow('Service Initialized', _isServiceInitialized),
                  _buildStatusRow('Privacy Mode', true), // Always true in demo
                  _buildStatusRow('NLP Analysis', true),
                  _buildStatusRow('Hindi Support', true),
                  _buildStatusRow('English Support', true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final analyzed = await _moodService.analyzePendingEntries();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ Analyzed ${analyzed.length} pending entries'),
                          ),
                        );
                      }
                      await _loadMoodEntries();
                    },
                    icon: const Icon(Icons.psychology),
                    label: const Text('Analyze Pending Entries'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _loadDemoData,
                    icon: const Icon(Icons.download),
                    label: const Text('Load Demo Data'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear All Entries'),
                          content: const Text('यह सभी mood entries को delete कर देगा। Continue?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete All'),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirmed == true) {
                        await _moodService.clearAllEntries();
                        await _loadMoodEntries();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All entries cleared')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Clear All Entries'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Icon(
            status ? Icons.check_circle : Icons.cancel,
            color: status ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _moodTextController.dispose();
    _contactController.dispose();
    _moodService.dispose();
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/relationship_contact.dart';
import '../models/communication_entry.dart';
import '../services/relationship_pulse_analyzer.dart';
import '../services/communication_tracker_service.dart';
import '../core/service_locator.dart';
import '../core/video_auto_player.dart';
import 'relationship_network_visualization.dart';
import 'voice_command_interface.dart';

/// Interactive insights dashboard with voice commands and visual relationship maps
/// Provides contextual AI advice based on current emotional state
class InteractiveInsightsDashboard extends StatefulWidget {
  const InteractiveInsightsDashboard({super.key});

  @override
  State<InteractiveInsightsDashboard> createState() =>
      _InteractiveInsightsDashboardState();
}

class _InteractiveInsightsDashboardState
    extends State<InteractiveInsightsDashboard>
    with TickerProviderStateMixin {
  late CommunicationTrackerService _service;
  late TabController _tabController;
  late AnimationController _pulseAnimationController;

  List<RelationshipContact> _contacts = [];
  Map<String, RelationshipPulseScore> _pulseScores = {};
  Map<String, List<CommunicationEntry>> _contactEntries = {};

  bool _isLoading = true;
  bool _isListening = false;
  String _currentEmotionalState = 'neutral';

  // Voice command integration
  late stt.SpeechToText _speechToText;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _service = ServiceLocator.instance.get<CommunicationTrackerService>();
    _tabController = TabController(length: 4, vsync: this);
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _speechToText = stt.SpeechToText();
    _initializeData();
    _initializeSpeech();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      final contacts = _service.getAllContacts();
      final pulseScores = <String, RelationshipPulseScore>{};
      final contactEntries = <String, List<CommunicationEntry>>{};

      for (final contact in contacts) {
        final entries = _service.getEntriesForContact(contact.id);
        contactEntries[contact.id] = entries;
        pulseScores[contact.id] = RelationshipPulseAnalyzer.calculatePulseScore(
          contact,
          entries,
        );
      }

      if (mounted) {
        setState(() {
          _contacts = contacts;
          _pulseScores = pulseScores;
          _contactEntries = contactEntries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) => debugPrint('Speech status: $status'),
      onError: (error) => debugPrint('Speech error: $error'),
    );

    if (!available) {
      debugPrint('Speech recognition not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing relationships...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeaderWithVideo(),
                title: const Text(
                  'Relationship Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _toggleVoiceCommand,
                  icon: AnimatedBuilder(
                    animation: _pulseAnimationController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.3),
                                    blurRadius:
                                        10 * _pulseAnimationController.value,
                                    spreadRadius:
                                        5 * _pulseAnimationController.value,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: _showEmotionalStateSelector,
                  icon: const Icon(Icons.psychology),
                ),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Pulse Scores'),
                    Tab(text: 'Network Map'),
                    Tab(text: 'AI Insights'),
                    Tab(text: 'Voice Commands'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPulseScoreTab(),
            _buildNetworkMapTab(),
            _buildAIInsightsTab(),
            _buildVoiceCommandTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showContextualAdvice,
        icon: const Icon(Icons.psychology),
        label: const Text('Get AI Advice'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildHeaderWithVideo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade600, Colors.blue.shade600],
        ),
      ),
      child: Stack(
        children: [
          // Background video
          Positioned(
            top: 20,
            right: 20,
            child: TrueCircleCoinAnimation(size: 80),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.pink.shade300,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_contacts.length} Active Relationships',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Overall Health: ${_calculateOverallHealth().toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
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

  Widget _buildPulseScoreTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final pulseScore = _pulseScores[contact.id];

        if (pulseScore == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: pulseScore.categoryColor,
                      child: Text(
                        contact.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            pulseScore.healthCategory,
                            style: TextStyle(
                              color: pulseScore.categoryColor,
                              fontWeight: FontWeight.w500,
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
                        color: pulseScore.categoryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pulseScore.overallScore.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildPulseMetric(
                  'Communication Frequency',
                  pulseScore.communicationFrequency,
                  Icons.chat_bubble_outline,
                ),
                _buildPulseMetric(
                  'Emotional Connection',
                  pulseScore.emotionalConnection,
                  Icons.favorite_outline,
                ),
                _buildPulseMetric(
                  'Conflict Resolution',
                  pulseScore.conflictResolution,
                  Icons.handshake_outlined,
                ),
                _buildPulseMetric(
                  'Growth Trend',
                  pulseScore.growthTrend,
                  Icons.trending_up,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseMetric(String label, double value, IconData icon) {
    final color = value >= 70
        ? Colors.green
        : value >= 40
        ? Colors.orange
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkMapTab() {
    return RelationshipNetworkVisualization(
      contacts: _contacts,
      pulseScores: _pulseScores,
      onContactTapped: (contact) {
        // Navigate to contact details
        debugPrint('Tapped on ${contact.name}');
      },
    );
  }

  Widget _buildAIInsightsTab() {
    final allInsights = <RelationshipInsight>[];

    for (final contact in _contacts) {
      final pulseScore = _pulseScores[contact.id];
      final entries = _contactEntries[contact.id] ?? [];

      if (pulseScore != null) {
        final insights = RelationshipPulseAnalyzer.generatePersonalizedInsights(
          contact,
          entries,
          pulseScore,
        );
        allInsights.addAll(insights);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allInsights.length,
      itemBuilder: (context, index) {
        final insight = allInsights[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
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
                        color: _getSeverityColor(
                          insight.severity,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getInsightIcon(insight.type),
                        color: _getSeverityColor(insight.severity),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            insight.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (insight.actionable &&
                    insight.suggestedActions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Suggested Actions:',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  ...insight.suggestedActions.map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Text(
                              action,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
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

  Widget _buildVoiceCommandTab() {
    return VoiceCommandInterface(
      isListening: _isListening,
      lastWords: _lastWords,
      emotionalState: _currentEmotionalState,
      onVoiceCommand: _processVoiceCommand,
      onToggleListening: _toggleVoiceCommand,
    );
  }

  // Helper Methods
  double _calculateOverallHealth() {
    if (_pulseScores.isEmpty) return 0;

    final totalScore = _pulseScores.values
        .map((score) => score.overallScore)
        .reduce((a, b) => a + b);

    return totalScore / _pulseScores.length;
  }

  Color _getSeverityColor(InsightSeverity severity) {
    switch (severity) {
      case InsightSeverity.low:
        return Colors.green;
      case InsightSeverity.medium:
        return Colors.orange;
      case InsightSeverity.high:
        return Colors.red;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.communicationFrequency:
        return Icons.chat_bubble_outline;
      case InsightType.emotionalConnection:
        return Icons.favorite_outline;
      case InsightType.conflictResolution:
        return Icons.handshake_outlined;
      case InsightType.positive:
        return Icons.star_outline;
      case InsightType.growth:
        return Icons.trending_up;
      case InsightType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  void _toggleVoiceCommand() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() async {
    if (!_speechToText.isAvailable) return;

    setState(() => _isListening = true);

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords;
          if (result.finalResult) {
            _processVoiceCommand(_lastWords);
            _isListening = false;
          }
        });
      },
      listenFor: const Duration(seconds: 10),
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _processVoiceCommand(String command) {
    // Process voice commands for AI assistant interaction
    final lowerCommand = command.toLowerCase();

    if (lowerCommand.contains('show') &&
        lowerCommand.contains('relationship')) {
      _tabController.animateTo(1); // Navigate to network map
    } else if (lowerCommand.contains('advice') ||
        lowerCommand.contains('help')) {
      _showContextualAdvice();
    } else if (lowerCommand.contains('pulse') ||
        lowerCommand.contains('score')) {
      _tabController.animateTo(0); // Navigate to pulse scores
    }

    // Update emotional state based on voice tone (simplified)
    if (lowerCommand.contains('sad') || lowerCommand.contains('upset')) {
      _currentEmotionalState = 'sad';
    } else if (lowerCommand.contains('happy') ||
        lowerCommand.contains('good')) {
      _currentEmotionalState = 'happy';
    } else if (lowerCommand.contains('angry') ||
        lowerCommand.contains('frustrated')) {
      _currentEmotionalState = 'angry';
    }
  }

  void _showEmotionalStateSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How are you feeling?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Happy', 'Sad', 'Angry', 'Anxious', 'Neutral']
              .map(
                (emotion) => ListTile(
                  title: Text(emotion),
                  leading: Icon(_getEmotionIcon(emotion)),
                  onTap: () {
                    setState(
                      () => _currentEmotionalState = emotion.toLowerCase(),
                    );
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_dissatisfied;
      case 'anxious':
        return Icons.sentiment_neutral;
      default:
        return Icons.sentiment_neutral;
    }
  }

  void _showContextualAdvice() {
    final advice = _generateContextualAdvice();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('AI Relationship Coach'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Based on your current emotional state ($_currentEmotionalState) and relationship patterns:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...advice.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.amber.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(tip)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  List<String> _generateContextualAdvice() {
    final advice = <String>[];
    final overallHealth = _calculateOverallHealth();

    // Emotional state based advice
    switch (_currentEmotionalState) {
      case 'sad':
        advice.add(
          'When feeling down, reach out to your strongest relationships for support.',
        );
        advice.add('Consider sharing your feelings with someone you trust.');
        break;
      case 'angry':
        advice.add(
          'Take some time to cool down before having important conversations.',
        );
        advice.add(
          'Practice deep breathing and focus on understanding others\' perspectives.',
        );
        break;
      case 'anxious':
        advice.add(
          'Connect with calming presences in your life for reassurance.',
        );
        advice.add('Try scheduling regular check-ins to reduce uncertainty.');
        break;
      case 'happy':
        advice.add(
          'Share your positive energy with others - it\'s contagious!',
        );
        advice.add(
          'This is a great time to deepen connections and create memories.',
        );
        break;
      default:
        advice.add(
          'Regular communication is the foundation of healthy relationships.',
        );
    }

    // Relationship health based advice
    if (overallHealth < 50) {
      advice.add('Focus on your top 3 most important relationships first.');
      advice.add(
        'Consider having honest conversations about improving communication.',
      );
    } else if (overallHealth > 80) {
      advice.add('Your relationships are thriving! Consider mentoring others.');
      advice.add('Maintain your excellent communication patterns.');
    }

    return advice;
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

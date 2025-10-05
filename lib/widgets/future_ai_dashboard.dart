import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/contact.dart';
import '../models/contact_interaction.dart';
import '../models/emotion_entry.dart';
import '../services/future_ai_service.dart';

/// 🚀 Future AI Possibilities Dashboard
/// Showcases advanced AI features: Video Analysis, Location Insights, Group Dynamics, Mental Health
class FutureAIDashboard extends StatefulWidget {
  final List<Contact> contacts;
  final List<ContactInteraction> interactions;
  final List<EmotionEntry> moodEntries;

  const FutureAIDashboard({
    super.key,
    required this.contacts,
    required this.interactions,
    required this.moodEntries,
  });

  @override
  State<FutureAIDashboard> createState() => _FutureAIDashboardState();
}

class _FutureAIDashboardState extends State<FutureAIDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  VideoCallAnalysis? _videoAnalysis;
  LocationInsights? _locationInsights;
  GroupDynamicAnalysis? _groupAnalysis;
  MentalHealthImpactAnalysis? _mentalHealthAnalysis;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _generateSampleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _generateSampleData() {
    // Generate sample video call analysis
    if (widget.contacts.isNotEmpty) {
      final demoSessions = _generateSampleVideoSessions();
      _videoAnalysis = FutureAIService.analyzeVideoCallHealth(
        widget.contacts.first,
        demoSessions,
      );

      // Generate sample location insights
      final demoMeetings = _generateSampleLocationMeetings();
      _locationInsights = FutureAIService.analyzeLocationPatterns(
        widget.contacts.first,
        demoMeetings,
      );

      // Generate sample group analysis
      final demoConversations = _generateSampleGroupConversations();
      _groupAnalysis = FutureAIService.analyzeGroupDynamics(
        widget.contacts.take(4).toList(),
        demoConversations,
      );

      // Generate mental health analysis
      _mentalHealthAnalysis = FutureAIService.analyzeMentalHealthImpact(
        widget.contacts,
        widget.interactions,
        widget.moodEntries,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E27),
              Color(0xFF1A1B3E),
              Color(0xFF2A2D5A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildVideoAnalysisTab(),
                    _buildLocationInsightsTab(),
                    _buildGroupDynamicsTab(),
                    _buildMentalHealthTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF4285F4),
                            size: 32,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Future AI Possibilities',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Next-generation relationship intelligence',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Balance for back button
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF4285F4),
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        tabs: const [
          Tab(icon: Icon(Icons.videocam, size: 20), text: 'Video AI'),
          Tab(icon: Icon(Icons.location_on, size: 20), text: 'Location'),
          Tab(icon: Icon(Icons.group, size: 20), text: 'Group'),
          Tab(icon: Icon(Icons.psychology, size: 20), text: 'Mental'),
        ],
      ),
    );
  }

  Widget _buildVideoAnalysisTab() {
    if (_videoAnalysis == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('📹 Video Call Analysis',
              'Facial expressions से relationship health'),
          const SizedBox(height: 20),
          _buildVideoHealthScore(_videoAnalysis!),
          const SizedBox(height: 20),
          _buildEmotionalTrendsChart(_videoAnalysis!),
          const SizedBox(height: 20),
          _buildInsightsCard(_videoAnalysis!.insights, Colors.purple),
          const SizedBox(height: 20),
          _buildRecommendationsCard(
              _videoAnalysis!.recommendations, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildLocationInsightsTab() {
    if (_locationInsights == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('📍 Location-Based Insights',
              'कहाँ मिलते हैं, frequency क्या है'),
          const SizedBox(height: 20),
          _buildFrequentLocationsMap(_locationInsights!),
          const SizedBox(height: 20),
          _buildMeetingPatternsChart(_locationInsights!),
          const SizedBox(height: 20),
          _buildInsightsCard(_locationInsights!.insights, Colors.green),
          const SizedBox(height: 20),
          _buildRecommendationsCard(
              _locationInsights!.suggestions, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildGroupDynamicsTab() {
    if (_groupAnalysis == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
              '👥 Group Dynamic Analysis', 'Group conversations में dynamics'),
          const SizedBox(height: 20),
          _buildGroupHealthScore(_groupAnalysis!),
          const SizedBox(height: 20),
          _buildDominancePatternsChart(_groupAnalysis!),
          const SizedBox(height: 20),
          _buildInteractionMatrix(_groupAnalysis!),
          const SizedBox(height: 20),
          _buildInsightsCard(_groupAnalysis!.insights, Colors.cyan),
          const SizedBox(height: 20),
          _buildRecommendationsCard(
              _groupAnalysis!.recommendations, Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildMentalHealthTab() {
    if (_mentalHealthAnalysis == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🧠 Mental Health Integration',
              'Relationships का mood पर impact'),
          const SizedBox(height: 20),
          _buildMentalHealthScore(_mentalHealthAnalysis!),
          const SizedBox(height: 20),
          _buildContactImpactChart(_mentalHealthAnalysis!),
          const SizedBox(height: 20),
          _buildMoodTriggersSection(_mentalHealthAnalysis!),
          const SizedBox(height: 20),
          _buildInsightsCard(_mentalHealthAnalysis!.insights, Colors.pink),
          const SizedBox(height: 20),
          _buildRecommendationsCard(
              _mentalHealthAnalysis!.recommendations, Colors.deepPurple),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white60,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoHealthScore(VideoCallAnalysis analysis) {
    final score = analysis.overallHealthScore;
    final color = score > 0.7
        ? Colors.green
        : score > 0.4
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.videocam, color: color, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${analysis.contact.displayName} के साथ Video Health',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Facial expression analysis से',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${(score * 100).round()}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const Text(
                      'Health Score',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: score,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        score > 0.7
                            ? Icons.sentiment_very_satisfied
                            : score > 0.4
                                ? Icons.sentiment_neutral
                                : Icons.sentiment_dissatisfied,
                        color: color,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionalTrendsChart(VideoCallAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emotional Trends Over Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: TrendChartPainter(analysis.emotionalTrends),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrendLegendItem('Happiness', Colors.yellow),
              _buildTrendLegendItem('Engagement', Colors.blue),
              _buildTrendLegendItem('Overall', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFrequentLocationsMap(LocationInsights insights) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frequent Meeting Locations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (insights.frequentLocations.isNotEmpty) ...[
            for (final location in insights.frequentLocations.take(5))
              _buildLocationItem(location),
          ] else ...[
            const Text(
              'No frequent locations detected yet',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationItem(FrequentLocation location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            location.name.toLowerCase().contains('home')
                ? Icons.home
                : location.name.toLowerCase().contains('office')
                    ? Icons.work
                    : location.name.toLowerCase().contains('restaurant')
                        ? Icons.restaurant
                        : Icons.place,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${location.visitCount} visits • ${location.averageDuration.inMinutes}min avg',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${(location.meetingQuality * 100).round()}%',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingPatternsChart(LocationInsights insights) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meeting Patterns',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (insights.meetingPatterns.isNotEmpty) ...[
            for (final pattern in insights.meetingPatterns.entries)
              _buildPatternItem(pattern.key, pattern.value),
          ] else ...[
            const Text(
              'Analyzing meeting patterns...',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatternItem(String key, MeetingPattern pattern) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Preference: ${pattern.preference}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              Text(
                'Home: ${pattern.homeCount} | Outside: ${pattern.outsideCount}',
                style: const TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHealthScore(GroupDynamicAnalysis analysis) {
    final score = analysis.groupHealth;
    final color = score > 0.7
        ? Colors.green
        : score > 0.4
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.group, color: color, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Group Health Score',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${analysis.groupMembers.length} members analyzed',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${(score * 100).round()}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const Text(
                      'Healthy Dynamics',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: score,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        score > 0.7
                            ? Icons.groups
                            : score > 0.4
                                ? Icons.group_work
                                : Icons.group_off,
                        color: color,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDominancePatternsChart(GroupDynamicAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Member Participation Patterns',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          for (final entry in analysis.dominancePatterns.entries)
            _buildDominanceItem(entry.key, entry.value, analysis.groupMembers),
        ],
      ),
    );
  }

  Widget _buildDominanceItem(
      String memberId, DominanceMetrics metrics, List<Contact> members) {
    final member = members.firstWhere((m) => m.id == memberId,
        orElse: () => Contact(id: memberId, displayName: 'Unknown'));
    final dominanceColor = metrics.dominanceScore > 0.7
        ? Colors.red
        : metrics.dominanceScore > 0.4
            ? Colors.orange
            : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: dominanceColor.withValues(alpha: 0.3),
                child: Text(
                  member.displayName.isNotEmpty
                      ? member.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: dominanceColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${metrics.messageCount} messages • ${metrics.averageMessageLength.round()} chars avg',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: dominanceColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(metrics.dominanceScore * 100).round()}%',
                  style: TextStyle(
                    color: dominanceColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: metrics.dominanceScore,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(dominanceColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionMatrix(GroupDynamicAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interaction Matrix',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Who talks to whom most',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: InteractionMatrixPainter(
                  analysis.interactionMatrix, analysis.groupMembers),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentalHealthScore(MentalHealthImpactAnalysis analysis) {
    final score = analysis.overallMentalHealthScore;
    final color = score > 0.7
        ? Colors.green
        : score > 0.4
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: color, size: 30),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mental Health Impact Score',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Relationships का आपके mood पर effect',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${(score * 100).round()}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const Text(
                      'Positive Impact',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: score,
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        score > 0.7
                            ? Icons.sentiment_very_satisfied
                            : score > 0.4
                                ? Icons.sentiment_neutral
                                : Icons.sentiment_very_dissatisfied,
                        color: color,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactImpactChart(MentalHealthImpactAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Impact on Mood',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          for (final impact in analysis.contactImpacts.take(5))
            _buildContactImpactItem(impact),
        ],
      ),
    );
  }

  Widget _buildContactImpactItem(ContactMentalImpact impact) {
    final isPositive = impact.averageMoodImpact > 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon =
        isPositive ? Icons.sentiment_satisfied : Icons.sentiment_dissatisfied;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.3),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  impact.contact.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${impact.interactionCount} interactions analyzed',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${isPositive ? '+' : ''}${impact.averageMoodImpact.toStringAsFixed(1)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'mood impact',
                style: TextStyle(
                  color: color.withValues(alpha: 0.3),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTriggersSection(MentalHealthImpactAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Significant Mood Triggers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Interactions that caused major mood changes',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          if (analysis.moodTriggers.isNotEmpty) ...[
            for (final trigger in analysis.moodTriggers.take(3))
              _buildMoodTriggerItem(trigger),
          ] else ...[
            const Text(
              'No significant mood triggers detected',
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodTriggerItem(MoodTrigger trigger) {
    final isPositive = trigger.impactScore > 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  trigger.contact.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${trigger.impactScore.toStringAsFixed(1)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Before: ${trigger.moodBefore.emotion}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(width: 16),
              Icon(Icons.arrow_forward,
                  color: Colors.white.withValues(alpha: 0.3), size: 16),
              const SizedBox(width: 16),
              Text(
                'After: ${trigger.moodAfter.emotion}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(List<String> insights, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: color, size: 24),
              const SizedBox(width: 12),
              const Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final insight in insights.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(List<String> recommendations, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.recommend, color: color, size: 24),
              const SizedBox(width: 12),
              const Text(
                'AI Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final recommendation in recommendations.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 14,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Sample data generators for testing purposes

  List<VideoCallSession> _generateSampleVideoSessions() {
    final sessions = <VideoCallSession>[];
    final random = math.Random();

    for (int i = 0; i < 5; i++) {
      final date = DateTime.now().subtract(Duration(days: i * 7));
      final expressions = <FacialExpression>[];

      for (int j = 0; j < 10; j++) {
        expressions.add(FacialExpression(
          emotion: [
            'happiness',
            'interest',
            'attention',
            'neutral'
          ][random.nextInt(4)],
          confidence: 0.3 + random.nextDouble() * 0.7,
          timestamp: date.add(Duration(minutes: j * 2)),
        ));
      }

      sessions.add(VideoCallSession(
        date: date,
        duration: Duration(minutes: 15 + random.nextInt(30)),
        facialExpressions: expressions,
        averageEngagement: 0.4 + random.nextDouble() * 0.6,
      ));
    }

    return sessions;
  }

  List<LocationMeeting> _generateSampleLocationMeetings() {
    final meetings = <LocationMeeting>[];
    final random = math.Random();
    final locations = [
      MeetingLocation(name: 'Home', latitude: 0, longitude: 0, isHome: true),
      MeetingLocation(
          name: 'Coffee Shop', latitude: 0, longitude: 0, isHome: false),
      MeetingLocation(name: 'Office', latitude: 0, longitude: 0, isHome: false),
      MeetingLocation(
          name: 'Restaurant', latitude: 0, longitude: 0, isHome: false),
      MeetingLocation(name: 'Park', latitude: 0, longitude: 0, isHome: false),
    ];

    for (int i = 0; i < 15; i++) {
      final location = locations[random.nextInt(locations.length)];
      meetings.add(LocationMeeting(
        date: DateTime.now().subtract(Duration(days: random.nextInt(60))),
        duration: Duration(minutes: 30 + random.nextInt(120)),
        location: location,
      ));
    }

    return meetings;
  }

  List<GroupConversation> _generateSampleGroupConversations() {
    final conversations = <GroupConversation>[];
    final random = math.Random();
    final memberIds = widget.contacts.take(4).map((c) => c.id).toList();

    for (int i = 0; i < 10; i++) {
      final messages = <GroupMessage>[];
      final startTime =
          DateTime.now().subtract(Duration(days: random.nextInt(30)));

      for (int j = 0; j < 5 + random.nextInt(10); j++) {
        messages.add(GroupMessage(
          senderId: memberIds[random.nextInt(memberIds.length)],
          content: 'Sample message ${j + 1}',
          timestamp: startTime.add(Duration(minutes: j * 2)),
        ));
      }

      conversations.add(GroupConversation(
        id: 'conv_$i',
        startTime: startTime,
        endTime: startTime.add(Duration(minutes: messages.length * 2)),
        messages: messages,
      ));
    }

    return conversations;
  }
}

// Custom Painters for Charts

class TrendChartPainter extends CustomPainter {
  final List<EmotionalTrend> trends;

  TrendChartPainter(this.trends);

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final happinessPath = Path();
    final engagementPath = Path();
    final overallPath = Path();

    for (int i = 0; i < trends.length; i++) {
      final x = (i / (trends.length - 1)) * size.width;
      final happinessY = size.height - (trends[i].happiness * size.height);
      final engagementY = size.height - (trends[i].engagement * size.height);
      final overallY =
          size.height - (trends[i].overallPositivity * size.height);

      if (i == 0) {
        happinessPath.moveTo(x, happinessY);
        engagementPath.moveTo(x, engagementY);
        overallPath.moveTo(x, overallY);
      } else {
        happinessPath.lineTo(x, happinessY);
        engagementPath.lineTo(x, engagementY);
        overallPath.lineTo(x, overallY);
      }
    }

    paint.color = Colors.yellow;
    canvas.drawPath(happinessPath, paint);

    paint.color = Colors.blue;
    canvas.drawPath(engagementPath, paint);

    paint.color = Colors.purple;
    canvas.drawPath(overallPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class InteractionMatrixPainter extends CustomPainter {
  final Map<String, Map<String, int>> matrix;
  final List<Contact> members;

  InteractionMatrixPainter(this.matrix, this.members);

  @override
  void paint(Canvas canvas, Size size) {
    if (matrix.isEmpty || members.isEmpty) return;

    final paint = Paint();
    final cellSize = size.width / members.length;

    for (int i = 0; i < members.length; i++) {
      for (int j = 0; j < members.length; j++) {
        final member1 = members[i];
        final member2 = members[j];
        final interactions = matrix[member1.id]?[member2.id] ?? 0;
        final intensity = math.min(1.0, interactions / 10.0);

        paint.color = Colors.cyan.withValues(alpha: 0.3 * intensity);

        canvas.drawRect(
          Rect.fromLTWH(j * cellSize, i * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import '../models/relationship_contact.dart';
import '../models/communication_entry.dart';
import '../services/communication_tracker_service.dart';
import '../core/service_locator.dart';
import 'conversation_entry_page.dart';
import 'add_contact_page.dart';

/// Detailed view and management page for individual relationship contacts
class ContactDetailsPage extends StatefulWidget {
  final RelationshipContact contact;

  const ContactDetailsPage({super.key, required this.contact});

  @override
  State<ContactDetailsPage> createState() => _ContactDetailsPageState();
}

class _ContactDetailsPageState extends State<ContactDetailsPage>
    with SingleTickerProviderStateMixin {
  late CommunicationTrackerService _service;
  late TabController _tabController;

  List<CommunicationEntry> _allEntries = [];
  bool _isLoading = true;

  // Statistics
  int _totalConversations = 0;
  double _averageQuality = 0;
  int _totalConflicts = 0;
  int _specialMoments = 0;
  Duration _totalTime = Duration.zero;
  DateTime? _lastConversation;

  @override
  void initState() {
    super.initState();
    _service = ServiceLocator.instance.get<CommunicationTrackerService>();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() async {
    try {
      final entries = _service.getEntriesForContact(widget.contact.id);

      setState(() {
        _allEntries = entries;
        _calculateStatistics();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _calculateStatistics() {
    _totalConversations = _allEntries.length;

    if (_allEntries.isNotEmpty) {
      _averageQuality =
          _allEntries.map((e) => e.overallQuality).reduce((a, b) => a + b) /
          _allEntries.length;

      _totalConflicts = _allEntries.where((e) => e.hadConflict).length;
      _specialMoments = _allEntries.where((e) => e.hadSpecialMoment).length;

      _totalTime = Duration(
        minutes: _allEntries
            .map((e) => e.conversationDuration)
            .reduce((a, b) => a + b),
      );

      final sortedEntries = List<CommunicationEntry>.from(_allEntries)
        ..sort((a, b) => b.conversationDate.compareTo(a.conversationDate));
      _lastConversation = sortedEntries.first.conversationDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildContactHeader(),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: _handleMenuAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit Contact'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Delete Contact',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'History'),
                    Tab(text: 'Insights'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildHistoryTab(),
                  _buildInsightsTab(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewConversation,
        icon: const Icon(Icons.add_comment),
        label: const Text('Log Conversation'),
      ),
    );
  }

  Widget _buildContactHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade400, Colors.blue.shade600],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.contact.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.contact.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRelationshipType(widget.contact.relationship),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        if (widget.contact.isPriority) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow.shade300,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Priority Contact',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatChip(
                    '${widget.contact.relationshipStrength}/10',
                    'Strength',
                    Colors.white,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    '${widget.contact.importanceLevel}/10',
                    'Importance',
                    Colors.white,
                  ),
                  const SizedBox(width: 12),
                  if (_lastConversation != null)
                    _buildStatChip(
                      _getTimeSinceLastContact(_lastConversation!),
                      'Last Talk',
                      Colors.white,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStatsSection(),
          const SizedBox(height: 24),
          _buildContactInfoSection(),
          const SizedBox(height: 24),
          _buildRecentActivitySection(),
          const SizedBox(height: 24),
          _buildCommunicationPatternsSection(),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Communication Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Conversations',
                  _totalConversations.toString(),
                  Icons.chat_bubble,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Average Quality',
                  '${_averageQuality.toStringAsFixed(1)}/10',
                  Icons.star,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Total Time',
                  _formatDuration(_totalTime),
                  Icons.access_time,
                  Colors.green,
                ),
                _buildStatCard(
                  'Conflicts',
                  _totalConflicts.toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Phone',
              widget.contact.phoneNumber ?? 'Not provided',
            ),
            _buildInfoRow('Email', widget.contact.email ?? 'Not provided'),
            _buildInfoRow(
              'Relationship',
              _formatRelationshipType(widget.contact.relationship),
            ),
            _buildInfoRow(
              'Preferred Communication',
              widget.contact.preferredCommunication.join(', '),
            ),
            if (widget.contact.personalityTraits.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Personality Traits',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: widget.contact.personalityTraits
                    .map(
                      (trait) => Chip(
                        label: Text(trait),
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (widget.contact.interests.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Common Interests',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: widget.contact.interests
                    .map(
                      (interest) => Chip(
                        label: Text(interest),
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    final recentEntries = _allEntries.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Conversations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (_allEntries.isNotEmpty)
                  TextButton(
                    onPressed: () => _tabController.animateTo(1),
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentEntries.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No conversations logged yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentEntries.map((entry) => _buildConversationTile(entry)),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(CommunicationEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getQualityColor(entry.overallQuality),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                entry.overallQuality.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(entry.conversationDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                if (entry.conversationSummary.isNotEmpty)
                  Text(
                    entry.conversationSummary.length > 50
                        ? '${entry.conversationSummary.substring(0, 50)}...'
                        : entry.conversationSummary,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                Text(
                  '${entry.conversationDuration} min • ${_formatConversationType(entry.conversationType)}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
          if (entry.hadConflict)
            Icon(Icons.warning, color: Colors.red.shade400, size: 16),
          if (entry.hadSpecialMoment)
            Icon(Icons.star, color: Colors.amber.shade600, size: 16),
        ],
      ),
    );
  }

  Widget _buildCommunicationPatternsSection() {
    if (_allEntries.isEmpty) return const SizedBox.shrink();

    // Analyze patterns
    final typeDistribution = <String, int>{};
    final qualityTrend = <DateTime, int>{};

    for (final entry in _allEntries) {
      typeDistribution[entry.conversationType] =
          (typeDistribution[entry.conversationType] ?? 0) + 1;
      qualityTrend[entry.conversationDate] = entry.overallQuality;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Communication Patterns',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            const Text(
              'Preferred Communication Methods',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            ...typeDistribution.entries.map((entry) {
              final percentage = (entry.value / _totalConversations * 100)
                  .round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        _formatConversationType(entry.key),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: entry.value / _totalConversations,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$percentage%', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allEntries.length,
      itemBuilder: (context, index) {
        final entry = _allEntries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(entry.conversationDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getQualityColor(entry.overallQuality),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.overallQuality}/10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  '${entry.conversationDuration} min • ${_formatConversationType(entry.conversationType)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                if (entry.conversationSummary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(entry.conversationSummary),
                ],

                if (entry.topicsDiscussed.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: entry.topicsDiscussed
                        .take(3)
                        .map(
                          (topic) => Chip(
                            label: Text(topic),
                            backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          ),
                        )
                        .toList(),
                  ),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (entry.hadConflict) ...[
                          Icon(
                            Icons.warning,
                            color: Colors.red.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Conflict',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (entry.hadSpecialMoment) ...[
                          Icon(
                            Icons.star,
                            color: Colors.amber.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Special Moment',
                            style: TextStyle(
                              color: Colors.amber.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildRelationshipHealthCard(),
          const SizedBox(height: 16),
          _buildCommunicationInsightsCard(),
          const SizedBox(height: 16),
          _buildRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildRelationshipHealthCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Relationship Health',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Quality trend
            Text(
              'Average conversation quality: ${_averageQuality.toStringAsFixed(1)}/10',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _averageQuality / 10,
              backgroundColor: Colors.grey.shade200,
              color: _getQualityColor(_averageQuality.round()),
            ),
            const SizedBox(height: 16),

            // Special moments vs conflicts
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _specialMoments.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        'Special Moments',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        _totalConflicts.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const Text('Conflicts', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunicationInsightsCard() {
    if (_allEntries.isEmpty) return const SizedBox.shrink();

    final recentEntries = _allEntries.take(5).toList();
    final averageEmotionalState =
        recentEntries.map((e) => e.emotionalState).reduce((a, b) => a + b) /
        recentEntries.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Communication Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            Text(
              'Recent emotional state: ${averageEmotionalState.toStringAsFixed(1)}/10',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: averageEmotionalState / 10,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 16),

            if (_lastConversation != null) ...[
              Text(
                'Last conversation: ${_getTimeSinceLastContact(_lastConversation!)} ago',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),

              if (DateTime.now().difference(_lastConversation!).inDays > 7)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'It\'s been a while since your last conversation. Consider reaching out!',
                          style: TextStyle(color: Colors.orange),
                        ),
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

  Widget _buildRecommendationsCard() {
    final recommendations = _generateRecommendations();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            ...recommendations.map(
              (rec) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue.shade600),
                    const SizedBox(width: 12),
                    Expanded(child: Text(rec)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  String _formatRelationshipType(String relationship) {
    switch (relationship) {
      case 'family':
        return 'Family Member';
      case 'romantic_partner':
        return 'Romantic Partner';
      case 'friend':
        return 'Friend';
      case 'colleague':
        return 'Colleague';
      case 'neighbor':
        return 'Neighbor';
      case 'relative':
        return 'Relative';
      default:
        return 'Contact';
    }
  }

  String _formatConversationType(String type) {
    switch (type) {
      case 'in_person':
        return 'In Person';
      case 'phone_call':
        return 'Phone Call';
      case 'video_call':
        return 'Video Call';
      case 'text_message':
        return 'Text/Chat';
      default:
        return type;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _getTimeSinceLastContact(DateTime lastContact) {
    final difference = DateTime.now().difference(lastContact);

    if (difference.inDays > 0) {
      return '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours';
    } else {
      return '${difference.inMinutes} minutes';
    }
  }

  Color _getQualityColor(int quality) {
    if (quality >= 8) return Colors.green;
    if (quality >= 6) return Colors.orange;
    return Colors.red;
  }

  List<String> _generateRecommendations() {
    final recommendations = <String>[];

    if (_totalConversations == 0) {
      recommendations.add(
        'Start tracking your conversations with ${widget.contact.name} to get personalized insights.',
      );
      return recommendations;
    }

    // Quality-based recommendations
    if (_averageQuality < 6) {
      recommendations.add(
        'Your conversation quality seems low. Try active listening and asking more open-ended questions.',
      );
    }

    // Conflict recommendations
    if (_totalConflicts > _totalConversations * 0.3) {
      recommendations.add(
        'There seem to be frequent conflicts. Consider discussing communication styles and boundaries.',
      );
    }

    // Frequency recommendations
    if (_lastConversation != null) {
      final daysSinceLastContact = DateTime.now()
          .difference(_lastConversation!)
          .inDays;
      if (daysSinceLastContact > 14) {
        recommendations.add(
          'It\'s been $daysSinceLastContact days since your last conversation. Consider reaching out!',
        );
      }
    }

    // Special moments
    if (_specialMoments == 0 && _totalConversations > 5) {
      recommendations.add(
        'Try creating more meaningful moments by sharing personal stories or expressing appreciation.',
      );
    }

    // Relationship strength
    if (widget.contact.relationshipStrength < 7) {
      recommendations.add(
        'Focus on building trust and emotional intimacy through deeper conversations.',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        'Your relationship with ${widget.contact.name} looks healthy! Keep maintaining regular, quality communication.',
      );
    }

    return recommendations;
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'edit':
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddContactPage(contactToEdit: widget.contact),
          ),
        );

        if (result == true) {
          // Refresh the page
          setState(() {
            _isLoading = true;
          });
          _loadData();
        }
        break;

      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Contact'),
            content: Text(
              'Are you sure you want to delete ${widget.contact.name}? This will also delete all conversation history.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await _service.deleteContact(widget.contact.id);
            if (mounted) {
              Navigator.pop(context, true);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error deleting contact: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
        break;
    }
  }

  void _addNewConversation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ConversationEntryPage(preSelectedContact: widget.contact),
      ),
    );

    if (result == true) {
      // Refresh data
      _loadData();
    }
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

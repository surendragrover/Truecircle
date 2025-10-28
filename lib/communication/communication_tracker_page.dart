import 'package:flutter/material.dart';
import '../models/relationship_contact.dart';
import '../models/communication_entry.dart';
import '../models/conversation_insight.dart';
import '../services/communication_tracker_service.dart';
import '../core/service_locator.dart';
import 'add_contact_page.dart';
import 'conversation_entry_page.dart';
import 'contact_details_page.dart';

/// Main Communication Tracker Page
/// Top-level feature for tracking relationships and conversations
class CommunicationTrackerPage extends StatefulWidget {
  const CommunicationTrackerPage({super.key});

  @override
  State<CommunicationTrackerPage> createState() =>
      _CommunicationTrackerPageState();
}

class _CommunicationTrackerPageState extends State<CommunicationTrackerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CommunicationTrackerService _service;

  List<RelationshipContact> _contacts = [];
  List<CommunicationEntry> _recentEntries = [];
  List<ConversationInsight> _unreadInsights = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _service = ServiceLocator.instance.get<CommunicationTrackerService>();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _contacts = _service.getAllContacts();
      _recentEntries = _service.getRecentEntries(days: 7);
      _unreadInsights = _service.getUnreadInsights();
      _stats = _service.getRelationshipStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Communication Tracker',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.dashboard_outlined),
              text: 'Overview',
              height: 60,
            ),
            Tab(
              icon: Stack(
                children: [
                  const Icon(Icons.people_outline),
                  if (_contacts.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${_contacts.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              text: 'Contacts',
              height: 60,
            ),
            Tab(
              icon: Stack(
                children: [
                  const Icon(Icons.chat_bubble_outline),
                  if (_recentEntries.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${_recentEntries.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              text: 'Recent',
              height: 60,
            ),
            Tab(
              icon: Stack(
                children: [
                  const Icon(Icons.insights_outlined),
                  if (_unreadInsights.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${_unreadInsights.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              text: 'Insights',
              height: 60,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildContactsTab(),
          _buildRecentTab(),
          _buildInsightsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: _addNewEntry,
          backgroundColor: Colors.blue,
          heroTag: "add_entry",
          child: const Icon(Icons.add_comment, color: Colors.white),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: _addNewContact,
          backgroundColor: Colors.green,
          heroTag: "add_contact",
          child: const Icon(Icons.person_add, color: Colors.white),
        ),
      ],
    );
  }

  // ===== OVERVIEW TAB =====
  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            _buildStatsCards(),
            const SizedBox(height: 24),

            // Priority Contacts
            _buildPriorityContactsSection(),
            const SizedBox(height: 24),

            // Recent Activity
            _buildRecentActivitySection(),
            const SizedBox(height: 24),

            // Quick Insights
            _buildQuickInsightsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Contacts',
            '${_stats['totalContacts'] ?? 0}',
            Icons.people,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'This Week',
            '${_stats['entriesThisWeek'] ?? 0} entries',
            Icons.calendar_today,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityContactsSection() {
    final priorityContacts = _contacts
        .where((c) => c.isPriority)
        .take(4)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Priority Relationships',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (priorityContacts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No priority contacts yet',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _addNewContact,
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Contact'),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: priorityContacts.length,
            itemBuilder: (context, index) {
              final contact = priorityContacts[index];
              return _buildContactCard(contact);
            },
          ),
      ],
    );
  }

  Widget _buildContactCard(RelationshipContact contact) {
    final daysSinceContact = contact.lastInteractionDate != null
        ? DateTime.now().difference(contact.lastInteractionDate!).inDays
        : 999;

    return GestureDetector(
      onTap: () => _openContactDetails(contact),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRelationshipColor(contact.relationship),
                  child: Text(
                    contact.name.isNotEmpty
                        ? contact.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatRelationshipType(contact.relationship),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  daysSinceContact > contact.interactionFrequency * 1.5
                      ? Icons.schedule
                      : Icons.check_circle_outline,
                  size: 12,
                  color: daysSinceContact > contact.interactionFrequency * 1.5
                      ? Colors.orange
                      : Colors.green,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    daysSinceContact == 999
                        ? 'No recent contact'
                        : daysSinceContact == 0
                        ? 'Talked today'
                        : '$daysSinceContact days ago',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(2),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_recentEntries.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent conversations',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _addNewEntry,
                  icon: const Icon(Icons.add),
                  label: const Text('Log Conversation'),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentEntries.take(3).length,
            itemBuilder: (context, index) {
              final entry = _recentEntries[index];
              final contact = _service.getContact(entry.contactId);
              return _buildRecentEntryCard(entry, contact);
            },
          ),
      ],
    );
  }

  Widget _buildRecentEntryCard(
    CommunicationEntry entry,
    RelationshipContact? contact,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _getRelationshipColor(
              contact?.relationship ?? 'friend',
            ),
            child: Text(
              contact?.name.isNotEmpty == true
                  ? contact!.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact?.name ?? 'Unknown Contact',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  entry.conversationSummary.isNotEmpty
                      ? entry.conversationSummary
                      : 'Conversation logged',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getQualityColor(entry.overallQuality),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${entry.overallQuality}/10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(entry.conversationDate),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInsightsSection() {
    final urgentInsights = _unreadInsights
        .where((i) => i.priority >= 7)
        .take(2)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Important Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => _tabController.animateTo(3),
              child: Text('View All (${_unreadInsights.length})'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (urgentInsights.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All relationships looking good! Keep up the great communication.',
                    style: TextStyle(color: Colors.green.shade700),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: urgentInsights.length,
            itemBuilder: (context, index) {
              final insight = urgentInsights[index];
              final contact = _service.getContact(insight.contactId);
              return _buildInsightCard(insight, contact);
            },
          ),
      ],
    );
  }

  Widget _buildInsightCard(
    ConversationInsight insight,
    RelationshipContact? contact,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getInsightColor(insight.insightType).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getInsightColor(insight.insightType).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getInsightIcon(insight.insightType),
                color: _getInsightColor(insight.insightType),
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _getInsightColor(insight.insightType),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getInsightColor(insight.insightType),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Priority ${insight.priority}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.description,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ===== CONTACTS TAB =====
  Widget _buildContactsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _contacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No contacts yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first relationship to start tracking',
                    style: TextStyle(color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addNewContact,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Contact'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return _buildFullContactCard(contact);
              },
            ),
    );
  }

  Widget _buildFullContactCard(RelationshipContact contact) {
    final daysSinceContact = contact.lastInteractionDate != null
        ? DateTime.now().difference(contact.lastInteractionDate!).inDays
        : 999;
    final recentEntries = _service.getEntriesForContact(contact.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openContactDetails(contact),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _getRelationshipColor(
                      contact.relationship,
                    ),
                    child: Text(
                      contact.name.isNotEmpty
                          ? contact.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              contact.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (contact.isPriority) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Priority',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRelationshipType(contact.relationship),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStrengthColor(
                            contact.currentRelationshipStrength,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${contact.currentRelationshipStrength}/10',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${recentEntries.length} entries',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    daysSinceContact > contact.interactionFrequency * 1.5
                        ? Icons.schedule
                        : Icons.check_circle_outline,
                    size: 16,
                    color: daysSinceContact > contact.interactionFrequency * 1.5
                        ? Colors.orange
                        : Colors.green,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    daysSinceContact == 999
                        ? 'No recent contact'
                        : daysSinceContact == 0
                        ? 'Talked today'
                        : 'Last contact: $daysSinceContact days ago',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _addEntryForContact(contact),
                    icon: const Icon(Icons.add_comment, size: 16),
                    label: const Text(
                      'Log Chat',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== RECENT TAB =====
  Widget _buildRecentTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _recentEntries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recent conversations',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start logging your conversations to see them here',
                    style: TextStyle(color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addNewEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('Log Conversation'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _recentEntries.length,
              itemBuilder: (context, index) {
                final entry = _recentEntries[index];
                final contact = _service.getContact(entry.contactId);
                return _buildDetailedEntryCard(entry, contact);
              },
            ),
    );
  }

  Widget _buildDetailedEntryCard(
    CommunicationEntry entry,
    RelationshipContact? contact,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRelationshipColor(
                    contact?.relationship ?? 'friend',
                  ),
                  child: Text(
                    contact?.name.isNotEmpty == true
                        ? contact!.name[0].toUpperCase()
                        : '?',
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
                        contact?.name ?? 'Unknown Contact',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(entry.conversationDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
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
                        'Quality: ${entry.overallQuality}/10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.conversationDuration} min',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (entry.conversationSummary.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                entry.conversationSummary,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildEntryTag(
                  _formatConversationType(entry.conversationType),
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                if (entry.hadConflict) _buildEntryTag('Conflict', Colors.red),
                if (entry.hadSpecialMoment)
                  _buildEntryTag('Special Moment', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ===== INSIGHTS TAB =====
  Widget _buildInsightsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: _unreadInsights.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insights_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No insights yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log more conversations to get AI-powered insights',
                    style: TextStyle(color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _unreadInsights.length,
              itemBuilder: (context, index) {
                final insight = _unreadInsights[index];
                final contact = _service.getContact(insight.contactId);
                return _buildDetailedInsightCard(insight, contact);
              },
            ),
    );
  }

  Widget _buildDetailedInsightCard(
    ConversationInsight insight,
    RelationshipContact? contact,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _getInsightColor(insight.insightType).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getInsightColor(insight.insightType).withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: () {
          _service.markInsightAsRead(insight.id);
          _loadData();
          _showInsightDetails(insight, contact);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getInsightIcon(insight.insightType),
                    color: _getInsightColor(insight.insightType),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: _getInsightColor(insight.insightType),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getInsightColor(insight.insightType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Priority ${insight.priority}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'About: ${contact?.name ?? 'Unknown Contact'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                insight.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
              if (insight.recommendations.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Recommendations:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                ...insight.recommendations
                    .take(2)
                    .map(
                      (rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: TextStyle(
                                color: _getInsightColor(insight.insightType),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                rec,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (insight.recommendations.length > 2)
                  Text(
                    'Tap to see ${insight.recommendations.length - 2} more recommendations',
                    style: TextStyle(
                      fontSize: 11,
                      color: _getInsightColor(insight.insightType),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===== HELPER METHODS =====

  Color _getRelationshipColor(String relationship) {
    switch (relationship) {
      case 'family':
        return Colors.green;
      case 'romantic_partner':
        return Colors.red;
      case 'friend':
        return Colors.blue;
      case 'colleague':
        return Colors.orange;
      case 'neighbor':
        return Colors.purple;
      case 'relative':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

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

  Color _getQualityColor(int quality) {
    if (quality >= 8) return Colors.green;
    if (quality >= 6) return Colors.orange;
    if (quality >= 4) return Colors.yellow.shade700;
    return Colors.red;
  }

  Color _getStrengthColor(int strength) {
    if (strength >= 8) return Colors.green;
    if (strength >= 6) return Colors.blue;
    if (strength >= 4) return Colors.orange;
    return Colors.red;
  }

  Color _getInsightColor(String type) {
    switch (type) {
      case 'warning':
        return Colors.red;
      case 'improvement':
        return Colors.orange;
      case 'celebration':
        return Colors.green;
      case 'suggestion':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getInsightIcon(String type) {
    switch (type) {
      case 'warning':
        return Icons.warning;
      case 'improvement':
        return Icons.trending_up;
      case 'celebration':
        return Icons.celebration;
      case 'suggestion':
        return Icons.lightbulb;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // ===== ACTION METHODS =====

  void _addNewContact() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddContactPage()),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _addNewEntry() async {
    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add a contact first before logging conversations',
          ),
        ),
      );
      _addNewContact();
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ConversationEntryPage()),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _addEntryForContact(RelationshipContact contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ConversationEntryPage(preSelectedContact: contact),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _openContactDetails(RelationshipContact contact) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailsPage(contact: contact),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  void _showInsightDetails(
    ConversationInsight insight,
    RelationshipContact? contact,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getInsightIcon(insight.insightType),
              color: _getInsightColor(insight.insightType),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(insight.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'About: ${contact?.name ?? 'Unknown Contact'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(insight.description),
              if (insight.recommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Recommendations:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...insight.recommendations.map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: _getInsightColor(insight.insightType),
                          ),
                        ),
                        Expanded(child: Text(rec)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (contact != null)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addEntryForContact(contact);
              },
              child: const Text('Log Conversation'),
            ),
        ],
      ),
    );
  }
}

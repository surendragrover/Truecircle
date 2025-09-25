import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../models/contact_interaction.dart';
import '../services/cultural_regional_ai.dart';

/// 🎭 Cultural AI Dashboard - Advanced Indian cultural intelligence interface
/// Displays festival reminders, regional insights, family dynamics, and language preferences
/// Enhanced with user-friendly design and intuitive navigation
class CulturalAIDashboard extends StatefulWidget {
  final List<Contact> contacts;
  final List<ContactInteraction> interactions;

  const CulturalAIDashboard({
    super.key,
    required this.contacts,
    required this.interactions,
  });

  @override
  State<CulturalAIDashboard> createState() => _CulturalAIDashboardState();
}

class _CulturalAIDashboardState extends State<CulturalAIDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  List<FestivalReminder> festivalReminders = [];
  Map<String, RegionalProfile> regionalProfiles = {};
  Map<String, FamilyDynamicsInsight> familyInsights = {};
  bool isLoading = true;
  bool showTutorial = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _loadCulturalData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCulturalData() async {
    setState(() => isLoading = true);

    try {
      // Load festival reminders
      festivalReminders =
          await CulturalRegionalAI.generateFestivalReminders(widget.contacts);

      // Analyze regional profiles for key contacts
      for (final contact in widget.contacts.take(10)) {
        final interactions = widget.interactions
            .where((i) => i.contactId == contact.id)
            .toList();

        if (interactions.isNotEmpty) {
          regionalProfiles[contact.id] =
              CulturalRegionalAI.detectRegionalCommunicationStyle(
                  contact, interactions);
          familyInsights[contact.id] =
              CulturalRegionalAI.analyzeFamilyDynamics(contact, interactions);
        }
      }
    } catch (e) {
      debugPrint('Error loading cultural data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('🎭', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cultural AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Indian Cultural Intelligence',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              if (showTutorial) _buildTutorialBanner(),
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.celebration),
                      text: 'Festivals',
                      height: 60,
                    ),
                    Tab(
                      icon: Icon(Icons.public),
                      text: 'Regional',
                      height: 60,
                    ),
                    Tab(
                      icon: Icon(Icons.family_restroom),
                      text: 'Family',
                      height: 60,
                    ),
                    Tab(
                      icon: Icon(Icons.language),
                      text: 'Language',
                      height: 60,
                    ),
                  ],
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.orange,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
            tooltip: 'Help & Tutorial',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingState()
          : SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: FadeTransition(
                opacity: _slideAnimation,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFestivalTab(),
                    _buildRegionalTab(),
                    _buildFamilyTab(),
                    _buildLanguageTab(),
                  ],
                ),
              ),
            ),
      floatingActionButton: _buildSmartActionButton(),
    );
  }

  Widget _buildFestivalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            '🎉 Upcoming Festivals',
            'Plan your cultural connections',
            showCount: festivalReminders.length,
          ),
          const SizedBox(height: 16),
          if (festivalReminders.isEmpty)
            _buildEmptyState(
              'No upcoming festivals',
              'आपके पास कोई आगामी त्योहार नहीं हैं',
            )
          else ...[
            ...festivalReminders
                .map((reminder) => _buildFestivalCard(reminder)),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildRegionalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              '🗺️ Regional Insights', 'Understand communication styles'),
          const SizedBox(height: 16),
          if (regionalProfiles.isEmpty)
            _buildEmptyState('No regional data', 'कोई क्षेत्रीय डेटा नहीं मिला')
          else
            ...regionalProfiles.entries
                .map((entry) => _buildRegionalCard(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildFamilyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('👨‍👩‍👧‍👦 Family Dynamics',
              'Navigate Indian family relationships'),
          const SizedBox(height: 16),
          if (familyInsights.isEmpty)
            _buildEmptyState(
                'No family insights', 'कोई पारिवारिक जानकारी नहीं मिली')
          else
            ...familyInsights.entries
                .map((entry) => _buildFamilyCard(entry.key, entry.value)),
        ],
      ),
    );
  }

  Widget _buildLanguageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              '🌐 Language Intelligence', 'Master multilingual communication'),
          const SizedBox(height: 16),
          _buildLanguageOverview(),
          const SizedBox(height: 24),
          _buildLanguageRecommendations(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, {int? showCount}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            if (showCount != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$showCount',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFestivalCard(FestivalReminder reminder) {
    final festival = reminder.festival;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.red.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getFestivalEmoji(festival.name),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${festival.name} (${festival.hindiName})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${reminder.daysUntil} days away',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: reminder.daysUntil <= 7 ? Colors.red : Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      reminder.daysUntil <= 7 ? 'Urgent' : 'Plan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${reminder.priorityContacts.length} priority contacts',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: reminder.priorityContacts
                    .take(3)
                    .map(
                      (contact) => Chip(
                        label: Text(contact.displayName),
                        backgroundColor: Colors.white,
                        labelStyle: const TextStyle(fontSize: 12),
                      ),
                    )
                    .toList(),
              ),
              if (reminder.priorityContacts.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${reminder.priorityContacts.length - 3} more',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Suggested Actions:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...reminder.suggestedActions.take(2).map(
                    (action) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              action,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _sendFestivalMessages(reminder),
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Send Messages'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _viewFestivalDetails(festival),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Details'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
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

  Widget _buildRegionalCard(String contactId, RegionalProfile profile) {
    final contact = widget.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => Contact(
        id: contactId,
        displayName: 'Unknown',
        emotionalScore: EmotionalScore.friendlyButFading,
      ),
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRegionColor(profile.detectedRegion),
                  child: Text(
                    _getRegionEmoji(profile.detectedRegion),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getRegionName(profile.detectedRegion),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        profile.confidence > 0.7 ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(profile.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStyleIndicator('Language', profile.languagePreference),
                const SizedBox(width: 16),
                _buildStyleIndicator('Style',
                    _getFormalityText(profile.communicationStyle.formality)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTraitBar('Direct', profile.communicationStyle.directness),
                const SizedBox(width: 16),
                _buildTraitBar('Emotional',
                    profile.communicationStyle.emotionalExpression),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyCard(String contactId, FamilyDynamicsInsight insight) {
    final contact = widget.contacts.firstWhere(
      (c) => c.id == contactId,
      orElse: () => Contact(
        id: contactId,
        displayName: 'Unknown',
        emotionalScore: EmotionalScore.friendlyButFading,
      ),
    );

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    color: _getFamilyColor(insight.relationshipType),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getFamilyEmoji(insight.relationshipType),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getFamilyRelationText(insight.relationshipType),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRespectColor(insight.respectLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRespectText(insight.respectLevel),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (insight.suggestedApproach.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.suggestedApproach,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                        ),
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

  Widget _buildLanguageOverview() {
    final languageStats = _calculateLanguageStats();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLanguageBar(
                      'Hindi', languageStats['hindi']!, Colors.orange),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLanguageBar(
                      'English', languageStats['english']!, Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLanguageBar(
                      'Hinglish', languageStats['hinglish']!, Colors.purple),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageBar(String language, double percentage, Color color) {
    return Column(
      children: [
        Text(
          language,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          width: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                height: 60 * percentage,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(percentage * 100).toInt()}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLanguageRecommendations() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecommendationTile(
              'Use Hindi for family contacts',
              'पारिवारिक संपर्कों के लिए हिंदी का उपयोग करें',
              Icons.family_restroom,
              Colors.orange,
            ),
            _buildRecommendationTile(
              'English for professional contacts',
              'व्यावसायिक संपर्कों के लिए अंग्रेजी',
              Icons.business,
              Colors.blue,
            ),
            _buildRecommendationTile(
              'Hinglish for casual friends',
              'दोस्तों के लिए हिंग्लिश',
              Icons.group,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationTile(
      String title, String subtitle, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _createFestivalGroups(),
                    icon: const Icon(Icons.group_add),
                    label: const Text('Create Festival Groups'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _scheduleReminders(),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Schedule Reminders'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.sentiment_neutral,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleIndicator(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTraitBar(String label, double value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              value > 0.7
                  ? Colors.green
                  : value > 0.4
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // UI Helper Methods - Enhanced for User-Friendliness

  Widget _buildTutorialBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Tap tabs to explore festivals, regional styles & family insights!',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => showTutorial = false),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyzing Cultural Data...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading festivals, regional patterns & family insights',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showSmartActions,
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.auto_awesome),
      label: const Text('Smart Actions'),
      elevation: 6,
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help, color: Colors.blue),
            SizedBox(width: 8),
            Text('Cultural AI Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎉 Festivals Tab:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  '• View upcoming Indian festivals\n• Get personalized message suggestions\n• See priority contacts for each festival\n'),
              Text(
                '🗺️ Regional Tab:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  '• Understand communication styles\n• Regional language preferences\n• Cultural adaptation tips\n'),
              Text(
                '👨‍👩‍👧‍👦 Family Tab:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  '• Indian family dynamics insights\n• Relationship type detection\n• Respectful communication guidance\n'),
              Text(
                '🌐 Language Tab:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  '• Hindi/English/Hinglish analysis\n• Language preference detection\n• Code-switching patterns'),
            ],
          ),
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

  void _refreshData() {
    setState(() => isLoading = true);
    _loadCulturalData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Refreshing cultural data...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showSmartActions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🤖 Smart Cultural Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildActionTile(
              icon: Icons.celebration,
              title: 'Send Festival Messages',
              subtitle: 'Bulk send personalized festival wishes',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _bulkSendFestivalMessages();
              },
            ),
            _buildActionTile(
              icon: Icons.group_add,
              title: 'Create Cultural Groups',
              subtitle: 'Group contacts by region & language',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                _createCulturalGroups();
              },
            ),
            _buildActionTile(
              icon: Icons.schedule,
              title: 'Smart Reminders',
              subtitle: 'Set cultural context reminders',
              color: Colors.green,
              onTap: () {
                Navigator.pop(context);
                _setupSmartReminders();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
      onTap: onTap,
    );
  }

  String _getFestivalEmoji(String festivalName) {
    switch (festivalName) {
      case 'Diwali':
        return '🪔';
      case 'Holi':
        return '🌈';
      case 'Eid':
        return '🌙';
      case 'Dussehra':
        return '🏹';
      case 'Karva Chauth':
        return '🌕';
      default:
        return '🎉';
    }
  }

  String _getRegionEmoji(IndianRegion region) {
    switch (region) {
      case IndianRegion.northIndia:
        return '🏔️';
      case IndianRegion.southIndia:
        return '🌴';
      case IndianRegion.eastIndia:
        return '🐅';
      case IndianRegion.westIndia:
        return '🏖️';
    }
  }

  Color _getRegionColor(IndianRegion region) {
    switch (region) {
      case IndianRegion.northIndia:
        return Colors.blue;
      case IndianRegion.southIndia:
        return Colors.green;
      case IndianRegion.eastIndia:
        return Colors.orange;
      case IndianRegion.westIndia:
        return Colors.purple;
    }
  }

  String _getRegionName(IndianRegion region) {
    switch (region) {
      case IndianRegion.northIndia:
        return 'North India';
      case IndianRegion.southIndia:
        return 'South India';
      case IndianRegion.eastIndia:
        return 'East India';
      case IndianRegion.westIndia:
        return 'West India';
    }
  }

  String _getFormalityText(CommunicationFormality formality) {
    switch (formality) {
      case CommunicationFormality.casual:
        return 'Casual';
      case CommunicationFormality.moderate:
        return 'Moderate';
      case CommunicationFormality.formal:
        return 'Formal';
      case CommunicationFormality.traditional:
        return 'Traditional';
    }
  }

  String _getFamilyEmoji(FamilyRelationshipType type) {
    switch (type) {
      case FamilyRelationshipType.parent:
        return '👨‍👩';
      case FamilyRelationshipType.mother:
        return '👩';
      case FamilyRelationshipType.father:
        return '👨';
      case FamilyRelationshipType.sibling:
        return '👫';
      case FamilyRelationshipType.extendedFamily:
        return '👴';
      case FamilyRelationshipType.nonFamily:
        return '👤';
    }
  }

  Color _getFamilyColor(FamilyRelationshipType type) {
    switch (type) {
      case FamilyRelationshipType.parent:
      case FamilyRelationshipType.mother:
      case FamilyRelationshipType.father:
        return Colors.red;
      case FamilyRelationshipType.sibling:
        return Colors.blue;
      case FamilyRelationshipType.extendedFamily:
        return Colors.green;
      case FamilyRelationshipType.nonFamily:
        return Colors.grey;
    }
  }

  String _getFamilyRelationText(FamilyRelationshipType type) {
    switch (type) {
      case FamilyRelationshipType.parent:
        return 'Parent';
      case FamilyRelationshipType.mother:
        return 'Mother / माता';
      case FamilyRelationshipType.father:
        return 'Father / पिता';
      case FamilyRelationshipType.sibling:
        return 'Sibling / भाई-बहन';
      case FamilyRelationshipType.extendedFamily:
        return 'Extended Family / रिश्तेदार';
      case FamilyRelationshipType.nonFamily:
        return 'Friend / दोस्त';
    }
  }

  Color _getRespectColor(RespectLevel level) {
    switch (level) {
      case RespectLevel.casual:
        return Colors.blue;
      case RespectLevel.moderate:
        return Colors.green;
      case RespectLevel.formal:
        return Colors.orange;
      case RespectLevel.reverential:
        return Colors.red;
    }
  }

  String _getRespectText(RespectLevel level) {
    switch (level) {
      case RespectLevel.casual:
        return 'Casual';
      case RespectLevel.moderate:
        return 'Moderate';
      case RespectLevel.formal:
        return 'Formal';
      case RespectLevel.reverential:
        return 'Reverent';
    }
  }

  Map<String, double> _calculateLanguageStats() {
    // Simplified language statistics
    return {
      'hindi': 0.35,
      'english': 0.45,
      'hinglish': 0.20,
    };
  }

  // Action Methods

  void _sendFestivalMessages(FestivalReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send ${reminder.festival.name} Messages'),
        content: Text(
            'Send personalized messages to ${reminder.priorityContacts.length} contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processFestivalMessages(reminder);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _processFestivalMessages(FestivalReminder reminder) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sending ${reminder.festival.name} messages...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewFestivalDetails(IndianFestival festival) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${festival.name} (${festival.hindiName})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Date: ${festival.date.day}/${festival.date.month}/${festival.date.year}'),
            const SizedBox(height: 8),
            Text('Regions: ${festival.regions.join(', ')}'),
            const SizedBox(height: 8),
            Text('Description: ${festival.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _createFestivalGroups() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating festival contact groups...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _scheduleReminders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scheduling festival reminders...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Enhanced Smart Action Methods
  void _bulkSendFestivalMessages() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Festival Message Blast'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Send personalized festival messages to all priority contacts?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Messages will be customized based on relationship type and regional preferences.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processBulkMessages();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Send Messages'),
          ),
        ],
      ),
    );
  }

  void _processBulkMessages() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📱 Sending personalized festival messages...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _createCulturalGroups() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗺️ Create Cultural Groups'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Automatically group contacts by:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.language, color: Colors.blue),
                SizedBox(width: 8),
                Text('Language Preference'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 8),
                Text('Regional Communication Style'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.family_restroom, color: Colors.purple),
                SizedBox(width: 8),
                Text('Family Relationship Type'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processGroupCreation();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Create Groups'),
          ),
        ],
      ),
    );
  }

  void _processGroupCreation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('👥 Creating cultural contact groups...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _setupSmartReminders() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⏰ Smart Cultural Reminders'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Setup reminders for:'),
            SizedBox(height: 16),
            Text('📅 Festival Dates (3 days before)'),
            Text('🎂 Family Birthdays (Cultural style)'),
            Text('🕕 Regional Optimal Contact Times'),
            Text('💬 Language Preference Updates'),
            SizedBox(height: 16),
            Text(
              'All reminders will include cultural context and personalized suggestions.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processReminderSetup();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Setup Reminders'),
          ),
        ],
      ),
    );
  }

  void _processReminderSetup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⏰ Setting up intelligent cultural reminders...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

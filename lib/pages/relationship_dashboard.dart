import 'package:flutter/material.dart';
import '../widgets/quick_actions_panel.dart';
import '../models/contact.dart';
import '../models/contact_interaction.dart';
import '../services/relationship_analyzer.dart';
import '../widgets/avatar_placeholder.dart';
import '../widgets/smart_message_widget.dart';
// import '../widgets/simple_analytics_dashboard.dart'; // Disabled - HuggingFace dependency removed
import '../models/privacy_settings.dart';

class RelationshipDashboard extends StatefulWidget {
  final List<Contact> contacts;
  final PrivacySettings privacySettings;

  const RelationshipDashboard({
    super.key,
    required this.contacts,
    required this.privacySettings,
  });

  @override
  State<RelationshipDashboard> createState() => _RelationshipDashboardState();
}

class _RelationshipDashboardState extends State<RelationshipDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RelationshipAnalyzer _analyzer = RelationshipAnalyzer();

  List<RelationshipHealth> _relationshipHealthData = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, needs_attention, thriving, at_risk

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _analyzeRelationships();
  }

  Future<void> _analyzeRelationships() async {
    setState(() => _isLoading = true);

    try {
      // Simulate analysis process
      await Future.delayed(const Duration(seconds: 1));

      List<RelationshipHealth> healthData = [];
      for (final contact in widget.contacts) {
        // For demo, creating mock interaction data
        final mockInteractions = _generateMockInteractions(contact);
        final health =
            _analyzer.analyzeRelationshipHealth(contact, mockInteractions);
        healthData.add(health);
      }

      // Sort by overall score (worst first for attention)
      healthData.sort((a, b) => a.overallScore.compareTo(b.overallScore));

      setState(() {
        _relationshipHealthData = healthData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = widget.privacySettings.language == 'hi';

    return Scaffold(
      appBar: AppBar(
        title: Text(isHindi ? 'रिश्ते डैशबोर्ड' : 'Relationship Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.dashboard),
              text: isHindi ? 'ओवरव्यू' : 'Overview',
            ),
            Tab(
              icon: const Icon(Icons.warning_amber),
              text: isHindi ? 'सुझाव' : 'Insights',
            ),
            Tab(
              icon: const Icon(Icons.lightbulb),
              text: isHindi ? 'सलाह' : 'Advice',
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text(isHindi ? 'सभी संपर्क' : 'All Contacts'),
              ),
              PopupMenuItem(
                value: 'needs_attention',
                child: Text(isHindi ? 'ध्यान चाहिए' : 'Needs Attention'),
              ),
              PopupMenuItem(
                value: 'thriving',
                child: Text(isHindi ? 'अच्छे रिश्ते' : 'Thriving'),
              ),
              PopupMenuItem(
                value: 'at_risk',
                child: Text(isHindi ? 'जोखिम में' : 'At Risk'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(isHindi)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(isHindi),
                _buildInsightsTab(isHindi),
                _buildAdviceTab(isHindi),
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => _showSmartMessages(isHindi),
            heroTag: "smartMessages",
            backgroundColor: Colors.purple.shade400,
            tooltip: isHindi ? 'AI स्मार्ट मैसेज' : 'AI Smart Messages',
            child: const Icon(Icons.psychology),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: _analyzeRelationships,
            heroTag: "refresh",
            icon: const Icon(Icons.refresh),
            label: Text(isHindi ? 'अपडेट करें' : 'Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isHindi) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            isHindi
                ? 'रिश्तों का विश्लेषण हो रहा है...'
                : 'Analyzing relationships...',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            isHindi ? 'कृपया प्रतीक्षा करें' : 'Please wait',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isHindi) {
    final filteredData = _getFilteredData();

    if (filteredData.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.people_outline,
        title: isHindi ? 'कोई संपर्क नहीं' : 'No Contacts',
        subtitle: isHindi
            ? 'अपने संपर्क import करें और TrueCircle का जादू देखें'
            : 'Import your contacts and see TrueCircle magic',
        actionText: isHindi ? 'संपर्क जोड़ें' : 'Add Contacts',
        onAction: () {
          // Navigate to contact import
        },
      );
    }

    return Column(
      children: [
        _buildStatsHeader(filteredData, isHindi),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final health = filteredData[index];
              return _buildContactCard(health, isHindi);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(List<RelationshipHealth> data, bool isHindi) {
    final thriving = data.where((h) => h.overallScore >= 0.8).length;
    final needsAttention =
        data.where((h) => h.overallScore < 0.6 && h.overallScore >= 0.4).length;
    final atRisk = data.where((h) => h.overallScore < 0.4).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              isHindi ? 'अच्छे' : 'Thriving',
              thriving.toString(),
              Icons.favorite,
              Colors.green,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.blue[200]),
          Expanded(
            child: _buildStatItem(
              isHindi ? 'ध्यान चाहिए' : 'Attention',
              needsAttention.toString(),
              Icons.warning_amber,
              Colors.orange,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.blue[200]),
          Expanded(
            child: _buildStatItem(
              isHindi ? 'जोखिम में' : 'At Risk',
              atRisk.toString(),
              Icons.error,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContactCard(RelationshipHealth health, bool isHindi) {
    final contact = health.contact;

    return ContactPlaceholder(
      name: contact.displayName,
      subtitle: _getContactSubtitle(health, isHindi),
      emotionalScore: contact.emotionalScoreEmoji,
      scoreValue: health.overallScore * 100,
      imageUrl: contact.profilePicture,
      showInsights: true,
      onTap: () => _showContactDetails(health, isHindi),
    );
  }

  String _getContactSubtitle(RelationshipHealth health, bool isHindi) {
    final days = health.contact.daysSinceLastContact;

    if (days == 0) {
      return isHindi ? 'आज संपर्क हुआ' : 'Contacted today';
    } else if (days == 1) {
      return isHindi ? 'कल संपर्क हुआ' : 'Contacted yesterday';
    } else if (days < 7) {
      return isHindi ? '$days दिन पहले' : '$days days ago';
    } else if (days < 30) {
      final weeks = (days / 7).round();
      return isHindi ? '$weeks हफ्ते पहले' : '$weeks weeks ago';
    } else {
      final months = (days / 30).round();
      return isHindi ? '$months महीने पहले' : '$months months ago';
    }
  }

  Widget _buildInsightsTab(bool isHindi) {
    final urgentContacts = _relationshipHealthData
        .where((h) => h.overallScore < 0.4)
        .take(5)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi ? '🚨 तुरंत ध्यान चाहिए' : '🚨 Urgent Attention Needed',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (urgentContacts.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.celebration,
                        size: 48, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(
                      isHindi ? 'बहुत बढ़िया!' : 'Great job!',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isHindi
                          ? 'आपके सभी रिश्ते अच्छी स्थिति में हैं'
                          : 'All your relationships are in good shape',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...urgentContacts
                .map((health) => _buildWarningCard(health, isHindi)),
          const SizedBox(height: 24),
          Text(
            isHindi ? '💡 मुख्य अंतर्दृष्टि' : '💡 Key Insights',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildInsightCards(isHindi),
          const SizedBox(height: 20),
          QuickActionsPanel(
            isHindi: isHindi,
            actions: [
              QuickActionItem(
                icon: Icons.psychology,
                labelEn: 'AI Analytics Dashboard',
                labelHi: 'AI विश्लेषण डैशबोर्ड',
                color: Colors.purple,
                onPressed: () {
                  // TODO: Implement navigation to AI Analytics Dashboard
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(RelationshipHealth health, bool isHindi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.orange[50],
      child: ListTile(
        leading: EmotionalScoreAvatar(
          name: health.contact.displayName,
          emotionalScore: health.contact.emotionalScoreEmoji,
          scoreValue: health.overallScore * 100,
        ),
        title: Text(health.contact.displayName),
        subtitle: Text(
          health.warnings.isNotEmpty
              ? (isHindi
                  ? health.warnings.first.titleHi
                  : health.warnings.first.titleEn)
              : (isHindi
                  ? 'रिश्ता कमजोर पड़ रहा है'
                  : 'Relationship weakening'),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
        onTap: () => _showContactDetails(health, isHindi),
      ),
    );
  }

  Widget _buildInsightCards(bool isHindi) {
    return Column(
      children: [
        _buildInsightCard(
          icon: Icons.trending_down,
          title: isHindi ? 'संपर्क पैटर्न' : 'Communication Patterns',
          description: isHindi
              ? '${_relationshipHealthData.where((h) => h.contact.daysSinceLastContact > 30).length} लोगों से लंबे समय से बात नहीं हुई'
              : '${_relationshipHealthData.where((h) => h.contact.daysSinceLastContact > 30).length} people haven\'t been contacted in over 30 days',
          color: Colors.orange,
        ),
        _buildInsightCard(
          icon: Icons.balance,
          title: isHindi ? 'बातचीत संतुलन' : 'Conversation Balance',
          description: isHindi
              ? '${_relationshipHealthData.where((h) => h.contact.mutualityScore < 0.4).length} रिश्तों में एकतरफा बातचीत हो रही है'
              : '${_relationshipHealthData.where((h) => h.contact.mutualityScore < 0.4).length} relationships show one-sided communication',
          color: Colors.blue,
        ),
        _buildInsightCard(
          icon: Icons.schedule,
          title: isHindi ? 'सबसे अच्छा समय' : 'Best Contact Time',
          description: isHindi
              ? 'शाम 6-9 बजे सबसे अच्छा response मिलता है'
              : 'Evening 6-9 PM shows best response rates',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceTab(bool isHindi) {
    if (_relationshipHealthData.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isHindi
                ? 'विश्लेषण के बाद सलाह यहाँ दिखाई देगी।'
                : 'Advice will appear here after you analyze relationships.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    final recommendations = <Widget>[];

    for (final health in _relationshipHealthData) {
      for (final recommendation in health.recommendations) {
        recommendations.add(
          _buildRecommendationCard(
            health,
            recommendation,
            isHindi,
          ),
        );
      }
    }

    if (recommendations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            isHindi
                ? 'AI ने फिलहाल कोई सुझाव नहीं दिया है।'
                : 'The AI has no suggestions right now.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: recommendations,
    );
  }

  Widget _buildRecommendationCard(
    RelationshipHealth health,
    RelationshipRecommendation recommendation,
    bool isHindi,
  ) {
    final contact = health.contact;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    contact.displayName.isNotEmpty
                        ? contact.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(color: Colors.blue.shade700),
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
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isHindi
                            ? recommendation.titleHi
                            : recommendation.titleEn,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                _buildPriorityChip(recommendation.priority, isHindi),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isHindi
                  ? recommendation.descriptionHi
                  : recommendation.descriptionEn,
              style: const TextStyle(height: 1.4),
            ),
            if (recommendation.suggestedActions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (isHindi
                          ? recommendation.suggestedActionsHi
                          : recommendation.suggestedActions)
                      .map(
                        (action) => Chip(
                          label: Text(action,
                              style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.blue.shade50,
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showContactDetails(health, isHindi),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: Text(isHindi ? 'विस्तार' : 'Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _takeAction(health, recommendation),
                    icon: const Icon(Icons.message, size: 16),
                    label: Text(isHindi ? 'संदेश भेजें' : 'Send Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(RecommendationPriority priority, bool isHindi) {
    Color background;
    String label;

    switch (priority) {
      case RecommendationPriority.urgent:
        background = Colors.red.shade100;
        label = isHindi ? 'अत्यावश्यक' : 'Urgent';
        break;
      case RecommendationPriority.high:
        background = Colors.orange.shade100;
        label = isHindi ? 'उच्च' : 'High';
        break;
      case RecommendationPriority.medium:
        background = Colors.amber.shade100;
        label = isHindi ? 'मध्यम' : 'Medium';
        break;
      default:
        background = Colors.green.shade100;
        label = isHindi ? 'निम्न' : 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSmartMessages(bool isHindi) {
    if (_relationshipHealthData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isHindi
              ? 'पहले रिश्ते का विश्लेषण करें'
              : 'Please analyze relationships first'),
        ),
      );
      return;
    }

    // Show contacts that need attention for smart messaging
    final contactsNeedingAttention = _relationshipHealthData
        .where((h) => h.overallScore < 0.7)
        .map((h) => h.contact)
        .toList();

    if (contactsNeedingAttention.isEmpty) {
      contactsNeedingAttention.addAll(
        _relationshipHealthData.take(3).map((h) => h.contact),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.psychology,
                      color: Colors.purple.shade400, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'AI स्मार्ट मैसेज' : 'AI Smart Messages',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isHindi
                              ? 'बेहतर रिश्तों के लिए सुझाव'
                              : 'Suggestions for better relationships',
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
            ),

            const Divider(),

            // Contact selection
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: contactsNeedingAttention.length,
                itemBuilder: (context, index) {
                  final contact = contactsNeedingAttention[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          contact.displayName[0],
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(contact.displayName),
                      subtitle: Text(
                        isHindi
                            ? '${contact.daysSinceLastContact} दिन पहले संपर्क'
                            : 'Last contact ${contact.daysSinceLastContact} days ago',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        SmartMessageBottomSheet.show(context, contact);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<RelationshipHealth> _getFilteredData() {
    switch (_selectedFilter) {
      case 'needs_attention':
        return _relationshipHealthData
            .where((h) => h.overallScore < 0.6 && h.overallScore >= 0.4)
            .toList();
      case 'thriving':
        return _relationshipHealthData
            .where((h) => h.overallScore >= 0.8)
            .toList();
      case 'at_risk':
        return _relationshipHealthData
            .where((h) => h.overallScore < 0.4)
            .toList();
      default:
        return _relationshipHealthData;
    }
  }

  void _showContactDetails(RelationshipHealth health, bool isHindi) {
    // Navigate to detailed contact analysis page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactDetailsPage(
          health: health,
          privacySettings: widget.privacySettings,
        ),
      ),
    );
  }

  void _takeAction(
      RelationshipHealth health, RelationshipRecommendation recommendation) {
    // Open messaging app or show message template
    showDialog(
      context: context,
      builder: (context) => MessageTemplateDialog(
        contact: health.contact,
        recommendation: recommendation,
        isHindi: widget.privacySettings.language == 'hi',
      ),
    );
  }

  // Mock data generation for demo
  List<ContactInteraction> _generateMockInteractions(Contact contact) {
    // Generate realistic mock interactions based on contact data
    return []; // Simplified for now
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Enhanced Contact Details Page with AI Analytics
class ContactDetailsPage extends StatelessWidget {
  final RelationshipHealth health;
  final PrivacySettings privacySettings;

  const ContactDetailsPage({
    super.key,
    required this.health,
    required this.privacySettings,
  });

  @override
  Widget build(BuildContext context) {
    final isHindi = privacySettings.language == 'hi';

    return Scaffold(
      appBar: AppBar(
        title: Text(health.contact.displayName),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Contact Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        AvatarPlaceholder(
                          name: health.contact.displayName,
                          size: 60,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                health.contact.displayName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${isHindi ? "स्वास्थ्य स्कोर" : "Health Score"}: ${(health.overallScore * 100).round()}%',
                                style: TextStyle(
                                  color: _getScoreColor(health.overallScore),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${isHindi ? "अंतिम संपर्क" : "Last Contact"}: ${health.contact.daysSinceLastContact} ${isHindi ? "दिन पहले" : "days ago"}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick Actions
            Text(
              isHindi ? '⚡ त्वरित कार्य' : '⚡ Quick Actions',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // AI Analytics Button
            Card(
              elevation: 4,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.psychology, color: Colors.purple.shade700),
                ),
                title: Text(
                  isHindi
                      ? '🤖 AI विश्लेषण डैशबोर्ड'
                      : '🤖 AI Analytics Dashboard',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  isHindi
                      ? 'विस्तृत AI-powered रिश्ते की जानकारी'
                      : 'Detailed AI-powered relationship insights',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Analytics disabled - HuggingFace dependency removed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Advanced Analytics temporarily unavailable'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Contact Action Button
            Card(
              elevation: 4,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.message, color: Colors.blue.shade700),
                ),
                title: Text(
                  isHindi ? '💬 संदेश भेजें' : '💬 Send Message',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  isHindi
                      ? 'स्मार्ट संदेश सुझाव के साथ'
                      : 'With smart message suggestions',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isHindi
                            ? 'संदेश सुविधा जल्द आएगी!'
                            : 'Messaging feature coming soon!',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Call Action Button
            Card(
              elevation: 4,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.call, color: Colors.green.shade700),
                ),
                title: Text(
                  isHindi ? '📞 कॉल करें' : '📞 Make Call',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  isHindi
                      ? 'सबसे अच्छे समय की सिफारिश'
                      : 'Best time recommendations',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isHindi
                            ? 'कॉल सुविधा जल्द आएगी!'
                            : 'Calling feature coming soon!',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Relationship Stats
            Text(
              isHindi ? '📊 रिश्ते के आंकड़े' : '📊 Relationship Stats',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatRow(
                      isHindi ? 'कुल कॉल' : 'Total Calls',
                      '${health.contact.totalCalls}',
                      Icons.call,
                      Colors.green,
                    ),
                    const Divider(),
                    _buildStatRow(
                      isHindi ? 'कुल संदेश' : 'Total Messages',
                      '${health.contact.totalMessages}',
                      Icons.message,
                      Colors.blue,
                    ),
                    const Divider(),
                    _buildStatRow(
                      isHindi ? 'भावनात्मक स्कोर' : 'Emotional Score',
                      '${health.contact.emotionalScoreValue.round()}%',
                      Icons.favorite,
                      Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    if (score >= 0.4) return Colors.amber;
    return Colors.red;
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class MessageTemplateDialog extends StatelessWidget {
  final Contact contact;
  final RelationshipRecommendation recommendation;
  final bool isHindi;

  const MessageTemplateDialog({
    super.key,
    required this.contact,
    required this.recommendation,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isHindi ? 'संदेश भेजें' : 'Send Message'),
      content: Text(isHindi
          ? 'संदेश सुविधा जल्द आएगी!'
          : 'Messaging feature coming soon!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isHindi ? 'ठीक है' : 'OK'),
        ),
      ],
    );
  }
}

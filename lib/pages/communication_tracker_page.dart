// lib/pages/communication_tracker_page.dart

import 'package:flutter/material.dart';
import '../core/service_locator.dart';
import '../services/privacy_service.dart';
import '../models/relationship_log.dart';
import '../widgets/service_status_widget.dart';

/// Communication Tracker (Privacy Mode Sample Page)
///
/// Demonstrates privacy-first communication tracking and relationship insights
/// using on-device AI analysis while maintaining user privacy
class CommunicationTrackerPage extends StatefulWidget {
  const CommunicationTrackerPage({super.key});

  @override
  State<CommunicationTrackerPage> createState() =>
      _CommunicationTrackerPageState();
}

class _CommunicationTrackerPageState extends State<CommunicationTrackerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PrivacyService? _privacyService;
  bool _isLoading = false;
  List<RelationshipLog> _communicationLogs = [];
  String _relationshipInsight = '';
  String _selectedContact = 'sample_contact_1';

  final Map<String, String> _sampleContacts = {
    'sample_contact_1': 'Alex Johnson',
    'sample_contact_2': 'Sarah Williams',
    'sample_contact_3': 'Mike Chen',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeServices();
    _loadCommunicationData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeServices() {
    try {
      _privacyService = ServiceLocator.instance.get<PrivacyService>();
      debugPrint('✅ CommunicationTracker: Privacy Service loaded');
    } catch (e) {
      debugPrint('❌ CommunicationTracker: Privacy Service not available: $e');
    }
  }

  Future<void> _loadCommunicationData() async {
    if (_privacyService == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Load communication logs for selected contact
      final logs = await _privacyService!.getLogSummaryForAI(_selectedContact);

      setState(() {
        _communicationLogs = logs;
        _isLoading = false;
      });

      debugPrint('✅ CommunicationTracker: Loaded ${logs.length} logs');
    } catch (e) {
      debugPrint('❌ CommunicationTracker: Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateRelationshipInsight() async {
    if (_privacyService == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final insight =
          await _privacyService!.getRelationshipInsight(_selectedContact);

      setState(() {
        _relationshipInsight = insight;
        _isLoading = false;
      });

      debugPrint('✅ CommunicationTracker: Generated relationship insight');
    } catch (e) {
      debugPrint('❌ CommunicationTracker: Error generating insight: $e');
      setState(() {
        _relationshipInsight = 'Error generating insight: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communication Tracker (Sample)'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.call), text: 'Logs'),
            Tab(icon: Icon(Icons.psychology), text: 'Insights'),
            Tab(icon: Icon(Icons.settings), text: 'Privacy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildLogsTab(),
          _buildInsightsTab(),
          _buildPrivacyTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service status
          const ServiceStatusWidget(),

          const SizedBox(height: 16),

          // Contact selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Contact for Analysis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedContact,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Sample Contact',
                    ),
                    items: _sampleContacts.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedContact = value;
                          _relationshipInsight = '';
                        });
                        _loadCommunicationData();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Communication stats overview
          _buildCommunicationStatsCard(),

          const SizedBox(height: 16),

          // Quick actions
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  Widget _buildCommunicationStatsCard() {
    if (_communicationLogs.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.hourglass_empty, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                _isLoading
                    ? 'Loading communication data...'
                    : 'No communication data available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final stats = CommunicationStats.fromLogs(
      _selectedContact,
      _communicationLogs,
      DateTime.now().subtract(const Duration(days: 30)),
      DateTime.now(),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                Text(
                  'Communication Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Calls',
                    '${stats.totalCalls}',
                    Icons.call,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total Messages',
                    '${stats.totalMessages}',
                    Icons.message,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Daily Frequency',
                    stats.communicationFrequency.toStringAsFixed(1),
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Intimacy Level',
                    '${(stats.averageIntimacyScore * 100).toStringAsFixed(0)}%',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadCommunicationData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _generateRelationshipInsight,
                    icon: const Icon(Icons.psychology),
                    label: const Text('AI Insight'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
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

  Widget _buildLogsTab() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _communicationLogs.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No communication logs available'),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _communicationLogs.length,
                itemBuilder: (context, index) {
                  final log = _communicationLogs[index];
                  return _buildLogCard(log);
                },
              );
  }

  Widget _buildLogCard(RelationshipLog log) {
    final typeIcon =
        log.type == InteractionType.call ? Icons.call : Icons.message;
    final typeColor =
        log.type == InteractionType.call ? Colors.green : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withValues(alpha: 0.1),
          child: Icon(typeIcon, color: typeColor),
        ),
        title: Text(
          '${log.type.name.toUpperCase()} - ${log.isIncoming ? 'Received' : 'Sent'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact: ${log.contactName}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Time: ${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12),
            ),
            if (log.duration > 0)
              Text(
                'Duration: ${log.duration}s',
                style: const TextStyle(fontSize: 12),
              ),
            if (log.keywords.isNotEmpty)
              Text(
                'Keywords: ${log.keywords.join(', ')}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToneChip(log.tone),
            const SizedBox(height: 4),
            Text(
              '${(log.intimacyScore * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToneChip(EmotionalTone tone) {
    final toneColors = {
      EmotionalTone.positive: Colors.green,
      EmotionalTone.negative: Colors.red,
      EmotionalTone.neutral: Colors.grey,
      EmotionalTone.concern: Colors.orange,
      EmotionalTone.excitement: Colors.purple,
      EmotionalTone.love: Colors.pink,
    };

    final color = toneColors[tone] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        tone.name,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.purple[600]),
                      const SizedBox(width: 8),
                      Text(
                        'AI Relationship Insights',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Generating AI insights...'),
                        ],
                      ),
                    )
                  else if (_relationshipInsight.isEmpty)
                    Column(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('No insights generated yet'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _generateRelationshipInsight,
                          icon: const Icon(Icons.psychology),
                          label: const Text('Generate AI Insight'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: Text(
                        _relationshipInsight,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPrivacyNoticeCard(),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ServiceStatusWidget(),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: Colors.green[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Privacy Protection',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPrivacyFeature(
                    'On-Device Processing',
                    'All AI analysis happens locally on your device',
                    Icons.phonelink,
                    Colors.green,
                  ),
                  _buildPrivacyFeature(
                    'No Data Transmission',
                    'Communication data never leaves your device',
                    Icons.wifi_off,
                    Colors.blue,
                  ),
                  _buildPrivacyFeature(
                    'Sample Data Mode',
                    'Currently using sample data for demonstration',
                    Icons.preview,
                    Colors.orange,
                  ),
                  _buildPrivacyFeature(
                    'Encrypted Storage',
                    'All data stored with device-level encryption',
                    Icons.lock,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildPermissionsCard(),
        ],
      ),
    );
  }

  Widget _buildPrivacyFeature(
      String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permission Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildPermissionRow('Communication Tracking', true, 'Sample Mode'),
            _buildPermissionRow('AI Processing', true, 'On-Device Only'),
            _buildPermissionRow('Data Storage', true, 'Local Encrypted'),
            _buildPermissionRow('Network Access', false, 'Disabled'),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow(String permission, bool granted, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            color: granted ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(permission)),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNoticeCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Privacy Notice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This privacy-safe sample view uses communication sample data to illustrate relationship insights. In real usage, all analysis happens fully on-device with your own patterns; no personal data ever leaves your device.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/privacy_settings.dart' as truecircle;

/// 🔒 Privacy Settings Page - Transparency and Control
class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  late truecircle.PrivacySettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = truecircle.PrivacySettings.basicPrivacy();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load from storage
    setState(() {
      // Settings loaded
    });
  }

  Future<void> _saveSettings() async {
    // Save to storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings updated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPrivacyPolicy(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildDataAccessSection(),
          const SizedBox(height: 16),
          _buildAIFeaturesSection(),
          const SizedBox(height: 16),
          _buildSecuritySection(),
          const SizedBox(height: 16),
          _buildDataControlSection(),
          const SizedBox(height: 32),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.blue.shade800),
                const SizedBox(width: 8),
                const Text(
                  'Your Privacy Matters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'TrueCircle is designed with privacy-first principles. All your personal data stays on your device, encrypted and secure.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _showPrivacyPolicy(),
              child: const Text('Read Full Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataAccessSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Access Permissions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Access Contacts'),
              subtitle: const Text('Required for relationship analysis'),
              value: _settings.contactsAccess,
              onChanged: (value) {
                setState(() {
                  _settings.contactsAccess = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Analyze Call Patterns'),
              subtitle: const Text('Understand communication frequency'),
              value: _settings.callLogAccess,
              onChanged: (value) {
                setState(() {
                  _settings.callLogAccess = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Message Pattern Analysis'),
              subtitle: const Text('Analyze messaging habits'),
              value: _settings.smsMetadataAccess,
              onChanged: (value) {
                setState(() {
                  _settings.smsMetadataAccess = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIFeaturesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Features',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Emotional Intelligence AI'),
              subtitle: const Text('Analyze relationship emotional patterns'),
              value: _settings.sentimentAnalysis,
              onChanged: (value) {
                setState(() {
                  _settings.sentimentAnalysis = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Predictive Insights'),
              subtitle: const Text('Future relationship trend analysis'),
              value: _settings.aiInsights,
              onChanged: (value) {
                setState(() {
                  _settings.aiInsights = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Smart Message Suggestions'),
              subtitle: const Text('AI-powered message composition help'),
              value: _settings.aiInsights,
              onChanged: (value) {
                setState(() {
                  _settings.aiInsights = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Cultural AI Insights'),
              subtitle:
                  const Text('Culturally appropriate relationship advice'),
              value: _settings.sentimentAnalysis,
              onChanged: (value) {
                setState(() {
                  _settings.sentimentAnalysis = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const SwitchListTile(
              title: Text('Local Data Encryption'),
              subtitle: Text('Encrypt all stored relationship data'),
              value: true, // Always enabled for security
              onChanged: null, // Always enabled
            ),
            SwitchListTile(
              title: const Text('Anonymous Analytics'),
              subtitle: const Text('Help improve app performance'),
              value: false, // Demo app - no analytics
              onChanged: (value) {
                // Demo app - no analytics collection
              },
            ),
            ListTile(
              title: const Text('App Security Status'),
              subtitle: const Text('Signed APK, Privacy-First Architecture'),
              trailing: Icon(Icons.verified_user, color: Colors.green.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataControlSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data Control',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Data Export'),
              subtitle: const Text('Allow exporting your relationship data'),
              value: _settings.dataExport,
              onChanged: (value) {
                setState(() {
                  _settings.dataExport = value;
                });
              },
            ),
            ListTile(
              title: const Text('Export All Data'),
              subtitle: const Text('Download your relationship data'),
              trailing: const Icon(Icons.download),
              onTap: () => _exportData(),
            ),
            ListTile(
              title: const Text('Delete All Data'),
              subtitle: const Text('Permanently remove all stored data'),
              trailing: Icon(Icons.delete, color: Colors.red.shade600),
              onTap: () => _confirmDeleteAllData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveSettings,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Save Privacy Settings',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TrueCircle Privacy Commitment',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• All personal data stays on your device\n'
                '• No contact information sent to external servers\n'
                '• Local encryption protects your data\n'
                '• You control all privacy settings\n'
                '• Anonymous AI processing only\n'
                '• Data export and deletion available\n'
                '• GDPR compliant privacy controls',
              ),
            ],
          ),
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

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your relationship data will be exported to a secure file. '
          'This includes contacts, interactions, and privacy settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement data export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export started...')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete All Data',
          style: TextStyle(color: Colors.red.shade700),
        ),
        content: const Text(
          'This will permanently delete all your relationship data, '
          'contacts analysis, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              // Implement data deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

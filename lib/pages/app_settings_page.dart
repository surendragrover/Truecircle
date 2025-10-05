import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:truecircle/pages/contact_list_page.dart';
import 'package:truecircle/services/app_mode_service.dart';
import 'package:truecircle/widgets/global_navigation_bar.dart';
import 'package:truecircle/widgets/truecircle_logo.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _isFullMode = false;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final isFull = await AppModeService.isFullMode();
    if (!mounted) return;
    setState(() {
      _isFullMode = isFull;
    });
  }

  Future<void> _toggleFullMode(bool value) async {
    if (!mounted) return;

    if (value) {
      await _showSampleModeRestrictionDialog();
      await AppModeService.setFullMode(false);
      setState(() => _isFullMode = false);
      return;
    }

    await AppModeService.setFullMode(false);
    setState(() => _isFullMode = false);
  }

  Future<void> _showSampleModeRestrictionDialog() {
    final isHindi =
        Localizations.localeOf(context).languageCode.startsWith('hi');
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isHindi ? '🔒 सैंपल मोड सक्रिय' : '🔒 Sample Mode Active'),
        content: Text(
          isHindi
              ? 'Google Play Store अनुपालन के लिए यह ऐप केवल सैंपल मोड में चलता है। वास्तविक अनुमति अनुरोध सक्षम नहीं है।'
              : 'For Google Play Store compliance this release runs strictly in sample mode. Real permission requests are disabled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isHindi ? 'समझ गया' : 'Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!mounted) return;

    final isHindi =
        Localizations.localeOf(context).languageCode.startsWith('hi');
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      _showSnackBar(
        isHindi ? 'URL खोलने में असमर्थ' : 'Could not launch URL',
        isError: true,
      );
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.blue.shade700,
      ),
    );
  }

  void _openAIChatDialog(bool isHindi) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🤖 Iris - AI Relationship Adviser'),
        content: Text(
          isHindi
              ? 'Iris आपकी relationship problems को समझकर व्यक्तिगत सुझाव देगा।\n\n✅ कोई अनुमति नहीं\n✅ सैंपल मोड में कार्यरत\n✅ 100% गोपनीयता\n\nयह फीचर जल्द ही उपलब्ध होगा!'
              : 'Iris understands your relationship patterns and offers personalised suggestions.\n\n✅ Zero permissions needed\n✅ Works in sample mode\n✅ 100% privacy maintained\n\nThis feature is coming soon!',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isHindi ? 'ठीक है' : 'Close'),
          ),
        ],
      ),
    );
  }

  void _showAISuggestionsDialog(bool isHindi) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💡 Smart Suggestions'),
        content: Text(isHindi
            ? 'AI आपके relationship patterns को analyze करके:\n\n• व्यक्तिगत सलाह देता है\n• संवाद सुधारने के टिप्स देता है\n• संबंध लक्ष्य सुझाता है\n\n🔒 Zero permissions\n🎯 Sample mode friendly\n📊 Demo data analysis\n\nयह फीचर विकास में है!'
            : 'AI analyses your relationship patterns to:\n\n• Deliver personalised advice\n• Offer communication tips\n• Suggest relationship goals\n\n🔒 Zero permissions\n🎯 Sample mode friendly\n📊 Demo data analysis\n\nThis feature is under active development!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(isHindi ? 'समझ गया' : 'Understood'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  Widget _buildLinkTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String url,
  }) {
    return _buildInfoTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: const Icon(Icons.open_in_new),
      onTap: () => _launchUrl(url),
    );
  }

  Widget _buildSDKDownloadTile(bool isHindi) {
    final platform = Theme.of(context).platform;
    String title;
    String subtitle;
    String url = '';

    switch (platform) {
      case TargetPlatform.android:
        title = isHindi ? 'Android SDK डाउनलोड करें' : 'Download Android SDK';
        subtitle = isHindi
            ? 'अपने डिवाइस के लिए TrueCircle SDK प्राप्त करें'
            : 'Fetch the TrueCircle SDK for your device';
        url = 'https://truecircle.online/sdk/android';
        break;
      case TargetPlatform.windows:
        title = isHindi ? 'Windows SDK डाउनलोड करें' : 'Download Windows SDK';
        subtitle = isHindi
            ? 'Windows प्लेटफ़ॉर्म के लिए SDK डाउनलोड'
            : 'Download the SDK for Windows';
        url = 'https://truecircle.online/sdk/windows';
        break;
      case TargetPlatform.macOS:
        title = isHindi ? 'macOS SDK डाउनलोड करें' : 'Download macOS SDK';
        subtitle = isHindi
            ? 'macOS संस्करण के लिए SDK प्राप्त करें'
            : 'Get the SDK for macOS builds';
        url = 'https://truecircle.online/sdk/macos';
        break;
      case TargetPlatform.linux:
        title = isHindi ? 'Linux SDK डाउनलोड करें' : 'Download Linux SDK';
        subtitle = isHindi
            ? 'Linux वितरणों के लिए SDK'
            : 'SDK for Linux distributions';
        url = 'https://truecircle.online/sdk/linux';
        break;
      default:
        title = isHindi ? 'SDK डाउनलोड करें' : 'Download SDK';
        subtitle = isHindi
            ? 'अपने प्लेटफ़ॉर्म के लिए TrueCircle SDK डाउनलोड करें'
            : 'Download the TrueCircle SDK for your platform';
        url = 'https://truecircle.online/sdk';
        break;
    }

    return _buildInfoTile(
      icon: Icons.download,
      title: title,
      subtitle: subtitle,
      onTap: () => _launchUrl(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHindi =
        Localizations.localeOf(context).languageCode.startsWith('hi');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const TrueCircleLogo(size: 30),
            const SizedBox(width: 12),
            Text(isHindi ? '⚙️ सेटिंग्स' : '⚙️ Settings'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: isHindi ? '🚀 ऐप मोड' : '🚀 App Mode',
              children: [
                SwitchListTile.adaptive(
                  value: _isFullMode,
                  onChanged: _toggleFullMode,
                  secondary: Icon(
                    _isFullMode ? Icons.data_usage : Icons.preview,
                    color: Colors.blue.shade700,
                  ),
                  title: Text(
                    isHindi
                        ? (_isFullMode ? 'फुल मोड सक्रिय' : 'सैंपल मोड सक्रिय')
                        : (_isFullMode
                            ? 'Full Mode Active'
                            : 'Sample Mode Active'),
                  ),
                  subtitle: Text(
                    isHindi
                        ? 'यह रिलीज़ गोपनीयता की वजह से हमेशा सैंपल मोड में रहती है'
                        : 'This release stays in sample mode to honour privacy guarantees',
                  ),
                ),
                const Divider(height: 0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    isHindi
                        ? 'सैंपल मोड में ऐप डेमो डेटा का उपयोग करता है और कोई व्यक्तिगत अनुमति नहीं मांगता।'
                        : 'In sample mode the app uses demo data and never requests personal permissions.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: isHindi ? '🛠️ डेवलपर विकल्प' : '🛠️ Developer Options',
              children: [
                _buildInfoTile(
                  icon: Icons.contacts,
                  title: isHindi
                      ? 'डिवाइस संपर्क (डेमो)'
                      : 'Device Contacts (Demo)',
                  subtitle: isHindi
                      ? 'सैंपल संपर्क सूची देखें'
                      : 'View the sample contact list',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactListPage(),
                      ),
                    );
                  },
                ),
                _buildInfoTile(
                  icon: Icons.smart_toy,
                  title: isHindi ? 'AI चैट पूर्वावलोकन' : 'AI Chat Preview',
                  subtitle: isHindi
                      ? 'Iris AI सलाहकार का पूर्वावलोकन'
                      : 'Preview the Iris AI advisor experience',
                  onTap: () => _openAIChatDialog(isHindi),
                ),
                _buildSDKDownloadTile(isHindi),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: isHindi ? '⚡ AI संचालित फीचर्स' : '⚡ AI Powered Features',
              children: [
                _buildInfoTile(
                  icon: Icons.psychology,
                  title: isHindi ? 'स्मार्ट सुझाव' : 'Smart Suggestions',
                  subtitle: isHindi
                      ? 'AI संचालित relationship insights'
                      : 'AI-powered relationship insights',
                  onTap: () => _showAISuggestionsDialog(isHindi),
                ),
                _buildInfoTile(
                  icon: Icons.analytics,
                  title:
                      isHindi ? 'सैंपल डेटा विश्लेषण' : 'Sample Data Analysis',
                  subtitle: isHindi
                      ? 'Demo_data फ़ाइलों का उपयोग कर इनसाइट्स'
                      : 'Insights generated from Demo_data assets',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: isHindi ? '🔒 गोपनीयता और कानूनी' : '🔒 Privacy & Legal',
              children: [
                _buildLinkTile(
                  icon: Icons.privacy_tip,
                  title: isHindi ? 'गोपनीयता नीति' : 'Privacy Policy',
                  subtitle: isHindi
                      ? 'हम आपकी गोपनीयता कैसे सुरक्षित रखते हैं (कोई डेटा संग्रह नहीं)'
                      : 'How we protect your privacy (zero data collection)',
                  url: 'https://truecircle.online/privacy-policy',
                ),
                _buildLinkTile(
                  icon: Icons.description,
                  title: isHindi ? 'नियम और शर्तें' : 'Terms & Conditions',
                  subtitle: isHindi
                      ? 'केवल शैक्षिक उपयोग के लिए'
                      : 'For educational/demo usage',
                  url: 'https://truecircle.online/terms-and-conditions/',
                ),
                _buildInfoTile(
                  icon: Icons.security,
                  title: isHindi ? 'डेटा सुरक्षा' : 'Data Safety',
                  subtitle: isHindi
                      ? 'Zero permissions • 100% offline • केवल सैंपल डेटा'
                      : 'Zero permissions • 100% offline • Sample data only',
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'SAFE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified_user,
                      color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    isHindi ? '🔒 गोपनीयता गारंटी' : '🔒 Privacy Guarantee',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isHindi
                        ? 'TrueCircle कोई व्यक्तिगत डेटा एकत्र नहीं करता।\nआपकी गोपनीयता 100% सुरक्षित है।'
                        : 'TrueCircle collects ZERO personal data.\nYour privacy is 100% protected.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    isHindi
                        ? '© 2025 TrueCircle विकास टीम'
                        : '© 2025 TrueCircle Development Team',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isHindi
                        ? 'जयपुर, राजस्थान, भारत 🇮🇳 में निर्मित'
                        : 'Made in Jaipur, Rajasthan, India 🇮🇳',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GlobalNavigationBar(isHindi: isHindi),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  // URLs for hosted policies (truecircle.online domain)
  static const String privacyPolicyUrl =
      'https://truecircle.online/privacy-policy';
  static const String termsConditionsUrl =
      'https://truecircle.online/terms-and-conditions/'; // Live URL with hyphens and trailing slash
  static const String supportEmail = 'support@truecircle.app';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy & Legal Section
            _buildSection(
              title: '🔒 Privacy & Legal',
              children: [
                _buildLinkTile(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  subtitle:
                      'How we protect your privacy (Zero data collection)',
                  url: privacyPolicyUrl,
                  context: context,
                ),
                _buildLinkTile(
                  icon: Icons.description,
                  title: 'Terms & Conditions',
                  subtitle: 'Educational use terms and conditions',
                  url: termsConditionsUrl,
                  context: context,
                ),
                _buildInfoTile(
                  icon: Icons.security,
                  title: 'Data Safety',
                  subtitle:
                      'Zero permissions • 100% offline • Sample data only',
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

            // AI Powered App Section
            _buildSection(
              title: '🤖 AI Powered App',
              children: [
                _buildInfoTile(
                  icon: Icons.smart_toy,
                  title: 'AI Powered Technology',
                  subtitle: 'This app uses advanced AI for emotional analysis',
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildInfoTile(
                  icon: Icons.chat_bubble_outline,
                  title: 'Dr. Iris - Your Emotional Therapist',
                  subtitle:
                      'Chat with Dr. Iris for emotional support • Demo mode ready',
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => _openAIChat(context),
                ),
                _buildInfoTile(
                  icon: Icons.psychology,
                  title: 'Smart Suggestions',
                  subtitle:
                      'AI-powered relationship insights और recommendations',
                  onTap: () => _showAISuggestions(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy Guarantee Banner
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
              child: const Column(
                children: [
                  Icon(Icons.verified_user, color: Colors.white, size: 32),
                  SizedBox(height: 8),
                  Text(
                    '🔒 Privacy Guarantee',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'TrueCircle collects ZERO personal data.\nYour privacy is 100% protected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Legal Footer
            Center(
              child: Column(
                children: [
                  Text(
                    '© 2025 TrueCircle Development Team',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made in Jaipur, Rajasthan, India 🇮🇳',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
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
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => _launchURL(url, context),
    );
  }

  Future<void> _launchURL(String url, BuildContext context) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Cannot open link');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error opening link: $e');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _openAIChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('🤖 Iris - AI Relationship Adviser'),
          content: const Text(
            'Iris आपकी relationship problems को समझकर personalized सलाह देगा।\n\n'
            '✅ No permissions required\n'
            '✅ Works in demo mode\n'
            '✅ 100% privacy protected\n'
            '✅ Fully functional\n\n'
            'यह AI adviser जल्द ही available होगा!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ठीक है'),
            ),
          ],
        );
      },
    );
  }

  void _showAISuggestions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('💡 Smart Suggestions'),
          content: const Text(
            'AI आपके relationship patterns को analyze करके:\n\n'
            '• व्यक्तिगत सलाह देगा\n'
            '• Communication tips provide करेगा\n'
            '• Relationship goals suggest करेगा\n\n'
            '🔒 Zero permissions needed\n'
            '🎯 Demo mode friendly\n'
            '📊 Sample data analysis\n\n'
            'यह feature development में है!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('समझ गया'),
            ),
          ],
        );
      },
    );
  }
}

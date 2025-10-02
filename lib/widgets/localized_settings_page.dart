import 'package:flutter/material.dart';
import '../services/app_localization_service.dart';
import '../services/indian_languages_service.dart';
import '../widgets/indian_language_selector.dart';

/// Localized Settings Page
class LocalizedSettingsPage extends StatefulWidget {
  const LocalizedSettingsPage({super.key});

  @override
  State<LocalizedSettingsPage> createState() => _LocalizedSettingsPageState();
}

class _LocalizedSettingsPageState extends State<LocalizedSettingsPage>
    with AutomaticKeepAliveClientMixin {
  final AppLocalizationService _localizationService =
      AppLocalizationService.instance;
  final IndianLanguagesService _languageService =
      IndianLanguagesService.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return Directionality(
          textDirection: _languageService
              .getTextDirection(_localizationService.currentLanguage),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('settings'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLanguageSection(),
                const SizedBox(height: 20),
                _buildPrivacySection(),
                const SizedBox(height: 20),
                _buildNotificationSection(),
                const SizedBox(height: 20),
                _buildAboutSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: Colors.indigo[600]),
                const SizedBox(width: 12),
                Text(
                  context.t('languages'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(context.t('change_language')),
              subtitle: Text(
                'Current: ${_localizationService.currentLanguageDetails.nameNative}',
                style: TextStyle(
                  fontFamily: _languageService
                      .getFontFamily(_localizationService.currentLanguage),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showLanguageSelector,
            ),
            const Divider(),
            ListTile(
              title: Text(context.t('translation_demo')),
              subtitle: const Text('Test translation features'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to translation demo
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.privacy_tip, color: Colors.green[600]),
                const SizedBox(width: 12),
                Text(
                  context.t('privacy_settings'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(context.t('sync_contacts')),
              subtitle: const Text('Allow app to access contacts'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text(context.t('data_analysis')),
              subtitle: const Text('Enable emotion pattern analysis'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text(context.t('content_analysis')),
              subtitle: const Text('Analyze message content for insights'),
              value: false,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text(context.t('cultural_insights')),
              subtitle: const Text('Regional festival recommendations'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: Colors.orange[600]),
                const SizedBox(width: 12),
                Text(
                  context.t('notification_settings'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(context.t('enable_notifications')),
              subtitle: const Text('Receive app notifications'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: Text(context.t('daily_reminder')),
              subtitle: const Text('Daily emotion logging reminder'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Festival Reminders'),
              subtitle: const Text('Get notified about upcoming festivals'),
              value: true,
              onChanged: (value) {},
            ),
            SwitchListTile(
              title: const Text('Loyalty Updates'),
              subtitle: const Text('Updates about loyalty points'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600]),
                const SizedBox(width: 12),
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(context.t('app_name')),
              subtitle: const Text('Version 1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text('Language Coverage'),
              subtitle: Text(
                  '${IndianLanguagesService.supportedLanguages.length} Indian languages supported'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showLanguageStats,
            ),
            const Divider(),
            ListTile(
              title: const Text('Help & Support'),
              subtitle: const Text('Get help with using the app'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text('Terms & Privacy'),
              subtitle: const Text('Read our terms and privacy policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text('Clear Cache'),
              subtitle: const Text('Clear cached translations'),
              trailing: const Icon(Icons.delete_outline),
              onTap: _clearCache,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.t('select_language'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: IndianLanguageSelector(
                  onLanguageChanged: (language) {
                    _localizationService.setLanguage(language.code);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Language changed to ${language.nameNative}',
                          style: TextStyle(
                            fontFamily:
                                _languageService.getFontFamily(language.code),
                          ),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageStats() {
    const languages = IndianLanguagesService.supportedLanguages;
    final regions = {
      'North India': languages
          .where((l) => ['hi', 'pa', 'ur', 'ne'].contains(l.code))
          .length,
      'South India': languages
          .where((l) => ['ta', 'te', 'kn', 'ml'].contains(l.code))
          .length,
      'East India':
          languages.where((l) => ['bn', 'as', 'or'].contains(l.code)).length,
      'West India':
          languages.where((l) => ['gu', 'mr', 'ko'].contains(l.code)).length,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language Statistics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Languages: ${languages.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Regional Distribution:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...regions.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              const Text(
                'Script Support:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text('• Devanagari (Hindi, Marathi, Nepali)'),
              const Text('• Bengali Script (Bengali, Assamese)'),
              const Text('• Tamil Script'),
              const Text('• Telugu Script'),
              const Text('• Gujarati Script'),
              const Text('• Kannada Script'),
              const Text('• Malayalam Script'),
              const Text('• Gurmukhi (Punjabi)'),
              const Text('• Arabic Script (Urdu)'),
              const Text('• Odia Script'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('ok')),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'This will clear all cached translations. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await _localizationService.clearCache();
              if (context.mounted) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.t('success')),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

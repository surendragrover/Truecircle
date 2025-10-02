import 'package:flutter/material.dart';
import '../services/app_localization_service.dart';
import '../services/indian_languages_service.dart';

/// Localized Home Page
class LocalizedHomePage extends StatefulWidget {
  const LocalizedHomePage({super.key});

  @override
  State<LocalizedHomePage> createState() => _LocalizedHomePageState();
}

class _LocalizedHomePageState extends State<LocalizedHomePage>
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
                // Welcome card
                _buildWelcomeCard(),
                const SizedBox(height: 20),

                // Quick stats
                _buildQuickStats(),
                const SizedBox(height: 20),

                // Quick actions
                _buildQuickActions(),
                const SizedBox(height: 20),

                // Recent activity
                _buildRecentActivity(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    final greeting = _getLocalizedGreeting();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[400]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.t('welcome'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _localizationService.currentLanguageDetails.nameNative,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.waving_hand,
                  color: Colors.orange,
                  size: 32,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite,
            title: context.t('emotions'),
            value: '12',
            subtitle: 'This week',
            color: Colors.pink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            title: context.t('contacts'),
            value: '45',
            subtitle: 'Total',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.celebration,
            title: context.t('festivals'),
            value: '3',
            subtitle: 'Coming up',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.favorite_border,
                label: context.t('log_emotion'),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.person_add,
                label: context.t('add_contact'),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.card_giftcard,
                label: context.t('loyalty'),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.language,
                label: context.t('languages'),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildActivityTile(
                icon: Icons.favorite,
                title: '${context.t('emotion_happy')} logged',
                subtitle: '2 hours ago',
                color: Colors.yellow,
              ),
              const Divider(height: 1),
              _buildActivityTile(
                icon: Icons.celebration,
                title: 'Diwali reminder set',
                subtitle: '1 day ago',
                color: Colors.orange,
              ),
              const Divider(height: 1),
              _buildActivityTile(
                icon: Icons.language,
                title:
                    '${context.t('change_language')}: ${_localizationService.currentLanguageDetails.nameNative}',
                subtitle: 'Just now',
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.black,
      ),
    );
  }

  String _getLocalizedGreeting() {
    final hour = DateTime.now().hour;
    final currentLang = _localizationService.currentLanguage;

    final morningGreetings = {
      'hi': 'सुप्रभात',
      'bn': 'সুপ্রভাত',
      'ta': 'காலை வணக்கம்',
      'te': 'శుభోదయం',
      'gu': 'સુપ્રભાત',
      'kn': 'ಶುಭೋದಯ',
      'ml': 'സുപ്രഭാതം',
      'mr': 'सुप्रभात',
      'ur': 'صبح بخیر',
      'pa': 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ',
    };

    final eveningGreetings = {
      'hi': 'शुभ संध्या',
      'bn': 'শুভ সন্ধ্যা',
      'ta': 'மாலை வணக்கம்',
      'te': 'శుభ సాయంత్రం',
      'gu': 'સાંજે સારી',
      'kn': 'ಶುಭ ಸಂಜೆ',
      'ml': 'ശുഭ സായാഹ്നം',
      'mr': 'शुभ संध्याकाळ',
      'ur': 'شام بخیر',
      'pa': 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ',
    };

    final generalGreetings = {
      'hi': 'नमस्ते',
      'bn': 'নমস্কার',
      'ta': 'வணக்கம்',
      'te': 'నమస్కారం',
      'gu': 'નમસ્તે',
      'kn': 'ನಮಸ್ಕಾರ',
      'ml': 'നമസ്കാരം',
      'mr': 'नमस्कार',
      'ur': 'السلام علیکم',
      'pa': 'ਸਤ ਸ੍ਰੀ ਅਕਾਲ',
    };

    if (hour < 12) {
      return morningGreetings[currentLang] ?? context.t('good_morning');
    } else if (hour < 18) {
      return generalGreetings[currentLang] ?? context.t('hello');
    } else {
      return eveningGreetings[currentLang] ?? context.t('good_evening');
    }
  }
}

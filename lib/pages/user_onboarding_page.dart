import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth_wrapper.dart';

class UserOnboardingPage extends StatefulWidget {
  const UserOnboardingPage({super.key});

  @override
  State<UserOnboardingPage> createState() => _UserOnboardingPageState();
}

class _UserOnboardingPageState extends State<UserOnboardingPage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  String _selectedLanguage = 'English';
  bool _isProcessing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(theme),
                  _buildCompletePage(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Chip(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            label: Text(
              _selectedLanguage == 'English'
                  ? 'Sample Mode On'
                  : 'सैंपल मोड सक्रिय',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: _selectedLanguage,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(
                value: 'English',
                child: Text('English'),
              ),
              DropdownMenuItem(
                value: 'हिंदी',
                child: Text('हिंदी'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedLanguage = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    final isEnglish = _selectedLanguage == 'English';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEnglish
                      ? 'Welcome to TrueCircle'
                      : 'TrueCircle में आपका स्वागत है',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isEnglish
                      ? 'Set up the privacy-first demo experience in a couple of quick steps.'
                      : 'कदम दर कदम मार्गदर्शन के साथ प्राइवेसी-प्रथम डेमो अनुभव सेट करें।',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                _buildStepCard(
                  theme,
                  index: 1,
                  title:
                      isEnglish ? 'Confirm Sample Mode' : 'सैंपल मोड सुनिश्चित करें',
                  description: isEnglish
                      ? 'All analysis happens with on-device demo data. No permissions required.'
                      : 'सारी एनालिसिस डिवाइस पर मौजूद डेमो डेटा से होती है। किसी अनुमति की आवश्यकता नहीं है।',
                ),
                const SizedBox(height: 16),
                _buildStepCard(
                  theme,
                  index: 2,
                  title:
                      isEnglish ? 'Prepare Demo Insights' : 'डेमो इनसाइट्स तैयार करें',
                  description: isEnglish
                      ? 'We generate cultural AI samples so you can explore every feature offline.'
                      : 'हम सांस्कृतिक AI नमूने तैयार करते हैं ताकि आप सभी फीचर ऑफलाइन देख सकें।',
                ),
                const SizedBox(height: 16),
                _buildStepCard(
                  theme,
                  index: 3,
                  title:
                      isEnglish ? 'Review Privacy Promises' : 'प्राइवेसी वादे पढ़ें',
                  description: isEnglish
                      ? 'Understand how zero-permission architecture keeps your personal world safe.'
                      : 'जानें कि ज़ीरो परमिशन आर्किटेक्चर आपकी जानकारी कैसे सुरक्षित रखता है।',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(
                      isEnglish ? 'Begin Demo Setup' : 'डेमो सेटअप शुरू करें',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isProcessing ? null : _prepareDemoData,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepCard(
    ThemeData theme, {
    required int index,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
            child: Text(
              index.toString(),
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletePage(ThemeData theme) {
    final isEnglish = _selectedLanguage == 'English';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  isEnglish ? 'Demo Ready!' : 'डेमो तैयार है!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isEnglish
                      ? 'Cultural AI, relationship insights, and emotional wellness guides are prepared for you.'
                      : 'सांस्कृतिक AI, रिलेशनशिप इनसाइट्स और भावनात्मक वेलनेस गाइड अब आपके लिए उपलब्ध हैं।',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildHighlightCard(
                  theme,
                  icon: Icons.psychology,
                  title: isEnglish ? 'AI Smart Messages' : 'AI स्मार्ट संदेश',
                  description: isEnglish
                      ? 'Get context-aware nudges for people who need attention.'
                      : 'जिन्हें ध्यान की ज़रूरत है उनके लिए संदर्भ आधारित सुझाव प्राप्त करें।',
                ),
                const SizedBox(height: 12),
                _buildHighlightCard(
                  theme,
                  icon: Icons.security,
                  title: isEnglish ? 'Private By Default' : 'डिफ़ॉल्ट रूप से निजी',
                  description: isEnglish
                      ? 'All insights are generated on-device using mock data only.'
                      : 'सभी इनसाइट्स केवल ऑन-डिवाइस मॉक डेटा से तैयार की जाती हैं।',
                ),
                const SizedBox(height: 12),
                _buildHighlightCard(
                  theme,
                  icon: Icons.celebration,
                  title: isEnglish ? 'Festival Intelligence' : 'त्योहारी बुद्धिमत्ता',
                  description: isEnglish
                      ? 'See upcoming cultural moments and bilingual greetings.'
                      : 'आगामी सांस्कृतिक अवसर और द्विभाषी शुभकामनाएँ देखें।',
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _completeOnboarding,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      isEnglish
                          ? 'Start Exploring TrueCircle'
                          : 'TrueCircle का उपयोग शुरू करें',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6233),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHighlightCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _prepareDemoData() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _currentPage = 1;
    });
    _pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);
    await prefs.setString('preferred_language', _selectedLanguage);
    await prefs.setString(
      'setup_completed_at',
      DateTime.now().toIso8601String(),
    );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
      (route) => false,
    );
  }
}

import 'package:flutter/material.dart';
import '../services/app_localization_service.dart';
import '../services/indian_languages_service.dart';
import '../widgets/indian_language_selector.dart';
import 'localized_home_page.dart';
import 'localized_emotions_page.dart';
import 'localized_festivals_page.dart';
import 'localized_settings_page.dart';

/// Main app widget with complete localization support
class LocalizedAppMain extends StatefulWidget {
  const LocalizedAppMain({super.key});

  @override
  State<LocalizedAppMain> createState() => _LocalizedAppMainState();
}

class _LocalizedAppMainState extends State<LocalizedAppMain>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final AppLocalizationService _localizationService =
      AppLocalizationService.instance;
  final IndianLanguagesService _languageService =
      IndianLanguagesService.instance;

  final List<Widget> _pages = [
    const LocalizedHomePage(),
    const LocalizedEmotionsPage(),
    const LocalizedFestivalsPage(),
    const LocalizedSettingsPage(),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return Directionality(
          textDirection: _languageService
              .getTextDirection(_localizationService.currentLanguage),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                context.t('app_name'),
                style: TextStyle(
                  fontFamily: _languageService
                      .getFontFamily(_localizationService.currentLanguage),
                ),
              ),
              actions: [
                // Language selector in app bar
                CompactLanguageSelector(
                  onLanguageChanged: (language) {
                    _localizationService.setLanguage(language.code);
                  },
                ),
                const SizedBox(width: 8),

                // Settings button
                IconButton(
                  icon: const Icon(Icons.settings),
                  tooltip: context.t('settings'),
                  onPressed: () {
                    setState(() {
                      _currentIndex = 3; // Settings page
                    });
                  },
                ),
              ],
            ),
            body: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => FadeTransition(
                opacity: _fadeAnimation,
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedItemColor: Colors.indigo,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: context.t('home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.favorite),
                  label: context.t('emotions'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.celebration),
                  label: context.t('festivals'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: context.t('settings'),
                ),
              ],
            ),
            floatingActionButton: _buildFloatingActionButton(),
          ),
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 0: // Home
        return FloatingActionButton(
          onPressed: _showQuickActions,
          tooltip: context.t('add'),
          child: const Icon(Icons.add),
        );
      case 1: // Emotions
        return FloatingActionButton(
          onPressed: _logEmotion,
          tooltip: context.t('log_emotion'),
          child: const Icon(Icons.favorite_border),
        );
      case 2: // Festivals
        return FloatingActionButton(
          onPressed: _addFestivalReminder,
          tooltip: context.t('add'),
          child: const Icon(Icons.celebration_outlined),
        );
      default:
        return null;
    }
  }

  void _showQuickActions() {
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
            Text(
              context.t('add'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.favorite,
                  label: context.t('emotions'),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 1;
                    });
                    _logEmotion();
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.person_add,
                  label: context.t('add_contact'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddContact();
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.celebration,
                  label: context.t('festivals'),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.account_balance_wallet,
                  label: context.t('budget'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showBudget();
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.card_giftcard,
                  label: context.t('loyalty'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showLoyalty();
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.language,
                  label: context.t('languages'),
                  onPressed: () {
                    Navigator.pop(context);
                    _showLanguageSelector();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.indigo[50],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.indigo[200]!),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.indigo),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _logEmotion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('how_are_you_feeling')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEmotionChip(
                  context.t('emotion_happy'), '😊', Colors.yellow),
              _buildEmotionChip(context.t('emotion_sad'), '😢', Colors.blue),
              _buildEmotionChip(context.t('emotion_angry'), '😠', Colors.red),
              _buildEmotionChip(
                  context.t('emotion_excited'), '🤩', Colors.orange),
              _buildEmotionChip(context.t('emotion_calm'), '😌', Colors.green),
              _buildEmotionChip(
                  context.t('emotion_anxious'), '😰', Colors.purple),
              _buildEmotionChip(context.t('emotion_love'), '🥰', Colors.pink),
              _buildEmotionChip(
                  context.t('emotion_grateful'), '🙏', Colors.teal),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('cancel')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionChip(String emotion, String emoji, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${context.t('emotion')}: $emotion $emoji'),
                backgroundColor: color,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.1),
            foregroundColor: color,
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(emotion),
            ],
          ),
        ),
      ),
    );
  }

  void _addFestivalReminder() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('upcoming_festivals')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🪔', style: TextStyle(fontSize: 24)),
              title: const Text('Diwali'),
              subtitle: Text(context.t('festival_wishes')),
              onTap: () {
                Navigator.pop(context);
                _showFestivalWishes('Diwali', '🪔');
              },
            ),
            ListTile(
              leading: const Text('🎉', style: TextStyle(fontSize: 24)),
              title: const Text('Holi'),
              subtitle: Text(context.t('festival_wishes')),
              onTap: () {
                Navigator.pop(context);
                _showFestivalWishes('Holi', '🎉');
              },
            ),
            ListTile(
              leading: const Text('🕉️', style: TextStyle(fontSize: 24)),
              title: const Text('Navratri'),
              subtitle: Text(context.t('festival_wishes')),
              onTap: () {
                Navigator.pop(context);
                _showFestivalWishes('Navratri', '🕉️');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('cancel')),
          ),
        ],
      ),
    );
  }

  void _showFestivalWishes(String festival, String emoji) {
    final greetings = {
      'hi': 'आपको और आपके परिवार को $festival की हार्दिक शुभकामनाएं! $emoji',
      'bn': 'আপনাকে এবং আপনার পরিবারকে $festival এর শুভেচ্ছা! $emoji',
      'ta':
          'உங்களுக்கும் உங்கள் குடும்பத்திற்கும் $festival வாழ்த்துக்கள்! $emoji',
      'te': 'మీకు మరియు మీ కుటుంబానికి $festival శుభాకాంక్షలు! $emoji',
      'gu': 'તમને અને તમારા કુટુંબને $festival ની શુભકામનાઓ! $emoji',
      'kn': 'ನಿಮಗೆ ಮತ್ತು ನಿಮ್ಮ ಕುಟುಂಬಕ್ಕೆ $festival ಶುಭಾಶಯಗಳು! $emoji',
      'ml': 'നിങ്ങൾക്കും നിങ്ങളുടെ കുടുംബത്തിനും $festival ആശംസകൾ! $emoji',
      'mr': 'तुम्हाला आणि तुमच्या कुटुंबाला $festival च्या शुभेच्छा! $emoji',
      'ur': 'آپ کو اور آپ کے خاندان کو $festival مبارک ہو! $emoji',
      'pa': 'ਤੁਹਾਨੂੰ ਅਤੇ ਤੁਹਾਡੇ ਪਰਿਵਾਰ ਨੂੰ $festival ਦੀਆਂ ਮੁਬਾਰਕਾਂ! $emoji',
    };

    final greeting = greetings[_localizationService.currentLanguage] ??
        'Wishing you and your family a happy $festival! $emoji';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$festival ${context.t('festival_wishes')}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontSize: 16,
                fontFamily: _languageService
                    .getFontFamily(_localizationService.currentLanguage),
              ),
              textDirection: _languageService
                  .getTextDirection(_localizationService.currentLanguage),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Share functionality
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Copy functionality
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ],
            ),
          ],
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

  void _showAddContact() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('add_contact')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: context.t('contact_name'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: context.t('relationship_type'),
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                    value: 'family', child: Text(context.t('family'))),
                DropdownMenuItem(
                    value: 'friends', child: Text(context.t('friends'))),
                DropdownMenuItem(
                    value: 'colleagues', child: Text(context.t('colleagues'))),
                DropdownMenuItem(
                    value: 'partner', child: Text(context.t('partner'))),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.t('success')),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(context.t('save')),
          ),
        ],
      ),
    );
  }

  void _showBudget() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('event_budget')),
        content: Text('${context.t('feature_not_available')} - Coming Soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t('ok')),
          ),
        ],
      ),
    );
  }

  void _showLoyalty() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.t('loyalty')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.t('daily_login')),
            Text(context.t('point_value')),
            Text(context.t('max_discount')),
          ],
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

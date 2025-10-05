import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/dr_iris_dashboard.dart';
import 'pages/gift_marketplace_page.dart';
import 'pages/breathing_exercises_page.dart';
import 'pages/sleep_tracker_page.dart';
import 'pages/mood_journal_page.dart';
import 'pages/emotional_check_in_entry_page.dart';
import 'widgets/permission_explanation_dialog.dart';
import 'package:truecircle/services/ai_orchestrator_service.dart';
import 'pages/event_budget_page.dart';
import 'pages/how_truecircle_works_page.dart';
import 'pages/feature_page.dart';
import 'theme/coral_theme.dart';
import 'pages/cbt_center_page.dart';
import 'pages/progress_tracker_page.dart';
import 'pages/sample_data_diagnostics_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String selectedLanguage = 'English';
  bool _isFullFunctionalMode = false; // Default to Sample mode
  static const String _homeLangPrefKey = 'home_language_pref';

  @override
  void initState() {
    super.initState();
    _restoreLanguage();
  }

  Future<void> _restoreLanguage() async {
    try {
      final box = await Hive.openBox('truecircle_settings');
      final lang = box.get(_homeLangPrefKey, defaultValue: 'English') as String;
      if (lang != selectedLanguage) {
        setState(() => selectedLanguage = lang);
      }
    } catch (_) {}
  }

  Future<void> _persistLanguage() async {
    try {
      final box = await Hive.openBox('truecircle_settings');
      await box.put(_homeLangPrefKey, selectedLanguage);
    } catch (_) {}
  }

  // Feature data for the dashboard
  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Emotional Check-in',
      'titleHi': 'भावनात्मक जांच',
      'subtitle': 'Track your daily emotions',
      'subtitleHi': 'अपनी दैनिक भावनाओं को ट्रैक करें',
      'icon': Icons.psychology,
      'color': Colors.purple,
      'action': 'emotional_checkin',
    },
    {
      'title': 'Relationship Insights',
      'titleHi': 'रिश्ते की जानकारी',
      'subtitle': 'Analyze your connections',
      'subtitleHi': 'अपने रिश्तों का विश्लेषण करें',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'action': 'relationship_insights',
    },
    {
      'title': 'Mood Journal',
      'titleHi': 'मूड डायरी',
      'subtitle': 'Track your daily moods',
      'subtitleHi': 'अपने दैनिक मूड को ट्रैक करें',
      'icon': Icons.book,
      'color': Colors.orange,
      'action': 'mood_journal',
    },
    {
      'title': 'Breathing Exercises',
      'titleHi': 'सांस की एक्सरसाइज',
      'subtitle': 'Daily breathing techniques',
      'subtitleHi': 'दैनिक सांस तकनीकें',
      'icon': Icons.air,
      'color': Colors.teal,
      'action': 'breathing_exercises',
    },
    {
      'title': 'Sleep Tracker',
      'titleHi': 'नींद ट्रैकर',
      'subtitle': 'Sleep quality insights',
      'subtitleHi': 'नींद की गुणवत्ता की जानकारी',
      'icon': Icons.bedtime,
      'color': Colors.indigo,
      'action': 'sleep_tracker',
    },
    {
      'title': 'Event Budget',
      'titleHi': 'इवेंट बजट',
      'subtitle': 'Upcoming festivals & events',
      'subtitleHi': 'आगामी त्योहार और कार्यक्रम',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
      'action': 'event_budget',
    },
    {
      'title': 'Chat with Dr. Iris',
      'titleHi': 'डॉ. आइरिस से चैट',
      'subtitle': 'Your Emotional Therapist',
      'subtitleHi': 'आपका इमोशनल थेरेपिस्ट',
      'icon': Icons.chat,
      'color': Colors.teal,
      'action': 'ai_chat',
    },
    {
      'title': 'Meditation Guide',
      'titleHi': 'ध्यान गाइड',
      'subtitle': 'Guided mindfulness',
      'subtitleHi': 'निर्देशित माइंडफुलनेस',
      'icon': Icons.self_improvement,
      'color': Colors.green,
      'action': 'meditation',
    },
    {
      'title': 'Progress Tracker',
      'titleHi': 'प्रगति ट्रैकर',
      'subtitle': 'See your growth',
      'subtitleHi': 'अपनी वृद्धि देखें',
      'icon': Icons.trending_up,
      'color': Colors.orange,
      'action': 'progress',
    },
    {
      'title': 'Gift Marketplace',
      'titleHi': 'गिफ्ट मार्केटप्लेस',
      'subtitle': 'Offline virtual gifts',
      'subtitleHi': 'ऑफलाइन वर्चुअल उपहार',
      'icon': Icons.card_giftcard,
      'color': Colors.red,
      'action': 'gift_marketplace',
    },
    {
      'title': 'CBT Center',
      'titleHi': 'सीबीटी केंद्र',
      'subtitle': 'Assess • Reframe • Cope',
      'subtitleHi': 'जांच • रिफ्रेम • सामना',
      'icon': Icons.health_and_safety,
      'color': Colors.teal,
      'action': 'cbt_center',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: CoralTheme.background,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildDashboard()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HowTrueCircleWorksPage(),
            ),
          );
        },
        icon: const Icon(Icons.help_outline, color: Colors.white),
        label: Text(
          selectedLanguage == 'English' ? 'How it Works' : 'कैसे काम करता है',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: CoralTheme.dark,
        elevation: 8,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedLanguage == 'English'
                    ? 'Welcome Back'
                    : 'फिर से स्वागत है',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              ValueListenableBuilder<Map<String, String>>(
                valueListenable: AIOrchestratorService().featureInsights,
                builder: (context, insights, _) {
                  final moodLine = insights['mood'];
                  return Text(
                    moodLine == null || moodLine.isEmpty
                        ? (selectedLanguage == 'English'
                            ? 'How are you feeling today?'
                            : 'आज आप कैसा महसूस कर रहे हैं?')
                        : moodLine,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HowTrueCircleWorksPage(),
                    ),
                  );
                },
                tooltip: selectedLanguage == 'English'
                    ? 'How TrueCircle Works'
                    : 'TrueCircle कैसे काम करता है',
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: _showSettingsDialog,
              ),
              IconButton(
                icon: const Icon(Icons.dataset_outlined, color: Colors.white),
                tooltip: selectedLanguage == 'English'
                    ? 'Sample Data Diagnostics'
                    : 'नमूना डेटा रिपोर्ट',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SampleDataDiagnosticsPage(),
                    ),
                  );
                },
              ),
              // Language and Mode switch can be added here if needed
              IconButton(
                icon: Text(
                  selectedLanguage == 'English' ? 'हि' : 'EN',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  setState(() {
                    selectedLanguage =
                        selectedLanguage == 'English' ? 'Hindi' : 'English';
                  });
                  _persistLanguage();
                },
                tooltip: selectedLanguage == 'English'
                    ? 'Switch to Hindi'
                    : 'अंग्रेजी पर स्विच करें',
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        _buildModeToggleSection(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              final feature = _features[index];
              return _buildFeatureCard(feature);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    bool isLocked =
        ['relationship_insights', 'progress'].contains(feature['action']) &&
            !_isFullFunctionalMode;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: isLocked
          ? Colors.white.withValues(alpha: 0.55)
          : Colors.white.withValues(alpha: 0.90),
      child: InkWell(
        onTap: () => _handleFeatureAction(feature['action']),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    feature['icon'],
                    size: 40,
                    color: isLocked ? Colors.grey : feature['color'],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedLanguage == 'English'
                        ? feature['title']
                        : feature['titleHi'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isLocked ? Colors.grey.shade600 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedLanguage == 'English'
                        ? feature['subtitle']
                        : feature['subtitleHi'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLocked ? Colors.grey.shade500 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isLocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggleSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            selectedLanguage == 'English' ? 'Privacy Mode' : 'प्राइवेसी मोड',
            style: TextStyle(
              color: !_isFullFunctionalMode ? Colors.orange : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: _isFullFunctionalMode,
            onChanged: (value) {
              if (value) {
                // Show permission explanation before enabling
                showDialog(
                  context: context,
                  builder: (ctx) => PermissionExplanationDialog(
                    isHindi: selectedLanguage == 'Hindi',
                    onOpenSettings: () {
                      // Placeholder: In real implementation navigate to settings/permission page
                      setState(() {
                        _isFullFunctionalMode = true;
                      });
                      _showModeChangeSnackBar(true);
                    },
                  ),
                );
              } else {
                setState(() {
                  _isFullFunctionalMode = false;
                });
                _showModeChangeSnackBar(false);
              }
            },
            activeThumbColor: Colors.green,
            inactiveThumbColor: Colors.orange,
          ),
          Text(
            selectedLanguage == 'English' ? 'Full Mode' : 'पूर्ण मोड',
            style: TextStyle(
              color: _isFullFunctionalMode ? Colors.green : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showModeChangeSnackBar(bool isFullMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedLanguage == 'English'
              ? (isFullMode
                  ? 'Full Mode - Your data is used.'
                  : 'Sample Data Mode - Using sample data.')
              : (isFullMode
                  ? 'पूर्ण मोड - आपका डेटा उपयोग किया जाता है।'
                  : 'नमूना डेटा मोड - नमूना डेटा का उपयोग।'),
        ),
        backgroundColor: isFullMode ? Colors.green : Colors.orange,
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        _handleBottomNavigation(index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: selectedLanguage == 'English' ? 'Home' : 'होम',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat),
          label: selectedLanguage == 'English' ? 'Chat' : 'चैट',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.analytics),
          label: selectedLanguage == 'English' ? 'Insights' : 'जानकारी',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: selectedLanguage == 'English' ? 'Profile' : 'प्रोफाइल',
        ),
      ],
    );
  }

  void _handleFeatureAction(String action) {
    if ((action == 'relationship_insights' || action == 'progress') &&
        !_isFullFunctionalMode) {
      _showFullModeRequiredDialog();
      return;
    }

    switch (action) {
      case 'emotional_checkin':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const EmotionalCheckInEntryPage()),
        );
        break;
      case 'mood_journal':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MoodJournalPage()),
        );
        break;
      case 'ai_chat':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DrIrisDashboard(isFullMode: _isFullFunctionalMode),
          ),
        );
        break;
      case 'meditation':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeaturePage(
              feature: const {
                'title': 'Meditation Guide',
                'titleHi': 'ध्यान गाइड',
                'subtitle': 'Daily meditation practices',
                'subtitleHi': 'दैनिक ध्यान अभ्यास',
                'description':
                    'Guided mindfulness, breath focus, mantra and calm body scan sessions to improve emotional balance.',
                'descriptionHi':
                    'मार्गदर्शित माइंडफुलनेस, श्वास पर ध्यान, मंत्र और शांत बॉडी स्कैन सत्र भावनात्मक संतुलन के लिए।',
                'demoCount': '30 Sessions',
                'icon': Icons.self_improvement,
                'color': Colors.green,
              },
              isHindi: selectedLanguage == 'Hindi',
            ),
          ),
        );
        break;
      case 'breathing_exercises':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const BreathingExercisesPage()),
        );
        break;
      case 'sleep_tracker':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SleepTrackerPage()),
        );
        break;
      case 'event_budget':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EventBudgetPage()),
        );
        break;
      case 'gift_marketplace':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GiftMarketplacePage()),
        );
        break;
      case 'cbt_center':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CBTCenterPage()),
        );
        break;
      case 'progress':
        // ProgressTrackerPage navigation implemented
        try {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProgressTrackerPage(),
            ),
          );
        } catch (e) {
          _showComingSoon('Progress Tracker (Error: $e)');
        }
        break;
      default:
        _showComingSoon(action);
    }
  }

  void _handleBottomNavigation(int index) {
    if (index == 1) {
      _handleFeatureAction('ai_chat');
    }
    // Add navigation for other items if needed
  }

  void _showFullModeRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(selectedLanguage == 'English'
            ? 'Full Mode Required'
            : 'पूर्ण मोड आवश्यक है'),
        content: Text(selectedLanguage == 'English'
            ? 'This feature is only available in Full Mode. Please switch from Sample Data Mode to continue.'
            : 'यह सुविधा केवल पूर्ण मोड में उपलब्ध है। जारी रखने के लिए कृपया नमूना डेटा मोड से स्विच करें।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(selectedLanguage == 'English' ? 'Cancel' : 'रद्द करें'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isFullFunctionalMode = true;
              });
              _showModeChangeSnackBar(true);
            },
            child: Text(selectedLanguage == 'English'
                ? 'Switch to Full Mode'
                : 'पूर्ण मोड पर स्विच करें'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '''$feature (coming soon)''',
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(selectedLanguage == 'English' ? 'Settings' : 'सेटिंग्स'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(selectedLanguage == 'English' ? 'Language' : 'भाषा'),
              trailing: DropdownButton<String>(
                value: selectedLanguage,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLanguage = newValue;
                      Navigator.pop(context);
                    });
                    _persistLanguage();
                  }
                },
                items: <String>['English', 'Hindi']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            // Other settings can be added here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(selectedLanguage == 'English' ? 'Close' : 'बंद करें'),
          ),
        ],
      ),
    );
  }
}

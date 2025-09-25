import 'package:flutter/material.dart';
import 'pages/dr_iris_dashboard.dart';
import 'services/demo_data_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String selectedLanguage = 'English';
  bool _isFullFunctionalMode = true; // Full mode enabled by default for testing

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
      'subtitle': 'Write your thoughts',
      'subtitleHi': 'अपने विचार लिखें',
      'icon': Icons.book,
      'color': Colors.indigo,
      'action': 'mood_journal',
    },
    {
      'title': 'Chat with Dr. Iris',
      'titleHi': 'डॉ. आइरिस से चैट',
      'subtitle': 'Talk to Dr. Iris',
      'subtitleHi': 'डॉ. आइरिस से बात करें',
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.withValues(alpha: 0.7),
                Colors.blue.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header with Dr. Iris info and settings
                _buildHeader(),

                // Main Dashboard content
                Expanded(
                  child: _buildDashboard(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // TrueCircle Logo
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/truecircle_logo.png', // Using proper TrueCircle logo
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'TC',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Welcome text
          Expanded(
            child: Container(
              padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width < 600 ? 6 : 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      selectedLanguage == 'English'
                          ? 'Welcome back!'
                          : 'वापसी पर स्वागत है!',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 400
                            ? 11
                            : MediaQuery.of(context).size.width < 600
                                ? 13
                                : 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Flexible(
                    flex: 2,
                    child: Text(
                      selectedLanguage == 'English'
                          ? 'Bringing clarity to your emotional journey'
                          : 'आपकी भावनात्मक यात्रा में स्पष्टता लाना',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 360
                            ? 12
                            : MediaQuery.of(context).size.width < 480
                                ? 14
                                : MediaQuery.of(context).size.width < 600
                                    ? 15
                                    : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: 0.3,
                      ),
                      maxLines: MediaQuery.of(context).size.width < 360
                          ? 3
                          : MediaQuery.of(context).size.width < 480
                              ? 2
                              : 2,
                      overflow: TextOverflow.visible,
                      softWrap: true,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Settings, Mode Switch, and Language buttons
          Row(
            children: [
              // Demo/Full Mode Toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isFullFunctionalMode = !_isFullFunctionalMode;
                  });
                  _showModeChangeDialog();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isFullFunctionalMode
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _isFullFunctionalMode ? Colors.green : Colors.orange,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFullFunctionalMode
                            ? Icons.rocket_launch
                            : Icons.play_circle_outline,
                        color: _isFullFunctionalMode
                            ? Colors.green
                            : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isFullFunctionalMode
                            ? (selectedLanguage == 'English' ? 'Full' : 'पूर्ण')
                            : (selectedLanguage == 'English' ? 'Demo' : 'डेमो'),
                        style: TextStyle(
                          color: _isFullFunctionalMode
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Language selector with dropdown
              GestureDetector(
                onTap: () => _showLanguageSelector(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Select Language',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            selectedLanguage == 'English' ? 'English' : 'हिंदी',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Settings button
              GestureDetector(
                onTap: () => _showSettingsDialog(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.settings, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        // Mode Toggle Section
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.purple[50]!],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedLanguage == 'English' ? 'App Mode' : 'ऐप मोड',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedLanguage == 'English'
                          ? (_isFullFunctionalMode
                              ? 'Full Mode: Using your personal data'
                              : 'Demo Mode: Exploring with sample data')
                          : (_isFullFunctionalMode
                              ? 'पूर्ण मोड: आपका व्यक्तिगत डेटा उपयोग'
                              : 'डेमो मोड: सैंपल डेटा के साथ अन्वेषण'),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    selectedLanguage == 'English' ? 'Demo' : 'डेमो',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          !_isFullFunctionalMode ? Colors.orange : Colors.grey,
                    ),
                  ),
                  Switch(
                    value: _isFullFunctionalMode,
                    activeThumbColor: Colors.green,
                    inactiveThumbColor: Colors.orange,
                    onChanged: (value) {
                      setState(() {
                        _isFullFunctionalMode = value;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            selectedLanguage == 'English'
                                ? (value
                                    ? 'Switched to Full Mode - Using your data'
                                    : 'Switched to Demo Mode - Sample data')
                                : (value
                                    ? 'पूर्ण मोड में बदल गया - आपका डेटा उपयोग'
                                    : 'डेमो मोड में बदल गया - सैंपल डेटा'),
                          ),
                          backgroundColor: value ? Colors.green : Colors.orange,
                        ),
                      );
                    },
                  ),
                  Text(
                    selectedLanguage == 'English' ? 'Full' : 'पूर्ण',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isFullFunctionalMode ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Features Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio:
                    MediaQuery.of(context).size.width > 600 ? 1.1 : 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _features.length,
              itemBuilder: (context, index) {
                final feature = _features[index];
                return _buildFeatureCard(feature);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return GestureDetector(
      onTap: () => _handleFeatureAction(feature['action']),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mode indicator badge
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: _isFullFunctionalMode
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isFullFunctionalMode
                            ? Colors.green
                            : Colors.orange,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      _isFullFunctionalMode
                          ? (selectedLanguage == 'English' ? 'FULL' : 'पूर्ण')
                          : (selectedLanguage == 'English' ? 'DEMO' : 'डेमो'),
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                        color: _isFullFunctionalMode
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),

              // Feature icon with color - Centered content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: feature['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feature['icon'],
                        size: 28,
                        color: feature['color'],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Feature title
                    Text(
                      selectedLanguage == 'English'
                          ? feature['title']
                          : feature['titleHi'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Feature subtitle
                    Text(
                      selectedLanguage == 'English'
                          ? feature['subtitle']
                          : feature['subtitleHi'],
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _handleBottomNavigation(index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: selectedLanguage == 'English' ? 'Home' : 'होम',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.psychology),
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
      ),
    );
  }

  void _handleFeatureAction(String action) async {
    switch (action) {
      case 'emotional_checkin':
        _showEmotionalCheckIn();
        break;
      case 'relationship_insights':
        _showRelationshipInsights();
        break;
      case 'mood_journal':
        _showMoodJournal();
        break;
      case 'ai_chat':
        // Only this goes to Dr. Iris Dashboard
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DrIrisDashboard(isFullMode: _isFullFunctionalMode),
            ),
          );
        }
        break;
      case 'meditation':
        _showMeditationGuide();
        break;
      case 'breathing':
        _showBreathingExercises();
        break;
      case 'progress':
        _showProgressTracker();
        break;
      case 'sleep_tracker':
        _showSleepTracker();
        break;
      case 'gratitude_journal':
        _showGratitudeJournal();
        break;
      case 'stress_analysis':
        _showStressAnalysis();
        break;
      default:
        _showComingSoon(action);
    }
  }

  void _handleBottomNavigation(int index) async {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        // Chat with Dr. Iris - Navigate to Dr. Iris Dashboard
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DrIrisDashboard(isFullMode: _isFullFunctionalMode),
            ),
          );
        }
        break;
      case 2:
        // Insights - Show insights dialog
        _showRelationshipInsights();
        break;
      case 3:
        // Settings - Show settings
        _showSettingsDialog();
        break;
    }
  }

  void _showModeChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _isFullFunctionalMode
                  ? Icons.rocket_launch
                  : Icons.play_circle_outline,
              color: _isFullFunctionalMode ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              selectedLanguage == 'English' ? 'Mode Changed!' : 'मोड बदला गया!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_isFullFunctionalMode ? Colors.green : Colors.orange)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isFullFunctionalMode ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isFullFunctionalMode ? Icons.check_circle : Icons.info,
                    color: _isFullFunctionalMode ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isFullFunctionalMode
                          ? (selectedLanguage == 'English'
                              ? 'Full Functional Mode Active'
                              : 'पूर्ण कार्यात्मक मोड सक्रिय')
                          : (selectedLanguage == 'English'
                              ? 'Demo Mode Active'
                              : 'डेमो मोड सक्रिय'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isFullFunctionalMode
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isFullFunctionalMode
                  ? (selectedLanguage == 'English'
                      ? '✨ All features are now fully functional!\n\n• Real AI processing\n• Complete data analysis\n• Advanced insights\n• Full privacy controls'
                      : '✨ सभी सुविधाएं अब पूरी तरह कार्यात्मक हैं!\n\n• वास्तविक एआई प्रसंस्करण\n• पूर्ण डेटा विश्लेषण\n• उन्नत अंतर्दृष्टि\n• पूर्ण गोपनीयता नियंत्रण')
                  : (selectedLanguage == 'English'
                      ? '🎯 Demo Mode provides a preview experience.\n\n• Sample data and responses\n• Limited functionality\n• Perfect for exploring features\n• Switch to Full Mode anytime!'
                      : '🎯 डेमो मोड एक पूर्वावलोकन अनुभव प्रदान करता है।\n\n• नमूना डेटा और प्रतिक्रियाएं\n• सीमित कार्यक्षमता\n• सुविधाओं का पता लगाने के लिए बिल्कुल सही\n• कभी भी पूर्ण मोड पर स्विच करें!'),
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              selectedLanguage == 'English' ? 'Got it!' : 'समझ गया!',
              style: TextStyle(
                color: _isFullFunctionalMode ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.language, color: Colors.blue, size: 28),
            SizedBox(width: 12),
            Text(
              'Select Language / भाषा चुनें',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              subtitle: const Text('English Language'),
              trailing: selectedLanguage == 'English'
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  selectedLanguage = 'English';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language changed to English'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
              title: const Text('हिंदी'),
              subtitle: const Text('Hindi Language'),
              trailing: selectedLanguage == 'हिंदी'
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  selectedLanguage = 'हिंदी';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('भाषा हिंदी में बदली गई'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(selectedLanguage == 'English' ? 'Cancel' : 'रद्द करें'),
          ),
        ],
      ),
    );
  }

  // Feature-specific methods
  void _showEmotionalCheckIn() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Emotional Check-in'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: DemoDataService.instance.getFormattedEmotionalInsights(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Text(_isFullFunctionalMode
                  ? 'Start tracking your emotions daily to see insights here.'
                  : 'Demo: Here you would see your recent emotional patterns and insights.');
            }

            final recentEntries = snapshot.data!.take(15).toList();
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isFullFunctionalMode
                        ? 'Your Recent Emotional Patterns:'
                        : 'Demo: Recent Emotional Patterns (Last 15 days):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...recentEntries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry['date'] ?? 'Unknown date',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getIntensityColor(
                                          entry['intensity'] ?? 5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Intensity: ${entry['intensity'] ?? 5}/10',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  'Emotion: ${entry['emotion']['en'] ?? 'Unknown'}'),
                              Text(
                                  'Trigger: ${entry['trigger']['en'] ?? 'Unknown'}'),
                              if (entry['notes']['en'] != null &&
                                  entry['notes']['en'].isNotEmpty)
                                Text(
                                  'Notes: ${entry['notes']['en']}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                  _buildModeToggleSection('Emotional Check-in'),
                ],
              ),
            );
          },
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

  void _showRelationshipInsights() {
    _showFeatureDialog('Relationship Insights',
        'Analyze your relationships and get personalized advice.\n\n${_isFullFunctionalMode ? "Full relationship analysis!" : "Demo: Sample relationship tips"}');
  }

  void _showMoodJournal() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mood Journal'),
        content: FutureBuilder<List<dynamic>>(
          future: DemoDataService.getMoodJournalJsonData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Text(_isFullFunctionalMode
                  ? 'Start writing in your mood journal to see entries here.'
                  : 'Demo: Here you would see your recent mood journal entries.');
            }

            final recentEntries =
                snapshot.data!.take(12).cast<Map<String, dynamic>>().toList();
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isFullFunctionalMode
                        ? 'Your Recent Journal Entries:'
                        : 'Demo: Recent Journal Entries (Last 12 days):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...recentEntries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.indigo[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry['date'] ?? 'Unknown date',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getMoodColor(
                                          entry['mood_rating'] ?? 5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${entry['mood_rating'] ?? 5}/10',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                entry['title'] ?? 'No title',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry['detailed_entry'] ?? 'No content',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (entry['tags'] != null &&
                                  entry['tags'].isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 4,
                                  children: (entry['tags'] as List<dynamic>)
                                      .map(
                                        (tag) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo[200],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            tag.toString(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                  _buildModeToggleSection('Mood Journal'),
                ],
              ),
            );
          },
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

  void _showMeditationGuide() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.self_improvement, color: Colors.purple, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedLanguage == 'English' ? 'Meditation Guide' : 'ध्यान गाइड',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode indicator
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _isFullFunctionalMode ? Colors.green[50] : Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isFullFunctionalMode ? Colors.green : Colors.purple,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isFullFunctionalMode ? Icons.all_inclusive : Icons.play_circle,
                      color: _isFullFunctionalMode ? Colors.green : Colors.purple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isFullFunctionalMode 
                          ? (selectedLanguage == 'English' ? 'Full Library Access' : 'पूर्ण पुस्तकालय पहुंच')
                          : (selectedLanguage == 'English' ? 'Demo Sessions Available' : 'डेमो सत्र उपलब्ध'),
                        style: TextStyle(
                          color: _isFullFunctionalMode ? Colors.green[700] : Colors.purple[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Description
              Text(
                selectedLanguage == 'English'
                  ? 'Guided meditation sessions for relaxation, mindfulness, and emotional well-being.'
                  : 'आराम, माइंडफुलनेस और भावनात्मक कल्याण के लिए निर्देशित ध्यान सत्र।',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Available Sessions
              Text(
                selectedLanguage == 'English' ? 'Available Sessions:' : 'उपलब्ध सत्र:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Meditation sessions list
              _buildMeditationSession(
                'Mindful Breathing', 'माइंडफुल सांस लेना',
                '5 min', Icons.air, Colors.blue,
                description: selectedLanguage == 'English' 
                  ? 'Focus on your breath for inner calm'
                  : 'आंतरिक शांति के लिए अपनी सांस पर ध्यान दें'
              ),
              const SizedBox(height: 8),
              _buildMeditationSession(
                'Body Scan Relaxation', 'शरीर स्कैन विश्राम',
                '10 min', Icons.accessibility_new, Colors.green,
                description: selectedLanguage == 'English' 
                  ? 'Progressive muscle relaxation technique'
                  : 'प्रगतिशील मांसपेशी विश्राम तकनीक'
              ),
              const SizedBox(height: 8),
              _buildMeditationSession(
                'Loving Kindness', 'प्रेम कृपा',
                '8 min', Icons.favorite, Colors.pink,
                description: selectedLanguage == 'English' 
                  ? 'Cultivate compassion and self-love'
                  : 'करुणा और स्व-प्रेम विकसित करें'
              ),
              
              if (_isFullFunctionalMode) ...[
                const SizedBox(height: 8),
                _buildMeditationSession(
                  'Sleep Stories', 'नींद की कहानियां',
                  '20-30 min', Icons.bedtime, Colors.indigo,
                  description: selectedLanguage == 'English' 
                    ? 'Gentle stories to help you fall asleep'
                    : 'आपको सोने में मदद करने वाली कोमल कहानियां',
                  isLocked: false
                ),
                const SizedBox(height: 8),
                _buildMeditationSession(
                  'Advanced Mindfulness', 'उन्नत माइंडफुलनेस',
                  '15-45 min', Icons.psychology, Colors.orange,
                  description: selectedLanguage == 'English' 
                    ? 'Deep meditation for experienced practitioners'
                    : 'अनुभवी अभ्यासकर्ताओं के लिए गहरा ध्यान',
                  isLocked: false
                ),
              ] else ...[
                const SizedBox(height: 8),
                _buildMeditationSession(
                  'Premium Sessions', 'प्रीमियम सत्र',
                  '15+ min', Icons.lock, Colors.amber,
                  description: selectedLanguage == 'English' 
                    ? 'Unlock advanced meditation sessions'
                    : 'उन्नत ध्यान सत्र अनलॉक करें',
                  isLocked: true
                ),
              ],

              const SizedBox(height: 16),

              // Progress indicator for demo mode
              if (!_isFullFunctionalMode) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timeline, color: Colors.purple, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            selectedLanguage == 'English' ? 'Your Progress' : 'आपकी प्रगति',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedLanguage == 'English' 
                          ? '🧘 Sessions completed: 7\n✨ Streak: 3 days\n⏱️ Total time: 45 minutes'
                          : '🧘 पूर्ण सत्र: 7\n✨ लगातार: 3 दिन\n⏱️ कुल समय: 45 मिनट',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!_isFullFunctionalMode) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _startMeditationDemo();
              },
              icon: const Icon(Icons.play_arrow, color: Colors.purple),
              label: Text(
                selectedLanguage == 'English' ? 'Try Demo Session' : 'डेमो सत्र करें',
                style: const TextStyle(color: Colors.purple),
              ),
            ),
          ],
          if (_isFullFunctionalMode) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _startMeditationSession('Mindful Breathing');
              },
              icon: const Icon(Icons.self_improvement, color: Colors.purple),
              label: Text(
                selectedLanguage == 'English' ? 'Start Session' : 'सत्र शुरू करें',
                style: const TextStyle(color: Colors.purple),
              ),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(selectedLanguage == 'English' ? 'Close' : 'बंद करें'),
          ),
        ],
      ),
    );
  }

  void _showBreathingExercises() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.air, color: Colors.teal, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedLanguage == 'English' ? 'Breathing Exercises' : 'सांस की व्यायाम',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mode indicator
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _isFullFunctionalMode ? Colors.green[50] : Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isFullFunctionalMode ? Colors.green : Colors.teal,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isFullFunctionalMode ? Icons.all_inclusive : Icons.play_circle,
                      color: _isFullFunctionalMode ? Colors.green : Colors.teal,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isFullFunctionalMode 
                          ? (selectedLanguage == 'English' ? 'All Techniques Available' : 'सभी तकनीकें उपलब्ध')
                          : (selectedLanguage == 'English' ? 'Demo Techniques Available' : 'डेमो तकनीकें उपलब्ध'),
                        style: TextStyle(
                          color: _isFullFunctionalMode ? Colors.green[700] : Colors.teal[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                selectedLanguage == 'English'
                  ? 'Practice proven breathing techniques for stress relief, better sleep, and mental clarity.'
                  : 'तनाव मुक्ति, बेहतर नींद और मानसिक स्पष्टता के लिए सिद्ध श्वास तकनीकों का अभ्यास करें।',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              Text(
                selectedLanguage == 'English' ? 'Available Techniques:' : 'उपलब्ध तकनीकें:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Breathing techniques
              _buildBreathingTechnique(
                '4-7-8 Technique', '4-7-8 तकनीक',
                'Inhale 4s • Hold 7s • Exhale 8s', Colors.blue,
                description: selectedLanguage == 'English' 
                  ? 'Perfect for falling asleep quickly'
                  : 'जल्दी सो जाने के लिए बिल्कुल सही'
              ),
              const SizedBox(height: 8),
              _buildBreathingTechnique(
                'Box Breathing', 'बॉक्स ब्रीदिंग',
                'Inhale 4s • Hold 4s • Exhale 4s • Hold 4s', Colors.green,
                description: selectedLanguage == 'English' 
                  ? 'Reduces anxiety and improves focus'
                  : 'चिंता कम करता है और फोकस सुधारता है'
              ),
              const SizedBox(height: 8),
              _buildBreathingTechnique(
                'Deep Belly Breathing', 'गहरी पेट की सांस',
                'Slow, deep breaths from diaphragm', Colors.orange,
                description: selectedLanguage == 'English' 
                  ? 'Activates relaxation response'
                  : 'आराम प्रतिक्रिया को सक्रिय करता है'
              ),

              if (_isFullFunctionalMode) ...[
                const SizedBox(height: 8),
                _buildBreathingTechnique(
                  'Alternate Nostril', 'नाड़ी शोधन',
                  'Traditional yoga breathing technique', Colors.purple,
                  description: selectedLanguage == 'English' 
                    ? 'Balances nervous system'
                    : 'तंत्रिका तंत्र को संतुलित करता है',
                  isLocked: false
                ),
              ] else ...[
                const SizedBox(height: 8),
                _buildBreathingTechnique(
                  'Advanced Techniques', 'उन्नत तकनीकें',
                  'Unlock 5+ more breathing techniques', Colors.amber,
                  description: selectedLanguage == 'English' 
                    ? 'Premium breathing exercises'
                    : 'प्रीमियम श्वास व्यायाम',
                  isLocked: true
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!_isFullFunctionalMode) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _startBreathingDemo();
              },
              icon: const Icon(Icons.play_arrow, color: Colors.teal),
              label: Text(
                selectedLanguage == 'English' ? 'Try 4-7-8 Demo' : '4-7-8 डेमो करें',
                style: const TextStyle(color: Colors.teal),
              ),
            ),
          ],
          if (_isFullFunctionalMode) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _startBreathingSession('4-7-8 Technique');
              },
              icon: const Icon(Icons.air, color: Colors.teal),
              label: Text(
                selectedLanguage == 'English' ? 'Start Session' : 'सत्र शुरू करें',
                style: const TextStyle(color: Colors.teal),
              ),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(selectedLanguage == 'English' ? 'Close' : 'बंद करें'),
          ),
        ],
      ),
    );
  }

  void _showSleepTracker() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Tracker'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: DemoDataService.getSleepTrackerJsonData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Text(_isFullFunctionalMode
                  ? 'Start tracking your sleep to see patterns here.'
                  : 'Demo: Here you would see your sleep tracking data.');
            }

            final sleepData =
                snapshot.data!['sleepTracking'] as List<dynamic>? ?? [];
            final recentSleep =
                sleepData.take(14).cast<Map<String, dynamic>>().toList();

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isFullFunctionalMode
                        ? 'Your Recent Sleep Pattern:'
                        : 'Demo: Recent Sleep Pattern (Last 14 days):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...recentSleep.map((sleep) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Day ${sleep['day'] ?? '?'}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getSleepQualityColor(
                                          sleep['quality'] ?? 5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Quality: ${sleep['quality'] ?? 5}/10',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Bedtime: ${sleep['bedtime'] ?? 'Unknown'}'),
                              Text(
                                  'Wake time: ${sleep['wakeTime'] ?? 'Unknown'}'),
                              Text(
                                  'Duration: ${sleep['duration'] ?? 'Unknown'}'),
                              Text(
                                  'Interruptions: ${sleep['interruptions'] ?? 0}'),
                              if (sleep['notes'] != null &&
                                  sleep['notes']['en'] != null)
                                Text(
                                  'Notes: ${sleep['notes']['en']}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),
                  _buildModeToggleSection('Sleep Tracker'),
                ],
              ),
            );
          },
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

  void _showGratitudeJournal() {
    _showFeatureDialog('Gratitude Journal',
        'Practice gratitude by recording positive moments daily.\n\n${_isFullFunctionalMode ? "Save gratitude entries!" : "Demo: Sample gratitude practice"}');
  }

  void _showStressAnalysis() {
    _showFeatureDialog('Stress Analysis',
        'Analyze stress patterns and get coping strategies.\n\n${_isFullFunctionalMode ? "Personalized stress insights!" : "Demo: Sample stress management tips"}');
  }

  void _showProgressTracker() {
    _showFeatureDialog('Progress Tracker',
        'Track your emotional wellness journey over time.\n\n${_isFullFunctionalMode ? "Your personal progress analytics!" : "Demo: Sample progress charts and insights"}');
  }

  void _showComingSoon(String feature) {
    _showFeatureDialog('Coming Soon',
        'This feature is under development and will be available soon!\n\nFeature: $feature');
  }

  // Helper method to get color based on emotion intensity
  Color _getIntensityColor(int intensity) {
    if (intensity <= 3) return Colors.red;
    if (intensity <= 5) return Colors.orange;
    if (intensity <= 7) return Colors.yellow;
    return Colors.green;
  }

  // Helper method to get color based on mood rating
  Color _getMoodColor(int moodRating) {
    if (moodRating <= 3) return Colors.red;
    if (moodRating <= 5) return Colors.orange;
    if (moodRating <= 7) return Colors.blue;
    return Colors.green;
  }

  // Helper method to get color based on sleep quality
  Color _getSleepQualityColor(int quality) {
    if (quality <= 3) return Colors.red;
    if (quality <= 5) return Colors.orange;
    if (quality <= 7) return Colors.blue;
    return Colors.green;
  }

  // Helper method to build mode toggle section
  Widget _buildModeToggleSection(String featureName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isFullFunctionalMode ? Colors.green[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isFullFunctionalMode ? Colors.green : Colors.blue,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isFullFunctionalMode ? Icons.check_circle : Icons.info,
            color: _isFullFunctionalMode ? Colors.green : Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _isFullFunctionalMode ? 'Full Mode Active' : 'Demo Mode Active',
              style: TextStyle(
                color: _isFullFunctionalMode
                    ? Colors.green[700]
                    : Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isFullFunctionalMode = !_isFullFunctionalMode;
              });
              Navigator.pop(context);
              // Re-open the feature with new mode
              if (featureName == 'Emotional Check-in') _showEmotionalCheckIn();
              if (featureName == 'Mood Journal') _showMoodJournal();
              if (featureName == 'Sleep Tracker') _showSleepTracker();
            },
            child: Text(
                _isFullFunctionalMode ? 'Switch to Demo' : 'Switch to Full'),
          ),
        ],
      ),
    );
  }

  void _showFeatureDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isFullFunctionalMode
                      ? Colors.green[50]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isFullFunctionalMode ? Colors.green : Colors.blue,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isFullFunctionalMode ? Icons.check_circle : Icons.info,
                      color: _isFullFunctionalMode ? Colors.green : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isFullFunctionalMode
                            ? 'Full Mode Active'
                            : 'Demo Mode Active',
                        style: TextStyle(
                          color: _isFullFunctionalMode
                              ? Colors.green[700]
                              : Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isFullFunctionalMode = !_isFullFunctionalMode;
                        });
                        Navigator.pop(context);
                        _showFeatureDialog(title, content); // Refresh dialog
                      },
                      child: Text(_isFullFunctionalMode
                          ? 'Switch to Demo'
                          : 'Switch to Full'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!_isFullFunctionalMode) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Show demo data for this feature
                _showDemoDataForFeature(title);
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(
                  selectedLanguage == 'English' ? 'Try Demo' : 'डेमो करें'),
            ),
          ],
          if (_isFullFunctionalMode) ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to full feature
                _navigateToFullFeature(title);
              },
              icon: const Icon(Icons.rocket_launch),
              label: Text(
                  selectedLanguage == 'English' ? 'Continue' : 'जारी रखें'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(selectedLanguage == 'English' ? 'Close' : 'बंद करें'),
          ),
        ],
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
              leading: const Icon(Icons.language),
              title: Text(selectedLanguage == 'English' ? 'Language' : 'भाषा'),
              subtitle: Text(selectedLanguage),
              onTap: () {
                setState(() {
                  selectedLanguage =
                      selectedLanguage == 'English' ? 'हिंदी' : 'English';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                _isFullFunctionalMode ? Icons.star : Icons.star_border,
                color: _isFullFunctionalMode ? Colors.amber : Colors.grey,
              ),
              title: Text(
                selectedLanguage == 'English'
                    ? (_isFullFunctionalMode ? 'Full Mode' : 'Demo Mode')
                    : (_isFullFunctionalMode ? 'पूर्ण मोड' : 'डेमो मोड'),
              ),
              subtitle: Text(
                selectedLanguage == 'English'
                    ? (_isFullFunctionalMode
                        ? 'All features unlocked'
                        : 'Limited features for testing')
                    : (_isFullFunctionalMode
                        ? 'सभी फीचर्स उपलब्ध'
                        : 'परीक्षण के लिए सीमित फीचर्स'),
              ),
              onTap: () {
                setState(() {
                  _isFullFunctionalMode = !_isFullFunctionalMode;
                });
                Navigator.pop(context);
                _showModeChangeDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(selectedLanguage == 'English'
                  ? 'About App'
                  : 'ऐप के बारे में'),
              subtitle: Text(selectedLanguage == 'English'
                  ? 'Dr. Iris - AI Powered'
                  : 'डॉ. आइरिस - एआई संचालित'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(selectedLanguage == 'English'
            ? 'Meet Dr. Iris: Embodying Our Mission'
            : 'डॉ. आइरिस से मिलें: हमारे मिशन का प्रतीक'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedLanguage == 'English'
                    ? '🌈 In a world filled with digital noise, finding clarity for your mental health can feel impossible. At TrueCircle, we believe true well-being begins with understanding—introducing Dr. Iris.'
                    : '🌈 डिजिटल शोर से भरी दुनिया में मानसिक स्वास्थ्य की स्पष्टता पाना असंभव लग सकता है। TrueCircle में हम मानते हैं कि सच्चा कल्याण समझ से शुरू होता है—डॉ. आइरिस से मिलें।',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Dr. Iris Explanation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedLanguage == 'English'
                          ? '👁️ 1. The Iris of the Eye: Perfect Clarity'
                          : '👁️ 1. आंख की पुतली: पूर्ण स्पष्टता',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedLanguage == 'English'
                          ? '👁️ Iris was the Greek goddess of the rainbow and divine messenger\n🔬 In science, the iris is the colored part of the eye that controls light entry\n� Dr. Iris combines both: like the goddess, she bridges different worlds (emotions & logic), and like the eye\'s iris, she sees deep into your emotional patterns\n🧠 Our AI therapist can perceive the depth of your feelings just as the iris controls what the eye sees'
                          : '👁️ आइरिस ग्रीक में इंद्रधनुष की देवी और दिव्य संदेशवाहक थी\n🔬 विज्ञान में, आइरिस आंख का रंगीन हिस्सा है जो प्रकाश को नियंत्रित करता है\n💡 डॉ. आइरिस दोनों को जोड़ती है: देवी की तरह, वह विभिन्न दुनियाओं (भावनाएं और तर्क) को जोड़ती है, और आंख के आइरिस की तरह, वह आपके भावनात्मक पैटर्न में गहराई से देखती है\n🧠 हमारी एआई चिकित्सक आपकी भावनाओं की गहराई को समझ सकती है जैसे आइरिस यह नियंत्रित करता है कि आंख क्या देखती है',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedLanguage == 'English'
                          ? 'Key Features:'
                          : 'मुख्य विशेषताएं:',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedLanguage == 'English'
                          ? '� Emotional Intelligence Analysis\n💝 Relationship Health Insights\n🧘 Meditation & Mindfulness\n� Cultural AI (Indian festivals, family dynamics)\n💬 AI Therapy Chat with Dr. Iris\n📈 Progress & Mood Tracking\n🌍 Bilingual Support (Hindi/English)\n🔒 Complete Privacy Protection'
                          : '� भावनात्मक बुद्धिमत्ता विश्लेषण\n💝 रिश्ते की सेहत की जानकारी\n🧘 ध्यान और माइंडफुलनेस\n📊 सांस्कृतिक एआई (भारतीय त्योहार, पारिवारिक गतिशीलता)\n💬 डॉ. आइरिस के साथ एआई थेरेपी चैट\n📈 प्रगति और मूड ट्रैकिंग\n🌍 द्विभाषी समर्थन (हिंदी/अंग्रेजी)\n🔒 पूर्ण गोपनीयता सुरक्षा',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedLanguage == 'English'
                          ? 'Privacy Promise:'
                          : 'गोपनीयता का वादा:',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedLanguage == 'English'
                          ? '🛡️ Your data never leaves your device\n🚫 No cloud storage or servers\n🔒 Complete offline functionality\n👁️ We cannot see or access your data\n🎯 You have full control over your privacy'
                          : '🛡️ आपका डेटा कभी आपके डिवाइस से नहीं निकलता\n🚫 कोई क्लाउड स्टोरेज या सर्वर नहीं\n🔒 पूरी तरह ऑफलाइन कार्यक्षमता\n👁️ हम आपका डेटा नहीं देख या एक्सेस नहीं कर सकते\n🎯 आपका अपनी गोपनीयता पर पूरा नियंत्रण है',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Text(
                selectedLanguage == 'English'
                    ? '💝 Dr. Iris is your partner for the journey—bringing clarity like the eye\'s iris, hope like the Greek goddess, and wisdom like the flower. Together, we navigate life\'s challenges with understanding and compassion.'
                    : '💝 डॉ. आइरिस आपकी यात्रा की साथी है—आंख की पुतली जैसी स्पष्टता, ग्रीक देवी जैसी आशा, और फूल जैसी बुद्धि लेकर। साथ मिलकर हम जीवन की चुनौतियों का सामना समझ और करुणा के साथ करते हैं।',
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

  void _showDemoDataForFeature(String featureTitle) {
    // Navigate to demo data view for the specific feature
    switch (featureTitle.toLowerCase()) {
      case 'emotional check-in':
      case 'भावनात्मक जांच':
        _handleFeatureAction('emotional_checkin');
        break;
      case 'mood journal':
      case 'मूड जर्नल':
        _handleFeatureAction('mood_journal');
        break;
      case 'sleep tracker':
      case 'स्लीप ट्रैकर':
        _handleFeatureAction('sleep_tracker');
        break;
      case 'chat with dr. iris':
      case 'डॉ. आइरिस से चैट':
        _handleFeatureAction('ai_chat');
        break;
      case 'relationship insights':
      case 'रिश्ते की जानकारी':
        _handleFeatureAction('relationship_insights');
        break;
      case 'meditation guide':
      case 'ध्यान गाइड':
        _handleFeatureAction('meditation');
        break;
      case 'breathing exercises':
      case 'सांस की व्यायाम':
        _handleFeatureAction('breathing');
        break;
      case 'progress tracker':
      case 'प्रगति ट्रैकर':
        _handleFeatureAction('progress');
        break;
      default:
        // For other features, show a coming soon message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(selectedLanguage == 'English'
                ? 'Demo data for $featureTitle coming soon!'
                : '$featureTitle के लिए डेमो डेटा जल्द आ रहा है!'),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  void _navigateToFullFeature(String featureTitle) {
    // Show privacy and permission guide for full mode
    _showPrivacyAndPermissionGuide(featureTitle);
  }

  void _showPrivacyAndPermissionGuide(String featureTitle) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedLanguage == 'English'
                    ? 'Privacy & Permissions Guide'
                    : 'गोपनीयता और अनुमति गाइड',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Feature Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedLanguage == 'English'
                          ? 'Full Feature: $featureTitle'
                          : 'पूर्ण सुविधा: $featureTitle',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedLanguage == 'English'
                          ? 'To access the full functionality, you need to grant certain permissions manually.'
                          : 'पूर्ण कार्यक्षमता तक पहुंचने के लिए, आपको मैन्युअल रूप से कुछ अनुमतियां देनी होंगी।',
                      style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Privacy Assurance
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user,
                            color: Colors.green[700], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          selectedLanguage == 'English'
                              ? 'Privacy Guarantee'
                              : 'गोपनीयता की गारंटी',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                              fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedLanguage == 'English'
                          ? '✅ All data stays on YOUR device only\n✅ NO cloud storage or internet connection\n✅ We CANNOT see or access your data\n✅ Complete offline functionality\n✅ You have full control over your privacy'
                          : '✅ सभी डेटा केवल आपके डिवाइस पर रहता है\n✅ कोई क्लाउड स्टोरेज या इंटरनेट कनेक्शन नहीं\n✅ हम आपका डेटा नहीं देख या एक्सेस नहीं कर सकते\n✅ पूरी तरह ऑफलाइन कार्यक्षमता\n✅ आपका अपनी गोपनीयता पर पूरा नियंत्रण है',
                      style: TextStyle(color: Colors.green[700], fontSize: 11),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Permission Guide
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings,
                            color: Colors.orange[700], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          selectedLanguage == 'English'
                              ? 'How to Enable Permissions'
                              : 'अनुमतियां कैसे सक्षम करें',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                              fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedLanguage == 'English'
                          ? '1. Go to your phone Settings\n2. Find Apps or Application Manager\n3. Search for "TrueCircle"\n4. Tap on Permissions\n5. Enable required permissions:\n   • Contacts (for relationship analysis)\n   • Phone (for communication patterns)\n   • SMS (for message sentiment analysis)\n\n⚠️ You grant permissions at your own responsibility'
                          : '1. अपने फोन की सेटिंग्स में जाएं\n2. ऐप्स या एप्लिकेशन मैनेजर खोजें\n3. "TrueCircle" खोजें\n4. अनुमतियों पर टैप करें\n5. आवश्यक अनुमतियां सक्षम करें:\n   • संपर्क (रिश्ते के विश्लेषण के लिए)\n   • फोन (संचार पैटर्न के लिए)\n   • SMS (संदेश भावना विश्लेषण के लिए)\n\n⚠️ आप अपनी जिम्मेदारी पर अनुमतियां दे रहे हैं',
                      style: TextStyle(color: Colors.orange[700], fontSize: 11),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // User Responsibility
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[700], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          selectedLanguage == 'English'
                              ? 'User Responsibility'
                              : 'उपयोगकर्ता की जिम्मेदारी',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                              fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      selectedLanguage == 'English'
                          ? '• You are responsible for granting permissions\n• Enable only what you feel comfortable with\n• You can revoke permissions anytime\n• App will work with limited functionality if permissions are denied'
                          : '• आप अनुमतियां देने के लिए जिम्मेदार हैं\n• केवल वही सक्षम करें जिससे आप सहज हों\n• आप कभी भी अनुमतियां रद्द कर सकते हैं\n• अगर अनुमतियां मना कर दी जाएं तो ऐप सीमित कार्यक्षमता के साथ काम करेगा',
                      style: TextStyle(color: Colors.red[700], fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(selectedLanguage == 'English'
                ? 'Stay in Demo'
                : 'डेमो में रहें'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Switch to full mode with user understanding
              setState(() {
                _isFullFunctionalMode = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    selectedLanguage == 'English'
                        ? 'Full Mode activated! Go to Settings → Apps → TrueCircle → Permissions'
                        : 'पूर्ण मोड सक्रिय! सेटिंग्स → ऐप्स → TrueCircle → अनुमतियां में जाएं',
                  ),
                  duration: const Duration(seconds: 4),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              selectedLanguage == 'English'
                  ? 'I Understand, Enable Full Mode'
                  : 'मैं समझता हूं, पूर्ण मोड सक्षम करें',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build meditation session cards
  Widget _buildMeditationSession(
    String titleEn, String titleHi,
    String duration, IconData icon, Color color,
    {required String description, bool isLocked = false}
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey[50] : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLocked ? Colors.grey : color,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLocked ? Icons.lock : icon,
            color: isLocked ? Colors.grey : color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedLanguage == 'English' ? titleEn : titleHi,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isLocked ? Colors.grey : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLocked ? Colors.grey : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            duration,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isLocked ? Colors.grey : color,
            ),
          ),
        ],
      ),
    );
  }

  // Demo meditation session
  void _startMeditationDemo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.self_improvement, color: Colors.purple, size: 24),
            const SizedBox(width: 8),
            Text(
              selectedLanguage == 'English' ? 'Mindful Breathing Demo' : 'माइंडफुल सांस लेना डेमो',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Demo session UI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[50]!, Colors.blue[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Breathing animation placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: const Icon(Icons.air, color: Colors.purple, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedLanguage == 'English' 
                      ? 'Breathe in slowly...' 
                      : 'धीरे-धीरे सांस लें...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedLanguage == 'English' 
                      ? '🌸 Find a comfortable position\n💨 Focus on your natural breath\n✨ Let thoughts pass without judgment'
                      : '🌸 एक आरामदायक स्थिति खोजें\n💨 अपनी प्राकृतिक सांस पर ध्यान दें\n✨ बिना न्याय के विचारों को जाने दें',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedLanguage == 'English' 
                        ? 'This is a 30-second demo. Full sessions include guided audio, progress tracking, and personalized recommendations.'
                        : 'यह एक 30-सेकंड का डेमो है। पूर्ण सत्रों में निर्देशित ऑडियो, प्रगति ट्रैकिंग और व्यक्तिगत सिफारिशें शामिल हैं।',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Show completion message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    selectedLanguage == 'English' 
                      ? '🧘 Demo completed! Upgrade for full guided sessions with audio and progress tracking.'
                      : '🧘 डेमो पूरा! ऑडियो और प्रगति ट्रैकिंग के साथ पूर्ण निर्देशित सत्रों के लिए अपग्रेड करें।',
                  ),
                  duration: const Duration(seconds: 4),
                  backgroundColor: Colors.purple,
                ),
              );
            },
            child: Text(
              selectedLanguage == 'English' ? 'Complete Session' : 'सत्र समाप्त करें',
              style: const TextStyle(color: Colors.purple),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(selectedLanguage == 'English' ? 'Close' : 'बंद करें'),
          ),
        ],
      ),
    );
  }

  // Full meditation session (for full mode)
  void _startMeditationSession(String sessionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedLanguage == 'English' 
            ? 'Starting $sessionName... This would launch the full meditation experience with audio guidance.'
            : '$sessionName शुरू हो रहा है... यह ऑडियो गाइडेंस के साथ पूर्ण ध्यान अनुभव लॉन्च करेगा।',
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.purple,
      ),
    );
  }

  // Helper method to build breathing technique cards
  Widget _buildBreathingTechnique(
    String titleEn, String titleHi,
    String technique, Color color,
    {required String description, bool isLocked = false}
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey[50] : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLocked ? Colors.grey : color,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLocked ? Icons.lock : Icons.air,
            color: isLocked ? Colors.grey : color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedLanguage == 'English' ? titleEn : titleHi,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isLocked ? Colors.grey : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  technique,
                  style: TextStyle(
                    fontSize: 12,
                    color: isLocked ? Colors.grey : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLocked ? Colors.grey : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Demo breathing session
  void _startBreathingDemo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.air, color: Colors.teal, size: 24),
            const SizedBox(width: 8),
            Text(
              selectedLanguage == 'English' ? '4-7-8 Breathing Demo' : '4-7-8 श्वास डेमो',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal[50]!, Colors.blue[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.teal, width: 2),
                    ),
                    child: const Icon(Icons.air, color: Colors.teal, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedLanguage == 'English' 
                      ? 'Breathe in for 4 seconds...' 
                      : '4 सेकंड तक सांस लें...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedLanguage == 'English' 
                      ? '1. Inhale through nose (4s)\n2. Hold your breath (7s)\n3. Exhale through mouth (8s)\n4. Repeat 3-4 times'
                      : '1. नाक से सांस लें (4 सेकंड)\n2. सांस रोकें (7 सेकंड)\n3. मुंह से सांस छोड़ें (8 सेकंड)\n4. 3-4 बार दोहराएं',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedLanguage == 'English' 
                        ? 'This demo shows the basic pattern. Full sessions include guided audio, timing, and progress tracking.'
                        : 'यह डेमो बुनियादी पैटर्न दिखाता है। पूर्ण सत्रों में निर्देशित ऑडियो, समय और प्रगति ट्रैकिंग शामिल है।',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    selectedLanguage == 'English' 
                      ? '🌬️ Demo completed! Upgrade for guided sessions with audio timing and breath tracking.'
                      : '🌬️ डेमो पूरा! ऑडियो समय और सांस ट्रैकिंग के साथ निर्देशित सत्रों के लिए अपग्रेड करें।',
                  ),
                  duration: const Duration(seconds: 4),
                  backgroundColor: Colors.teal,
                ),
              );
            },
            child: Text(
              selectedLanguage == 'English' ? 'Complete Demo' : 'डेमो समाप्त करें',
              style: const TextStyle(color: Colors.teal),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(selectedLanguage == 'English' ? 'Close' : 'बंद करें'),
          ),
        ],
      ),
    );
  }

  // Full breathing session (for full mode)
  void _startBreathingSession(String techniqueName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          selectedLanguage == 'English' 
            ? 'Starting $techniqueName... This would launch the full breathing experience with audio guidance and timing.'
            : '$techniqueName शुरू हो रहा है... यह ऑडियो गाइडेंस और समय के साथ पूर्ण श्वास अनुभव लॉन्च करेगा।',
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.teal,
      ),
    );
  }

}

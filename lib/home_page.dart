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
  bool _isFullFunctionalMode = false; // Demo mode by default

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
          // Dr. Iris Avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/avatar.jpg',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'logo.png',
                    width: 50,
                    height: 50,
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Welcome text
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedLanguage == 'English' ? 'Welcome back!' : 'वापसी पर स्वागत है!',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 14 : 16,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedLanguage == 'English' ? 'Dr. Iris is here to help' : 'डॉ. आइरिस मदद के लिए यहां है',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width < 600 ? 15 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isFullFunctionalMode 
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isFullFunctionalMode ? Colors.green : Colors.orange,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFullFunctionalMode ? Icons.rocket_launch : Icons.play_circle_outline,
                        color: _isFullFunctionalMode ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isFullFunctionalMode 
                          ? (selectedLanguage == 'English' ? 'Full' : 'पूर्ण')
                          : (selectedLanguage == 'English' ? 'Demo' : 'डेमो'),
                        style: TextStyle(
                          color: _isFullFunctionalMode ? Colors.green : Colors.orange,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
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
                  child: const Icon(Icons.settings, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.1 : 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _features.length,
        itemBuilder: (context, index) {
          final feature = _features[index];
          return _buildFeatureCard(feature);
        },
      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: _isFullFunctionalMode 
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isFullFunctionalMode ? Colors.green : Colors.orange,
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
                        color: _isFullFunctionalMode ? Colors.green : Colors.orange,
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
                      selectedLanguage == 'English' ? feature['title'] : feature['titleHi'],
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
                      selectedLanguage == 'English' ? feature['subtitle'] : feature['subtitleHi'],
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
              builder: (context) => DrIrisDashboard(isFullMode: _isFullFunctionalMode),
            ),
          );
        }
        break;
      case 'meditation_guide':
        _showMeditationGuide();
        break;
      case 'breathing_exercises':
        _showBreathingExercises();
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
              builder: (context) => DrIrisDashboard(isFullMode: _isFullFunctionalMode),
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
              _isFullFunctionalMode ? Icons.rocket_launch : Icons.play_circle_outline,
              color: _isFullFunctionalMode ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              selectedLanguage == 'English' 
                ? 'Mode Changed!'
                : 'मोड बदला गया!',
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
                color: (_isFullFunctionalMode ? Colors.green : Colors.orange).withValues(alpha: 0.1),
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
                        color: _isFullFunctionalMode ? Colors.green : Colors.orange,
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
            
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(_isFullFunctionalMode 
                ? 'Start tracking your emotions daily to see insights here.'
                : 'Demo: Here you would see your recent emotional patterns and insights.');
            }
            
            final recentEntries = snapshot.data!.take(3).toList();
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isFullFunctionalMode 
                      ? 'Your Recent Emotional Patterns:' 
                      : 'Demo: Recent Emotional Patterns:',
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry['date'] ?? 'Unknown date',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getIntensityColor(entry['intensity'] ?? 5),
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
                          Text('Emotion: ${entry['emotion']['en'] ?? 'Unknown'}'),
                          Text('Trigger: ${entry['trigger']['en'] ?? 'Unknown'}'),
                          if (entry['notes']['en'] != null && entry['notes']['en'].isNotEmpty)
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
            
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(_isFullFunctionalMode 
                ? 'Start writing in your mood journal to see entries here.'
                : 'Demo: Here you would see your recent mood journal entries.');
            }
            
            final recentEntries = snapshot.data!.take(3).cast<Map<String, dynamic>>().toList();
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isFullFunctionalMode 
                      ? 'Your Recent Journal Entries:' 
                      : 'Demo: Recent Journal Entries:',
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry['date'] ?? 'Unknown date',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getMoodColor(entry['mood_rating'] ?? 5),
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
                          if (entry['tags'] != null && entry['tags'].isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 4,
                              children: (entry['tags'] as List<dynamic>).map((tag) => 
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    tag.toString(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ).toList(),
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

  void _showMeditationGuide() {
    _showFeatureDialog('Meditation Guide', 
      'Guided meditation sessions for relaxation and mindfulness.\n\n${_isFullFunctionalMode ? "Access all meditation tracks!" : "Demo: Sample 5-minute meditation"}');
  }

  void _showBreathingExercises() {
    _showFeatureDialog('Breathing Exercises', 
      'Practice breathing techniques for stress relief.\n\n${_isFullFunctionalMode ? "Personalized breathing patterns!" : "Demo: 4-7-8 breathing technique"}');
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
            
            final sleepData = snapshot.data!['sleepTracking'] as List<dynamic>? ?? [];
            final recentSleep = sleepData.take(3).cast<Map<String, dynamic>>().toList();
            
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isFullFunctionalMode 
                      ? 'Your Recent Sleep Pattern:' 
                      : 'Demo: Recent Sleep Pattern:',
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Day ${sleep['day'] ?? '?'}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getSleepQualityColor(sleep['quality'] ?? 5),
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
                          Text('Wake time: ${sleep['wakeTime'] ?? 'Unknown'}'),
                          Text('Duration: ${sleep['duration'] ?? 'Unknown'}'),
                          Text('Interruptions: ${sleep['interruptions'] ?? 0}'),
                          if (sleep['notes'] != null && sleep['notes']['en'] != null)
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
                color: _isFullFunctionalMode ? Colors.green[700] : Colors.blue[700],
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
            child: Text(_isFullFunctionalMode ? 'Switch to Demo' : 'Switch to Full'),
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
                          color: _isFullFunctionalMode ? Colors.green[700] : Colors.blue[700],
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
                      child: Text(_isFullFunctionalMode ? 'Switch to Demo' : 'Switch to Full'),
                    ),
                  ],
                ),
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
                  selectedLanguage = selectedLanguage == 'English' ? 'हिंदी' : 'English';
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
              title: Text(selectedLanguage == 'English' ? 'About App' : 'ऐप के बारे में'),
              subtitle: Text(selectedLanguage == 'English' ? 'Dr. Iris - AI Powered' : 'डॉ. आइरिस - एआई संचालित'),
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
        title: Text(selectedLanguage == 'English' ? 'About Dr. Iris' : 'डॉ. आइरिस के बारे में'),
        content: Text(
          selectedLanguage == 'English'
            ? 'Dr. Iris is your personal emotional therapist powered by AI technology. The app helps you understand your emotions, improve relationships, and maintain mental wellness.\n\n✨ AI Powered Technology\n🔒 Privacy Focused\n🌍 Bilingual Support (Hindi/English)\n💝 Completely Free'
            : 'डॉ. आइरिस आपका व्यक्तिगत भावनात्मक चिकित्सक है जो एआई तकनीक द्वारा संचालित है। यह ऐप आपको अपनी भावनाओं को समझने, रिश्तों में सुधार, और मानसिक स्वास्थ्य बनाए रखने में मदद करता है।\n\n✨ एआई संचालित तकनीक\n🔒 गोपनीयता केंद्रित\n🌍 द्विभाषी समर्थन (हिंदी/अंग्रेजी)\n💝 पूरी तरह मुफ्त',
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

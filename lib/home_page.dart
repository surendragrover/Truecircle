
import 'package:flutter/material.dart';
import 'pages/dr_iris_dashboard.dart';
import 'services/demo_data_service.dart';
import 'pages/gift_marketplace_page.dart'; // Import the new page

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String selectedLanguage = 'English';
  bool _isFullFunctionalMode = false; // Default to Demo mode

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
    {
      'title': 'Gift Marketplace',
      'titleHi': 'गिफ्ट मार्केटप्लेस',
      'subtitle': 'Offline virtual gifts',
      'subtitleHi': 'ऑफलाइन वर्चुअल उपहार',
      'icon': Icons.card_giftcard,
      'color': Colors.red,
      'action': 'gift_marketplace',
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
                Colors.blue.withAlpha(180),
                Colors.purple.withAlpha(180),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedLanguage == 'English' ? 'Welcome Back' : 'फिर से स्वागत है',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                selectedLanguage == 'English'
                    ? 'How are you feeling today?'
                    : 'आज आप कैसा महसूस कर रहे हैं?',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: _showSettingsDialog,
              ),
              // Language and Mode switch can be added here if needed
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
    bool isLocked = ['relationship_insights', 'progress']
            .contains(feature['action']) &&
        !_isFullFunctionalMode;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isLocked ? Colors.grey.shade200 : Colors.white,
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
                  color: Colors.black.withOpacity(0.3),
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
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            selectedLanguage == 'English' ? 'Demo Mode' : 'डेमो मोड',
            style: TextStyle(
              color: !_isFullFunctionalMode ? Colors.orange : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: _isFullFunctionalMode,
            onChanged: (value) {
              setState(() {
                _isFullFunctionalMode = value;
              });
              _showModeChangeSnackBar(value);
            },
            activeColor: Colors.green,
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
                  ? 'Switched to Full Mode - Your data is used.'
                  : 'Switched to Demo Mode - Using sample data.')
              : (isFullMode
                  ? 'पूर्ण मोड पर स्विच किया गया - आपका डेटा उपयोग किया जाता है।'
                  : 'डेमो मोड पर स्विच किया गया - नमूना डेटा का उपयोग।'),
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
        _showComingSoon(action);
        break;
      case 'mood_journal':
        _showComingSoon(action);
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
        _showComingSoon(action);
        break;
      case 'gift_marketplace': // New action
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GiftMarketplacePage()),
        );
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
            ? 'This feature is only available in Full Mode. Please switch from Demo Mode to continue.'
            : 'यह सुविधा केवल पूर्ण मोड में उपलब्ध है। जारी रखने के लिए कृपया डेमो मोड से स्विच करें।'),
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
              title: Text(
                  selectedLanguage == 'English' ? 'Language' : 'भाषा'),
              trailing: DropdownButton<String>(
                value: selectedLanguage,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLanguage = newValue;
                      Navigator.pop(context);
                    });
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

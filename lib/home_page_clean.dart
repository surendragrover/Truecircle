import 'package:flutter/material.dart';
import 'widgets/truecircle_logo.dart';
import 'widgets/dr_iris_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String selectedLanguage = 'English';

  // Feature data for the dashboard
  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Daily Login Rewards',
      'titleHi': 'दैनिक लॉगिन रिवार्ड',
      'subtitle': 'Earn points, get discounts',
      'subtitleHi': 'Points कमाएं, छूट पाएं',
      'icon': Icons.stars,
      'color': Colors.amber,
      'action': 'loyalty_points',
    },
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
      'titleHi': 'उपहार बाज़ार',
      'subtitle': 'AI-powered gift recommendations',
      'subtitleHi': 'AI-संचालित उपहार सुझाव',
      'icon': Icons.card_giftcard,
      'color': Colors.deepOrange,
      'action': 'gift_marketplace',
    },
    {
      'title': 'Sleep Tracker',
      'titleHi': 'नींद ट्रैकर',
      'subtitle': 'Track your sleep patterns',
      'subtitleHi': 'अपनी नींद का पैटर्न ट्रैक करें',
      'icon': Icons.bedtime,
      'color': Colors.deepPurple,
      'action': 'sleep_tracker',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFeatureTapped(String action) {
    Widget destinationPage;

    switch (action) {
      case 'loyalty_points':
        destinationPage = _buildLoyaltyPointsPage();
        break;
      case 'emotional_checkin':
        destinationPage = _buildEmotionalCheckinPage();
        break;
      case 'relationship_insights':
        destinationPage = _buildRelationshipInsightsPage();
        break;
      case 'mood_journal':
        destinationPage = _buildMoodJournalPage();
        break;
      case 'ai_chat':
        destinationPage = _buildDrIrisChatPage();
        break;
      case 'meditation':
        destinationPage = _buildMeditationPage();
        break;
      case 'progress':
        destinationPage = _buildProgressTrackerPage();
        break;
      case 'gift_marketplace':
        destinationPage = _buildGiftMarketplacePage();
        break;
      case 'sleep_tracker':
        destinationPage = _buildSleepTrackerPage();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              selectedLanguage == 'English'
                  ? 'Feature: $action coming soon!'
                  : 'फीचर: $action जल्दी आएगा!',
            ),
          ),
        );
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destinationPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TrueCircleLogo(size: 32),
            SizedBox(width: 8),
            Text(
              'TrueCircle',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedLanguage = newValue;
                });
              }
            },
            items: [
              'English',
              'Hindi',
              'বাংলা',
              'తెలుగు',
              'मराठी',
              'தமிழ்',
              'ગુજરાતી',
              'ಕನ್ನಡ',
              'മലയാളം',
              'ਪੰਜਾਬੀ',
              'اردو'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            underline: Container(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildEmotionsTab(),
          _buildFestivalsTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _onItemTapped(0),
            backgroundColor:
                _selectedIndex == 0 ? Colors.blue : Colors.grey[300],
            foregroundColor: _selectedIndex == 0 ? Colors.white : Colors.black,
            icon: const Icon(Icons.home),
            label: Text(selectedLanguage == 'English' ? 'Home' : 'होम'),
          ),
          FloatingActionButton.extended(
            onPressed: () => _onItemTapped(1),
            backgroundColor:
                _selectedIndex == 1 ? Colors.purple : Colors.grey[300],
            foregroundColor: _selectedIndex == 1 ? Colors.white : Colors.black,
            icon: const Icon(Icons.psychology),
            label: Text(selectedLanguage == 'English' ? 'Emotions' : 'भावनाएं'),
          ),
          FloatingActionButton.extended(
            onPressed: () => _onItemTapped(2),
            backgroundColor:
                _selectedIndex == 2 ? Colors.orange : Colors.grey[300],
            foregroundColor: _selectedIndex == 2 ? Colors.white : Colors.black,
            icon: const Icon(Icons.celebration),
            label:
                Text(selectedLanguage == 'English' ? 'Festivals' : 'त्योहार'),
          ),
          FloatingActionButton.extended(
            onPressed: () => _onItemTapped(3),
            backgroundColor:
                _selectedIndex == 3 ? Colors.grey[700] : Colors.grey[300],
            foregroundColor: _selectedIndex == 3 ? Colors.white : Colors.black,
            icon: const Icon(Icons.settings),
            label:
                Text(selectedLanguage == 'English' ? 'Settings' : 'सेटिंग्स'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section with Dr. Iris
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dr. Iris Avatar
                Row(
                  children: [
                    DrIrisAvatar(
                      size: 50,
                      showName: true,
                      isHindi: selectedLanguage != 'English',
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        selectedLanguage == 'English'
                            ? '✨ AI Assistant'
                            : '✨ AI सहायक',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  selectedLanguage == 'English'
                      ? 'Welcome to TrueCircle! 🎉'
                      : 'TrueCircle में आपका स्वागत है! 🎉',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedLanguage == 'English'
                      ? 'Understanding relationships through emotional intelligence'
                      : 'भावनात्मक बुद्धिमत्ता के माध्यम से रिश्तों को समझना',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Features grid
          Text(
            selectedLanguage == 'English' ? 'Features' : 'फीचर्स',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              final feature = _features[index];
              return GestureDetector(
                onTap: () => _onFeatureTapped(feature['action']),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        feature['icon'],
                        size: 40,
                        color: feature['color'],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        selectedLanguage == 'English'
                            ? feature['title']
                            : feature['titleHi'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedLanguage == 'English'
                            ? feature['subtitle']
                            : feature['subtitleHi'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 100), // Space for floating buttons
        ],
      ),
    );
  }

  Widget _buildEmotionsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology, size: 64, color: Colors.purple),
          const SizedBox(height: 16),
          Text(
            selectedLanguage == 'English' ? 'Emotions' : 'भावनाएं',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedLanguage == 'English'
                ? 'Track your emotional journey'
                : 'अपनी भावनात्मक यात्रा को ट्रैक करें',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFestivalsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            selectedLanguage == 'English' ? 'Festivals' : 'त्योहार',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedLanguage == 'English'
                ? 'Discover cultural celebrations'
                : 'सांस्कृतिक उत्सवों की खोज करें',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            selectedLanguage == 'English' ? 'Settings' : 'सेटिंग्स',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedLanguage == 'English'
                ? 'Customize your experience'
                : 'अपने अनुभव को अनुकूलित करें',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Feature Page Builders
  Widget _buildLoyaltyPointsPage() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TrueCircleLogo(
                size: 32, showText: false, style: LogoStyle.icon),
            const SizedBox(width: 8),
            Text(selectedLanguage == 'English'
                ? 'Loyalty Points'
                : 'लॉयल्टी पॉइंट्स'),
          ],
        ),
        backgroundColor: Colors.amber[100],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            Text(
              selectedLanguage == 'English'
                  ? '🎯 Daily Login Rewards'
                  : '🎯 दैनिक लॉगिन रिवार्ड',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              selectedLanguage == 'English'
                  ? 'Login daily to earn points!\n1 point = ₹1 discount\nMax 15% discount on gifts'
                  : 'रोज लॉगिन करें पॉइंट्स पाएं!\n1 पॉइंट = ₹1 छूट\nगिफ्ट्स पर अधिकतम 15% छूट',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(selectedLanguage == 'English'
                          ? '🎉 +1 Point Added!'
                          : '🎉 +1 पॉइंट मिला!')),
                );
              },
              icon: const Icon(Icons.add_circle),
              label: Text(selectedLanguage == 'English'
                  ? 'Claim Today\'s Point'
                  : 'आज का पॉइंट लें'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalCheckinPage() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TrueCircleLogo(
                size: 32, showText: false, style: LogoStyle.icon),
            const SizedBox(width: 8),
            Text(selectedLanguage == 'English'
                ? 'Emotional Check-in'
                : 'भावनात्मक जांच'),
          ],
        ),
        backgroundColor: Colors.purple[100],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 100, color: Colors.purple),
            const SizedBox(height: 20),
            Text(
              selectedLanguage == 'English'
                  ? '💭 How are you feeling today?'
                  : '💭 आज आप कैसा महसूस कर रहे हैं?',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildEmotionButton(
                    '😊', selectedLanguage == 'English' ? 'Happy' : 'खुश'),
                _buildEmotionButton(
                    '😢', selectedLanguage == 'English' ? 'Sad' : 'उदास'),
                _buildEmotionButton(
                    '😠', selectedLanguage == 'English' ? 'Angry' : 'गुस्सा'),
                _buildEmotionButton(
                    '😰', selectedLanguage == 'English' ? 'Anxious' : 'चिंतित'),
                _buildEmotionButton(
                    '😴', selectedLanguage == 'English' ? 'Tired' : 'थका'),
                _buildEmotionButton(
                    '🤗', selectedLanguage == 'English' ? 'Grateful' : 'आभारी'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionButton(String emoji, String label) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${selectedLanguage == 'English' ? 'Feeling' : 'महसूस कर रहे'} $emoji $label')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple[50],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRelationshipInsightsPage() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TrueCircleLogo(
                size: 32, showText: false, style: LogoStyle.icon),
            const SizedBox(width: 8),
            Text(selectedLanguage == 'English'
                ? 'Relationship Insights'
                : 'रिश्ते की जानकारी'),
          ],
        ),
        backgroundColor: Colors.pink[100],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, size: 100, color: Colors.pink),
            const SizedBox(height: 20),
            Text(
              selectedLanguage == 'English'
                  ? '💕 Analyze Your Connections'
                  : '💕 अपने रिश्तों का विश्लेषण',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              selectedLanguage == 'English'
                  ? 'Understand your relationships better\nwith AI-powered insights'
                  : 'AI की मदद से अपने रिश्तों को\nबेहतर तरीके से समझें',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(selectedLanguage == 'English'
                          ? '📊 Analyzing relationships...'
                          : '📊 रिश्तों का विश्लेषण हो रहा...')),
                );
              },
              icon: const Icon(Icons.analytics),
              label: Text(selectedLanguage == 'English'
                  ? 'Start Analysis'
                  : 'विश्लेषण शुरू करें'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.pink[100]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodJournalPage() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TrueCircleLogo(
                size: 32, showText: false, style: LogoStyle.icon),
            const SizedBox(width: 8),
            Text(selectedLanguage == 'English' ? 'Mood Journal' : 'मूड डायरी'),
          ],
        ),
        backgroundColor: Colors.indigo[100],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.book, size: 100, color: Colors.indigo),
            const SizedBox(height: 20),
            Text(
              selectedLanguage == 'English'
                  ? '📝 Write Your Thoughts'
                  : '📝 अपने विचार लिखें',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              selectedLanguage == 'English'
                  ? 'Express yourself freely\nTrack your mental wellness'
                  : 'अपने मन की बात कहें\nअपनी मानसिक स्वास्थ्य को ट्रैक करें',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(selectedLanguage == 'English'
                          ? '📖 Opening journal...'
                          : '📖 डायरी खोली जा रही...')),
                );
              },
              icon: const Icon(Icons.edit),
              label: Text(selectedLanguage == 'English'
                  ? 'Start Writing'
                  : 'लिखना शुरू करें'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.indigo[100]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrIrisChatPage() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TrueCircleLogo(
                size: 32, showText: false, style: LogoStyle.icon),
            const SizedBox(width: 8),
            Text(selectedLanguage == 'English'
                ? 'Chat with Dr. Iris'
                : 'डॉ. आइरिस से चैट'),
          ],
        ),
        backgroundColor: Colors.teal[100],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat, size: 100, color: Colors.teal),
            const SizedBox(height: 20),
            Text(
              selectedLanguage == 'English'
                  ? '🤖 Talk to Dr. Iris'
                  : '🤖 डॉ. आइरिस से बात करें',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              selectedLanguage == 'English'
                  ? 'Your AI companion for\nemotional support and guidance'
                  : 'भावनात्मक सहारा और मार्गदर्शन के लिए\nआपका AI साथी',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(selectedLanguage == 'English'
                          ? '💬 Dr. Iris is ready to chat!'
                          : '💬 डॉ. आइरिस चैट के लिए तैयार!')),
                );
              },
              icon: const Icon(Icons.psychology),
              label: Text(selectedLanguage == 'English'
                  ? 'Start Conversation'
                  : 'बातचीत शुरू करें'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.teal[100]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationPage() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TrueCircleLogo(
                size: 32, showText: false, style: LogoStyle.icon),
            const SizedBox(width: 8),
            Text(selectedLanguage == 'English'
                ? 'Meditation Guide'
                : 'ध्यान गाइड'),
          ],
        ),
        backgroundColor: Colors.green[100],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.self_improvement, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              selectedLanguage == 'English'
                  ? '🧘 Guided Mindfulness'
                  : '🧘 निर्देशित माइंडफुलनेस',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              selectedLanguage == 'English'
                  ? 'Find inner peace with\nguided meditation sessions'
                  : 'निर्देशित ध्यान सत्रों के साथ\nअंतरिक शांति पाएं',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(selectedLanguage == 'English'
                          ? '🕯️ Starting meditation...'
                          : '🕯️ ध्यान शुरू हो रहा...')),
                );
              },
              icon: const Icon(Icons.play_circle),
              label: Text(selectedLanguage == 'English'
                  ? 'Begin Meditation'
                  : 'ध्यान शुरू करें'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.green[100]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTrackerPage() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TrueCircleLogo(
                size: 32, showText: false, style: LogoStyle.icon),
            const SizedBox(width: 8),
            Text(selectedLanguage == 'English'
                ? 'Progress Tracker'
                : 'प्रगति ट्रैकर'),
          ],
        ),
        backgroundColor: Colors.orange[100],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.trending_up, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            Text(
              selectedLanguage == 'English'
                  ? '📈 See Your Growth'
                  : '📈 अपनी वृद्धि देखें',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              selectedLanguage == 'English'
                  ? 'Track your emotional wellness\njourney over time'
                  : 'समय के साथ अपनी भावनात्मक\nकल्याण यात्रा को ट्रैक करें',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(selectedLanguage == 'English'
                          ? '📊 Loading progress data...'
                          : '📊 प्रगति डेटा लोड हो रहा...')),
                );
              },
              icon: const Icon(Icons.timeline),
              label: Text(selectedLanguage == 'English'
                  ? 'View Progress'
                  : 'प्रगति देखें'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.orange[100]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftMarketplacePage() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TrueCircleLogo(
                size: 32, showText: false, style: LogoStyle.icon),
            const SizedBox(width: 8),
            Text(selectedLanguage == 'English'
                ? 'Gift Marketplace'
                : 'उपहार बाज़ार'),
          ],
        ),
        backgroundColor: Colors.deepOrange[100],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard,
                size: 100, color: Colors.deepOrange),
            const SizedBox(height: 20),
            Text(
              selectedLanguage == 'English'
                  ? '🎁 AI-Powered Gift Recommendations'
                  : '🎁 AI-संचालित उपहार सुझाव',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              selectedLanguage == 'English'
                  ? 'Discover perfect gifts for\nevery relationship and occasion'
                  : 'हर रिश्ते और अवसर के लिए\nसही उपहार खोजें',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(selectedLanguage == 'English'
                          ? '🛍️ Opening marketplace...'
                          : '🛍️ बाज़ार खोला जा रहा...')),
                );
              },
              icon: const Icon(Icons.shopping_bag),
              label: Text(selectedLanguage == 'English'
                  ? 'Browse Gifts'
                  : 'गिफ्ट्स देखें'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange[100]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepTrackerPage() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TrueCircleLogo(
                size: 32, showText: false, style: LogoStyle.icon),
            const SizedBox(width: 8),
            Text(selectedLanguage == 'English'
                ? 'Sleep Tracker'
                : 'नींद ट्रैकर'),
          ],
        ),
        backgroundColor: Colors.deepPurple[100],
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bedtime, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 20),
            Text(
              selectedLanguage == 'English'
                  ? '😴 Track Your Sleep'
                  : '😴 अपनी नींद ट्रैक करें',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const SizedBox(height: 16),
            Text(
              selectedLanguage == 'English'
                  ? 'Monitor sleep patterns and improve\nyour rest quality for better wellness'
                  : 'नींद के पैटर्न को मॉनिटर करें और\nबेहतर कल्याण के लिए आराम की गुणवत्ता सुधारें',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
            // Sleep tracking options
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildSleepButton('🛌',
                    selectedLanguage == 'English' ? 'Bedtime' : 'सोने का समय'),
                _buildSleepButton('⏰',
                    selectedLanguage == 'English' ? 'Wake Up' : 'उठने का समय'),
                _buildSleepButton(
                    '📊',
                    selectedLanguage == 'English'
                        ? 'Sleep Stats'
                        : 'नींद के आंकड़े'),
                _buildSleepButton(
                    '🎯',
                    selectedLanguage == 'English'
                        ? 'Sleep Goal'
                        : 'नींद का लक्ष्य'),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(selectedLanguage == 'English'
                          ? '🌙 Starting sleep tracking...'
                          : '🌙 नींद ट्रैकिंग शुरू हो रही...')),
                );
              },
              icon: const Icon(Icons.play_circle),
              label: Text(selectedLanguage == 'English'
                  ? 'Start Sleep Tracking'
                  : 'नींद ट्रैकिंग शुरू करें'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[100],
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            // Sleep quality indicators
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    selectedLanguage == 'English'
                        ? '🌟 Last Night\'s Sleep'
                        : '🌟 कल रात की नींद',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSleepMetric('⏱️', '7h 45m',
                          selectedLanguage == 'English' ? 'Duration' : 'अवधि'),
                      _buildSleepMetric(
                          '⭐',
                          '85%',
                          selectedLanguage == 'English'
                              ? 'Quality'
                              : 'गुणवत्ता'),
                      _buildSleepMetric(
                          '🔥',
                          '92%',
                          selectedLanguage == 'English'
                              ? 'Deep Sleep'
                              : 'गहरी नींद'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepButton(String emoji, String label) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '$emoji $label ${selectedLanguage == 'English' ? 'selected' : 'चुना गया'}')),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple[50],
        foregroundColor: Colors.black,
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSleepMetric(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:truecircle/services/auth_service.dart';
import '../auth_wrapper.dart';
import '../widgets/truecircle_logo.dart';
import 'dr_iris_dashboard.dart';
import 'feature_page.dart';
import 'loyalty_points_page.dart';
import 'daily_progress_demo_page.dart';
import '../services/loyalty_points_service.dart';

// TrueCircle Complete Dashboard with All Features
class GiftMarketplacePage extends StatefulWidget {
  const GiftMarketplacePage({super.key});

  @override
  State<GiftMarketplacePage> createState() => _GiftMarketplacePageState();
}

class _GiftMarketplacePageState extends State<GiftMarketplacePage> {
  final AuthService _authService = AuthService();
  String _selectedLanguage = 'English'; // Default English
  bool _isHindi = false; // Default English
  int _loyaltyPoints = 0;

  // Languages List - Only Hindi and English for now
  final List<Map<String, String>> _languages = [
    {'code': 'hi', 'name': 'हिंदी', 'english': 'Hindi'},
    {'code': 'en', 'name': 'English', 'english': 'English'},
  ];

  // Complete Feature Categories with Sample Data
  final List<Map<String, dynamic>> _features = [
    {
      'title': 'Relationship Insights',
      'titleHi': 'रिश्तों की अंतर्दृष्टि',
      'icon': Icons.people_alt,
      'color': Colors.red,
      'description': 'Monitor and analyze your relationships',
      'descriptionHi': 'अपने रिश्तों की निगरानी और विश्लेषण करें',
      'category': 'relationship'
    },
    {
      'title': 'Emotional Check-in',
      'titleHi': 'भावनात्मक जांच',
      'icon': Icons.psychology,
      'color': Colors.teal,
      'description': 'Daily emotional wellness tracking',
      'descriptionHi': 'दैनिक भावनात्मक कल्याण ट्रैकिंग',
      'category': 'mental_health'
    },
    {
      'title': 'Mood Journal',
      'titleHi': 'मूड जर्नल',
      'icon': Icons.book,
      'color': Colors.purple,
      'description': 'Track your daily moods and patterns',
      'descriptionHi': 'अपनी दैनिक मूड और पैटर्न को ट्रैक करें',
      'category': 'mental_health'
    },
    {
      'title': 'Meditation Guide',
      'titleHi': 'ध्यान गाइड',
      'icon': Icons.self_improvement,
      'color': Colors.orange,
      'description': 'Guided meditation for mental peace',
      'descriptionHi': 'मानसिक शांति के लिए निर्देशित ध्यान',
      'category': 'mental_health'
    },
    {
      'title': 'Sleep Tracker',
      'titleHi': 'नींद ट्रैकर',
      'icon': Icons.nights_stay,
      'color': Colors.indigo,
      'description': 'Monitor your sleep quality patterns',
      'descriptionHi': 'अपनी नींद की गुणवत्ता का पैटर्न जानें',
      'category': 'mental_health'
    },
    {
      'title': 'Progress Tracker',
      'titleHi': 'प्रगति ट्रैकर',
      'icon': Icons.trending_up,
      'color': Colors.green,
      'description': 'Track your wellness journey progress',
      'descriptionHi': 'अपनी कल्याण यात्रा की प्रगति ट्रैक करें',
      'category': 'analytics'
    },
    {
      'title': 'Communication Tracker',
      'titleHi': 'संचार ट्रैकर',
      'icon': Icons.phone,
      'color': Colors.blue,
      'description': 'Track calls, messages and interactions',
      'descriptionHi': 'कॉल, संदेश और बातचीत को ट्रैक करें',
      'category': 'relationship'
    },
    {
      'title': 'Festival Reminders',
      'titleHi': 'त्योहार अनुस्मारक',
      'icon': Icons.celebration,
      'color': Colors.amber,
      'description': 'Get festival reminders & message tips',
      'descriptionHi': 'त्योहार अनुस्मारक और संदेश सुझाव पाएं',
      'category': 'social'
    },
    {
      'title': 'Gifts',
      'titleHi': 'उपहार',
      'icon': Icons.card_giftcard,
      'color': Colors.pink,
      'description': 'Offline gift purchasing options',
      'descriptionHi': 'ऑफ़लाइन उपहार खरीदारी विकल्प',
      'category': 'social'
    },
    {
      'title': 'Event Budgeting',
      'titleHi': 'इवेंट बजटिंग',
      'icon': Icons.account_balance_wallet,
      'color': Colors.cyan,
      'description': 'Plan and budget your events',
      'descriptionHi': 'अपने कार्यक्रमों की योजना और बजट बनाएं',
      'category': 'planning'
    },
    {
      'title': 'Dr. Iris Emotional Therapist',
      'titleHi': 'डॉ. आइरिस इमोशनल थेरेपिस्ट',
      'icon': Icons.psychology_alt,
      'color': Colors.deepPurple,
      'description': 'Your emotional therapist for mental wellness',
      'descriptionHi': 'मानसिक कल्याण के लिए आपका इमोशनल थेरेपिस्ट',
      'category': 'ai_counselor',
      'hasAvatar': true
    },
    {
      'title': 'Daily Login Rewards',
      'titleHi': 'दैनिक लॉगिन पुरस्कार',
      'icon': Icons.star,
      'color': Colors.yellow,
      'description': 'Earn loyalty points daily (1 point = ₹1)',
      'descriptionHi': 'प्रतिदिन पॉइंट कमाएं (1 पॉइंट = ₹1)',
      'category': 'rewards'
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkDailyReward();
  }

  Future<void> _checkDailyReward() async {
    try {
      final result = await LoyaltyPointsService.instance.processDailyLogin();
      setState(() {
        _loyaltyPoints = LoyaltyPointsService.instance.totalPoints;
      });

      if (result.pointsAwarded > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isHindi
                  ? 'दैनिक लॉगिन बोनस मिला! +${result.pointsAwarded} पॉइंट्स'
                  : 'Daily login bonus earned! +${result.pointsAwarded} points',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: '+${result.pointsAwarded}',
              textColor: Colors.yellow,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error silently
      setState(() {
        _loyaltyPoints = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF00BFA5), // Brilliant bluish green background
      appBar: AppBar(
        backgroundColor: const Color(0xFF00695C), // Darker teal for AppBar
        elevation: 2,
        title: Row(
          children: [
            TrueCircleLogo(
              size: 35,
              showText: false,
              isHindi: _isHindi,
              style: LogoStyle.icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isHindi ? 'ट्रू सर्कल' : 'TrueCircle',
                style: const TextStyle(
                  color: Colors.black, // Jet black text
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Loyalty Points Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_loyaltyPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Language Selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (String languageCode) {
              _changeLanguage(languageCode);
            },
            itemBuilder: (BuildContext context) {
              return _languages.map((language) {
                return PopupMenuItem<String>(
                  value: language['code'],
                  child: Text(
                    '${language['name']} (${language['english']})',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList();
            },
          ),
          // Logout Button
          IconButton(
            onPressed: () {
              _authService.resetPhoneVerification();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthWrapper()),
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: _isHindi ? 'लॉग आउट' : 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade500
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isHindi ? 'स्वागत है!' : 'Welcome!',
                    style: const TextStyle(
                      color: Colors.black, // Jet black text
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isHindi
                        ? 'रिश्तों में स्पष्टता लाना'
                        : 'bringing clarity in relations',
                    style: const TextStyle(
                      color: Colors.black87, // Dark text
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isHindi
                        ? 'आपका मानसिक स्वास्थ्य और रिश्तों का साथी - Dr. Iris के साथ'
                        : 'Your mental health & relationship companion - with Dr. Iris',
                    style: const TextStyle(
                      color: Colors.black, // Jet black text
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Dr. Iris Quick Access
            _buildDrIrisSection(),

            const SizedBox(height: 24),

            // Features Grid
            Text(
              _isHindi ? 'सभी सुविधाएं' : 'All Features',
              style: const TextStyle(
                color: Colors.black, // Jet black text
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: _features.map((feature) {
                return GestureDetector(
                  onTap: () {
                    _navigateToFeature(feature);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFF004D40), // Dark teal for feature cards
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00695C)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          feature['hasAvatar'] == true
                              ? CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.deepPurple.shade300,
                                  child: const Icon(
                                    Icons.psychology_alt,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: feature['color'].withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    feature['icon'],
                                    size: 30,
                                    color: feature['color'],
                                  ),
                                ),
                          const SizedBox(height: 12),
                          Text(
                            _isHindi ? feature['titleHi'] : feature['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors
                                  .white, // White text for dark background
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  _isHindi
                                      ? feature['descriptionHi']
                                      : feature['description'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors
                                        .white70, // Light white text for dark background
                                    fontSize: 9,
                                  ),
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
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              _isHindi ? 'त्वरित कार्य' : 'Quick Actions',
              style: const TextStyle(
                color: Colors.black, // Jet black text
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    title: _isHindi
                        ? 'Dr. Iris से बात करें'
                        : 'Chat with Dr. Iris',
                    icon: Icons.psychology_alt,
                    color: Colors.deepPurple,
                    onTap: () => _navigateToDrIris(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionCard(
                    title: _isHindi ? 'मूड चेक-इन' : 'Mood Check-in',
                    icon: Icons.psychology,
                    color: Colors.teal,
                    onTap: () => _showMoodCheckIn(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Statistics
            Text(
              _isHindi ? 'आज का सारांश' : 'Today\'s Summary',
              style: const TextStyle(
                color: Colors.black, // Jet black text
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF004D40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    _isHindi ? 'लॉयल्टी पॉइंट्स' : 'Loyalty Points',
                    '$_loyaltyPoints',
                    Icons.star,
                  ),
                  const Divider(color: Color(0xFF00695C)),
                  _buildStatRow(
                    _isHindi ? 'उपयोगकर्ता डेटा' : 'User Analytics',
                    _isHindi ? 'सुरक्षित' : 'Secure',
                    Icons.analytics,
                  ),
                  const Divider(color: Color(0xFF00695C)),
                  _buildStatRow(
                    _isHindi ? 'सुविधाएं' : 'Features',
                    '${_features.length}',
                    Icons.apps,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Permission Guide
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF004D40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings,
                          color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isHindi
                              ? '⚙️ पूर्ण कार्यक्षमता के लिए परमिशन दें'
                              : '⚙️ Grant Permissions for Full Functionality',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isHindi
                        ? 'फुल्ली फंक्शनल ऐप के लिए निम्न परमिशन दें:\n• 📞 कॉल लॉग्स - रिश्तों का विश्लेषण\n• 💬 SMS - संदेश पैटर्न जांच\n• 📱 WhatsApp - चैट एनालिसिस\n\n🔒 गारंटी: आपका डेटा केवल आपकी डिवाइस पर रहता है। कोई क्लाउड, कोई शेयरिंग नहीं!'
                        : 'For fully functional app, grant these permissions:\n• 📞 Call Logs - Relationship analysis\n• 💬 SMS - Message pattern check\n• 📱 WhatsApp - Chat analysis\n\n🔒 Guarantee: Your data stays only on your device. No cloud, no sharing!',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _showPermissionGuide(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isHindi ? 'परमिशन गाइड देखें' : 'View Permission Guide',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Privacy Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF004D40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isHindi
                          ? '🔒 आपकी निजता हमारी प्राथमिकता है। सभी डेटा ऑफ़लाइन संग्रहीत होता है।'
                          : '🔒 Your privacy is our priority. All data is stored offline.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
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

  Widget _buildDrIrisSection() {
    return GestureDetector(
      onTap: () => _navigateToDrIris(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade600, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepPurple.shade300,
              child: const Icon(
                Icons.psychology_alt,
                size: 35,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isHindi
                        ? 'डॉ. आइरिस इमोशनल थेरेपिस्ट'
                        : 'Dr. Iris Emotional Therapist',
                    style: const TextStyle(
                      color: Colors.white, // White text for gradient background
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isHindi
                        ? 'आपकी व्यक्तिगत भावनात्मक कल्याण सलाहकार - हमेशा उपलब्ध'
                        : 'Your personal emotional wellness counselor - Always available',
                    style: const TextStyle(
                      color: Colors
                          .white70, // Light white text for gradient background
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _isHindi ? '💬 चैट शुरू करें' : '💬 Start Chat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF004D40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _isHindi = (languageCode == 'hi'); // Properly set language based on code
      _selectedLanguage = _languages.firstWhere(
        (lang) => lang['code'] == languageCode,
        orElse: () => _languages[0],
      )['name']!;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isHindi
              ? 'भाषा बदली गई: $_selectedLanguage'
              : 'Language changed to: $_selectedLanguage',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToFeature(Map<String, dynamic> feature) {
    if (feature['title'] == 'Dr. Iris Emotional Therapist') {
      _navigateToDrIris();
    } else if (feature['title'] == 'Daily Login Rewards') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoyaltyPointsPage(isHindi: _isHindi),
        ),
      );
    } else if (feature['title'] == 'Progress Tracker') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DailyProgressDemoPage(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeaturePage(
            feature: feature,
            isHindi: _isHindi,
          ),
        ),
      );
    }
  }

  void _navigateToDrIris() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DrIrisDashboard(),
      ),
    );
  }

  void _showMoodCheckIn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF004D40),
        title: Text(
          _isHindi
              ? 'आज आप कैसा महसूस कर रहे हैं?'
              : 'How are you feeling today?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMoodButton('😊', _isHindi ? 'खुश' : 'Happy'),
                _buildMoodButton('😔', _isHindi ? 'उदास' : 'Sad'),
                _buildMoodButton('😰', _isHindi ? 'चिंतित' : 'Anxious'),
                _buildMoodButton('😴', _isHindi ? 'थका' : 'Tired'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _isHindi ? 'बंद करें' : 'Close',
              style: const TextStyle(color: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(String emoji, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isHindi ? 'मूड सेव हो गया: $label' : 'Mood saved: $label',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.teal,
          ),
        );
      },
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  void _showPermissionGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF004D40),
        title: Text(
          _isHindi ? 'परमिशन गाइड' : 'Permission Guide',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isHindi
                    ? 'TrueCircle को पूरी तरह काम करने के लिए निम्न परमिशन चाहिए:'
                    : 'TrueCircle needs these permissions to work fully:',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 16),
              _buildPermissionItem(
                '📞',
                _isHindi ? 'कॉल लॉग्स' : 'Call Logs',
                _isHindi
                    ? 'रिश्तों की संवाद आवृत्ति विश्लेषण'
                    : 'Analyze relationship communication frequency',
              ),
              _buildPermissionItem(
                '💬',
                _isHindi ? 'SMS' : 'SMS',
                _isHindi
                    ? 'संदेश पैटर्न और भावना विश्लेषण'
                    : 'Message patterns and sentiment analysis',
              ),
              _buildPermissionItem(
                '📱',
                _isHindi ? 'WhatsApp डेटा' : 'WhatsApp Data',
                _isHindi
                    ? 'चैट इतिहास भावनात्मक विश्लेषण'
                    : 'Chat history emotional analysis',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.security, color: Colors.green, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      _isHindi
                          ? '🔒 प्राइवेसी गारंटी:\n• सभी डेटा आपकी डिवाइस पर ही रहता है\n• कोई क्लाउड अपलोड नहीं\n• ऑफलाइन AI प्रोसेसिंग\n• आपकी जानकारी कहीं नहीं भेजी जाती'
                          : '🔒 Privacy Guarantee:\n• All data stays on your device\n• No cloud uploads\n• Offline AI processing\n• Your information is never sent anywhere',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isHindi
                    ? 'परमिशन देने के लिए: Settings > Apps > TrueCircle > Permissions'
                    : 'To grant permissions: Settings > Apps > TrueCircle > Permissions',
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              _isHindi ? 'समझ गया' : 'Got It',
              style: const TextStyle(color: Colors.teal),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In real app, open device settings
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isHindi
                        ? 'Settings > Apps > TrueCircle > Permissions में जाएं'
                        : 'Go to Settings > Apps > TrueCircle > Permissions',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(
              _isHindi ? 'सेटिंग्स खोलें' : 'Open Settings',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

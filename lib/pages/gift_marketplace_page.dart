import 'package:flutter/material.dart';
import 'package:truecircle/services/auth_service.dart';
import 'dart:async';
import '../auth_wrapper.dart';
import '../widgets/truecircle_logo.dart';
import 'dr_iris_dashboard.dart';
import 'feature_page.dart';
import 'loyalty_points_page.dart';
import 'daily_progress_page.dart';
import '../services/loyalty_points_service.dart';
import '../theme/coral_theme.dart';
import '../services/offline_ai_suggestion_service.dart';
import '../services/cloud_sync_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  bool _modelsReady = false; // AI model gate
  bool _cloudSyncEnabled = true; // Privacy toggle

  // Performance / throttling helpers
  bool _syncInFlight = false;
  DateTime? _lastSyncCall;
  bool _aiLoaded = false;

  // Offline AI suggestion data
  Map<String, dynamic>? _breathingSuggestion;
  Map<String, dynamic>? _meditationSuggestion;
  List<Map<String, String>> _festivalMessages = [];
  String? _eventPlanningTipEn;
  String? _eventPlanningTipHi;

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
    // Defer AI loading to next frame to avoid blocking first paint
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_aiLoaded) _loadAISuggestions();
    });
    _initPrivacySettings();
    CloudSyncService.instance.loadLastSyncFromStorage();
    // Removed noisy listeners; localized rebuilds handled via ValueListenableBuilder
  }

  void _throttledSync({
    required int loyaltyPoints,
    required int featuresCount,
    required bool modelsReady,
    required int aiFestivalMessages,
  }) {
    final now = DateTime.now();
    if (_syncInFlight) return;
    if (_lastSyncCall != null && now.difference(_lastSyncCall!) < const Duration(seconds: 3)) return;
    _lastSyncCall = now;
    _syncInFlight = true;
    CloudSyncService.instance
        .syncUserState(
          loyaltyPoints: loyaltyPoints,
          featuresCount: featuresCount,
          modelsReady: modelsReady,
          aiFestivalMessages: aiFestivalMessages,
        )
        .whenComplete(() => _syncInFlight = false);
  }

  Future<void> _initPrivacySettings() async {
    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      final stored = box.get('cloud_sync_enabled', defaultValue: true) as bool;
      _cloudSyncEnabled = stored;
      CloudSyncService.instance.setSyncEnabled(stored);
      if (mounted) setState(() {});
    } catch (_) {
      // Silent failure keeps default true (still respects privacy: only metadata)
    }
  }

  Future<void> _toggleCloudSync(bool value) async {
    setState(() => _cloudSyncEnabled = value);
    CloudSyncService.instance.setSyncEnabled(value);
    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      await box.put('cloud_sync_enabled', value);
    } catch (_) {}
    if (value) {
      // When re-enabling, immediately attempt a sync (will flush pending if any)
      CloudSyncService.instance.enableAndKick(
        loyaltyPoints: _loyaltyPoints,
        featuresCount: _features.length,
        modelsReady: _modelsReady,
        aiFestivalMessages: _festivalMessages.length,
      );
    }
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
      if (_cloudSyncEnabled) {
        // Attempt an initial sync (only runs once if never synced yet)
        CloudSyncService.instance.initialSyncIfPossible(
          loyaltyPoints: _loyaltyPoints,
          featuresCount: _features.length,
          modelsReady: _modelsReady,
          aiFestivalMessages: _festivalMessages.length,
        );
        _throttledSync(
          loyaltyPoints: _loyaltyPoints,
          featuresCount: _features.length,
          modelsReady: _modelsReady,
          aiFestivalMessages: _festivalMessages.length,
        );
      }
    } catch (e) {
      // Handle error silently
      setState(() {
        _loyaltyPoints = 0;
      });
    }
  }

  Future<void> _loadAISuggestions() async {
    if (_aiLoaded) return;
    _aiLoaded = true;
    try {
      final ready = await OfflineAISuggestionService.instance.isModelReady();
      if (!mounted) return;
      if (!ready) {
        setState(() => _modelsReady = false);
        return;
      }
      final results = await Future.wait([
        OfflineAISuggestionService.instance.getDailyBreathingSuggestion(),
        OfflineAISuggestionService.instance.getDailyMeditationSuggestion(),
        OfflineAISuggestionService.instance.getFestivalMessageSuggestions(count: 2),
        OfflineAISuggestionService.instance.getEventPlanningSuggestion(hindi: false),
        OfflineAISuggestionService.instance.getEventPlanningSuggestion(hindi: true),
      ]);
      if (!mounted) return;
      setState(() {
        _modelsReady = true;
        _breathingSuggestion = results[0] as Map<String, dynamic>?;
        _meditationSuggestion = results[1] as Map<String, dynamic>?;
        _festivalMessages = results[2] as List<Map<String, String>>;
        _eventPlanningTipEn = results[3] as String?;
        _eventPlanningTipHi = results[4] as String?;
      });
      if (_cloudSyncEnabled) {
        _throttledSync(
          loyaltyPoints: _loyaltyPoints,
          featuresCount: _features.length,
          modelsReady: _modelsReady,
          aiFestivalMessages: _festivalMessages.length,
        );
      }
    } catch (e) {
      if (mounted) setState(() => _modelsReady = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: CoralTheme.appBarGradient),
        ),
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
      body: Container(
        decoration: CoralTheme.background,
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(18),
                boxShadow: CoralTheme.glowShadow(0.15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isHindi ? 'स्वागत है!' : 'Welcome!',
                    style: const TextStyle(
                      color: Colors.black,
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

            if (_modelsReady) _buildAIDailySuggestionsSection(),
            if (_modelsReady) const SizedBox(height: 24),

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
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      boxShadow: CoralTheme.glowShadow(0.12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          feature['hasAvatar'] == true
                              ? const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: CoralTheme.dark,
                                  child: Icon(
                                    Icons.psychology_alt,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: (feature['color'] as Color).withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    feature['icon'],
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                          const SizedBox(height: 12),
                          Text(
                            _isHindi ? feature['titleHi'] : feature['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
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
                                    color: Colors.white70,
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

            // Statistics (use coral translucent card for contrast over gradient)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: CoralTheme.translucentCard(alpha: 0.18, radius: BorderRadius.circular(16)),
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
            // Permission Guide (coral styled)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: CoralTheme.translucentCard(alpha: 0.15, radius: BorderRadius.circular(12)).copyWith(
                border: Border.all(color: Colors.orange.withValues(alpha: 0.55)),
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
            // Privacy Note (coral styled)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: CoralTheme.translucentCard(alpha: 0.15, radius: BorderRadius.circular(12)).copyWith(
                border: Border.all(color: Colors.green.withValues(alpha: 0.55)),
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
            const SizedBox(height: 14),
            _buildPrivacyControls(),
          ],
        ),
      )),
    );
  }

  Widget _buildDrIrisSection() {
    return GestureDetector(
      onTap: () => _navigateToDrIris(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: CoralTheme.translucentCard(alpha: 0.20, radius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: CoralTheme.dark,
              child: Icon(
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

  Widget _buildPrivacyControls() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: CoralTheme.translucentCard(alpha: 0.15, radius: BorderRadius.circular(12)).copyWith(
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_cloudSyncEnabled ? Icons.cloud_sync : Icons.cloud_off,
                  color: _cloudSyncEnabled ? Colors.lightBlueAccent : Colors.redAccent,
                  size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isHindi ? 'क्लाउड सिंक (केवल मेटाडेटा)' : 'Cloud Sync (Metadata Only)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Switch(
                value: _cloudSyncEnabled,
                activeThumbColor: Colors.lightBlueAccent,
                activeTrackColor: Colors.lightBlueAccent.withValues(alpha: 0.35),
                onChanged: (v) => _toggleCloudSync(v),
              ),
            ],
          ),
          const SizedBox(height: 6),
            Text(
              _cloudSyncEnabled
                  ? (_isHindi
                      ? 'सक्रिय: केवल सुरक्षित सारांश (पॉइंट्स, फीचर काउंट, मॉडल स्थिति) Firestore में सेव। कोई व्यक्तिगत चैट/भावना डेटा नहीं भेजा जाता।'
                      : 'Enabled: Only safe aggregates (points, feature count, model status) are stored. No personal chats or emotion text ever leaves device.')
                  : (_isHindi
                      ? 'अक्षम: अब कोई भी डेटा क्लाउड पर नहीं भेजा जाएगा।'
                      : 'Disabled: No further metadata will sync to cloud.'),
              style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
            ),
          const SizedBox(height: 8),
          _buildSyncStatusRow(),
          const SizedBox(height: 8),
          // Last payload keys (debug visibility of what was sent)
          ValueListenableBuilder<DateTime?>(
            valueListenable: CloudSyncService.instance.lastSyncNotifier,
            builder: (_, __, ___) {
              final keys = CloudSyncService.instance.lastPayloadKeys;
              if (keys == null) {
                return Text(
                  _isHindi ? 'अभी तक कोई पेलोड नहीं' : 'No payload yet',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                );
              }
              return Text(
                (_isHindi ? 'अंतिम कुंजियाँ: ' : 'Last keys: ') + keys.join(', '),
                style: const TextStyle(color: Colors.white54, fontSize: 10, height: 1.3),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _cloudSyncEnabled
                    ? () async {
                        final ok = await CloudSyncService.instance.manualTestSync(
                          loyaltyPoints: _loyaltyPoints,
                          featuresCount: _features.length,
                          modelsReady: _modelsReady,
                          aiFestivalMessages: _festivalMessages.length,
                        );
                        if (!mounted) return;
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isHindi ? 'टेस्ट सिंक भेजा गया' : 'Test sync dispatched',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.blueGrey,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isHindi ? 'टेस्ट सिंक विफल (फोन नहीं)' : 'Test sync failed (no phone)',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.redAccent,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent.withValues(alpha: 0.85),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 34),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.cloud_upload, size: 16, color: Colors.white),
                label: Text(
                  _isHindi ? 'टेस्ट सिंक' : 'Test Sync',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isHindi
                      ? 'यह बटन पेलोड को तुरंत भेजने का प्रयास करता है.'
                      : 'Forces an immediate sync attempt of current metadata.',
                  style: const TextStyle(color: Colors.white38, fontSize: 10, height: 1.25),
                ),
              )
            ],
          ),
          if (CloudSyncService.instance.lastErrorNotifier.value != null) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    (_isHindi ? 'त्रुटि: ' : 'Error: ') + (CloudSyncService.instance.lastErrorNotifier.value ?? ''),
                    style: const TextStyle(color: Colors.redAccent, fontSize: 10, height: 1.2),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    CloudSyncService.instance.lastErrorNotifier.value = null;
                    setState(() {});
                  },
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                  child: Text(_isHindi ? 'हटाएं' : 'Clear', style: const TextStyle(fontSize: 10, color: Colors.redAccent)),
                )
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _buildLastSyncLabel() {
    final dt = CloudSyncService.instance.lastSuccessfulSync;
    if (dt == null) {
      return _isHindi ? 'अभी तक कोई सिंक नहीं' : 'No sync yet';
    }
    final now = DateTime.now();
    final diff = now.difference(dt);
    String rel;
    if (diff.inSeconds < 60) {
      rel = _isHindi ? 'अभी' : 'just now';
    } else if (diff.inMinutes < 60) {
      rel = _isHindi ? '${diff.inMinutes} मिनट पहले' : '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      rel = _isHindi ? '${diff.inHours} घंटे पहले' : '${diff.inHours}h ago';
    } else {
      rel = _isHindi ? '${diff.inDays} दिन पहले' : '${diff.inDays}d ago';
    }
    return (_isHindi ? 'अंतिम सिंक: ' : 'Last sync: ') + rel;
  }

  Widget _buildSyncStatusRow() {
    return ValueListenableBuilder<bool>(
      valueListenable: CloudSyncService.instance.syncingNotifier,
      builder: (_, syncing, __) {
        return ValueListenableBuilder<int?>(
          valueListenable: CloudSyncService.instance.retryCountdownNotifier,
          builder: (_, retry, __) {
            final docId = CloudSyncService.instance.sanitizedUserId != null
                ? 'users/${CloudSyncService.instance.sanitizedUserId}/meta/state'
                : null;
            return Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.white70),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
          docId == null
            ? _buildLastSyncLabel()
            : '${_buildLastSyncLabel()}\n$docId',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ),
                if (syncing)
                  const Row(
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text('Syncing...', style: TextStyle(color: Colors.white60, fontSize: 10)),
                    ],
                  ),
                if (retry != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      _isHindi ? 'पुनः प्रयास ${retry}s में' : 'Retry in ${retry}s',
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 10),
                    ),
                  ),
                TextButton.icon(
                  onPressed: _cloudSyncEnabled ? () => CloudSyncService.instance.manualSync() : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                    disabledForegroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: Text(_isHindi ? 'सिंक' : 'Sync'),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: _cloudSyncEnabled ? _confirmClearCloud : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    disabledForegroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(_isHindi ? 'क्लियर' : 'Clear', style: const TextStyle(fontSize: 11)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmClearCloud() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF004D40),
        title: Text(
          _isHindi ? 'क्लाउड डेटा हटाएं?' : 'Clear Cloud Metadata?',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          _isHindi
              ? 'यह केवल अपलोड किया गया सुरक्षित मेटाडेटा (पॉइंट्स, फीचर काउंट, मॉडल फ्लैग) क्लाउड से हटा देगा। आपकी डिवाइस का लोकल डेटा सुरक्षित रहेगा.'
              : 'This will delete the uploaded safe metadata (points, feature count, model flag) from the cloud. Local device data remains untouched.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_isHindi ? 'रद्द करें' : 'Cancel', style: const TextStyle(color: Colors.teal)),
          ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                Navigator.pop(ctx);
                final ok = await CloudSyncService.instance.clearCloudMetadata();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? (_isHindi ? 'क्लाउड मेटाडेटा हटाया गया' : 'Cloud metadata cleared')
                            : (_isHindi ? 'हटाने में विफल' : 'Failed to clear'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: ok ? Colors.green : Colors.redAccent,
                    ),
                  );
                }
              },
              child: Text(_isHindi ? 'हटाएं' : 'Delete', style: const TextStyle(color: Colors.white)),
            ),
        ],
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
        decoration: CoralTheme.translucentCard(alpha: 0.16, radius: BorderRadius.circular(12)).copyWith(
          border: Border.all(color: color.withValues(alpha: 0.55)),
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
    } else if (feature['title'] == 'Breathing Exercises' || feature['title'] == 'Meditation Guide') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FeaturePage(
            feature: feature,
            isHindi: _isHindi,
          ),
        ),
      );
    } else if (feature['title'] == 'Progress Tracker') {
      // Navigate to the sample-enabled daily progress page (previously demo)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DailyProgressPage(), // Updated to new sample page
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

  Widget _buildAIDailySuggestionsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: CoralTheme.translucentCard(alpha: 0.18, radius: BorderRadius.circular(18)).copyWith(
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isHindi ? 'AI दैनिक सुझाव' : 'AI Daily Suggestions',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_breathingSuggestion != null)
            _buildMiniSuggestionCard(
              title: _isHindi ? 'आज का श्वास अभ्यास' : "Today's Breathing",
              emoji: '💨',
              body: _isHindi
                  ? (_breathingSuggestion!['technique_hindi'] ?? _breathingSuggestion!['technique'] ?? '')
                  : (_breathingSuggestion!['technique'] ?? _breathingSuggestion!['technique_hindi'] ?? ''),
              footer: _isHindi
                  ? '${_breathingSuggestion!['duration_minutes']} मिनट'
                  : '${_breathingSuggestion!['duration_minutes']} min',
            ),
          if (_meditationSuggestion != null)
            _buildMiniSuggestionCard(
              title: _isHindi ? 'आज का ध्यान' : "Today's Meditation",
              emoji: '🧘',
              body: _isHindi
                  ? (_meditationSuggestion!['title_hindi'] ?? _meditationSuggestion!['title'] ?? '')
                  : (_meditationSuggestion!['title'] ?? _meditationSuggestion!['title_hindi'] ?? ''),
              footer: _isHindi
                  ? '${_meditationSuggestion!['duration_minutes']} मिनट'
                  : '${_meditationSuggestion!['duration_minutes']} min',
            ),
          if (_festivalMessages.isNotEmpty) ...[
            _buildMiniSuggestionCard(
              title: _isHindi ? 'त्योहार संदेश' : 'Festival Messages',
              emoji: '🪔',
              body: (_isHindi
                      ? _festivalMessages.first['message_hi']
                      : _festivalMessages.first['message_en']) ?? '',
              footer: _isHindi
                  ? (_festivalMessages.first['festival_hi'] ?? '')
                  : (_festivalMessages.first['festival_en'] ?? ''),
            ),
            if (_festivalMessages.length > 1)
              _buildMiniSuggestionCard(
                title: '',
                emoji: '🎉',
                body: (_isHindi
                        ? _festivalMessages[1]['message_hi']
                        : _festivalMessages[1]['message_en']) ?? '',
                footer: _isHindi
                    ? (_festivalMessages[1]['festival_hi'] ?? '')
                    : (_festivalMessages[1]['festival_en'] ?? ''),
              ),
          ],
          if (_eventPlanningTipEn != null)
            _buildMiniSuggestionCard(
              title: _isHindi ? 'इवेंट प्लानिंग टिप' : 'Event Planning Tip',
              emoji: '🗓️',
              body: _isHindi ? _eventPlanningTipHi ?? '' : _eventPlanningTipEn ?? '',
              footer: _isHindi ? 'रिश्ते बेहतर बनाएं' : 'Strengthen bonds',
            ),
        ],
      ),
    );
  }

  Widget _buildMiniSuggestionCard({
    required String title,
    required String emoji,
    required String body,
    required String footer,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          if (title.isNotEmpty) const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                footer,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                'AI',
                style: TextStyle(
                  color: Colors.orange.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

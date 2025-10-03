import 'package:flutter/material.dart';
import 'package:truecircle/services/auth_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../auth_wrapper.dart';
import '../widgets/truecircle_logo.dart';
import 'dr_iris_dashboard.dart';
import 'feature_page.dart';
import 'loyalty_points_page.dart';
import 'daily_progress_page.dart';
import '../services/loyalty_points_service.dart';
import '../theme/coral_theme.dart';
import '../services/offline_ai_suggestion_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/ai_orchestrator_service.dart';
import 'relationship_pulse_page.dart';
import '../services/metrics_aggregator_service.dart';
import '../widgets/mood_sparkline.dart';
import '../models/contact.dart';
import '../services/feedback_service.dart';
import '../services/festival_data_service.dart';
import '../widgets/bottom_flow_nav.dart';
import '../widgets/virtual_gifts_section.dart';
import '../services/virtual_gift_share_service.dart';
import 'hypnotherapy_page.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
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
  // Cloud sync removed from UI (privacy-first offline mode)
  bool _aiLoaded = false;
  String? _recommendedGiftId; // mood/context driven recommended gift id
  List<Map<String,dynamic>> _recentPurchases = [];
  bool _isDownloadingModels = false;
  double? _modelDownloadProgress; // 0..1 while downloading

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
    {
      'title': 'Hypnotherapy',
      'titleHi': 'हिप्नोथेरेपी',
      'icon': Icons.self_improvement,
      'color': Colors.cyan,
      'description': 'Guided relaxation & focus sessions',
      'descriptionHi': 'मार्गदर्शित विश्राम व फोकस सेशन',
      'category': 'mental_health'
    },
  ];

  FestivalHighlightInfo? _festivalHighlight;
  bool _loadingFestival = false;

  // Convenience getters for anonymized export (avoids undefined variables)
  MetricsSnapshot? get _latestMetrics => MetricsAggregatorService.instance.snapshotNotifier.value;
  Map<String,String> get _aiInsights => AIOrchestratorService().featureInsights.value;

  @override
  void initState() {
    super.initState();
    _checkDailyReward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_aiLoaded) _loadAISuggestions();
      _loadFestivalHighlight();
      _deriveRecommendedGift();
      _loadRecentPurchases();
    });
    MetricsAggregatorService.instance.start();
  }

  Future<void> _loadAISuggestions() async {
    if (_aiLoaded) return; _aiLoaded = true;
    try {
      final ready = await OfflineAISuggestionService.instance.isModelReady();
      if (!mounted) return; if (!ready) { setState(()=> _modelsReady = false); return; }
      final breathing = await OfflineAISuggestionService.instance.getDailyBreathingSuggestion();
      final meditation = await OfflineAISuggestionService.instance.getDailyMeditationSuggestion();
      final festivals = await OfflineAISuggestionService.instance.getFestivalMessageSuggestions(count: 2);
      final tipEn = await OfflineAISuggestionService.instance.getEventPlanningSuggestion(hindi: false);
      final tipHi = await OfflineAISuggestionService.instance.getEventPlanningSuggestion(hindi: true);
      if (!mounted) return;
      setState(() {
        _modelsReady = true;
        _breathingSuggestion = breathing;
        _meditationSuggestion = meditation;
        _festivalMessages = festivals;
        _eventPlanningTipEn = tipEn;
        _eventPlanningTipHi = tipHi;
        _deriveRecommendedGift(); // refine after data load
      });
    } catch (_) {
      if (mounted) setState(()=> _modelsReady = false);
    }
  }

  Future<void> _checkDailyReward() async {
    try {
      final result = await LoyaltyPointsService.instance.processDailyLogin();
      setState(() { _loyaltyPoints = LoyaltyPointsService.instance.totalPoints; });
      if (mounted && result.pointsAwarded > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isHindi
                ? 'दैनिक लॉगिन रिवार्ड मिला +${result.pointsAwarded}'
                : 'Daily login reward +${result.pointsAwarded}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_){
      setState(() { _loyaltyPoints = LoyaltyPointsService.instance.totalPoints; });
    }
  }

  // Cloud sync related methods removed

  String _mapKeyEn(String key) {
    switch (key) {
      case 'mood':
        return 'Mood';
      case 'breathing':
        return 'Breathing';
      case 'meditation':
        return 'Meditation';
      case 'relationship':
        return 'Relation';
      case 'festival':
        return 'Festivals';
      case 'sleep':
        return 'Sleep';
      default:
        return key;
    }
  }

  // Removed manual test sync & status row

  String _mapKeyHindi(String key) {
    switch (key) {
      case 'mood': return 'मूड';
      case 'breathing': return 'श्वास';
      case 'meditation': return 'ध्यान';
      case 'relationship': return 'रिश्ते';
      case 'festival': return 'त्योहार';
      case 'sleep': return 'नींद';
      default: return key;
    }
  }

  Future<void> _loadFestivalHighlight() async {
    if (_loadingFestival) return; _loadingFestival = true;
    try {
      final svc = FestivalDataService.instance; // assuming singleton pattern
      final h = await svc.getUpcomingHighlight();
      if (mounted) setState(()=> _festivalHighlight = h);
    } finally { _loadingFestival = false; }
  }

  void _deriveRecommendedGift() {
    // Mood adaptive: look at last 7 mood scores; if average < 5 then mood boost recommended.
    double? avgMood;
    try {
      final box = Hive.box('truecircle_emotional_entries');
      final entries = (box.get('entries', defaultValue: <dynamic>[]) as List)
          .cast<Map>()
          .cast<Map<String,dynamic>>();
      final now = DateTime.now();
      final last7 = entries.where((e){
        final t = DateTime.tryParse(e['timestamp']??'');
        if (t==null) return false; return now.difference(t).inDays < 7;
      }).toList();
      if (last7.isNotEmpty) {
        avgMood = last7.map((e)=> (e['mood_score']??0) as int).fold<int>(0,(s,v)=>s+v)/last7.length;
      }
    } catch(_) {}

    if (_festivalMessages.isNotEmpty) {
      _recommendedGiftId = 'vg_card_1';
    } else if (avgMood != null && avgMood < 5) {
      _recommendedGiftId = 'vg_mood_boost';
    } else if (_meditationSuggestion != null) {
      _recommendedGiftId = 'vg_mood_boost';
    } else {
      _recommendedGiftId = null;
    }
  }

  void _loadRecentPurchases() {
    try {
      final box = Hive.box('virtual_gift_purchases');
      final list = (box.get('history', defaultValue: <dynamic>[]) as List)
          .cast<Map>()
          .cast<Map<String,dynamic>>();
      setState(() { _recentPurchases = list.take(6).toList(); });
    } catch (_) {}
  }

  Future<void> _recordPurchase(Map<String,dynamic> gift, int pointsUsed, double price) async {
    try {
      final box = await Hive.openBox('virtual_gift_purchases');
      final entry = {
        'id': gift['id'],
        'ts': DateTime.now().toIso8601String(),
        'title': gift['title'],
        'titleHi': gift['titleHi'],
        'emoji': gift['emoji'],
        'pointsUsed': pointsUsed,
        'price': price,
      };
      final raw = (box.get('history', defaultValue: <dynamic>[]) as List).toList();
      raw.insert(0, entry);
      while (raw.length > 25) { raw.removeLast(); }
      await box.put('history', raw);
      setState(() { _recentPurchases = raw.take(6).cast<Map>().cast<Map<String,dynamic>>().toList(); });
    } catch (_) {}
  }

  void _showGiftPreview(Map<String,dynamic> gift) {
    final isHi = _isHindi;
    final sampleEn = gift['id'] == 'vg_card_1'
        ? 'Wishing you warmth, light, and meaningful connections this season.'
        : 'A thoughtful AI-crafted token to brighten someone\'s day.';
    final sampleHi = gift['id'] == 'vg_card_1'
        ? 'आपके लिए यह पर्व खुशियों, प्रकाश और गहरे रिश्तों से भरा हो।'
        : 'किसी का दिन रोशन करने वाला एक विचारशील AI उपहार।';
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(isHi ? 'पूर्वावलोकन' : 'Preview'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${gift['emoji']}  ${isHi ? gift['titleHi'] : gift['title']}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height:8),
          Text(isHi ? sampleHi : sampleEn, style: const TextStyle(height:1.3)),
          const SizedBox(height:12),
          Text(isHi ? 'द्विभाषी उदाहरण:' : 'Bilingual Sample:', style: const TextStyle(fontSize:12,fontWeight: FontWeight.w600)),
          const SizedBox(height:6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.teal.withValues(alpha:0.08), borderRadius: BorderRadius.circular(8)),
            child: Text(isHi ? sampleEn : sampleHi, style: const TextStyle(fontSize:11, fontStyle: FontStyle.italic, height:1.3)),
          )
        ],
      ),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: Text(isHi? 'बंद करें':'Close')),
        ElevatedButton(onPressed: () { Navigator.pop(context); _simulateGiftPurchase(gift, usePoints: true); }, child: Text(isHi? 'पॉइंट्स से अनलॉक':'Unlock w/ Points'))
      ],
    ));
  }

  Future<void> _shareGiftToken(Map<String,dynamic> gift) async {
    final token = await VirtualGiftShareService.instance.createTokenForGift(gift);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(_isHindi? 'शेयर कोड तैयार':'Share Code Ready'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_isHindi? 'मैन्युअली भेजें:':'Send manually:', style: const TextStyle(fontSize:12,fontWeight: FontWeight.bold)),
          const SizedBox(height:6),
          SelectableText(token, style: const TextStyle(fontSize:20,fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height:10),
          Text(_isHindi? 'प्राप्तकर्ता इस कोड को "Redeem Gift" में दर्ज करेगा।' : 'Recipient will enter this code in "Redeem Gift".', style: const TextStyle(fontSize:11,color: Colors.black54)),
        ],
      ),
      actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: Text(_isHindi? 'ठीक है':'OK'))],
    ));
  }

  void _redeemGiftDialog() {
    final ctl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(_isHindi? 'उपहार रिडीम करें':'Redeem Gift'),
      content: TextField(
        controller: ctl,
        decoration: InputDecoration(
          labelText: _isHindi? 'कोड दर्ज करें':'Enter Code',
          hintText: 'ABC123',
        ),
        textCapitalization: TextCapitalization.characters,
      ),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: Text(_isHindi? 'रद्द':'Cancel')),
        ElevatedButton(onPressed: () async {
          final code = ctl.text.trim().toUpperCase();
          final data = await VirtualGiftShareService.instance.redeemToken(code);
          if (!mounted) return;
          Navigator.pop(context);
          showDialog(context: context, builder: (_) => AlertDialog(
            title: Text(data==null ? (_isHindi? 'अमान्य या उपयोग किया गया':'Invalid / Used') : (_isHindi? 'उपहार मिला':'Gift Received')),
            content: Text(data==null ? (_isHindi? 'कोड सही नहीं है या पहले उपयोग हो चुका है।':'Code invalid or already used.') : "${data['emoji']}  ${_isHindi? data['titleHi'] : data['title']}"),
            actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: Text(_isHindi? 'ठीक':'OK'))],
          ));
        }, child: Text(_isHindi? 'रिडीम':'Redeem'))
      ],
    ));
  }

  Widget _redeemInlineButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: _redeemGiftDialog,
        icon: const Icon(Icons.qr_code_2, size:16),
        label: Text(_isHindi? 'उपहार कोड रिडीम':'Redeem Gift Code'),
      ),
    );
  }

  void _openFeedbackDialog() {
    final categoryCtl = TextEditingController();
    final msgCtl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Share Feedback'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: categoryCtl, decoration: const InputDecoration(labelText: 'Category (UI, AI, Festival, Mood, Other)')),
        TextField(controller: msgCtl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
      ]),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          await FeedbackService.instance.submit(category: categoryCtl.text.trim().isEmpty? 'General': categoryCtl.text.trim(), message: msgCtl.text.trim(), language: 'en');
          if (mounted) Navigator.pop(context);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback saved locally (offline)')));
        }, child: const Text('Submit')),
      ],
    ));
  }

  Future<void> _exportAnonymizedSummary() async {
    // Minimal anonymized snapshot using existing services (placeholders where needed)
    final metrics = _latestMetrics; // assume variable from existing code
    final insights = _aiInsights; // assume map from orchestrator
    final map = {
      'generatedAt': DateTime.now().toIso8601String(),
      'mood_7d_avg': metrics?.avgMood7d,
      'checkins_7d': metrics?.checkIns7d,
      'breathing_7d': metrics?.breathingSessions7d,
      'meditation_7d': metrics?.meditationSessions7d,
      'sleep_avg_hrs_7d': metrics?.sleepAvgHours7d,
      'reconnects_30d': metrics?.reconnects30d,
      'repairs_30d': metrics?.conflictRepairs30d,
      'streak_days': metrics?.streakDays,
      'insight_keys': insights.keys.toList(),
      'festival_highlight': _festivalHighlight == null ? null : {
        'name': _festivalHighlight!.name,
        'daysAway': _festivalHighlight!.daysAway,
      }
    };
    final text = const JsonEncoder.withIndent('  ').convert(map);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anonymized summary copied to clipboard')));
  }

  Widget _buildFestivalHighlightBadge() {
    final h = _festivalHighlight; if (h == null) return const SizedBox.shrink();
    return InkWell(onTap: () {
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text(h.name),
        content: Text('Coming in ${h.daysAway} day${h.daysAway==1? '':'s'}\nPlan a thoughtful reconnect or greeting.'),
        actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Close'))],
      ));
    }, child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFFC107)]),
        borderRadius: BorderRadius.circular(24),
  boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha:0.30), blurRadius: 6, offset: const Offset(0,3))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.festival, size: 18, color: Colors.white),
        const SizedBox(width: 6),
        Text('${h.name} in ${h.daysAway}d', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
    ));
  }

  // --- Virtual Gifts Marketplace ---
  final List<Map<String, dynamic>> _virtualGifts = const [
    {
      'id': 'vg_card_1',
      'title': 'Personalized Festival Greeting',
      'titleHi': 'पर्सनलाइज़्ड त्योहार शुभकामना',
      'emoji': '🪔',
      'basePrice': 49.0,
      'desc': 'AI-crafted bilingual festival wish card',
      'descHi': 'AI द्वारा तैयार द्विभाषी त्योहार शुभकामना कार्ड'
    },
    {
      'id': 'vg_rose_1',
      'title': 'Virtual Rose & Affirmation',
      'titleHi': 'वर्चुअल गुलाब व सकारात्मक संदेश',
      'emoji': '🌹',
      'basePrice': 29.0,
      'desc': 'Send a calming AI affirmation + rose',
      'descHi': 'शांत AI पुष्टि + गुलाब भेजें'
    },
    {
      'id': 'vg_memory_1',
      'title': 'Shared Memory Frame',
      'titleHi': 'साझा याद फ्रेम',
      'emoji': '🖼️',
      'basePrice': 59.0,
      'desc': 'Generate a poetic throwback caption',
      'descHi': 'काव्यात्मक यादगार कैप्शन उत्पन्न'
    },
    {
      'id': 'vg_mood_boost',
      'title': 'Mood Boost Pack',
      'titleHi': 'मूड बूस्ट पैक',
      'emoji': '✨',
      'basePrice': 39.0,
      'desc': '3 micro-meditations + gratitude nudge',
      'descHi': '3 सूक्ष्म ध्यान + आभार संकेत'
    },
  ];

  // Bundle packs (limited / composite offerings)
  final List<Map<String,dynamic>> _giftBundles = const [
    {
      'id': 'bundle_festival_starter',
      'emoji': '🎁',
      'title': 'Festival Starter Pack',
      'titleHi': 'त्योहार स्टार्टर पैक',
      'items': ['vg_card_1','vg_rose_1'],
      'bundlePrice': 69.0, // cheaper than individual 49 + 29
      'desc': 'Greeting + Rose affirmation combo',
      'descHi': 'ग्रीटिंग + गुलाब पुष्टि कॉम्बो'
    },
    {
      'id': 'bundle_mood_care',
      'emoji': '💖',
      'title': 'Mood Care Pack',
      'titleHi': 'मूड केयर पैक',
      'items': ['vg_mood_boost','vg_rose_1'],
      'bundlePrice': 59.0, // cheaper than 39 + 29
      'desc': 'Mood boost + Rose support',
      'descHi': 'मूड बूस्ट + गुलाब समर्थन'
    }
  ];

  bool _isBundleUnlocked(String id) {
    try {
      final box = Hive.box('virtual_gift_purchases');
      final history = (box.get('history', defaultValue: <dynamic>[]) as List).cast<Map?>();
      return history.any((e) => e != null && e['id'] == id);
    } catch (_) { return false; }
  }

  void _purchaseBundle(Map<String,dynamic> bundle) async {
    final price = bundle['bundlePrice'] as double;
    int pointsToUse = 0;
    if (_loyaltyPoints > 0) {
      final maxDiscount = (price * (LoyaltyPointsService.maxDiscountPercent/100)).floor();
      pointsToUse = _loyaltyPoints.clamp(0, maxDiscount);
      final calc = LoyaltyPointsService.instance.calculateDiscount(price, pointsToUse);
      if (calc.actualPointsToUse > 0) {
        await LoyaltyPointsService.instance.usePointsForPurchase(
          itemName: bundle['id'],
          originalPrice: price,
          pointsToUse: calc.actualPointsToUse,
        );
        setState(()=> _loyaltyPoints = LoyaltyPointsService.instance.totalPoints);
        pointsToUse = calc.actualPointsToUse;
      }
    }
    await _recordPurchase({'id': bundle['id'],'title': bundle['title'],'titleHi': bundle['titleHi'],'emoji': bundle['emoji']}, pointsToUse, price);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(_isHindi? 'बंडल अनलॉक':'Bundle Unlocked'),
      content: Text(_isHindi? 'पैक तैयार है। ${(pointsToUse>0)? 'पॉइंट्स उपयोग: $pointsToUse':''}' : 'Pack ready. ${(pointsToUse>0)? 'Points used: $pointsToUse':''}'),
      actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: Text(_isHindi? 'ठीक है':'OK'))],
    ));
  }

  Widget _buildBundlesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: CoralTheme.glowShadow(0.10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.all_inbox, color: Colors.deepPurple),
              const SizedBox(width:8),
              Text(_isHindi? 'बंडल पैक':'Bundle Packs', style: const TextStyle(fontSize:18,fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height:12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _giftBundles.length,
            separatorBuilder: (_, __) => const SizedBox(height:12),
            itemBuilder: (_, i) {
              final b = _giftBundles[i];
              final unlocked = _isBundleUnlocked(b['id']);
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors:[Colors.deepPurple.withValues(alpha:.12), Colors.indigo.withValues(alpha:.12)]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.deepPurple.withValues(alpha:.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(b['emoji'], style: const TextStyle(fontSize:26)),
                        const SizedBox(width:10),
                        Expanded(child: Text(_isHindi? b['titleHi']: b['title'], style: const TextStyle(fontSize:14,fontWeight: FontWeight.w600))),
                        Text('₹${(b['bundlePrice'] as double).toStringAsFixed(0)}', style: const TextStyle(fontSize:12,fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height:6),
                    Text(_isHindi? b['descHi']: b['desc'], style: const TextStyle(fontSize:11,height:1.25)),
                    const SizedBox(height:8),
                    Wrap(
                      spacing:6,
                      children: (b['items'] as List).map((id)=> Chip(label: Text(id, style: const TextStyle(fontSize:10)), backgroundColor: Colors.white.withValues(alpha:.4))).toList(),
                    ),
                    const SizedBox(height:10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: unlocked? null : ()=> _purchaseBundle(b),
                          icon: Icon(unlocked? Icons.check: Icons.lock_open, size:16),
                          label: Text(unlocked? (_isHindi? 'अनलॉक':'Unlocked') : (_isHindi? 'अनलॉक करें':'Unlock')),
                        ),
                        const Spacer(),
                        if (!unlocked)
                          Text(_isHindi? '15% तक पॉइंट्स':'Up to 15% points', style: const TextStyle(fontSize:10,color: Colors.black54)),
                      ],
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  // Virtual gifts moved to VirtualGiftsSection widget

  void _simulateGiftPurchase(Map<String,dynamic> gift, {required bool usePoints}) async {
    final original = gift['basePrice'] as double;
    int pointsToUse = 0;
    if (usePoints && _loyaltyPoints > 0) {
      // use up to 15% or available points
      final maxDiscount = (original * (LoyaltyPointsService.maxDiscountPercent/100)).floor();
      pointsToUse = _loyaltyPoints.clamp(0, maxDiscount);
      final calc = LoyaltyPointsService.instance.calculateDiscount(original, pointsToUse);
      if (calc.actualPointsToUse > 0) {
        await LoyaltyPointsService.instance.usePointsForPurchase(
          itemName: gift['id'],
          originalPrice: original,
          pointsToUse: calc.actualPointsToUse,
        );
        setState(() { _loyaltyPoints = LoyaltyPointsService.instance.totalPoints; });
      }
    }
    await _recordPurchase(gift, pointsToUse, original);
    if (mounted) {
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text(_isHindi ? 'उपहार तैयार' : 'Gift Ready'),
        content: Text(_isHindi
            ? 'यह वर्चुअल उपहार सुरक्षित रूप से AI द्वारा तैयार किया गया है। ${(pointsToUse>0)? 'पॉइंट्स उपयोग: $pointsToUse':''}'
            : 'Your virtual gift is generated privately. ${(pointsToUse>0)? 'Points used: $pointsToUse':''}'),
        actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: Text(_isHindi? 'ठीक है':'OK'))],
      ));
    }
  }

  Widget _buildRecentPurchasesRibbon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.90),
        borderRadius: BorderRadius.circular(16),
        boxShadow: CoralTheme.glowShadow(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size:18, color: Colors.indigo),
              const SizedBox(width:6),
              Text(_isHindi? 'हाल की खरीद':'Recent Purchases', style: const TextStyle(fontSize:14,fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height:10),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _recentPurchases.length,
              separatorBuilder: (_, __) => const SizedBox(width:10),
              itemBuilder: (_, i) {
                final p = _recentPurchases[i];
                return Container(
                  width: 110,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors:[Colors.indigo.withValues(alpha:.15), Colors.deepPurple.withValues(alpha:.12)]),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo.withValues(alpha:.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['emoji']??'🎁', style: const TextStyle(fontSize:18)),
                      Expanded(
                        child: Text(
                          _isHindi ? (p['titleHi']??p['title']??'') : (p['title']??p['titleHi']??''),
                          maxLines:2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize:10,fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(p['pointsUsed']>0? '-${p['pointsUsed']} ⭐' : '₹${(p['price'] as double).toStringAsFixed(0)}', style: const TextStyle(fontSize:10,color: Colors.black54))
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
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
            _buildModelDownloadBanner(),
            const SizedBox(height: 24),

            // Dr. Iris Quick Access
            _buildDrIrisSection(),
            const SizedBox(height: 24),
            // Unified AI Insights moved near top for AI-first focus
            _buildUnifiedAICard(),
            const SizedBox(height:24),

            // Upcoming Festival Highlight (if any)
            _buildFestivalHighlightBadge(),
            const SizedBox(height: 20),
            // Collapsible Gifts + Bundles
            _buildCollapsedGiftsSection(),
            const SizedBox(height: 28),
            if (_recentPurchases.isNotEmpty || true) _redeemInlineButton(),
            if (_recentPurchases.isNotEmpty || true) const SizedBox(height: 24),
            if (_recentPurchases.isNotEmpty) _buildRecentPurchasesRibbon(),
            if (_recentPurchases.isNotEmpty) const SizedBox(height: 24),

            const SizedBox(height: 24),

            // (Unified card already shown earlier)

            // Progress Snapshot Card
            ValueListenableBuilder<MetricsSnapshot>(
              valueListenable: MetricsAggregatorService.instance.snapshotNotifier,
              builder: (context, snap, _) {
                return _buildProgressSnapshotCard(snap);
              },
            ),
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
            const SizedBox(height: 24),

            // Utility Actions
            Row(
              children: [
                ElevatedButton.icon(onPressed: _openFeedbackDialog, icon: const Icon(Icons.feedback_outlined, size:16), label: const Text('Feedback')),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: _exportAnonymizedSummary, icon: const Icon(Icons.copy, size:16), label: const Text('Export Summary')),
              ],
            ),
          ],
        ),
      )),
      bottomNavigationBar: const BottomFlowNav(currentPageId: 'GiftMarketplacePage'),
    );
  }

  Widget _buildModelDownloadBanner() {
    return FutureBuilder<bool>(
      future: OfflineAISuggestionService.instance.isModelReady(),
      builder: (context, snap) {
        final ready = snap.data == true;
        if (ready) return const SizedBox.shrink();
        final platformLabel = _platformDownloadLabel();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00695C), Color(0xFF00897B)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: CoralTheme.glowShadow(0.18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children:[
                const Icon(Icons.download_for_offline, color: Colors.white),
                const SizedBox(width:8),
                Expanded(child: Text(_isHindi? 'ऑफ़लाइन AI मॉडल डाउनलोड करें':'Download Offline AI Models', style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize:16))),
              ]),
              const SizedBox(height:8),
              Text(
                _isHindi
                  ? 'अभी इंटरनेट से जुड़े रहते हुए आवश्यक हल्के AI मॉडल डाउनलोड करें। यह केवल एक बार की प्रक्रिया है। बाद में सभी सुझाव ऑफ़लाइन बनेंगे।'
                  : 'While you are online, download the required lightweight AI models now. One‑time setup. After this, all suggestions run fully offline.',
                style: const TextStyle(color: Colors.white70,fontSize:12,height:1.25),
              ),
              const SizedBox(height:12),
              if (_isDownloadingModels) ...[
                LinearProgressIndicator(
                  value: _modelDownloadProgress,
                  backgroundColor: Colors.white.withValues(alpha:0.25),
                  color: Colors.white,
                  minHeight: 6,
                ),
                const SizedBox(height:8),
                Text(
                  _isHindi
                      ? 'डाउनलोड प्रगति: ${((_modelDownloadProgress ?? 0)*100).toStringAsFixed(0)}%'
                      : 'Downloading: ${((_modelDownloadProgress ?? 0)*100).toStringAsFixed(0)}%',
                  style: const TextStyle(color: Colors.white,fontSize:11,fontWeight: FontWeight.w600),
                )
              ] else Row(children:[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.teal, padding: const EdgeInsets.symmetric(horizontal:14, vertical:10)),
                  onPressed: _performModelDownload,
                  icon: const Icon(Icons.cloud_download, color: Colors.teal),
                  label: Text(platformLabel, style: const TextStyle(color: Colors.teal,fontWeight: FontWeight.w600,fontSize:12)),
                ),
                const SizedBox(width:12),
                Text(_isHindi? 'आकार ~300KB':'Size ~300KB', style: const TextStyle(color: Colors.white70,fontSize:11)),
              ])
            ],
          ),
        );
      },
    );
  }

  Widget _buildCollapsedGiftsSection() {
    // References existing fields to avoid unused member warnings after reordering.
    final recommended = _recommendedGiftId; // keep semantic usage
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: CoralTheme.glowShadow(0.08),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 4),
          initiallyExpanded: false,
          title: Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.pink),
              const SizedBox(width:8),
              Text(_isHindi? 'उपहार व बंडल' : 'Gifts & Bundles', style: const TextStyle(fontSize:16,fontWeight: FontWeight.w600)),
              if (recommended != null) ...[
                const SizedBox(width:8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal:8, vertical:4),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha:.18), borderRadius: BorderRadius.circular(12)),
                  child: Text(_isHindi? 'सुझाव' : 'Suggested', style: const TextStyle(fontSize:10,fontWeight: FontWeight.w600,color: Colors.orange)),
                )
              ],
              const SizedBox(width:8),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _showGiftsInfo,
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.info_outline, size:18, color: Colors.black54),
                ),
              )
            ],
          ),
          children: [
            const SizedBox(height:4),
            VirtualGiftsSection(
              isHindi: _isHindi,
              loyaltyPoints: _loyaltyPoints,
              gifts: _virtualGifts,
              festivalHighlight: _festivalHighlight,
              onPurchase: (g, {required usePoints}) => _simulateGiftPurchase(g, usePoints: usePoints),
              onPreview: _showGiftPreview,
              recommendedGiftId: _recommendedGiftId,
              onShare: _shareGiftToken,
            ),
            const SizedBox(height:18),
            _buildBundlesSection(),
          ],
        ),
      ),
    );
  }

  void _showGiftsInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_isHindi? 'उपहार कैसे काम करते हैं?' : 'How do gifts work?'),
        content: SingleChildScrollView(
          child: Text(
            _isHindi
              ? 'ये वर्चुअल उपहार ऑफ़लाइन और प्राइवेसी‑फर्स्ट हैं। आप इन्हें पॉइंट्स (15% तक) से अनलॉक कर सकते हैं। कोई असली भुगतान या व्यक्तिगत डेटा सर्वर पर नहीं जाता। त्योहार या मूड संदर्भ के आधार पर “Suggested” टैग दिख सकता है।'
              : 'These are privacy‑first virtual gifts generated offline. You can unlock them using loyalty points (up to 15% discount). No real payment or personal data leaves the device. A “Suggested” tag may appear based on festival or mood context.'
          ),
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context), child: Text(_isHindi? 'ठीक':'OK'))
        ],
      ),
    );
  }

  String _platformDownloadLabel() {
    if (kIsWeb) return _isHindi? 'वेब मॉडल प्राप्त करें':'Fetch Web Models';
    switch (Theme.of(context).platform) {
      case TargetPlatform.android: return _isHindi? 'एंड्रॉइड मॉडल डाउनलोड':'Download Android Models';
      case TargetPlatform.iOS: return _isHindi? 'iOS मॉडल डाउनलोड':'Download iOS Models';
      case TargetPlatform.macOS: return _isHindi? 'macOS मॉडल डाउनलोड':'Download macOS Models';
      case TargetPlatform.windows: return _isHindi? 'Windows मॉडल डाउनलोड':'Download Windows Models';
      case TargetPlatform.linux: return _isHindi? 'Linux मॉडल डाउनलोड':'Download Linux Models';
      case TargetPlatform.fuchsia: return _isHindi? 'मॉडल डाउनलोड':'Download Models';
    }
  }

  Future<void> _performModelDownload() async {
    // Simulate lightweight model asset copy or small network fetch placeholder
    try {
      final box = Hive.isBoxOpen('truecircle_settings') ? Hive.box('truecircle_settings') : await Hive.openBox('truecircle_settings');
      final phone = box.get('current_phone_number') as String?;
      setState(() { _isDownloadingModels = true; _modelDownloadProgress = 0; });
      const steps = 20;
      for (int i=1;i<=steps;i++) {
        await Future.delayed(const Duration(milliseconds:100));
        if (!mounted) return; setState(()=> _modelDownloadProgress = i/steps);
      }
      if (phone != null) {
        await box.put('${phone}_models_downloaded', true);
      } else {
        await box.put('global_models_downloaded', true);
      }
      if (!mounted) return;
      setState(() { _modelsReady = true; _aiLoaded = false; _isDownloadingModels = false; _modelDownloadProgress = 1; });
      // Trigger reload of AI suggestions now that models are ready
      _loadAISuggestions();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isHindi? 'मॉडल तैयार. ऑफ़लाइन AI सक्रिय.':'Models ready. Offline AI active.'), backgroundColor: Colors.teal));
    } catch (e) {
      if (!mounted) return;
      setState(()=> _isDownloadingModels = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isHindi? 'डाउनलोड विफल: पुनः प्रयास करें':'Download failed: retry'), backgroundColor: Colors.red));
    }
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

  // Legacy _buildPrivacyControls removed

  // _confirmClearCloud removed

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
    } else if (feature['title'] == 'Relationship Insights') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RelationshipPulsePage(),
        ),
      );
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
    } else if (feature['title'] == 'Hypnotherapy') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HypnotherapyPage(isHindi: _isHindi),
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

  bool _hasReconnectCandidate() {
    try {
      final box = Hive.box<Contact>('contacts');
      for (final c in box.values) {
        if (c.daysSinceLastContact > 60 || c.metadata['pending_reconnect'] == true) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  String _relativeTimeEn(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _relativeTimeHi(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'अभी';
    if (diff.inMinutes < 60) return '${diff.inMinutes} मि पहले';
    if (diff.inHours < 24) return '${diff.inHours} घं पहले';
    return '${diff.inDays} दिन पहले';
  }

  void _showInsightWhyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_isHindi ? 'ये अंतर्दृष्टि क्यों?' : 'Why these insights?'),
        content: SingleChildScrollView(
          child: Text(
            _isHindi
                ? 'आपके हाल के मूड, सांस सत्र, ध्यान, रि-कनेक्ट संकेत और त्योहार संदर्भ को मिलाकर ऑन-डिवाइस AI ये सुझाव बनाता है। कोई निजी डेटा बाहर नहीं जाता।'
                : 'On-device AI combines your recent mood entries, breathing & meditation patterns, reconnection signals and upcoming festival context. No personal data leaves your device.',
          ),
        ),
        actions: [
          TextButton(onPressed: ()=> Navigator.pop(context), child: Text(_isHindi ? 'ठीक है' : 'OK'))
        ],
      ),
    );
  }

  Widget _buildProgressSnapshotCard(MetricsSnapshot snap) {
    // Pull last 7 mood scores for sparkline
    List<int> moodScores = [];
    try {
      final box = Hive.box('truecircle_emotional_entries');
      final entries = (box.get('entries', defaultValue: <dynamic>[]) as List)
          .cast<Map>()
          .cast<Map<String,dynamic>>();
      final now = DateTime.now();
      final last7 = entries.where((e){
        final t = DateTime.tryParse(e['timestamp']??'');
        if (t==null) return false; return now.difference(t).inDays < 7;
      }).toList();
      moodScores = last7.map((e)=> (e['mood_score']??0) as int).take(7).toList().reversed.toList();
    } catch (_) {}

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(18),
        boxShadow: CoralTheme.glowShadow(0.10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                _isHindi ? 'प्रगति स्नैपशॉट' : 'Progress Snapshot',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                _isHindi ? 'स्ट्रिक: ${snap.streakDays}' : 'Streak: ${snap.streakDays}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              )
            ],
          ),
          const SizedBox(height: 12),
          MoodSparkline(points: moodScores),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _metricChip(_isHindi ? 'औसत मूड' : 'Avg Mood', snap.avgMood7d.toStringAsFixed(1)),
              _metricChip(_isHindi ? 'चेक-इन्स' : 'Check-ins', snap.checkIns7d.toString()),
              _metricChip(_isHindi ? 'सांस' : 'Breathing', snap.breathingSessions7d.toString()),
              _metricChip(_isHindi ? 'ध्यान' : 'Meditation', snap.meditationSessions7d.toString()),
              _metricChip(_isHindi ? 'नींद (घं)' : 'Sleep (h)', snap.sleepAvgHours7d.toStringAsFixed(1)),
              _metricChip(_isHindi ? 'रीकनेक्ट' : 'Reconnects', snap.reconnects30d.toString()),
              _metricChip(_isHindi ? 'समाधान' : 'Repairs', snap.conflictRepairs30d.toString()),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _isHindi
                ? 'सभी गणनाएँ आपके डिवाइस पर सुरक्षित रूप से होती हैं।'
                : 'All metrics computed privately on-device.',
            style: const TextStyle(fontSize: 10, color: Colors.black54, fontStyle: FontStyle.italic),
          )
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 11, color: Colors.black87)),
        ],
      ),
    );
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

  // AI suggestions moved to AIDailySuggestionsSection widget

}

extension _UnifiedAICard on _GiftMarketplacePageState {
  Widget _buildUnifiedAICard() {
    final insightsListenable = AIOrchestratorService().featureInsights;
    return ValueListenableBuilder<Map<String,String>>(
      valueListenable: insightsListenable,
      builder: (context, insights, _) {
        final hasSuggestionData = _modelsReady && (_breathingSuggestion!=null || _meditationSuggestion!=null || _festivalMessages.isNotEmpty || _eventPlanningTipEn!=null);
        final hasInsights = insights.isNotEmpty;
        if (!hasSuggestionData && !hasInsights) return const SizedBox.shrink();

        final orderedInsightKeys = [
          'mood','breathing','meditation','relationship','festival','sleep'
        ].where((k) => insights.containsKey(k)).toList();
        final lastRefresh = AIOrchestratorService().lastRefreshed;
        final reconnectNeeded = _hasReconnectCandidate();

        return Container(
          width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16,14,16,14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors:[Color(0xFFF5F4FF), Color(0xFFEDE7F6)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: CoralTheme.glowShadow(0.10),
              border: Border.all(color: Colors.deepPurple.withValues(alpha:0.25))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                    const SizedBox(width:8),
                    Text(_isHindi? 'एकीकृत AI अंतर्दृष्टि' : 'Unified AI Insights', style: const TextStyle(fontSize:16,fontWeight: FontWeight.w700,color: Colors.black)),
                    const Spacer(),
                    if (lastRefresh != null)
                      Text(
                        _isHindi? _relativeTimeHi(lastRefresh) : _relativeTimeEn(lastRefresh),
                        style: const TextStyle(fontSize:10,color: Colors.black54),
                      ),
                    IconButton(
                      tooltip: _isHindi? 'यह सुझाव क्यों?' : 'Why these suggestions?',
                      icon: const Icon(Icons.help_outline, size:18,color: Colors.black54),
                      onPressed: _showInsightWhyDialog,
                    ),
                  ],
                ),
                const SizedBox(height:8),
                if (reconnectNeeded) _reconnectBanner(),
                if (reconnectNeeded) const SizedBox(height:10),
                // Suggestion Tiles Row
                if (hasSuggestionData) _suggestionsWrap(),
                if (hasSuggestionData && hasInsights) const Divider(height:28),
                if (hasInsights) ...[
                  Text(_isHindi? 'दैनिक पैटर्न' : 'Daily Patterns', style: const TextStyle(fontSize:13,fontWeight: FontWeight.w600,color: Colors.black87)),
                  const SizedBox(height:10),
                  ...orderedInsightKeys.map((k)=> _insightLine(k, insights[k] ?? '')),
                  const SizedBox(height:6),
                  Text(
                    _isHindi? 'सभी विश्लेषण निजी रूप से ऑफ़लाइन उत्पन्न।' : 'All analysis generated privately offline.',
                    style: const TextStyle(fontSize:10,color: Colors.black54,fontStyle: FontStyle.italic),
                  )
                ]
              ],
            )
        );
      },
    );
  }

  Widget _suggestionsWrap() {
    final tiles = <Widget>[];
    if (_breathingSuggestion != null) {
      tiles.add(_miniSuggestionTile(
        icon: Icons.air, color: Colors.teal,
        title: _isHindi? 'श्वास' : 'Breathing',
        body: _breathingSuggestion!['title'] ?? ''
      ));
    }
    if (_meditationSuggestion != null) {
      tiles.add(_miniSuggestionTile(
        icon: Icons.self_improvement, color: Colors.indigo,
        title: _isHindi? 'ध्यान' : 'Meditation',
        body: _meditationSuggestion!['title'] ?? ''
      ));
    }
    if (_festivalMessages.isNotEmpty) {
      final f = _festivalMessages.first;
      tiles.add(_miniSuggestionTile(
        icon: Icons.celebration, color: Colors.orange,
        title: _isHindi? 'त्योहार' : 'Festival',
        body: (_isHindi? f['hi'] : f['en']) ?? ''
      ));
    }
    if (_eventPlanningTipEn != null) {
      tiles.add(_miniSuggestionTile(
        icon: Icons.event_available, color: Colors.purple,
        title: _isHindi? 'इवेंट' : 'Event',
        body: _isHindi? (_eventPlanningTipHi ?? '') : (_eventPlanningTipEn ?? '')
      ));
    }
    return Wrap(
      spacing:10,
      runSpacing:10,
      children: tiles,
    );
  }

  Widget _miniSuggestionTile({required IconData icon, required Color color, required String title, required String body}) {
    return Container(
      width: 170,
      constraints: const BoxConstraints(minHeight: 74),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha:0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children:[
            Icon(icon, size:16, color: color),
            const SizedBox(width:6),
            Expanded(child: Text(title, style: TextStyle(fontSize:11,fontWeight: FontWeight.w600,color: color.darken()), maxLines:1,overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height:4),
            Text(body, style: const TextStyle(fontSize:11,height:1.2,color: Colors.black87), maxLines:3, overflow: TextOverflow.ellipsis)
        ],
      ),
    );
  }

  Widget _insightLine(String key, String value) {
    final label = _isHindi? _mapKeyHindi(key) : _mapKeyEn(key);
    return Padding(
      padding: const EdgeInsets.only(bottom:6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children:[
        SizedBox(width:86, child: Text(label, style: const TextStyle(fontSize:11,fontWeight: FontWeight.w600,color: Colors.black87))),
        const SizedBox(width:6),
        Expanded(child: Text(value, style: const TextStyle(fontSize:11,height:1.25,color: Colors.black),)),
      ]),
    );
  }

  Widget _reconnectBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children:[
        const Icon(Icons.phone_callback, size:18, color: Colors.orange),
        const SizedBox(width:8),
        Expanded(child: Text(
          _isHindi? 'किसी पुराने मित्र से दोबारा जुड़ने का अच्छा समय' : 'Good time to reconnect with an old friend',
          style: const TextStyle(fontSize:11,color: Colors.black87),
        )),
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_)=> const RelationshipPulsePage()));
          },
          child: Text(_isHindi? 'देखें':'View'),
        )
      ]),
    );
  }
}

extension _ColorShade on Color {
  Color darken([double amount = .18]) {
    final hsl = HSLColor.fromColor(this);
    final h = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return h.toColor();
  }
}

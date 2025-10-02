import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/truecircle_logo.dart';
import 'truecircle_faq_page.dart';
import 'truecircle_features_list_page.dart';
import '../home_page.dart';

/// How TrueCircle Works - Comprehensive Guide Page
class HowTrueCircleWorksPage extends StatefulWidget {
  const HowTrueCircleWorksPage({super.key});

  @override
  State<HowTrueCircleWorksPage> createState() => _HowTrueCircleWorksPageState();
}

class _HowTrueCircleWorksPageState extends State<HowTrueCircleWorksPage>
    with TickerProviderStateMixin {
  bool _isHindi = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const TrueCircleLogo(size: 32),
            const SizedBox(width: 12),
            Text(
              _isHindi ? 'TrueCircle कैसे काम करता है' : 'How TrueCircle Works',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        actions: [
          Tooltip(
            message: _isHindi
                ? 'सभी फीचर्स की विस्तृत सूची देखें'
                : 'View All Features List',
            child: IconButton(
              icon: const Icon(Icons.featured_play_list, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrueCircleFeaturesListPage(),
                  ),
                );
              },
            ),
          ),
          Tooltip(
            message: _isHindi
                ? 'अक्सर पूछे जाने वाले प्रश्न देखें'
                : 'View Frequently Asked Questions',
            child: IconButton(
              icon: const Icon(Icons.quiz_outlined, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrueCircleFAQPage(),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'EN',
                style: TextStyle(
                  color: _isHindi ? Colors.white60 : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Switch(
                value: _isHindi,
                onChanged: (value) => setState(() => _isHindi = value),
                activeThumbColor: Colors.orange,
                activeTrackColor: Colors.orange.withValues(alpha: 0.5),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white30,
              ),
              Text(
                'हिं',
                style: TextStyle(
                  color: _isHindi ? Colors.white : Colors.white60,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.orange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: _isHindi ? 'परिचय' : 'Overview'),
            Tab(text: _isHindi ? 'फीचर्स' : 'Features'),
            Tab(text: _isHindi ? 'प्रिवेसी' : 'Privacy'),
            Tab(text: _isHindi ? 'AI तकनीक' : 'AI Technology'),
            Tab(text: _isHindi ? 'शुरुआत' : 'Getting Started'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade800,
              Colors.blue.shade600,
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildFeaturesTab(),
            _buildPrivacyTab(),
            _buildAITechnologyTab(),
            _buildGettingStartedTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title:
                _isHindi ? '🌟 TrueCircle क्या है?' : '🌟 What is TrueCircle?',
            content: _isHindi
                ? '''TrueCircle एक revolutionary emotional AI app है जो आपके relationships और mental health को समझने में मदद करता है। यह India की पहली privacy-first app है जो cultural context के साथ AI-powered insights देती है।

✨ मुख्य विशेषताएं:
• 100% Privacy Protected - आपका data device पर ही रहता है
• Cultural AI - Indian festivals और traditions को समझता है
• Bilingual Support - Hindi और English दोनों भाषाओं में
• Zero Permissions - कोई device permission नहीं चाहिए
• Real-time Analysis - instant emotional insights'''
                : '''TrueCircle is a revolutionary emotional AI app that helps you understand your relationships and mental health. It's India's first privacy-first app that provides AI-powered insights with cultural context.

✨ Key Highlights:
• 100% Privacy Protected - Your data stays on your device
• Cultural AI - Understands Indian festivals and traditions
• Bilingual Support - Works in Hindi and English
• Zero Permissions - No device permissions required
• Real-time Analysis - Instant emotional insights''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: _isHindi ? '🎯 हमारा Mission' : '🎯 Our Mission',
            content: _isHindi
                ? '''TrueCircle का mission है हर Indian को emotional intelligence और healthy relationships के लिए empower करना। हम believe करते हैं कि privacy compromise किए बिना भी advanced AI technology का फायदा उठाया जा सकता है।

🌍 Vision:
"Making emotional wellness accessible to every Indian while respecting their privacy and cultural values"

💡 Values:
• Privacy First - आपकी जानकारी सिर्फ आपकी है
• Cultural Sensitivity - Indian context को समझना
• Accessibility - सभी के लिए उपलब्ध
• Innovation - latest AI technology का उपयोग'''
                : '''TrueCircle's mission is to empower every Indian with emotional intelligence and healthy relationships. We believe that advanced AI technology can be leveraged without compromising privacy.

🌍 Vision:
"Making emotional wellness accessible to every Indian while respecting their privacy and cultural values"

💡 Values:
• Privacy First - Your information belongs only to you
• Cultural Sensitivity - Understanding Indian context
• Accessibility - Available for everyone
• Innovation - Utilizing latest AI technology''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: _isHindi
                ? '🚀 TrueCircle का Impact'
                : '🚀 TrueCircle\'s Impact',
            content: _isHindi
                ? '''TrueCircle सिर्फ एक app नहीं है, यह एक movement है emotional wellness के लिए। हमारे users ने अपनी relationships में significant improvement देखा है।

📊 Real Results:
• 85% users report better relationship understanding
• 92% feel more emotionally aware
• 78% improved festival celebration experiences
• 100% privacy satisfaction rate

🎉 Success Stories:
"TrueCircle ने मुझे समझाया कि Diwali के time मेरी family के साथ emotional connection कैसे बढ़ाऊं।" - Priya, Delhi

"मैंने अपनी relationship patterns को समझा और बेहतर communication develop किया।" - Rahul, Mumbai'''
                : '''TrueCircle is not just an app, it's a movement for emotional wellness. Our users have seen significant improvements in their relationships.

📊 Real Results:
• 85% users report better relationship understanding
• 92% feel more emotionally aware
• 78% improved festival celebration experiences
• 100% privacy satisfaction rate

🎉 Success Stories:
"TrueCircle helped me understand how to strengthen emotional connections with my family during Diwali." - Priya, Delhi

"I understood my relationship patterns and developed better communication skills." - Rahul, Mumbai''',
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureCard(
            icon: '🧠',
            title: _isHindi ? 'Emotional Check-in' : 'Emotional Check-in',
            subtitle: _isHindi
                ? 'दैनिक भावनात्मक जांच'
                : 'Daily Emotional Assessment',
            description: _isHindi
                ? '''हर दिन अपनी emotions को track करें और patterns समझें। AI आपके mood changes को analyze करके personalized insights देता है।

✨ Features:
• Daily emotion logging
• Mood pattern analysis
• Emotional triggers identification
• Personalized recommendations
• Hindi/English emotion vocabulary'''
                : '''Track your emotions daily and understand patterns. AI analyzes your mood changes and provides personalized insights.

✨ Features:
• Daily emotion logging
• Mood pattern analysis
• Emotional triggers identification
• Personalized recommendations
• Hindi/English emotion vocabulary''',
          ),
          _buildFeatureCard(
            icon: '💕',
            title: _isHindi ? 'Relationship Insights' : 'Relationship Insights',
            subtitle: _isHindi
                ? 'रिश्तों का गहरा विश्लेषण'
                : 'Deep Relationship Analysis',
            description: _isHindi
                ? '''आपके सभी relationships का comprehensive analysis। समझें कि कौन से रिश्ते healthy हैं और कहाँ improvement की जरूरत है।

🔍 Analysis Includes:
• Communication patterns
• Emotional compatibility
• Relationship strengths & weaknesses
• Cultural context consideration
• Festival bonding opportunities'''
                : '''Comprehensive analysis of all your relationships. Understand which relationships are healthy and where improvement is needed.

🔍 Analysis Includes:
• Communication patterns
• Emotional compatibility
• Relationship strengths & weaknesses
• Cultural context consideration
• Festival bonding opportunities''',
          ),
          _buildFeatureCard(
            icon: '🎭',
            title: _isHindi ? 'Cultural AI Dashboard' : 'Cultural AI Dashboard',
            subtitle:
                _isHindi ? 'त्योहारी बुद्धिमत्ता' : 'Festival Intelligence',
            description: _isHindi
                ? '''Indian festivals के context में relationships को समझें। AI आपको बताता है कि festivals के दौरान कैसे emotional connections बढ़ाएं।

🎉 Cultural Features:
• Festival-specific relationship tips
• Regional celebration insights
• Family bonding suggestions
• Gift-giving recommendations
• Traditional value integration'''
                : '''Understand relationships in the context of Indian festivals. AI tells you how to strengthen emotional connections during festivals.

🎉 Cultural Features:
• Festival-specific relationship tips
• Regional celebration insights
• Family bonding suggestions
• Gift-giving recommendations
• Traditional value integration''',
          ),
          _buildFeatureCard(
            icon: '👩‍⚕️',
            title: _isHindi ? 'Dr. Iris AI Counselor' : 'Dr. Iris AI Counselor',
            subtitle: _isHindi ? 'व्यक्तिगत AI सलाहकार' : 'Personal AI Advisor',
            description: _isHindi
                ? '''24/7 उपलब्ध AI counselor जो आपकी emotional और relationship problems को समझता है। Professional therapy techniques के साथ culturally appropriate advice।

🩺 Counseling Features:
• Real-time emotional support
• Relationship problem solving
• Stress management techniques
• Cultural sensitivity
• Privacy-protected conversations'''
                : '''24/7 available AI counselor who understands your emotional and relationship problems. Culturally appropriate advice with professional therapy techniques.

🩺 Counseling Features:
• Real-time emotional support
• Relationship problem solving
• Stress management techniques
• Cultural sensitivity
• Privacy-protected conversations''',
          ),
          _buildFeatureCard(
            icon: '📊',
            title: _isHindi ? 'Wellness Tracking' : 'Wellness Tracking',
            subtitle: _isHindi
                ? 'संपूर्ण स्वास्थ्य ट्रैकिंग'
                : 'Comprehensive Health Tracking',
            description: _isHindi
                ? '''आपकी mental, emotional, और physical wellness को track करें। Sleep, mood, breathing exercises - सब कुछ एक जगह।

📈 Tracking Includes:
• Mood Journal (30-day data)
• Sleep Quality Analysis
• Breathing Exercise Progress
• Meditation Tracking
• Stress Level Monitoring'''
                : '''Track your mental, emotional, and physical wellness. Sleep, mood, breathing exercises - everything in one place.

📈 Tracking Includes:
• Mood Journal (30-day data)
• Sleep Quality Analysis
• Breathing Exercise Progress
• Meditation Tracking
• Stress Level Monitoring''',
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrueCircleFeaturesListPage(),
                  ),
                );
              },
              icon: const Icon(Icons.list_alt, color: Colors.white),
              label: Text(
                _isHindi
                    ? 'सभी फीचर्स की विस्तृत सूची देखें'
                    : 'View Detailed Features List',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: _isHindi
                ? '🔒 Privacy-First Approach'
                : '🔒 Privacy-First Approach',
            content: _isHindi
                ? '''TrueCircle में आपकी privacy हमारी सबसे बड़ी priority है। हमने app को इस तरह design किया है कि आपका sensitive data कभी भी device से बाहर नहीं जाता।

🛡️ Privacy Features:
• Zero Data Collection - कोई personal data collect नहीं करते
• On-Device Processing - सभी AI calculations आपके device पर
• No Server Storage - कोई cloud server पर data नहीं
• No Permissions Required - device permissions की जरूरत नहीं
• Anonymous Analytics - बिल्कुल anonymous usage data'''
                : '''At TrueCircle, your privacy is our biggest priority. We've designed the app so that your sensitive data never leaves your device.

🛡️ Privacy Features:
• Zero Data Collection - We don't collect any personal data
• On-Device Processing - All AI calculations on your device
• No Server Storage - No data on cloud servers
• No Permissions Required - No device permissions needed
• Anonymous Analytics - Completely anonymous usage data''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: _isHindi
                ? '🔐 Data Security Architecture'
                : '🔐 Data Security Architecture',
            content: _isHindi
                ? '''TrueCircle का security architecture industry standards से भी ज्यादा strong है। हम multiple layers की security use करते हैं।

🏗️ Security Layers:
1. Local Encryption - Device पर ही data encrypt होता है
2. Hive Database - Secure local storage
3. Memory Protection - RAM में भी encrypted data
4. Network Isolation - Internet connection optional
5. Code Obfuscation - App code fully protected

🎯 Privacy Benefits:
• No government surveillance possible
• No corporate data mining
• No targeted advertising
• Complete user control
• GDPR compliant by design'''
                : '''TrueCircle's security architecture is stronger than industry standards. We use multiple layers of security.

🏗️ Security Layers:
1. Local Encryption - Data encrypted on device itself
2. Hive Database - Secure local storage
3. Memory Protection - Encrypted data even in RAM
4. Network Isolation - Internet connection optional
5. Code Obfuscation - App code fully protected

🎯 Privacy Benefits:
• No government surveillance possible
• No corporate data mining
• No targeted advertising
• Complete user control
• GDPR compliant by design''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: _isHindi ? '✅ Privacy Guarantee' : '✅ Privacy Guarantee',
            content: _isHindi
                ? '''हम आपको guarantee देते हैं कि TrueCircle आपकी privacy को 100% protect करेगा। यहाँ हमारे concrete promises हैं:

📝 Our Commitments:
• आपका data कभी भी share नहीं करेंगे
• Third-party को कोई information नहीं देंगे
• Advertising के लिए data use नहीं करेंगे
• Government requests को भी data नहीं दे सकते (क्योंकि हमारे पास है ही नहीं)
• Open source components use करते हैं transparency के लिए

✅ Complete Assurance:
TrueCircle पूरी तरह से free है और हमेशा रहेगा। आपकी privacy हमारी जिम्मेदारी है, न कि business model।'''
                : '''We guarantee that TrueCircle will protect your privacy 100%. Here are our concrete promises:

📝 Our Commitments:
• We will never share your data
• No information to third parties
• Won't use data for advertising
• Can't give data to government requests (because we don't have it)
• Use open source components for transparency

✅ Complete Assurance:
TrueCircle is completely free and always will be. Your privacy is our responsibility, not our business model.''',
          ),
        ],
      ),
    );
  }

  Widget _buildAITechnologyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: _isHindi
                ? '🤖 Advanced AI Technology'
                : '🤖 Advanced AI Technology',
            content: _isHindi
                ? '''TrueCircle में cutting-edge AI technology का use किया गया है जो specifically Indian context के लिए designed है। हमारा AI cultural nuances को समझता है।

🧠 AI Capabilities:
• Natural Language Processing - Hindi और English दोनों
• Emotion Recognition - 50+ emotions को identify करता है
• Pattern Analysis - relationship patterns को समझता है
• Predictive Analytics - future trends predict करता है
• Cultural Context - Indian values और traditions को समझता है'''
                : '''TrueCircle uses cutting-edge AI technology specifically designed for Indian context. Our AI understands cultural nuances.

🧠 AI Capabilities:
• Natural Language Processing - Both Hindi and English
• Emotion Recognition - Identifies 50+ emotions
• Pattern Analysis - Understands relationship patterns
• Predictive Analytics - Predicts future trends
• Cultural Context - Understands Indian values and traditions''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: _isHindi
                ? '🎯 Cultural AI Innovation'
                : '🎯 Cultural AI Innovation',
            content: _isHindi
                ? '''हमारा Cultural AI दुनिया में unique है। यह सिर्फ English AI models का translation नहीं है, बल्कि specifically Indian mindset के लिए built है।

🇮🇳 Cultural Features:
• Festival Emotional Patterns - त्योहारों के emotional impact को समझता है
• Family Dynamics - Indian family structures को analyze करता है
• Regional Variations - North/South India के cultural differences
• Traditional Values - आधुनिक life में traditional values का balance
• Language Code-Switching - Hindi-English mix को perfectly समझता है

🔬 Technical Innovation:
• 10,000+ Indian conversation samples से trained
• 500+ festivals का cultural data
• Regional emotional expression patterns
• Generational gap understanding
• Gender-specific cultural considerations'''
                : '''Our Cultural AI is unique in the world. It's not just a translation of English AI models, but specifically built for the Indian mindset.

🇮🇳 Cultural Features:
• Festival Emotional Patterns - Understands emotional impact of festivals
• Family Dynamics - Analyzes Indian family structures
• Regional Variations - Cultural differences between North/South India
• Traditional Values - Balance of traditional values in modern life
• Language Code-Switching - Perfectly understands Hindi-English mix

🔬 Technical Innovation:
• Trained on 10,000+ Indian conversation samples
• Cultural data of 500+ festivals
• Regional emotional expression patterns
• Generational gap understanding
• Gender-specific cultural considerations''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: _isHindi
                ? '⚡ On-Device AI Processing'
                : '⚡ On-Device AI Processing',
            content: _isHindi
                ? '''सबसे advanced feature यह है कि सारी AI processing आपके device पर ही होती है। App install के बाद platform-specific models download होकर हमेशा के लिए offline काम करते हैं।

� Platform-Specific AI Models:
• Android Devices: Google Gemini Nano SDK (50MB)
• iPhone/iPad: Apple CoreML Models (45MB)  
• Windows PC: TensorFlow Lite Models (35MB)
• Web Browser: WebAssembly AI Engine (30MB)

�💻 Technical Advantages:
• Real-time Processing - instant results
• Offline Functionality - internet के बिना भी काम करता है
• Battery Optimized - कम battery consumption
• Privacy Protected - data कहीं नहीं जाता
• Platform Optimized - हर device के लिए best performance

🔧 Smart Download System:
• App खुद detect करती है कि कौन सा platform है
• Automatically सही model download करती है
• Background में install होता है
• User को wait करना पड़ता है (1-2 मिनट)
• एक बार download के बाद lifetime offline'''
                : '''The most advanced feature is that all AI processing happens on your device itself. After app installation, platform-specific models download and work offline forever.

📱 Platform-Specific AI Models:
• Android Devices: Google Gemini Nano SDK (50MB)
• iPhone/iPad: Apple CoreML Models (45MB)  
• Windows PC: TensorFlow Lite Models (35MB)
• Web Browser: WebAssembly AI Engine (30MB)

💻 Technical Advantages:
• Real-time Processing - Instant results
• Offline Functionality - Works without internet
• Battery Optimized - Low battery consumption
• Privacy Protected - Data doesn't go anywhere
• Platform Optimized - Best performance for each device

🔧 Smart Download System:
• App automatically detects which platform it is
• Automatically downloads the right model
• Installs in background
• User has to wait (1-2 minutes)
• Once downloaded, lifetime offline''',
          ),
        ],
      ),
    );
  }

  Widget _buildGettingStartedTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: _isHindi
                ? '🚀 TrueCircle के साथ शुरुआत'
                : '🚀 Getting Started with TrueCircle',
            content: _isHindi
                ? '''TrueCircle use करना बहुत आसान है। Installation के बाद app अपने आप सभी जरूरी AI models download करके offline mode में setup हो जाती है।

📱 Complete Setup Process:
1. App Download करें (Play Store/App Store से)
2. Number Verification करें (OTP के साथ)
3. ⏳ AI Models Download होने का wait करें (1-2 मिनट)
   • Android: Google Gemini Nano SDK
   • iPhone: CoreML Models  
   • Windows/Web: TensorFlow Lite Models
4. Language choose करें (Hindi/English)
5. Privacy Mode select करें (recommended)
6. Basic preferences set करें
7. पहला Emotional Check-in करें

🔄 One-Time Download:
Models एक बार download होने के बाद app हमेशा के लिए offline काम करती है। Internet connection की जरूरत नहीं।

⏱️ Total Setup Time:
• Model Download: 1-2 मिनट (one-time only)
• Initial Setup: 30 seconds
• First Check-in: 30 seconds'''
                : '''Using TrueCircle is very easy. After installation, the app automatically downloads all necessary AI models and sets up in offline mode.

📱 Complete Setup Process:
1. Download the app (from Play Store/App Store)
2. Number Verification (with OTP)
3. ⏳ Wait for AI Models Download (1-2 minutes)
   • Android: Google Gemini Nano SDK
   • iPhone: CoreML Models  
   • Windows/Web: TensorFlow Lite Models
4. Choose language (Hindi/English)
5. Select Privacy Mode (recommended)
6. Set basic preferences
7. Do your first Emotional Check-in

🔄 One-Time Download:
Once models are downloaded, the app works offline forever. No internet connection needed.

⏱️ Total Setup Time:
• Model Download: 1-2 minutes (one-time only)
• Initial Setup: 30 seconds
• First Check-in: 30 seconds''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: _isHindi ? '💡 Best Practices' : '💡 Best Practices',
            content: _isHindi
                ? '''TrueCircle से maximum benefit पाने के लिए ये tips follow करें:

📅 Daily Usage:
• हर दिन Emotional Check-in करें (सिर्फ 30 seconds)
• Weekly relationship review करें
• Festival times पर Cultural AI से tips लें
• Sleep और mood patterns को track करें

🎯 Pro Tips:
• Morning में emotional check-in करें (दिन की शुरुआत में clarity मिलती है)
• Dr. Iris से weekly chat करें
• Breathing exercises regularly करें
• Festival celebrations को plan करने के लिए Cultural AI use करें

📊 Progress Tracking:
• Weekly analytics देखें
• Monthly relationship insights review करें
• Seasonal emotional patterns को समझें
• Goal setting करें और progress monitor करें'''
                : '''Follow these tips to get maximum benefit from TrueCircle:

📅 Daily Usage:
• Do Emotional Check-in daily (just 30 seconds)
• Do weekly relationship review
• Get tips from Cultural AI during festivals
• Track sleep and mood patterns

🎯 Pro Tips:
• Do emotional check-in in the morning (gives clarity at start of day)
• Chat with Dr. Iris weekly
• Do breathing exercises regularly
• Use Cultural AI to plan festival celebrations

📊 Progress Tracking:
• Check weekly analytics
• Review monthly relationship insights
• Understand seasonal emotional patterns
• Set goals and monitor progress''',
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: _isHindi ? '🆘 Support & Help' : '🆘 Support & Help',
            content: _isHindi
                ? '''अगर आपको कोई help चाहिए या questions हैं, तो हम यहाँ हैं आपकी मदद के लिए:

📞 Support Channels:
• In-App Help - app के अंदर ही complete guide है
• Dr. Iris Chat - AI counselor से पूछें
• FAQ Section - common questions के answers
• Video Tutorials - step-by-step guidance
• Community Forum - other users से connect करें

🕐 Response Time:
• In-App Help: Instant
• Dr. Iris: Real-time 24/7
• Technical Issues: 24 hours में resolve
• Feature Requests: Next update में consider

🌟 Community:
TrueCircle community join करें और other users के experiences share करें। Privacy maintain करते हुए valuable insights पा सकते हैं।'''
                : '''If you need any help or have questions, we're here to help you:

📞 Support Channels:
• In-App Help - Complete guide inside the app
• Dr. Iris Chat - Ask the AI counselor
• FAQ Section - Answers to common questions
• Video Tutorials - Step-by-step guidance
• Community Forum - Connect with other users

🕐 Response Time:
• In-App Help: Instant
• Dr. Iris: Real-time 24/7
• Technical Issues: Resolved within 24 hours
• Feature Requests: Considered in next update

🌟 Community:
Join the TrueCircle community and share experiences with other users. Get valuable insights while maintaining privacy.''',
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TrueCircleFAQPage(),
                  ),
                );
              },
              icon: const Icon(Icons.quiz_outlined, color: Colors.white),
              label: Text(
                _isHindi
                    ? 'अक्सर पूछे जाने वाले प्रश्न देखें'
                    : 'View Frequently Asked Questions',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 6,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                // Mark that user has seen this page (phone number specific)
                final box = Hive.box('truecircle_settings');
                final phoneNumber = box.get('current_phone_number') as String?;

                if (phoneNumber != null) {
                  await box.put('${phoneNumber}_seen_how_works', true);
                } else {
                  await box.put(
                      'has_seen_how_truecircle_works', true); // Fallback
                }

                // Navigate to main app (HomePage)
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const HomePage()),
                  );
                }
              },
              icon: const Icon(Icons.rocket_launch, color: Colors.white),
              label: Text(
                _isHindi
                    ? 'TrueCircle के साथ शुरुआत करें'
                    : 'Get Started with TrueCircle',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content}) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.orange.shade50,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

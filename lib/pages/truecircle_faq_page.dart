import 'package:flutter/material.dart';
import '../widgets/truecircle_logo.dart';

/// TrueCircle FAQ Page - Frequently Asked Questions
class TrueCircleFAQPage extends StatefulWidget {
  const TrueCircleFAQPage({super.key});

  @override
  State<TrueCircleFAQPage> createState() => _TrueCircleFAQPageState();
}

class _TrueCircleFAQPageState extends State<TrueCircleFAQPage>
    with TickerProviderStateMixin {
  bool _isHindi = false;
  late TabController _tabController;
  final List<bool> _expandedStates = List.generate(20, (index) => false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
              _isHindi ? 'अक्सर पूछे जाने वाले प्रश्न' : 'Frequently Asked Questions',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        actions: [
          Switch(
            value: _isHindi,
            onChanged: (value) => setState(() => _isHindi = value),
            activeThumbColor: Colors.orange,
          ),
          Text(
            _isHindi ? 'हिं' : 'EN',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            Tab(text: _isHindi ? 'सामान्य' : 'General'),
            Tab(text: _isHindi ? 'प्रिवेसी' : 'Privacy'),
            Tab(text: _isHindi ? 'फीचर्स' : 'Features'),
            Tab(text: _isHindi ? 'तकनीकी' : 'Technical'),
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
            _buildGeneralFAQ(),
            _buildPrivacyFAQ(),
            _buildFeaturesFAQ(),
            _buildTechnicalFAQ(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralFAQ() {
    final faqs = _isHindi ? [
      {
        'question': 'TrueCircle क्या है?',
        'answer': 'TrueCircle एक privacy-first emotional AI app है जो आपके relationships और mental health को समझने में मदद करता है। यह specifically Indian context के लिए designed है और cultural festivals के साथ emotional connections को बेहतर बनाता है।'
      },
      {
        'question': 'यह app free है या paid?',
        'answer': 'TrueCircle में दो modes हैं:\n\n• Privacy Mode (Free): सभी basic features उपलब्ध हैं\n• Full Mode (Premium): Advanced AI features और unlimited analysis\n\nPrivacy Mode में भी आप सारे main features use कर सकते हैं।'
      },
      {
        'question': 'क्या मुझे internet connection की जरूरत है?',
        'answer': 'नहीं! TrueCircle का सबसे बड़ा फायदा यह है कि यह offline काम करता है। सारी AI processing आपके device पर ही होती है। Internet connection सिर्फ initial setup और updates के लिए चाहिए।'
      },
      {
        'question': 'App install के बाद कैसे setup होती है?',
        'answer': 'Install के बाद ये steps होते हैं:\n\n1. Number verification (OTP)\n2. AI Models download (1-2 मिनट):\n   • Android: Google Gemini Nano SDK\n   • iPhone: CoreML Models\n   • PC: TensorFlow Lite\n3. Language selection\n4. Privacy settings\n\nModels एक बार download के बाद app हमेशा offline काम करती है!'
      },
      {
        'question': 'क्या यह app Hindi में काम करता है?',
        'answer': 'बिल्कुल! TrueCircle fully bilingual है। आप Hindi और English दोनों भाषाओं में use कर सकते हैं। हमारा AI Hindi emotions और expressions को perfectly समझता है।'
      },
      {
        'question': 'मैं कैसे शुरुआत करूं?',
        'answer': '1. App download करें\n2. Privacy Mode select करें\n3. भाषा choose करें (Hindi/English)\n4. पहला Emotional Check-in करें\n5. Dr. Iris से बात करें\n\nसिर्फ 2 मिनट में setup complete!'
      },
    ] : [
      {
        'question': 'What is TrueCircle?',
        'answer': 'TrueCircle is a privacy-first emotional AI app that helps you understand your relationships and mental health. It\'s specifically designed for Indian context and improves emotional connections with cultural festivals.'
      },
      {
        'question': 'Is this app free or paid?',
        'answer': 'TrueCircle has two modes:\n\n• Privacy Mode (Free): All basic features available\n• Full Mode (Premium): Advanced AI features and unlimited analysis\n\nYou can use all main features even in Privacy Mode.'
      },
      {
        'question': 'Do I need internet connection?',
        'answer': 'No! TrueCircle\'s biggest advantage is that it works offline. All AI processing happens on your device. Internet connection is only needed for initial setup and updates.'
      },
      {
        'question': 'How does setup work after app install?',
        'answer': 'After install, these steps happen:\n\n1. Number verification (OTP)\n2. AI Models download (1-2 minutes):\n   • Android: Google Gemini Nano SDK\n   • iPhone: CoreML Models\n   • PC: TensorFlow Lite\n3. Language selection\n4. Privacy settings\n\nOnce models are downloaded, app works offline forever!'
      },
      {
        'question': 'Does this app work in Hindi?',
        'answer': 'Absolutely! TrueCircle is fully bilingual. You can use it in both Hindi and English. Our AI perfectly understands Hindi emotions and expressions.'
      },
      {
        'question': 'How do I get started?',
        'answer': '1. Download the app\n2. Select Privacy Mode\n3. Choose language (Hindi/English)\n4. Do your first Emotional Check-in\n5. Chat with Dr. Iris\n\nSetup complete in just 2 minutes!'
      },
    ];

    return _buildFAQList(faqs, 0);
  }

  Widget _buildPrivacyFAQ() {
    final faqs = _isHindi ? [
      {
        'question': 'क्या मेरा data safe है?',
        'answer': '100% safe! आपका सारा data आपके device पर ही रहता है। हम कोई personal information collect नहीं करते। यहाँ तक कि हमारे पास भी आपका data नहीं आता।'
      },
      {
        'question': 'क्या आप मेरी बातचीत save करते हैं?',
        'answer': 'नहीं! Dr. Iris के साथ आपकी सारी conversations आपके device पर locally encrypted रहती हैं। ये कभी भी internet पर नहीं जातीं और हम इन्हें access नहीं कर सकते।'
      },
      {
        'question': 'क्या government मेरा data मांग सकती है?',
        'answer': 'नहीं मांग सकती क्योंकि हमारे पास आपका data है ही नहीं! सब कुछ आपके device पर है। यह complete legal protection देता है।'
      },
      {
        'question': 'Permissions क्यों नहीं मांगते?',
        'answer': 'TrueCircle को कोई device permissions की जरूरत नहीं है क्योंकि:\n• Contacts access नहीं चाहिए (sample data use करते हैं)\n• Camera/Microphone नहीं चाहिए\n• Location नहीं चाहिए\n• Storage permission नहीं चाहिए'
      },
      {
        'question': 'क्या companies को data sell करते हैं?',
        'answer': 'बिल्कुल नहीं! हमारे पास sell करने के लिए data है ही नहीं। हमारा business model premium features पर based है, data selling पर नहीं।'
      },
    ] : [
      {
        'question': 'Is my data safe?',
        'answer': '100% safe! All your data stays on your device. We don\'t collect any personal information. Even we don\'t have access to your data.'
      },
      {
        'question': 'Do you save my conversations?',
        'answer': 'No! All your conversations with Dr. Iris remain locally encrypted on your device. They never go on the internet and we cannot access them.'
      },
      {
        'question': 'Can government request my data?',
        'answer': 'They can\'t request because we don\'t have your data! Everything is on your device. This gives complete legal protection.'
      },
      {
        'question': 'Why don\'t you ask for permissions?',
        'answer': 'TrueCircle doesn\'t need any device permissions because:\n• No contacts access needed (we use sample data)\n• No camera/microphone needed\n• No location needed\n• No storage permission needed'
      },
      {
        'question': 'Do you sell data to companies?',
        'answer': 'Absolutely not! We don\'t have data to sell. Our business model is based on premium features, not data selling.'
      },
    ];

    return _buildFAQList(faqs, 5);
  }

  Widget _buildFeaturesFAQ() {
    final faqs = _isHindi ? [
      {
        'question': 'Emotional Check-in कैसे काम करता है?',
        'answer': 'रोज सिर्फ 30 seconds में अपनी emotions select करें। AI आपके patterns analyze करके insights देता है। यह आपको समझने में मदद करता है कि कौन से factors आपके mood को affect करते हैं।'
      },
      {
        'question': 'Dr. Iris कितना smart है?',
        'answer': 'Dr. Iris बहुत advanced AI है जो:\n• 50+ emotions को समझता है\n• Hindi-English code mixing handle करता है\n• Indian cultural context समझता है\n• Professional therapy techniques use करता है\n• Real-time में respond करता है'
      },
      {
        'question': 'Festival features क्या हैं?',
        'answer': 'Cultural AI आपको बताता है:\n• Festival के दौरान family bonding कैसे बढ़ाएं\n• Traditional celebrations के emotional benefits\n• Regional festival variations\n• Gift giving suggestions\n• Festival stress management'
      },
      {
        'question': 'Sleep और Mood tracking कैसे करें?',
        'answer': 'Simple daily inputs देकर आप track कर सकते हैं:\n• Sleep quality और duration\n• Daily mood changes\n• Energy levels\n• Stress indicators\n\nAI इन सब को correlate करके patterns find करता है।'
      },
      {
        'question': 'Breathing exercises क्यों जरूरी हैं?',
        'answer': 'Breathing exercises immediate benefits देते हैं:\n• Stress reduction\n• Better sleep quality\n• Improved focus\n• Emotional regulation\n\nApp में guided breathing sessions हैं जो proven techniques use करते हैं।'
      },
    ] : [
      {
        'question': 'How does Emotional Check-in work?',
        'answer': 'Just select your emotions in 30 seconds daily. AI analyzes your patterns and gives insights. This helps you understand which factors affect your mood.'
      },
      {
        'question': 'How smart is Dr. Iris?',
        'answer': 'Dr. Iris is a very advanced AI that:\n• Understands 50+ emotions\n• Handles Hindi-English code mixing\n• Understands Indian cultural context\n• Uses professional therapy techniques\n• Responds in real-time'
      },
      {
        'question': 'What are the festival features?',
        'answer': 'Cultural AI tells you:\n• How to increase family bonding during festivals\n• Emotional benefits of traditional celebrations\n• Regional festival variations\n• Gift giving suggestions\n• Festival stress management'
      },
      {
        'question': 'How to do Sleep and Mood tracking?',
        'answer': 'You can track by giving simple daily inputs:\n• Sleep quality and duration\n• Daily mood changes\n• Energy levels\n• Stress indicators\n\nAI correlates all these to find patterns.'
      },
      {
        'question': 'Why are breathing exercises important?',
        'answer': 'Breathing exercises give immediate benefits:\n• Stress reduction\n• Better sleep quality\n• Improved focus\n• Emotional regulation\n\nThe app has guided breathing sessions using proven techniques.'
      },
    ];

    return _buildFAQList(faqs, 10);
  }

  Widget _buildTechnicalFAQ() {
    final faqs = _isHindi ? [
      {
        'question': 'कौन से devices support करता है?',
        'answer': 'TrueCircle इन सभी पर काम करता है:\n• Android phones/tablets\n• iPhone/iPad\n• Windows computers\n• Mac computers\n• Web browsers (Chrome, Safari, Firefox)\n\nMinimum requirements: Android 6.0+ या iOS 12.0+'
      },
      {
        'question': 'App slow क्यों लग रहा है?',
        'answer': 'पहली बार use करने पर AI models load होते हैं जो time लेता है। इसके बाद:\n• RAM clear करें\n• Background apps close करें\n• Device restart करें\n• Latest version update करें'
      },
      {
        'question': 'AI Models कैसे download होते हैं?',
        'answer': 'App install के बाद automatic download होता है:\n\n📱 Platform-wise Models:\n• Android: Google Gemini Nano SDK (50MB)\n• iPhone: Apple CoreML Models (45MB)\n• Windows: TensorFlow Lite (35MB)\n• Web: WebAssembly Engine (30MB)\n\n⏱️ Download Time: 1-2 मिनट\n🔄 Frequency: One-time only\n📶 Required: Wi-Fi recommended\n💾 Storage: Models device पर permanently save'
      },
      {
        'question': 'Data backup कैसे करें?',
        'answer': 'Privacy mode में आपका data device पर ही रहता है। Backup के लिए:\n• Device का regular backup लें\n• Cloud backup enable करें (encrypted)\n• Export feature use करें (coming soon)\n• Multiple devices पर sync (premium feature)'
      },
      {
        'question': 'Updates कैसे मिलते हैं?',
        'answer': 'Regular updates मिलते हैं:\n• Play Store/App Store से automatic\n• In-app update notifications\n• Major updates monthly\n• Bug fixes weekly\n• New features quarterly'
      },
      {
        'question': 'Technical support कैसे लें?',
        'answer': 'Multiple ways से help मिल सकती है:\n• In-app help section\n• Dr. Iris से technical questions पूछें\n• Email: support@truecircle.app\n• Response time: 24 hours\n• Video tutorials in app'
      },
    ] : [
      {
        'question': 'Which devices does it support?',
        'answer': 'TrueCircle works on:\n• Android phones/tablets\n• iPhone/iPad\n• Windows computers\n• Mac computers\n• Web browsers (Chrome, Safari, Firefox)\n\nMinimum requirements: Android 6.0+ or iOS 12.0+'
      },
      {
        'question': 'Why does the app seem slow?',
        'answer': 'First time usage loads AI models which takes time. After that:\n• Clear RAM\n• Close background apps\n• Restart device\n• Update to latest version'
      },
      {
        'question': 'How do AI Models download?',
        'answer': 'Automatic download after app install:\n\n📱 Platform-wise Models:\n• Android: Google Gemini Nano SDK (50MB)\n• iPhone: Apple CoreML Models (45MB)\n• Windows: TensorFlow Lite (35MB)\n• Web: WebAssembly Engine (30MB)\n\n⏱️ Download Time: 1-2 minutes\n🔄 Frequency: One-time only\n📶 Required: Wi-Fi recommended\n💾 Storage: Models permanently saved on device'
      },
      {
        'question': 'How to backup data?',
        'answer': 'In privacy mode, your data stays on device. For backup:\n• Take regular device backup\n• Enable cloud backup (encrypted)\n• Use export feature (coming soon)\n• Sync across devices (premium feature)'
      },
      {
        'question': 'How do updates work?',
        'answer': 'Regular updates available:\n• Automatic from Play Store/App Store\n• In-app update notifications\n• Major updates monthly\n• Bug fixes weekly\n• New features quarterly'
      },
      {
        'question': 'How to get technical support?',
        'answer': 'Multiple ways to get help:\n• In-app help section\n• Ask technical questions to Dr. Iris\n• Email: support@truecircle.app\n• Response time: 24 hours\n• Video tutorials in app'
      },
    ];

    return _buildFAQList(faqs, 15);
  }

  Widget _buildFAQList(List<Map<String, String>> faqs, int startIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: faqs.asMap().entries.map((entry) {
          final index = entry.key + startIndex;
          final faq = entry.value;
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.blue.shade50,
                  ],
                ),
              ),
              child: ExpansionTile(
                title: Text(
                  faq['question']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade800,
                  ),
                ),
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 16,
                  child: Text(
                    'Q',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                trailing: Icon(
                  _expandedStates[index] ? Icons.expand_less : Icons.expand_more,
                  color: Colors.blue.shade600,
                ),
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedStates[index] = expanded;
                  });
                },
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      faq['answer']!,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
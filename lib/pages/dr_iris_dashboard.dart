import 'package:flutter/material.dart';

class DrIrisDashboard extends StatefulWidget {
  final bool isFullMode;

  const DrIrisDashboard({super.key, this.isFullMode = false});

  @override
  State<DrIrisDashboard> createState() => _DrIrisDashboardState();
}

class _DrIrisDashboardState extends State<DrIrisDashboard> {
  String selectedLanguage = 'English';

  // Sample data for demonstration
  final List<Map<String, dynamic>> _therapyTopics = [
    {
      'titleEn': 'Emotional Wellness Check',
      'titleHi': 'भावनात्मक कल्याण जांच',
      'descEn': 'How are you feeling today? Let\'s explore your emotions.',
      'descHi':
          'आज आप कैसा महसूस कर रहे हैं? आइए अपनी भावनाओं का पता लगाते हैं।',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'responses': [
        'I understand you\'re going through a challenging time. Let\'s work through this together.',
        'Your feelings are completely valid. How long have you been experiencing this?',
        'It takes courage to acknowledge these emotions. You\'re taking the right step.',
      ],
      'responsesHi': [
        'मैं समझती हूं कि आप एक कठिन समय से गुजर रहे हैं। आइए इसे मिलकर सुलझाते हैं।',
        'आपकी भावनाएं बिल्कुल वैध हैं। आप कितने समय से इसे महसूस कर रहे हैं?',
        'इन भावनाओं को स्वीकार करना साहस की बात है। आप सही कदम उठा रहे हैं।',
      ],
    },
    {
      'titleEn': 'Relationship Guidance',
      'titleHi': 'रिश्ते का मार्गदर्शन',
      'descEn': 'Let\'s discuss your relationships and connections.',
      'descHi': 'आइए अपने रिश्तों और जुड़ाव पर चर्चा करें।',
      'icon': Icons.people,
      'color': Colors.blue,
      'responses': [
        'Healthy relationships require open communication. What specific challenges are you facing?',
        'Every relationship has ups and downs. Let\'s identify patterns that might be affecting yours.',
        'Setting boundaries is important for your mental health. How comfortable are you with this?',
      ],
      'responsesHi': [
        'स्वस्थ रिश्तों के लिए खुला संचार आवश्यक है। आप किन विशिष्ट चुनौतियों का सामना कर रहे हैं?',
        'हर रिश्ते में उतार-चढ़ाव होते हैं। आइए उन पैटर्न की पहचान करते हैं जो आपके रिश्तों को प्रभावित कर सकते हैं।',
        'सीमाएं निर्धारित करना आपके मानसिक स्वास्थ्य के लिए महत्वपूर्ण है। इसके साथ आप कितना सहज महसूस करते हैं?',
      ],
    },
    {
      'titleEn': 'Stress Management',
      'titleHi': 'तनाव प्रबंधन',
      'descEn': 'Discover techniques to manage daily stress effectively.',
      'descHi': 'दैनिक तनाव को प्रभावी रूप से प्रबंधित करने की तकनीकें खोजें।',
      'icon': Icons.spa,
      'color': Colors.green,
      'responses': [
        'Stress is your body\'s natural response. Let\'s find healthy ways to manage it.',
        'Deep breathing can be incredibly powerful. Have you tried any mindfulness techniques?',
        'Regular exercise and good sleep can significantly reduce stress levels. How are your habits?',
      ],
      'responsesHi': [
        'तनाव आपके शरीर की प्राकृतिक प्रतिक्रिया है। आइए इसे संभालने के स्वस्थ तरीके खोजते हैं।',
        'गहरी सांस लेना अविश्वसनीय रूप से शक्तिशाली हो सकता है। क्या आपने कोई माइंडफुलनेस तकनीक आजमाई है?',
        'नियमित व्यायाम और अच्छी नींद तनाव के स्तर को काफी कम कर सकते हैं। आपकी आदतें कैसी हैं?',
      ],
    },
    {
      'titleEn': 'Self-Care & Mindfulness',
      'titleHi': 'आत्म-देखभाल और माइंडफुलनेस',
      'descEn': 'Learn to prioritize your mental and emotional well-being.',
      'descHi': 'अपने मानसिक और भावनात्मक कल्याण को प्राथमिकता देना सीखें।',
      'icon': Icons.self_improvement,
      'color': Colors.purple,
      'responses': [
        'Self-care isn\'t selfish, it\'s necessary. What activities make you feel recharged?',
        'Being present in the moment can transform your experience. How often do you practice mindfulness?',
        'Small daily rituals can create big changes in your mental health. What would you like to start with?',
      ],
      'responsesHi': [
        'आत्म-देखभाल स्वार्थी नहीं, आवश्यक है। कौन सी गतिविधियां आपको ऊर्जा से भर देती हैं?',
        'वर्तमान क्षण में उपस्थित रहना आपके अनुभव को बदल सकता है। आप कितनी बार माइंडफुलनेस का अभ्यास करते हैं?',
        'छोटी दैनिक रस्में आपके मानसिक स्वास्थ्य में बड़े बदलाव ला सकती हैं। आप किससे शुरुआत करना चाहेंगे?',
      ],
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
                Colors.blue.withValues(alpha: 0.6),
                Colors.blue.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header with Dr. Iris
                _buildHeader(),

                // Therapy Topics List
                Expanded(
                  child: _buildTherapyTopics(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.pop(context),
          ),

          const SizedBox(width: 12),

          // Dr. Iris Avatar
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
                    child: const Icon(Icons.psychology,
                        color: Colors.white, size: 30),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Welcome text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedLanguage == 'English'
                      ? 'Dr. Iris Therapy Session'
                      : 'डॉ. आइरिस थेरेपी सेशन',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      selectedLanguage == 'English'
                          ? 'Your AI Therapist'
                          : 'आपका एआई चिकित्सक',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Mode indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.isFullMode
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.orange.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              widget.isFullMode ? Colors.green : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.isFullMode
                            ? (selectedLanguage == 'English' ? 'FULL' : 'पूर्ण')
                            : (selectedLanguage == 'English' ? 'DEMO' : 'डेमो'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.isFullMode ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Language Toggle
          GestureDetector(
            onTap: () {
              setState(() {
                selectedLanguage =
                    selectedLanguage == 'English' ? 'हिंदी' : 'English';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                selectedLanguage == 'English' ? 'EN' : 'हि',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTherapyTopics() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _therapyTopics.length,
      itemBuilder: (context, index) {
        final topic = _therapyTopics[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.white.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _showTherapyDialog(topic),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Topic Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: topic['color'].withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      topic['icon'],
                      size: 32,
                      color: topic['color'],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Topic Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedLanguage == 'English'
                              ? topic['titleEn']
                              : topic['titleHi'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedLanguage == 'English'
                              ? topic['descEn']
                              : topic['descHi'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTherapyDialog(Map<String, dynamic> topic) {
    final responses = selectedLanguage == 'English'
        ? topic['responses']
        : topic['responsesHi'];
    final randomResponse = responses[
        (responses.length * (DateTime.now().millisecond / 1000)).floor() %
            responses.length];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: topic['color'].withValues(alpha: 0.2),
              child: Icon(
                Icons.psychology,
                color: topic['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dr. Iris',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: topic['color'],
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                randomResponse,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Mode-specific footer message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (widget.isFullMode ? Colors.green : Colors.orange)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isFullMode ? Colors.green : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isFullMode ? Icons.check_circle : Icons.info,
                    color: widget.isFullMode ? Colors.green : Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.isFullMode
                          ? (selectedLanguage == 'English'
                              ? '✨ Full Mode: Personalized therapy with real AI processing'
                              : '✨ पूर्ण मोड: वास्तविक एआई प्रोसेसिंग के साथ व्यक्तिगत चिकित्सा')
                          : (selectedLanguage == 'English'
                              ? '🎯 Demo Mode: Sample responses for exploration'
                              : '🎯 डेमो मोड: अन्वेषण के लिए नमूना प्रतिक्रियाएं'),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.isFullMode ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              selectedLanguage == 'English'
                  ? 'Continue Session'
                  : 'सेशन जारी रखें',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFollowUpDialog(topic);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: topic['color'],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              selectedLanguage == 'English' ? 'Tell me more' : 'और बताएं',
            ),
          ),
        ],
      ),
    );
  }

  void _showFollowUpDialog(Map<String, dynamic> topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: topic['color'].withValues(alpha: 0.2),
              child: Icon(
                Icons.psychology,
                color: topic['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Dr. Iris',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    selectedLanguage == 'English'
                        ? '🌟 I can see you\'re interested in exploring this further. In a full session, we would:\n\n• Dive deeper into your specific situation\n• Create personalized coping strategies\n• Set achievable goals together\n• Track your progress over time\n\nWould you like to continue with more topics or schedule a longer session?'
                        : '🌟 मैं देख सकती हूं कि आप इसे और गहराई से जानना चाहते हैं। एक पूर्ण सेशन में, हम करेंगे:\n\n• आपकी विशिष्ट स्थिति में गहराई से जाना\n• व्यक्तिगत मुकाबला रणनीतियां बनाना\n• एक साथ प्राप्त करने योग्य लक्ष्य निर्धारित करना\n• समय के साथ आपकी प्रगति को ट्रैक करना\n\nक्या आप और विषयों के साथ जारी रखना चाहते हैं या एक लंबा सेशन शेड्यूल करना चाहते हैं?',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              selectedLanguage == 'English'
                  ? 'Explore More Topics'
                  : 'और विषय देखें',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showScheduleSessionDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(
              selectedLanguage == 'English'
                  ? 'Schedule Session'
                  : 'सेशन शेड्यूल करें',
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleSessionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.schedule, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                selectedLanguage == 'English'
                    ? 'Schedule Session'
                    : 'सेशन शेड्यूल करें',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedLanguage == 'English'
                      ? 'Choose your preferred session time:'
                      : 'अपना पसंदीदा सेशन समय चुनें:',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                _buildTimeSlot('Morning (9:00 AM - 12:00 PM)', 'सुबह (9:00 AM - 12:00 PM)'),
                _buildTimeSlot('Afternoon (1:00 PM - 4:00 PM)', 'दोपहर (1:00 PM - 4:00 PM)'),
                _buildTimeSlot('Evening (5:00 PM - 8:00 PM)', 'शाम (5:00 PM - 8:00 PM)'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedLanguage == 'English'
                              ? 'Sessions are currently available in Demo Mode with AI-powered insights. Full personalized sessions coming soon!'
                              : 'डेमो मोड में AI-संचालित अंतर्दृष्टि के साथ सेशन वर्तमान में उपलब्ध हैं। पूर्ण व्यक्तिगत सेशन जल्द ही आ रहे हैं!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
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
              child: Text(
                selectedLanguage == 'English' ? 'Cancel' : 'रद्द करें',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      selectedLanguage == 'English'
                          ? '✨ Session preferences saved! You can start chatting anytime.'
                          : '✨ सेशन प्राथमिकताएं सहेजी गईं! आप कभी भी चैट शुरू कर सकते हैं।',
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                selectedLanguage == 'English'
                    ? 'Save Preferences'
                    : 'प्राथमिकताएं सहेजें',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimeSlot(String englishTime, String hindiTime) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                selectedLanguage == 'English'
                    ? 'Time slot selected: ${englishTime.split(' (')[0]}'
                    : 'समय स्लॉट चुना गया: ${hindiTime.split(' (')[0]}',
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 12),
              Text(
                selectedLanguage == 'English' ? englishTime : hindiTime,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

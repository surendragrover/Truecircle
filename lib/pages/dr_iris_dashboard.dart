import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';
import '../core/service_locator.dart';
import '../services/on_device_ai_service.dart';
import '../services/ai_orchestrator_service.dart';
// Updated to use Service Locator for platform-agnostic AI service access

// Represents a single message in the chat.
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, {this.isUser = false});
}

class DrIrisDashboard extends StatefulWidget {
  final bool isFullMode;

  const DrIrisDashboard({super.key, this.isFullMode = false});

  @override
  State<DrIrisDashboard> createState() => _DrIrisDashboardState();
}

class _DrIrisDashboardState extends State<DrIrisDashboard> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  String selectedLanguage = 'English';
  static const String _chatLangPrefKey = 'dr_iris_language_pref';
  
  // 1. Service Locator से AI Service को access करना - प्लेटफॉर्म की चिंता किए बिना
  OnDeviceAIService? _aiService;
  bool _serviceAvailable = false;
  // Mood context
  List<Map<String, dynamic>> _recentMoodEntries = [];
  String _contextSummary = '';
  // bool _contextLoaded kept for future loading indicator (removed usage to silence lint)
  bool _showContext = true;

  @override
  void initState() {
    super.initState();
  _restoreLanguage().then((_) async {
  _initializeAIService();
    await _loadMoodContext();
  });
    
    // Initial welcome message from Dr. Iris
    _messages.add(ChatMessage(
      selectedLanguage == 'English'
          ? 'Hello! I\'m Dr. Iris, your emotional therapist. I\'m analyzing your emotional data to provide personalized insights. How can I help you today?'
          : 'नमस्ते! मैं डॉ. आइरिस हूँ, आपकी इमोशनल थेरेपिस्ट। मैं आपके भावनात्मक डेटा का विश्लेषण कर रही हूँ। आज मैं आपकी कैसे मदद कर सकती हूँ?',
    ));
  }

  // 2. AI Service को initialize करना - प्लेटफॉर्म की चिंता किए बिना
  void _initializeAIService() async {
    // Only initialize real AI service if models downloaded flag exists for current phone user
    bool modelsReady = false;
    try {
      final settings = await Hive.openBox('truecircle_settings');
      final phone = settings.get('current_phone_number') as String?;
      if (phone != null) {
        modelsReady = settings.get('${phone}_models_downloaded', defaultValue: false) as bool;
      }
    } catch (_) {}

    if (!modelsReady) {
      debugPrint('ℹ️ Dr. Iris: Models not ready yet, staying in sample response mode');
      setState(() { _serviceAvailable = false; });
      return;
    }

    try {
      _aiService = ServiceLocator.instance.get<OnDeviceAIService>();
      _serviceAvailable = true;
      debugPrint('✅ Dr. Iris: AI Service initialized (modelsReady=$modelsReady)');
    } catch (e) {
      _serviceAvailable = false;
      debugPrint('⚠️ Dr. Iris: AI Service fetch failed, fallback to sample responses: $e');
    }
  }

  Future<void> _loadMoodContext() async {
    try {
      final box = await Hive.openBox('truecircle_emotional_entries');
      final raw = box.get('entries', defaultValue: <dynamic>[]) as List;
      final entries = raw.cast<Map>().cast<Map<String, dynamic>>();
      _recentMoodEntries = entries.take(25).toList();
      if (_recentMoodEntries.isEmpty) {
  setState(() { _contextSummary=''; });
        return;
      }
      final moods = _recentMoodEntries.map((e)=> (e['mood_score'] ?? 0).toDouble()).where((v)=> v>0).toList();
      final avgMood = moods.isNotEmpty ? moods.reduce((a,b)=>a+b)/moods.length : 0.0;
      final stressCounts = <String,int>{};
      for (final e in _recentMoodEntries) {
        final s = (e['stress'] ?? 'Unknown').toString();
        stressCounts[s] = (stressCounts[s] ?? 0) + 1;
      }
      final topFeelings = _recentMoodEntries
          .expand((e)=> (e['feelings']??'').toString().split(',').map((s)=>s.trim()).where((s)=>s.isNotEmpty))
          .fold<Map<String,int>>({}, (m,f){ m[f]=(m[f]??0)+1; return m; }).entries.toList()
        ..sort((a,b)=> b.value.compareTo(a.value));
      final feelingsStr = topFeelings.take(5).map((e)=> e.key).join(', ');
      final stressStr = stressCounts.entries.map((e)=> '${e.key}:${e.value}').join(', ');
      _contextSummary = selectedLanguage == 'Hindi'
        ? 'औसत मूड ${avgMood.toStringAsFixed(1)}/10 • तनाव: $stressStr • प्रमुख भावनाएँ: $feelingsStr'
        : 'Avg mood ${avgMood.toStringAsFixed(1)}/10 • Stress: $stressStr • Top feelings: $feelingsStr';
  setState(() {});
    } catch (e) {
      debugPrint('DrIris context load failed: $e');
  setState(() { _contextSummary=''; });
    }
  }

  Future<void> _restoreLanguage() async {
    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      final stored = box.get(_chatLangPrefKey, defaultValue: 'English') as String;
      if (stored != selectedLanguage) {
        setState(() => selectedLanguage = stored);
      }
    } catch (_) {}
  }

  Future<void> _persistLanguage() async {
    try {
      final box = Hive.isBoxOpen('truecircle_settings')
          ? Hive.box('truecircle_settings')
          : await Hive.openBox('truecircle_settings');
      await box.put(_chatLangPrefKey, selectedLanguage);
    } catch (_) {}
  }

  // Sample data for generating responses with 30-day emotional context.
  final Map<String, List<String>> _sampleResponses = {
    'relationship': [
      'Based on your 30-day emotional data, I see some relationship stress patterns. Let\'s explore what\'s affecting your connections with others.',
      'Your sample data shows varying relationship satisfaction levels. What specific challenges are you facing in your relationships?',
      'I notice fluctuations in your emotional well-being related to relationships. Would you like to discuss any particular relationship concerns?'
    ],
    'stress': [
      'Your 30-day emotional profile indicates stress peaks during certain periods. Let\'s identify healthy coping strategies that work for you.',
      'The sample data shows stress affecting your overall mood. Have you tried mindfulness or breathing exercises?',
      'I can see from your emotional tracking that stress management is important for you. What triggers stress in your daily life?'
    ],
    'feeling': [
      'Your emotional journey over the past 30 days shows both challenges and resilience. I\'m here to support you through difficult feelings.',
      'Based on your mood patterns, I understand you\'re experiencing various emotions. Let\'s work through these feelings together.',
      'Your emotional data indicates you\'ve been processing some difficult feelings. How can I help you navigate these emotions?'
    ],
    'mood': [
      'Your 30-day mood tracking shows interesting patterns. What factors do you think influence your mood the most?',
      'I can see from your emotional data that mood varies throughout different times. Let\'s explore what affects your emotional state.',
      'Your mood journal indicates both positive and challenging days. What helps you feel better during difficult times?'
    ],
    'data': [
      'Your 30-day emotional sample data provides valuable insights into your mental health patterns. What would you like to explore?',
      'Based on the sample data I\'m analyzing, I can help you understand your emotional trends and coping strategies.',
      'The emotional tracking data shows your unique patterns. How do you feel about your emotional journey over these 30 days?'
    ],
    'default': [
      'Based on your emotional sample data, I\'m here to provide personalized insights. Tell me more about what\'s on your mind.',
      'Your 30-day emotional journey shows unique patterns. How can I help you understand and improve your mental well-being?',
      'I\'m analyzing your emotional data to provide the best support. What aspect of your mental health would you like to focus on today?'
    ]
  };



  // 3. Message भेजना - Service Locator के through AI service का उपयोग
  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.insert(0, ChatMessage(text, isUser: true));
      _isLoading = true;
    });

    try {
      String response;
      
      // Service Locator से AI service का उपयोग करना (प्लेटफॉर्म की चिंता किए बिना)
      if (_serviceAvailable && _aiService != null) {
        debugPrint('📤 Dr. Iris: Sending message to AI service: $text');
    // Merge orchestrator feature insights if available
    String orchestratorContext = '';
    try {
      final insights = AIOrchestratorService().featureInsights.value;
      if (insights.isNotEmpty) {
      final parts = insights.entries.map((e) => '${e.key}: ${e.value}').join(' | ');
      orchestratorContext = parts;
      }
    } catch (_) {}

    final combinedContext = [_contextSummary, orchestratorContext]
      .where((s) => s.trim().isNotEmpty)
      .join(' • ');

    final contextPrompt = combinedContext.isNotEmpty
      ? (selectedLanguage == 'Hindi'
        ? 'एकीकृत संदर्भ: $combinedContext\nउपयोगकर्ता संदेश: $text\nदयालु, सहायक और सांस्कृतिक रूप से संवेदनशील जवाब दें।'
        : 'Unified context: $combinedContext\nUser message: $text\nProvide a compassionate, culturally aware therapeutic reply.')
      : text;
        response = await _aiService!.generateDrIrisResponse(contextPrompt);
        debugPrint('📥 Dr. Iris: Received AI response');
      } else {
        // Fallback to sample responses if AI service not available
        debugPrint('📝 Dr. Iris: Using sample response (AI service not available)');
        response = _generateSampleResponse(text);
      }
      
      _addBotMessage(response);
      
    } catch (e) {
      debugPrint('❌ Dr. Iris: Error getting AI response: $e');
      // Fallback to sample response on error
      final fallbackResponse = _generateSampleResponse(text);
      _addBotMessage(fallbackResponse);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.insert(0, ChatMessage(text));
    });
  }

  // Sample response generator - returns response instead of directly adding to messages
  String _generateSampleResponse(String userInput) {
    String responseKey = 'default';
    final input = userInput.toLowerCase();
    
    if (input.contains('relationship') || input.contains('रिश्ता')) {
      responseKey = 'relationship';
    } else if (input.contains('stress') || input.contains('तनाव')) {
      responseKey = 'stress';
    } else if (input.contains('feel') || input.contains('sad') || input.contains('दुख') || input.contains('महसूस')) {
      responseKey = 'feeling';
    } else if (input.contains('mood') || input.contains('मूड') || input.contains('मिजाज')) {
      responseKey = 'mood';
    } else if (input.contains('data') || input.contains('डेटा') || input.contains('30') || input.contains('day')) {
      responseKey = 'data';
    }

    final responses = _sampleResponses[responseKey]!;
    var response = responses[Random().nextInt(responses.length)];
    
    // Add bilingual support if selected language is Hindi
    if (selectedLanguage == 'Hindi') {
      response = _translateToHindi(response);
    }

    return response;
  }
  
  String _translateToHindi(String englishText) {
    // Simple Hindi translations for key responses
    final translations = {
      'Based on your 30-day emotional data': 'आपके 30-दिन के भावनात्मक डेटा के आधार पर',
      'Your sample data shows': 'आपका नमूना डेटा दिखाता है',
      'I notice fluctuations': 'मैं उतार-चढ़ाव देख रही हूं',
      'Let\'s explore': 'आइए जानें',
      'Tell me more': 'मुझे और बताएं',
      'How can I help': 'मैं कैसे मदद कर सकती हूं',
      'I\'m here to support': 'मैं आपकी सहायता के लिए यहां हूं'
    };
    
    String hindiResponse = englishText;
    translations.forEach((english, hindi) {
      hindiResponse = hindiResponse.replaceAll(english, hindi);
    });
    
    return hindiResponse;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Scaffold(
      body: Container(
        // Use global coral gradient background instead of image
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFA385), Color(0xFFFF7F50), Color(0xFFFF6233)],
        )),
        child: Column(
          children: [
            // Fixed header with proper mobile sizing
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFA385), Color(0xFFFF7F50)],
                ),
              ),
              child: _buildHeader(),
            ),
            if (_contextSummary.isNotEmpty && _showContext)
              Container(
                margin: const EdgeInsets.fromLTRB(12,6,12,4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.insights, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _contextSummary,
                        style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(()=> _showContext=false),
                      child: const Icon(Icons.close, size: 16, color: Colors.white70),
                    )
                  ],
                ),
              ),
            // Chat area with proper spacing
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  top: 8.0,
                  bottom: isSmallScreen ? 8.0 : 16.0,
                ),
                child: ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8.0 : 16.0,
                    vertical: 8.0,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (_, int index) =>
                      _buildMessageItem(_messages[index], isSmallScreen),
                ),
              ),
            ),
            // Loading indicator
            if (_isLoading)
              Container(
                padding: const EdgeInsets.all(8.0),
                child: const CircularProgressIndicator(),
              ),
            // Text input with better mobile visibility
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: _buildTextComposer(isSmallScreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 6.0 : 10.0,
        horizontal: isSmallScreen ? 4.0 : 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!message.isUser)
            CircleAvatar(
              radius: isSmallScreen ? 16 : 20,
              backgroundImage: const AssetImage('assets/images/avatar.png'),
            ),
          SizedBox(width: isSmallScreen ? 6.0 : 8.0),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue[400] : Colors.white,
                borderRadius: BorderRadius.circular(isSmallScreen ? 16.0 : 12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ),
          if (message.isUser) SizedBox(width: isSmallScreen ? 6.0 : 8.0),
          if (message.isUser)
            CircleAvatar(
              radius: isSmallScreen ? 16 : 20,
              child: const Icon(Icons.person),
            ),
        ],
      ),
    );
  }

  Widget _buildTextComposer(bool isSmallScreen) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8.0 : 12.0,
          vertical: isSmallScreen ? 6.0 : 8.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isSmallScreen ? 28.0 : 24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _isLoading ? null : _handleSubmitted,
                minLines: 1,
                maxLines: isSmallScreen ? 3 : 4,
                decoration: InputDecoration(
                  hintText: selectedLanguage == 'English'
                      ? 'Send a message to Dr. Iris...'
                      : 'डॉ. आइरिस को संदेश भेजें...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12.0 : 16.0,
                    vertical: isSmallScreen ? 10.0 : 12.0,
                  ),
                ),
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.black, // ensure typing text appears black for visibility
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(4.0),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  size: isSmallScreen ? 20 : 24,
                ),
                onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build time slot buttons.

  Widget _buildHeader() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    return Row(
      children: [
        CircleAvatar(
          radius: isSmallScreen ? 20 : 24,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: const Icon(Icons.psychology_alt, color: Colors.white),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedLanguage == 'English' ? 'Dr. Iris Therapy' : 'डॉ. आइरिस थेरेपी',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                selectedLanguage == 'English'
                    ? 'AI Therapist • Emotional Support'
                    : 'एआई चिकित्सक • भावनात्मक सहायता',
                style: TextStyle(
                  fontSize: isSmallScreen ? 11 : 13,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Text(
            selectedLanguage == 'English' ? 'हि' : 'EN',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            setState(() {
              selectedLanguage = selectedLanguage == 'English' ? 'Hindi' : 'English';
            });
            _persistLanguage();
          },
        ),
      ],
    );
  }
}

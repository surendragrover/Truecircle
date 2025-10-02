import 'package:flutter/material.dart';
import 'dart:math';
import '../core/service_locator.dart';
import '../services/on_device_ai_service.dart';
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
  
  // 1. Service Locator से AI Service को access करना - प्लेटफॉर्म की चिंता किए बिना
  OnDeviceAIService? _aiService;
  bool _serviceAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeAIService();
    
    // Initial welcome message from Dr. Iris
    _messages.add(ChatMessage(
      selectedLanguage == 'English'
          ? 'Hello! I\'m Dr. Iris, your emotional therapist. I\'m analyzing your emotional data to provide personalized insights. How can I help you today?'
          : 'नमस्ते! मैं डॉ. आइरिस हूँ, आपकी इमोशनल थेरेपिस्ट। मैं आपके भावनात्मक डेटा का विश्लेषण कर रही हूँ। आज मैं आपकी कैसे मदद कर सकती हूँ?',
    ));
  }

  // 2. AI Service को initialize करना - प्लेटफॉर्म की चिंता किए बिना
  void _initializeAIService() {
    try {
      _aiService = ServiceLocator.instance.get<OnDeviceAIService>();
      _serviceAvailable = true;
      debugPrint('✅ Dr. Iris: AI Service initialized successfully');
    } catch (e) {
      _serviceAvailable = false;
      debugPrint('⚠️ Dr. Iris: AI Service not available, using sample responses: $e');
    }
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
        response = await _aiService!.generateDrIrisResponse(text);
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Fixed header with proper mobile sizing
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade800,
                    Colors.blue.shade600.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: _buildHeader(),
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
  Widget _buildTimeSlot(String englishText, String hindiText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement scheduling logic.
        },
        child: Text(selectedLanguage == 'English' ? englishText : hindiText),
      ),
    );
  }

  Widget _buildHeader() {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back, 
                    color: Colors.white, 
                    size: isSmallScreen ? 20 : 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                CircleAvatar(
                  radius: isSmallScreen ? 18 : 22,
                  backgroundImage: const AssetImage('assets/images/avatar.png'),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedLanguage == 'English'
                            ? 'Dr. Iris Therapy'
                            : 'डॉ. आइरिस थेरेपी',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        selectedLanguage == 'English'
                            ? 'AI Therapist • Your Personal Assistant'
                            : 'एआई चिकित्सक • आपकी व्यक्तिगत सहायक',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Language toggle button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Text(
                      selectedLanguage == 'English' ? 'हि' : 'EN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedLanguage = selectedLanguage == 'English' ? 'Hindi' : 'English';
                      });
                    },
                  ),
                ),
              ],
            ),
            // Sample data indicator
            if (!widget.isFullMode)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      selectedLanguage == 'English'
                          ? 'Analyzing your emotional patterns'
                          : 'आपके भावनात्मक पैटर्न का विश्लेषण',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            // Conditionally show the scheduling UI only in full mode.
            if (widget.isFullMode)
              Padding(
                padding: EdgeInsets.only(top: isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                        selectedLanguage == 'English'
                            ? 'Choose your preferred session time:'
                            : 'अपना पसंदीदा सेशन समय चुनें:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500, 
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      _buildTimeSlot('Morning (9:00 AM - 12:00 PM)',
                          'सुबह (9:00 AM - 12:00 PM)'),
                      _buildTimeSlot('Afternoon (1:00 PM - 4:00 PM)',
                          'दोपहर (1:00 PM - 4:00 PM)'),
                      _buildTimeSlot(
                          'Evening (5:00 PM - 8:00 PM)', 'शाम (5:00 PM - 8:00 PM)'),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue, size: isSmallScreen ? 18 : 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedLanguage == 'English'
                                    ? 'Full personalized sessions available in full mode.'
                                    : 'पूर्ण व्यक्तिगत सेशन पूर्ण मोड में उपलब्ध हैं।',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
              ),
          ],
        ),
       ),
    );
  }
}

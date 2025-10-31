import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../core/service_locator.dart';
import '../services/on_device_ai_service.dart';
import '../services/coin_reward_service.dart';
import '../services/profanity_filter.dart';

class DrIrisChatPage extends StatefulWidget {
  const DrIrisChatPage({super.key});

  @override
  State<DrIrisChatPage> createState() => _DrIrisChatPageState();
}

class _DrIrisChatPageState extends State<DrIrisChatPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  late OnDeviceAIService _aiService;

  bool _isLoading = false;
  bool _showTypingIndicator = false;
  AnimationController? _typingAnimationController;
  AnimationController? _coinAnimationController;
  Animation<double>? _coinAnimation;
  final bool _showCoinAnimation = false;

  @override
  void initState() {
    super.initState();
    _aiService = ServiceLocator.instance.get<OnDeviceAIService>();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _coinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _coinAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _coinAnimationController!,
        curve: Curves.elasticOut,
      ),
    );
    _loadChatHistory();
    _showWelcomeMessage();
    _initializeAIService();
  }

  Future<void> _initializeAIService() async {
    try {
      final isSupported = await _aiService.isSupported();
      debugPrint('AI Service supported: $isSupported');

      if (isSupported) {
        final initialized = await _aiService.initialize();
        debugPrint('AI Service initialized: $initialized');
      } else {
        debugPrint(
          'AI Service not supported on this device, will use fallback responses',
        );
      }
    } catch (e) {
      debugPrint('Failed to initialize AI service: $e');
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final box = await Hive.openBox('dr_iris_chat');
      final history = box.get('chat_messages', defaultValue: <Map>[]);

      setState(() {
        _messages.clear();
        for (final messageData in history) {
          _messages.add(
            ChatMessage(
              text: messageData['text'] ?? '',
              isFromDrIris: messageData['isFromDrIris'] ?? false,
              timestamp: DateTime.parse(
                messageData['timestamp'] ?? DateTime.now().toIso8601String(),
              ),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final box = await Hive.openBox('dr_iris_chat');
      final history = _messages.map((message) {
        return {
          'text': message.text,
          'isFromDrIris': message.isFromDrIris,
          'timestamp': message.timestamp.toIso8601String(),
        };
      }).toList();

      await box.put('chat_messages', history);
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  void _showWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMessage = ChatMessage(
        text:
            "As soon as the app finished setup, it switched itself to offline mode. Everything you do here stays on your device and never leaves it. You can delete the app's logs at any time. So you can speak openly with Dr. Iris—your privacy is safe.",
        isFromDrIris: true,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(welcomeMessage);
      });
      _saveChatHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/Avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.purple,
                        size: 20,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Dr. Iris',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // User Wallet - Coin Display
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: InkWell(
              onTap: () => _showWallet(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/TrueCircle_Coin.png',
                    width: 18,
                    height: 18,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 18,
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  FutureBuilder<int>(
                    future: CoinRewardService.instance.getUserCoinsCount(),
                    builder: (context, snapshot) {
                      final coins = snapshot.data ?? 0;
                      return Text(
                        '$coins',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'copy':
                  _copyConversation();
                  break;
                case 'export':
                  _exportConversation();
                  break;
                case 'clear':
                  _clearConversation();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 12),
                    Text('Copy Conversation'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 12),
                    Text('Export as File'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 12),
                    Text('Clear Conversation'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_showTypingIndicator ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    return _ChatBubble(message: _messages[index]);
                  },
                ),
              ),
              _buildMessageInput(),
            ],
          ),
          // Coin Animation Overlay
          if (_showCoinAnimation)
            Positioned(
              top: 100,
              right: 20,
              child: AnimatedBuilder(
                animation: _coinAnimation!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.5 + (_coinAnimation!.value * 1.5),
                    child: Transform.rotate(
                      angle:
                          _coinAnimation!.value * 6.28 * 3, // 3 full rotations
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/TrueCircle_Coin.png',
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.monetization_on,
                                color: Color(0xFF8B4513),
                                size: 40,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.purple[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, color: Colors.purple, size: 24),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(
                  16,
                ).copyWith(topLeft: const Radius.circular(4)),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: AnimatedBuilder(
                animation: _typingAnimationController!,
                builder: (context, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity:
                                (_typingAnimationController!.value * 3 - index)
                                        .clamp(0.0, 1.0) >
                                    0.5
                                ? 1.0
                                : 0.3,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.purple[400],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 8),
                      const Text(
                        'Thinking…',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B21A8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Share what\'s on your mind...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.purple[400]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.purple[400],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Profanity filter: block sending offensive content to Dr. Iris
    if (ProfanityFilter.hasProfanity(text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please avoid offensive language. Your message was not sent.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final userMessage = ChatMessage(
      text: text,
      isFromDrIris: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
      _showTypingIndicator = true;
    });

    _messageController.clear();
    _scrollToBottom();
    await _saveChatHistory();

    try {
      // Show enhanced thinking mode with visible progress
      await Future.delayed(const Duration(milliseconds: 1000));

      // Add thinking message with animated dots (English)
      final thinkingMessage = ChatMessage(
        text:
            "🤔 Dr. Iris is thinking…\n\n💭 Processing your message\n⚡ Preparing the best response\n🎯 Thinking Mode…",
        isFromDrIris: true,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(thinkingMessage);
        _showTypingIndicator = false; // Hide typing, show thinking
      });

      _scrollToBottom();

      // Show thinking for 3 seconds so user can see
      await Future.delayed(const Duration(milliseconds: 3000));

      String response;
      try {
        response = await _aiService.generateDrIrisResponse(text);
        // Ensure response is not empty
        if (response.trim().isEmpty) {
          throw Exception('AI service returned empty response');
        }
      } catch (e) {
        debugPrint('AI service failed, using contextual fallback: $e');
        response = _getContextualFallbackResponse(text);
      }

      // Remove thinking message before adding real response
      setState(() {
        if (_messages.isNotEmpty &&
            (_messages.last.text.contains("Thinking Mode") ||
                _messages.last.text.contains("Dr. Iris is thinking"))) {
          _messages.removeLast();
        }
      });

      final drIrisMessage = ChatMessage(
        text: response,
        isFromDrIris: true,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.add(drIrisMessage);
        _isLoading = false;
        _showTypingIndicator = false;
      });

      _scrollToBottom();
      await _saveChatHistory();

      // No rewards for chatting with Dr. Iris (as per app rules)
    } catch (e) {
      setState(() {
        _isLoading = false;
        _showTypingIndicator = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Profanity filtering handled by ProfanityFilter service

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getContextualFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // Crisis situations - highest priority for safety
    if (message.contains('kill myself') ||
        message.contains('suicide') ||
        message.contains('end it all') ||
        message.contains("don't want to live")) {
      return "I'm deeply concerned about you, and I'm so grateful you trusted me with these thoughts. Your life matters immensely, even when everything feels hopeless. Please focus on staying safe right now. Are you in a safe place? If you're in immediate danger, please reach out to emergency services or a crisis helpline immediately.";
    }

    // Deep loss and devastation - core emotional trauma
    if (message.contains('lost everything') ||
        message.contains('lost all') ||
        message.contains('nothing left') ||
        message.contains('destroyed my life')) {
      return "Losing everything is devastating, but recovery is possible. Immediate steps: 1) Secure basic needs - reach out to local support services for food/shelter. 2) Connect with family/friends who care, even if it's hard. 3) Document what happened for potential legal/insurance help. 4) Take it one day at a time - you've survived 100% of your worst days. 5) Consider counseling for trauma processing. What's your most urgent need right now - practical support or emotional support?";
    }

    // Long-term depression with specific details (11 years, not smiled)
    if ((message.contains('not smiled') ||
            message.contains("can't smile") ||
            message.contains("haven't smiled")) &&
        (message.contains('years') ||
            message.contains('11') ||
            message.contains('long time'))) {
      return "11 years is a long journey with depression, but healing is possible. Start here: 1) Try 5 minutes of morning sunlight daily - it helps reset your brain chemistry. 2) Write down 3 tiny things that went okay each day. 3) Move your body for just 2 minutes - even stretching helps. 4) Consider professional help - therapy has helped millions recover. Your brain can rewire itself for joy again. Which of these feels most doable today?";
    }

    // Homelessness and living instability
    if (message.contains('gypsy') ||
        message.contains('homeless') ||
        message.contains('living like') ||
        message.contains('nowhere to go') ||
        message.contains('no place to stay')) {
      return "Housing instability is exhausting. Immediate action steps: 1) Contact local homeless services/shelters for emergency housing. 2) Visit libraries for internet, warmth, and job search. 3) Look into government assistance programs. 4) Connect with local food banks. 5) Keep important documents safe and accessible. Your situation can improve - many have rebuilt from here. Do you know about local support services in your area?";
    }

    // Family trauma causing major disruption
    if (message.contains('family') &&
        (message.contains('lost everything') ||
            message.contains('destroyed') ||
            message.contains('due to my family') ||
            message.contains('because of'))) {
      return "Family wounds cut the deepest because they're supposed to be our foundation of safety and love. When the people closest to us cause us to lose everything, it shakes our very sense of identity and belonging. I'm so sorry you've experienced this kind of betrayal and destruction from those who should have protected you. How are you processing this family trauma?";
    }

    // Greetings with immediate help requests - prioritize emotional need
    if ((message.contains('hi') || message.contains('hello')) &&
        (message.contains('help') ||
            message.contains('please') ||
            message.contains('can you'))) {
      return "Hello! I'm Dr. Iris, your emotional wellness companion. I can hear in your message that you're reaching out for support, and I'm completely here for you. I listen without judgment and hold space for whatever you're experiencing. What's weighing most heavily on your heart today?";
    }

    // Extended suffering and chronic pain patterns
    if ((message.contains('years') ||
            message.contains('long time') ||
            message.contains('always')) &&
        (message.contains('sad') ||
            message.contains('depressed') ||
            message.contains('pain') ||
            message.contains('suffering'))) {
      return "Carrying emotional pain for years requires incredible endurance of the human spirit. Your suffering has been a long, difficult companion, and I imagine you've had to develop ways of surviving that others might not understand. The fact that you're still here, still reaching out, tells me about your deep inner strength. What has this long journey with pain been like for you?";
    }

    // Recent trauma or life changes
    if (message.contains('since') &&
        (message.contains('then') ||
            message.contains('that') ||
            message.contains('everything changed'))) {
      return "It sounds like there was a specific moment or event that changed everything for you. Sometimes life has these devastating turning points where nothing feels the same afterward. Your experience of 'before' and 'after' is so real and valid. Can you tell me about what changed and how you've been coping since then?";
    }

    // General family dysfunction and abuse
    if (message.contains('family') &&
        (message.contains('hurt') ||
            message.contains('abuse') ||
            message.contains('toxic') ||
            message.contains('never') ||
            message.contains('always'))) {
      return "Family relationships that cause us harm create some of the deepest wounds because they violate our basic need for safety and unconditional love. Growing up or living in a harmful family environment affects how we see ourselves and the world. Your feelings about your family situation are completely valid. What aspect of your family dynamics has been most painful for you?";
    }

    // Simple greetings - warm but brief for short messages
    if ((message.contains('hi') ||
            message.contains('hello') ||
            message.contains('hey')) &&
        message.length < 25) {
      return "Hello! I'm Dr. Iris, your emotional wellness companion. I'm here to listen with my whole heart, without any judgment. Whatever you're carrying today - whether it's pain, confusion, hope, or anything in between - it's welcome here. What's alive in your heart right now?";
    }

    // Sadness and depression - differentiate intensity levels
    if (message.contains('depressed') ||
        message.contains('depression') ||
        (message.contains('sad') &&
            (message.contains('so') ||
                message.contains('very') ||
                message.contains('really') ||
                message.contains('extremely')))) {
      return "I hear the depth of sadness in your words, and I want you to know that what you're feeling is completely valid and important. Depression and deep sadness often carry messages about what matters most to us, even when the pain feels unbearable. I'm here to sit with you in this difficult emotional space. What is your sadness trying to tell you about your life or your needs?";
    }

    // General sadness
    if (message.contains('sad') ||
        message.contains('down') ||
        message.contains('crying') ||
        message.contains('tears')) {
      return "Your sadness is real and it matters. Even when it's painful, sadness is part of the full human experience and often signals that something important to you needs attention or care. I'm here to listen and understand what you're going through. What's behind these sad feelings you're experiencing?";
    }

    // Anxiety and overwhelming feelings
    if (message.contains('anxious') ||
        message.contains('anxiety') ||
        message.contains('panic') ||
        message.contains('overwhelmed') ||
        message.contains('scared')) {
      return "For anxiety relief, try this NOW: 1) 4-7-8 breathing: inhale 4, hold 7, exhale 8. Repeat 4 times. 2) Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste. 3) Cold water on wrists or face. 4) Tell yourself 'This feeling will pass, I am safe.' If panic continues, consider professional help. Which technique feels most helpful right now?";
    }

    // Relationship and interpersonal pain
    if (message.contains('relationship') ||
        message.contains('partner') ||
        message.contains('friend') ||
        message.contains('people') ||
        message.contains('trust')) {
      return "Relationships touch the deepest parts of who we are - our need for connection, understanding, and belonging. Whether you're dealing with conflict, loss, betrayal, or confusion in relationships, these experiences shape us profoundly. Your feelings about your relationships are important and valid. What's happening in your relational world that's affecting you most?";
    }

    // Trauma and abuse history
    if (message.contains('trauma') ||
        message.contains('abuse') ||
        message.contains('hurt me') ||
        message.contains('damaged') ||
        message.contains('ptsd')) {
      return "Trauma lives in our bodies and minds in complex ways, affecting how we experience ourselves and the world around us. What you've survived required immense strength, even if it doesn't feel that way. Your nervous system did everything it could to protect you through something incredibly difficult. How are you feeling in your body and heart as you share this with me?";
    }

    // Anger and rage
    if (message.contains('angry') ||
        message.contains('rage') ||
        message.contains('furious') ||
        message.contains('hate') ||
        message.contains('mad')) {
      return "Anger is powerful emotional energy that often carries crucial information about our boundaries, values, and unmet needs. It wants to protect something important or change something that feels wrong or unfair. Your anger makes complete sense, even when it feels overwhelming or scary. What do you think your anger is trying to protect or communicate about your situation?";
    }

    // Loneliness and isolation
    if (message.contains('alone') ||
        message.contains('lonely') ||
        message.contains('no one') ||
        message.contains('isolated') ||
        message.contains('nobody')) {
      return "Loneliness is one of the most painful human experiences because we're fundamentally wired for connection and belonging. When we feel isolated, it affects everything - our thoughts, our emotions, our sense of worth and meaning. Your reaching out to me shows courage and wisdom, even in your solitude. What does this loneliness feel like in your body and heart?";
    }

    // Help-seeking and desperation
    if (message.contains('help') ||
        message.contains('support') ||
        message.contains("don't know what to do") ||
        message.contains('desperate')) {
      return "Asking for help is one of the bravest and wisest things we can do as human beings. It shows self-awareness, hope, and inner strength, even when everything feels impossible or hopeless. I'm deeply honored that you're trusting me with whatever you're carrying right now. What feels most urgent or heavy in your heart that you'd like support with?";
    }

    // Physical health affecting emotional health
    if (message.contains('sick') ||
        message.contains('pain') ||
        message.contains('illness') ||
        message.contains('health') ||
        message.contains('tired')) {
      return "Physical and emotional pain often interweave and amplify each other in complex ways. Dealing with health challenges requires both physical and emotional resilience, and it can be exhausting on every level. How is your physical situation affecting your emotional and mental wellbeing right now?";
    }

    // Work and financial stress
    if (message.contains('work') ||
        message.contains('job') ||
        message.contains('money') ||
        message.contains('financial') ||
        message.contains('fired')) {
      return "Work and financial stress touch our fundamental needs for security, purpose, and survival. These pressures can affect every aspect of our wellbeing and relationships. When our livelihood feels threatened or unstable, it creates ripple effects throughout our emotional world. How is this work or financial situation impacting your daily life and emotional health?";
    }

    // Emotionally intelligent default responses with natural variation
    final responses = [
      "I sense there's something significant you want to share, and I'm here to receive it with my whole heart and full attention. Your inner world, your experiences, and your emotions all matter deeply to me. What's stirring most strongly inside you right now?",
      "Thank you for trusting me with whatever you're experiencing or feeling. Every emotion you have is welcome in this space, and your story - whatever it contains - matters profoundly. What would help you feel most heard and understood today?",
      "I can feel that you're carrying something important, and I want to understand your experience as deeply and compassionately as I possibly can. Your thoughts and feelings deserve attention and care. What's asking for the most attention in your heart or mind right now?",
      "You've taken a brave and meaningful step by reaching out, and I want you to know I don't take that trust lightly. Sometimes finding the right words for our inner experience is the hardest part of sharing. What feels most true and authentic for you in this moment?",
      "I'm here to walk alongside you, wherever you are emotionally and whatever you're going through. Your feelings, your thoughts, and your lived experiences are all important to me. What part of your inner world would you most like to explore together today?",
    ];

    // Use message content hash for consistent but naturally varied responses
    final index = userMessage.hashCode.abs() % responses.length;
    return responses[index];
  }

  Future<void> _clearConversation() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text(
          'Are you sure you want to clear all messages? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      setState(() {
        _messages.clear();
      });
      await _saveChatHistory();
      _showWelcomeMessage();
    }
  }

  Future<void> _exportConversation() async {
    try {
      if (_messages.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No messages to export.')));
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final ts = DateTime.now();
      final fname =
          'dr_iris_chat_${ts.year}${ts.month.toString().padLeft(2, '0')}${ts.day.toString().padLeft(2, '0')}_${ts.hour.toString().padLeft(2, '0')}${ts.minute.toString().padLeft(2, '0')}';
      final file = File('${dir.path}/$fname.txt');

      final buffer = StringBuffer();
      buffer.writeln('Dr. Iris — Chat Export');
      buffer.writeln('Generated: ${ts.toLocal()}');
      buffer.writeln('');
      for (final m in _messages) {
        final who = m.isFromDrIris ? 'Dr. Iris' : 'You';
        final time = m.timestamp.toLocal().toIso8601String();
        buffer.writeln('[$time] $who:');
        buffer.writeln(m.text);
        buffer.writeln('');
      }

      await file.writeAsString(buffer.toString());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chat exported to ${file.path}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export chat.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _copyConversation() async {
    try {
      if (_messages.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No messages to copy.')));
        return;
      }
      final ts = DateTime.now();
      final buffer = StringBuffer();
      buffer.writeln('Dr. Iris — Chat Copy');
      buffer.writeln('Generated: ${ts.toLocal()}');
      buffer.writeln('');
      for (final m in _messages) {
        final who = m.isFromDrIris ? 'Dr. Iris' : 'You';
        final time = m.timestamp.toLocal().toIso8601String();
        buffer.writeln('[$time] $who:');
        buffer.writeln(m.text);
        buffer.writeln('');
      }

      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to copy chat.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController?.dispose();
    _coinAnimationController?.dispose();
    super.dispose();
  }

  // Coin reward animation removed: no rewards for chatting with Dr. Iris

  void _showWallet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/TrueCircle_Coin.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 32,
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My Wallet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Current Balance
            Container(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<int>(
                future: CoinRewardService.instance.getUserCoinsCount(),
                builder: (context, snapshot) {
                  final coins = snapshot.data ?? 0;
                  return Column(
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/TrueCircle_Coin.png',
                            width: 28,
                            height: 28,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.monetization_on,
                                color: Colors.amber,
                                size: 28,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$coins Coins',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            // Information Sections
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWalletInfoSection('💰 How to Earn Coins', [
                      'Daily login: 1 coin per day',
                      'Complete a full entry: 1 coin',
                      'Note: No rewards for chatting with Dr. Iris',
                    ]),
                    const SizedBox(height: 20),
                    _buildWalletInfoSection('🛍️ How to Spend Coins', [
                      '1 Coin = ₹1 shopping discount',
                      'Use at marketplace for premium features',
                      'Redeem for exclusive content',
                      'Save up for special rewards',
                    ]),
                    const SizedBox(height: 20),
                    _buildWalletInfoSection('📊 Coin Types', [
                      'Available coins: ready to spend',
                      'Total coins: lifetime earnings',
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletInfoSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                Expanded(child: Text(point)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isFromDrIris;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromDrIris,
    required this.timestamp,
  });
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: message.isFromDrIris
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (message.isFromDrIris) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/Avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.purple[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.purple,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isFromDrIris
                    ? Colors.purple[50]
                    : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16).copyWith(
                  topLeft: message.isFromDrIris
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                  topRight: message.isFromDrIris
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                ),
                border: Border.all(
                  color: message.isFromDrIris
                      ? Colors.purple[200]!
                      : Theme.of(context).primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.isFromDrIris ? 'Dr. Iris' : 'You',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: message.isFromDrIris
                          ? Colors.purple[700]
                          : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: message.isFromDrIris
                          ? Colors.purple[800]
                          : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          if (!message.isFromDrIris) ...[
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

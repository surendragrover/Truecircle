import 'package:flutter/material.dart';
import 'dart:math';
import 'package:true_circle/services/huggingface_service.dart';

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
  late final HuggingFaceService _huggingFaceService;
  bool _isLoading = false;

  String selectedLanguage = 'English';

  // Sample data for generating responses in demo mode.
  final Map<String, List<String>> _demoResponses = {
    'relationship': [
      'Healthy relationships require open communication. What specific challenges are you facing?',
      'Every relationship has ups and downs. Let\'s identify patterns that might be affecting yours.'
    ],
    'stress': [
      'Stress is your body\'s natural response. Let\'s find healthy ways to manage it.',
      'Deep breathing can be incredibly powerful. Have you tried any mindfulness techniques?'
    ],
    'feeling': [
      'I understand you\'re going through a challenging time. Let\'s work through this together.',
      'Your feelings are completely valid. How long have you been experiencing this?'
    ],
    'default': [
      'Tell me more about that.',
      'How does that make you feel?',
      'I\'m here to listen. Please continue.'
    ]
  };

  @override
  void initState() {
    super.initState();
    _huggingFaceService = const HuggingFaceService();
    // Initial welcome message from Dr. Iris.
    _messages.add(ChatMessage(
      selectedLanguage == 'English'
          ? 'Hello! I\'m Dr. Iris, your personal AI therapist. How can I help you today?'
          : 'नमस्ते! मैं डॉ. आइरिस हूँ, आपकी व्यक्तिगत AI चिकित्सक। आज मैं आपकी कैसे मदद कर सकती हूँ?',
    ));
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.insert(0, ChatMessage(text, isUser: true));
      _isLoading = true;
    });

    if (widget.isFullMode) {
      try {
        final response = await _huggingFaceService.getChatResponse(text);
        _addBotMessage(response);
      } catch (e) {
        _addBotMessage('Sorry, I am having trouble connecting. Please try again.');
      }
    } else {
      // Simulate Dr. Iris's response after a short delay in demo mode.
      Future.delayed(const Duration(milliseconds: 500), () {
        _generateDemoResponse(text);
      });
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

  void _generateDemoResponse(String userInput) {
    String responseKey = 'default';
    if (userInput.toLowerCase().contains('relationship')) {
      responseKey = 'relationship';
    } else if (userInput.toLowerCase().contains('stress')) {
      responseKey = 'stress';
    } else if (userInput.toLowerCase().contains('feel') || userInput.toLowerCase().contains('sad')) {
      responseKey = 'feeling';
    }

    final responses = _demoResponses[responseKey]!;
    final response = responses[Random().nextInt(responses.length)];

    _addBotMessage(response);
  }

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
        child: Column(
          children: [
            _buildHeader(),
            // The chat UI is always present.
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length,
                itemBuilder: (_, int index) =>
                    _buildMessageItem(_messages[index]),
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          if (!message.isUser)
            const CircleAvatar(
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
          const SizedBox(width: 8.0),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue[300] : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                message.text,
                style: message.isUser
                    ? const TextStyle(color: Colors.white)
                    : const TextStyle(color: Colors.black87),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8.0),
          if (message.isUser)
            const CircleAvatar(child: Icon(Icons.person)),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _isLoading ? null : _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message to Dr. Iris...',
                  contentPadding: EdgeInsets.only(left: 16.0)
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
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
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column( // Use a column to stack the main header and the scheduling part
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage('assets/images/avatar.png'),
                ),
                const SizedBox(width: 16),
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
                      Text(
                        selectedLanguage == 'English'
                            ? 'Your AI Therapist' // This is the resolved line
                            : 'आपका एआई चिकित्सक',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Conditionally show the scheduling UI only in full mode.
            if (widget.isFullMode)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                        selectedLanguage == 'English'
                            ? 'Choose your preferred session time:'
                            : 'अपना पसंदीदा सेशन समय चुनें:',
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      _buildTimeSlot('Morning (9:00 AM - 12:00 PM)',
                          'सुबह (9:00 AM - 12:00 PM)'),
                      _buildTimeSlot('Afternoon (1:00 PM - 4:00 PM)',
                          'दोपहर (1:00 PM - 4:00 PM)'),
                      _buildTimeSlot(
                          'Evening (5:00 PM - 8:00 PM)', 'शाम (5:00 PM - 8:00 PM)'),
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
                                    ? 'Full personalized sessions are available in the full-functional mode.'
                                    : 'पूर्ण व्यक्तिगत सेशन पूर्ण-कार्यात्मक मोड में उपलब्ध हैं।',
                                style: TextStyle(
                                  fontSize: 12,
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

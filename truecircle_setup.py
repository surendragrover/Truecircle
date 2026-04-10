# truecircle_setup.py
# Run: python truecircle_setup.py

import os
import sys

BASE_DIR = r"C:\Users\suren\flutter_app\truecircle"

def create_file(path, content):
    """Create file with given content"""
    full_path = os.path.join(BASE_DIR, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Created: {path}")

def create_folders():
    """Create all necessary folders"""
    folders = [
        "lib/core/constants",
        "lib/core/theme",
        "lib/data/models",
        "lib/providers",
        "lib/screens",
        "lib/services/brains",
        "assets/data",
        "assets/onnx_models",
        "assets/images"
    ]
    for folder in folders:
        os.makedirs(os.path.join(BASE_DIR, folder), exist_ok=True)
    print("Folders created")

def create_pubspec():
    """Create pubspec.yaml"""
    content = """name: truecircle
description: TrueCircle AI - Offline Mental Health Companion
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  provider: ^6.1.1
  onnxruntime: ^1.4.1
  record: ^5.0.4
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1
  path: ^1.8.3
  intl: ^0.19.0
  google_fonts: ^6.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/data/
    - assets/onnx_models/
    - assets/images/
"""
    create_file("pubspec.yaml", content)

def create_main_dart():
    """Create lib/main.dart"""
    content = """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrueCircleApp());
}

class TrueCircleApp extends StatelessWidget {
  const TrueCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'TrueCircle',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const ChatScreen(),
      ),
    );
  }
}
"""
    create_file("lib/main.dart", content)

def create_app_constants():
    """Create lib/core/constants/app_constants.dart"""
    content = """class AppConstants {
  static const String brainAPath = 'assets/onnx_models/brainA.onnx';
  static const String brain1Path = 'assets/onnx_models/Brain_1_FP16.onnx';
  static const String brain2Path = 'assets/onnx_models/brain2.onnx';
  static const String vocabPath = 'assets/data/vocab.json';
  static const String appName = 'TrueCircle';
  static const String supportWhatsApp = '+91 8690888121';
}
"""
    create_file("lib/core/constants/app_constants.dart", content)

def create_app_theme():
    """Create lib/core/theme/app_theme.dart"""
    content = """import 'package:flutter/material.dart';

class AppTheme {
  static const Color indigoMain = Color(0xFF3F51B5);
  static const Color purpleMain = Color(0xFF9C27B0);
  
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [indigoMain, purpleMain],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: indigoMain,
        primary: indigoMain,
        secondary: purpleMain,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FE),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: indigoMain,
        foregroundColor: Colors.white,
      ),
    );
  }
}
"""
    create_file("lib/core/theme/app_theme.dart", content)

def create_chat_message():
    """Create lib/data/models/chat_message.dart"""
    content = """class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
"""
    create_file("lib/data/models/chat_message.dart", content)

def create_chat_provider():
    """Create lib/providers/chat_provider.dart"""
    content = """import 'package:flutter/material.dart';
import '../data/models/chat_message.dart';
import '../services/brains/three_brain_pipeline.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final ThreeBrainPipeline _pipeline = ThreeBrainPipeline();
  
  bool _isProcessing = false;
  bool _isRecording = false;
  bool _isInitialized = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isProcessing => _isProcessing;
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;

  ChatProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _pipeline.initialize();
      _isInitialized = true;
      _addBotMessage('Welcome to TrueCircle. I am here to listen. How are you feeling today?');
    } catch (e) {
      _addBotMessage('System initialization in progress...');
    }
    notifyListeners();
  }

  void _addBotMessage(String text) {
    _messages.add(ChatMessage(text: text, isUser: false));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    _messages.add(ChatMessage(text: text, isUser: true));
    _isProcessing = true;
    notifyListeners();

    try {
      final response = await _pipeline.processInput(text);
      _messages.add(ChatMessage(text: response, isUser: false));
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'I apologize, I am having trouble processing that. Could you try again?',
        isUser: false
      ));
    }
    
    _isProcessing = false;
    notifyListeners();
  }

  Future<void> toggleRecording() async {
    if (!_isRecording) {
      _isRecording = true;
      notifyListeners();
      await _pipeline.startListening();
    } else {
      _isRecording = false;
      _isProcessing = true;
      notifyListeners();
      
      final voiceText = await _pipeline.stopAndProcessVoice();
      if (voiceText.isNotEmpty) {
        await sendMessage(voiceText);
      }
      
      _isProcessing = false;
      notifyListeners();
    }
  }
}
"""
    create_file("lib/providers/chat_provider.dart", content)

def create_three_brain_pipeline():
    """Create lib/services/brains/three_brain_pipeline.dart"""
    content = """import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import '../../core/constants/app_constants.dart';

class ThreeBrainPipeline {
  OrtSession? _sessionA;
  OrtSession? _session1;
  OrtSession? _session2;
  bool _isLoaded = false;

  Future<void> initialize() async {
    try {
      OrtEnv.instance.init();
      _sessionA = await _loadModel(AppConstants.brainAPath);
      _session1 = await _loadModel(AppConstants.brain1Path);
      _session2 = await _loadModel(AppConstants.brain2Path);
      _isLoaded = true;
    } catch (e) {
      print('Model load error: $e');
    }
  }

  Future<OrtSession?> _loadModel(String path) async {
    try {
      final rawAssetFile = await rootBundle.load(path);
      final bytes = rawAssetFile.buffer.asUint8List();
      return OrtSession.fromBuffer(bytes, OrtSessionOptions());
    } catch (e) {
      print('Failed to load $path: $e');
      return null;
    }
  }

  Future<void> startListening() async {
    print('Recording started...');
  }

  Future<String> stopAndProcessVoice() async {
    return 'Voice processing not yet implemented';
  }

  Future<String> processInput(String text) async {
    if (!_isLoaded) {
      return 'TrueCircle is still initializing. Please wait.';
    }
    return _generateResponse(text);
  }

  String _generateResponse(String input) {
    final lowerInput = input.toLowerCase();
    if (lowerInput.contains('sad') || lowerInput.contains('depress')) {
      return 'I hear that you are going through a difficult time. Would you like to talk more about what is bothering you?';
    } else if (lowerInput.contains('anxious') || lowerInput.contains('worried')) {
      return 'Anxiety can be overwhelming. Let us work through this together. What is on your mind?';
    } else if (lowerInput.contains('happy') || lowerInput.contains('good')) {
      return 'I am glad to hear you are feeling positive. What has been going well for you?';
    }
    return 'Thank you for sharing that with me. Tell me more about how you are feeling.';
  }

  void dispose() {
    _sessionA?.release();
    _session1?.release();
    _session2?.release();
    OrtEnv.instance.release();
  }
}
"""
    create_file("lib/services/brains/three_brain_pipeline.dart", content)

def create_chat_screen():
    """Create lib/screens/chat_screen.dart"""
    content = """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../core/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        title: const Text('TrueCircle'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 8),
                SizedBox(width: 4),
                Text('Offline', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                _scrollToBottom();
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final msg = provider.messages[index];
                    return _buildMessageBubble(msg);
                  },
                );
              },
            ),
          ),
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              if (provider.isProcessing) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic msg) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser ? AppTheme.primaryGradient : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return GestureDetector(
                  onLongPress: () => provider.toggleRecording(),
                  onLongPressUp: () => provider.toggleRecording(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: provider.isRecording 
                          ? Colors.red.withOpacity(0.1) 
                          : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic,
                      color: provider.isRecording ? Colors.red : AppTheme.indigoMain,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (text) {
                  context.read<ChatProvider>().sendMessage(text);
                  _controller.clear();
                },
              ),
            ),
            const SizedBox(width: 12),
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: provider.isProcessing 
                        ? null 
                        : () {
                            provider.sendMessage(_controller.text);
                            _controller.clear();
                          },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
"""
    create_file("lib/screens/chat_screen.dart", content)

def main():
    """Main setup function"""
    print("=" * 50)
    print("TrueCircle Project Setup")
    print("=" * 50)
    
    if not os.path.exists(BASE_DIR):
        print(f"Error: {BASE_DIR} does not exist")
        print("Please create Flutter project first: flutter create truecircle")
        sys.exit(1)
    
    create_folders()
    create_pubspec()
    create_main_dart()
    create_app_constants()
    create_app_theme()
    create_chat_message()
    create_chat_provider()
    create_three_brain_pipeline()
    create_chat_screen()
    
    print("=" * 50)
    print("Setup complete!")
    print("Next steps:")
    print("1. cd C:\\Users\\suren\\flutter_app\\truecircle")
    print("2. flutter pub get")
    print("3. flutter run -d windows")
    print("=" * 50)

if __name__ == "__main__":
    main()
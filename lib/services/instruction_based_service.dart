import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class InstructionBasedService {
  static final InstructionBasedService instance = InstructionBasedService._();
  InstructionBasedService._();

  List<Map<String, dynamic>>? _instructions;

  Future<void> initialize() async {
    if (_instructions != null) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/ai/dr_iris_instructions.json',
      );
      final List<dynamic> decoded = json.decode(jsonString);
      _instructions = decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading instructions: $e');
      _instructions = [];
    }
  }

  String getResponse(String userMessage) {
    if (_instructions == null) return _getDefaultResponse();

    final message = userMessage.toLowerCase();

    // Find best matching instruction based on keywords
    for (final instruction in _instructions!) {
      final keywords = (instruction['keywords'] as List<dynamic>)
          .cast<String>();

      for (final keyword in keywords) {
        if (message.contains(keyword.toLowerCase())) {
          return instruction['response'] as String;
        }
      }
    }

    return _getDefaultResponse();
  }

  String _getDefaultResponse() {
    final responses = [
      "I'm here to listen and support you. What's on your mind?",
      "Thank you for sharing with me. How can I help you today?",
      "I want to understand what you're going through. Tell me more.",
      "Your feelings are valid. What would be helpful right now?",
      "I'm listening. What's the most important thing for you to share?",
    ];

    final index = DateTime.now().millisecondsSinceEpoch % responses.length;
    return responses[index];
  }
}

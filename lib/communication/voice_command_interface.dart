import 'package:flutter/material.dart';

/// Voice command interface for hands-free interaction with AI assistant
/// Supports natural language commands for relationship tracking
class VoiceCommandInterface extends StatefulWidget {
  final bool isListening;
  final String lastWords;
  final String emotionalState;
  final Function(String) onVoiceCommand;
  final VoidCallback onToggleListening;

  const VoiceCommandInterface({
    super.key,
    required this.isListening,
    required this.lastWords,
    required this.emotionalState,
    required this.onVoiceCommand,
    required this.onToggleListening,
  });

  @override
  State<VoiceCommandInterface> createState() => _VoiceCommandInterfaceState();
}

class _VoiceCommandInterfaceState extends State<VoiceCommandInterface>
    with TickerProviderStateMixin {
  late AnimationController _waveAnimationController;
  late AnimationController _pulseAnimationController;

  List<String> _commandHistory = [];
  List<VoiceCommandSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _waveAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _initializeSuggestions();

    if (widget.isListening) {
      _waveAnimationController.repeat();
      _pulseAnimationController.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceCommandInterface oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _waveAnimationController.repeat();
        _pulseAnimationController.repeat();
      } else {
        _waveAnimationController.stop();
        _pulseAnimationController.stop();
      }
    }

    if (widget.lastWords != oldWidget.lastWords &&
        widget.lastWords.isNotEmpty) {
      _addToCommandHistory(widget.lastWords);
    }
  }

  @override
  void dispose() {
    _waveAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _initializeSuggestions() {
    _suggestions = [
      VoiceCommandSuggestion(
        command: "Show my relationship network",
        description: "Display visual relationship map",
        category: VoiceCommandCategory.navigation,
      ),
      VoiceCommandSuggestion(
        command: "How is my relationship with [name]?",
        description: "Get specific relationship insights",
        category: VoiceCommandCategory.analysis,
      ),
      VoiceCommandSuggestion(
        command: "I want advice about relationships",
        description: "Get AI coaching and suggestions",
        category: VoiceCommandCategory.advice,
      ),
      VoiceCommandSuggestion(
        command: "Show pulse scores",
        description: "View all relationship health scores",
        category: VoiceCommandCategory.navigation,
      ),
      VoiceCommandSuggestion(
        command: "I'm feeling [emotion]",
        description: "Update emotional state for contextual advice",
        category: VoiceCommandCategory.emotional,
      ),
      VoiceCommandSuggestion(
        command: "Add conversation with [name]",
        description: "Start logging a new conversation",
        category: VoiceCommandCategory.logging,
      ),
      VoiceCommandSuggestion(
        command: "What should I work on?",
        description: "Get personalized improvement suggestions",
        category: VoiceCommandCategory.advice,
      ),
      VoiceCommandSuggestion(
        command: "Show my communication patterns",
        description: "Analyze how you communicate",
        category: VoiceCommandCategory.analysis,
      ),
    ];
  }

  void _addToCommandHistory(String command) {
    setState(() {
      _commandHistory.insert(0, command);
      if (_commandHistory.length > 10) {
        _commandHistory = _commandHistory.take(10).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVoiceInterface(),
          const SizedBox(height: 24),
          _buildEmotionalStateDisplay(),
          const SizedBox(height: 24),
          _buildCommandSuggestions(),
          const SizedBox(height: 24),
          _buildCommandHistory(),
          const SizedBox(height: 24),
          _buildVoiceCommandGuide(),
        ],
      ),
    );
  }

  Widget _buildVoiceInterface() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Microphone with animation
            GestureDetector(
              onTap: widget.onToggleListening,
              child: SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse animation
                    if (widget.isListening)
                      AnimatedBuilder(
                        animation: _pulseAnimationController,
                        builder: (context, child) {
                          return Container(
                            width: 120 + (20 * _pulseAnimationController.value),
                            height:
                                120 + (20 * _pulseAnimationController.value),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.red.withValues(
                                  alpha:
                                      0.3 *
                                      (1 - _pulseAnimationController.value),
                                ),
                                width: 2,
                              ),
                            ),
                          );
                        },
                      ),

                    // Main microphone button
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isListening ? Colors.red : Colors.blue,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (widget.isListening ? Colors.red : Colors.blue)
                                    .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              widget.isListening ? 'Listening...' : 'Tap to speak',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 8),

            if (widget.lastWords.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.lastWords,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Text(
                'Try saying "Show my relationship network" or "I need advice"',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionalStateDisplay() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getEmotionalStateIcon(widget.emotionalState),
                  color: _getEmotionalStateColor(widget.emotionalState),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Current Emotional State',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getEmotionalStateColor(
                  widget.emotionalState,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getEmotionalStateColor(
                    widget.emotionalState,
                  ).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getEmotionalStateIcon(widget.emotionalState),
                    color: _getEmotionalStateColor(widget.emotionalState),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.emotionalState.toUpperCase(),
                    style: TextStyle(
                      color: _getEmotionalStateColor(widget.emotionalState),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _getEmotionalStateAdvice(widget.emotionalState),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Say "I\'m feeling [emotion]" to update your state for better personalized advice.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandSuggestions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Command Suggestions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ...VoiceCommandCategory.values.map((category) {
              final categorySuggestions = _suggestions
                  .where((s) => s.category == category)
                  .toList();

              if (categorySuggestions.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _getCategoryName(category),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  ...categorySuggestions.map(
                    (suggestion) => _buildSuggestionTile(suggestion),
                  ),

                  const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionTile(VoiceCommandSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => widget.onVoiceCommand(suggestion.command),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(suggestion.category),
                size: 16,
                color: _getCategoryColor(suggestion.category),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.command,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      suggestion.description,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.mic, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommandHistory() {
    if (_commandHistory.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Commands',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => setState(() => _commandHistory.clear()),
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._commandHistory
                .take(5)
                .map(
                  (command) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            command,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        InkWell(
                          onTap: () => widget.onVoiceCommand(command),
                          child: Icon(
                            Icons.replay,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCommandGuide() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voice Command Tips',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ...[
              'Speak clearly and at normal pace',
              'Use natural language - the AI understands context',
              'Mention specific contact names when needed',
              'Update your emotional state for better advice',
              'Ask for specific insights about relationships',
              'Request general coaching and guidance',
            ].map(
              (tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 14,
                      color: Colors.amber.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(tip, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  IconData _getEmotionalStateIcon(String state) {
    switch (state.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'angry':
        return Icons.sentiment_dissatisfied;
      case 'anxious':
        return Icons.sentiment_neutral;
      case 'excited':
        return Icons.sentiment_very_satisfied;
      case 'confused':
        return Icons.help_outline;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _getEmotionalStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'anxious':
        return Colors.orange;
      case 'excited':
        return Colors.purple;
      case 'confused':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getEmotionalStateAdvice(String state) {
    switch (state.toLowerCase()) {
      case 'happy':
        return 'Great time to connect!';
      case 'sad':
        return 'Seek supportive friends';
      case 'angry':
        return 'Take time to cool down';
      case 'anxious':
        return 'Find calming presence';
      case 'excited':
        return 'Share your energy!';
      case 'confused':
        return 'Ask for guidance';
      default:
        return 'Stay balanced';
    }
  }

  String _getCategoryName(VoiceCommandCategory category) {
    switch (category) {
      case VoiceCommandCategory.navigation:
        return 'Navigation';
      case VoiceCommandCategory.analysis:
        return 'Analysis & Insights';
      case VoiceCommandCategory.advice:
        return 'AI Coaching';
      case VoiceCommandCategory.emotional:
        return 'Emotional State';
      case VoiceCommandCategory.logging:
        return 'Data Entry';
    }
  }

  IconData _getCategoryIcon(VoiceCommandCategory category) {
    switch (category) {
      case VoiceCommandCategory.navigation:
        return Icons.navigation;
      case VoiceCommandCategory.analysis:
        return Icons.analytics;
      case VoiceCommandCategory.advice:
        return Icons.psychology;
      case VoiceCommandCategory.emotional:
        return Icons.favorite;
      case VoiceCommandCategory.logging:
        return Icons.edit;
    }
  }

  Color _getCategoryColor(VoiceCommandCategory category) {
    switch (category) {
      case VoiceCommandCategory.navigation:
        return Colors.blue;
      case VoiceCommandCategory.analysis:
        return Colors.green;
      case VoiceCommandCategory.advice:
        return Colors.purple;
      case VoiceCommandCategory.emotional:
        return Colors.pink;
      case VoiceCommandCategory.logging:
        return Colors.orange;
    }
  }
}

// Supporting data classes
class VoiceCommandSuggestion {
  final String command;
  final String description;
  final VoiceCommandCategory category;

  VoiceCommandSuggestion({
    required this.command,
    required this.description,
    required this.category,
  });
}

enum VoiceCommandCategory { navigation, analysis, advice, emotional, logging }

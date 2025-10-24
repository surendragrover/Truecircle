import 'package:flutter/material.dart';
import '../services/dr_iris_suggestions_service.dart';
import '../services/on_device_ai_service.dart';
import '../services/prompt_generator.dart';

class DrIrisPage extends StatefulWidget {
  const DrIrisPage({super.key});

  @override
  State<DrIrisPage> createState() => _DrIrisPageState();
}

class _DrIrisPageState extends State<DrIrisPage> {
  late Future<List<String>> _future;
  late final OnDeviceAIService _ai = OnDeviceAIService.instance();
  bool _aiReady = false;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // साधारण चैट संदेश संरचना (पूरी तरह ऑफ़लाइन, इन-मैमोरी)
  final List<_ChatMsg> _messages = [];

  @override
  void initState() {
    super.initState();
    _future = DrIrisSuggestionsService.instance.getSuggestions();
    _initAI();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dr. Iris (Offline)')),
      body: FutureBuilder<List<String>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const [];
          return Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Fully offline and for educational use only. Live chat/network are disabled. You can explore the suggestions below in other modules.',
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // चैट संदेश (यदि हों)
                    if (_messages.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ..._messages.map((m) => _MessageBubble(message: m)),
                      const SizedBox(height: 16),
                      Divider(color: Theme.of(context).dividerColor),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      'Suggestions (tap to paste):',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (items.isEmpty)
                      const Text('इस समय कोई सुझाव उपलब्ध नहीं है।'),
                    ...items.map(
                      (q) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.question_answer_outlined),
                          title: Text(q),
                          onTap: () {
                            // सुझाव को इनपुट में भरें
                            _textController.text = q;
                            _textController
                                .selection = TextSelection.fromPosition(
                              TextPosition(offset: _textController.text.length),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    ), // इनपुट क्षेत्र के लिए नीचे स्पेस
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          textInputAction: TextInputAction.send,
                          decoration: const InputDecoration(
                            hintText: 'Type your question (offline reply)',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _handleSend(items),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _handleSend(items),
                        icon: const Icon(Icons.send),
                        label: const Text('Send'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _initAI() async {
    final supported = await _ai.isSupported();
    if (!mounted) return;
    if (supported) {
      final ok = await _ai.initialize();
      if (!mounted) return;
      setState(() => _aiReady = ok);
    } else {
      setState(() => _aiReady = false);
    }
  }

  void _handleSend(List<String> suggestions) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMsg(user: true, text: text));
      _textController.clear();
    });

    String reply;
    try {
      if (_aiReady) {
        // हालिया 3 यूज़र मैसेज लेकर कॉन्टेक्स्ट जोड़ें
        final recent = _messages
            .where((m) => m.user)
            .map((m) => m.text)
            .toList();
        final prompt = DrIrisPromptBuilder.build(
          userMessage: text,
          recentUserMessages: recent.isNotEmpty
              ? recent.sublist(
                  recent.length - (recent.length >= 3 ? 3 : recent.length),
                )
              : const [],
        );
        final modelReply = await _ai.generateDrIrisResponse(prompt);
        reply = (modelReply.isNotEmpty)
            ? modelReply
            : _generateOfflineReply(text, suggestions);
      } else {
        reply = _generateOfflineReply(text, suggestions);
      }
    } catch (_) {
      reply = _generateOfflineReply(text, suggestions);
    }

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMsg(user: false, text: reply));
    });

    // नीचे स्क्रॉल करें
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

  String _generateOfflineReply(String query, List<String> suggestions) {
    // बहुत साधारण मिलान: Jaccard आधारित शब्द-ओवरलैप
    final qTokens = _tokens(query);
    String? best;
    double bestScore = 0.0;
    for (final s in suggestions) {
      final sTokens = _tokens(s);
      final inter = qTokens.intersection(sTokens).length.toDouble();
      final union = qTokens.union(sTokens).length.toDouble();
      final score = union == 0 ? 0.0 : inter / union;
      if (score > bestScore) {
        bestScore = score;
        best = s;
      }
    }

    // उत्तर टेम्पलेट (शांत, तटस्थ, शैक्षिक)
    const fallbacks = [
      "I'm here offline to listen. Choose one small step: sip water, take slow breaths, and write for 2 minutes about what matters most right now.",
      'Pick one small thing you can control and gently focus on it today. Do a simple 2‑minute action that supports your attention/comfort.',
      'Try slow 4‑4 breathing: inhale 4, pause 4, exhale 4. Then write one line — “What matters most for me right now?”',
    ];

    final base =
        fallbacks[DateTime.now().millisecondsSinceEpoch % fallbacks.length];
    if (best == null || bestScore < 0.2) {
      return base;
    }

    return '$base\n\nRelated suggestion: “$best” — you can explore it in Learn/CBT modules.';
  }

  Set<String> _tokens(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z\u0900-\u097F0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toSet();
  }
}

class _ChatMsg {
  final bool user;
  final String text;
  const _ChatMsg({required this.user, required this.text});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMsg message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.user;
    final bg = isUser
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Text(message.text),
        ),
      ],
    );
  }
}

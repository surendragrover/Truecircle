import 'package:flutter/material.dart';
import 'iris_brain_router.dart';

class IrisChatScreen extends StatefulWidget {
  const IrisChatScreen({super.key});

  @override
  State<IrisChatScreen> createState() => _IrisChatScreenState();
}

class _IrisChatScreenState extends State<IrisChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<_Msg> _messages = [
    _Msg(
      fromIris: true,
      text:
          "Hi, I’m Dr. Iris.\nYou’re safe here.\nTell me what’s on your mind today.",
      time: DateTime.now(),
    ),
  ];

  bool _typing = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Msg(fromIris: false, text: text, time: DateTime.now()));
      _typing = true;
      _controller.clear();
    });

    _scrollToBottom();

    // Fake "thinking"
    await Future.delayed(const Duration(milliseconds: 700));

    final reply = IrisBrainRouter.reply(text);


    setState(() {
      _messages.add(_Msg(fromIris: true, text: reply, time: DateTime.now()));
      _typing = false;
    });

    _scrollToBottom();
  }

  String _demoReply(String userText) {
    final t = userText.toLowerCase();

    if (t.contains("stress") || t.contains("tension") || t.contains("anx")) {
      return "That sounds heavy.\n\nTry this with me:\n1) Inhale 4 sec\n2) Hold 4 sec\n3) Exhale 6 sec\n\nWant to tell me what triggered it today?";
    }

    if (t.contains("sad") || t.contains("depress") || t.contains("cry")) {
      return "I hear you.\nFeeling low doesn’t mean you’re weak.\n\nLet’s do one small step: write 1 line about what you needed today but didn’t get.";
    }

    if (t.contains("angry") || t.contains("gussa")) {
      return "Anger usually protects something important.\n\nBefore we solve it, tell me: what felt unfair in that moment?";
    }

    return "Thank you for sharing.\n\nIf we keep it simple: what is the ONE thing you want relief from right now?";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dr. Iris"),
        actions: [
          IconButton(
            tooltip: "Clear chat",
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  _Msg(
                    fromIris: true,
                    text:
                        "Hi, I’m Dr. Iris.\nYou’re safe here.\nTell me what’s on your mind today.",
                    time: DateTime.now(),
                  ),
                );
              });
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length + (_typing ? 1 : 0),
              itemBuilder: (context, index) {
                if (_typing && index == _messages.length) {
                  return const _TypingBubble();
                }
                final m = _messages[index];
                return _ChatBubble(msg: m);
              },
            ),
          ),

          // Input bar
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: "Type here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _send,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  final bool fromIris;
  final String text;
  final DateTime time;

  _Msg({required this.fromIris, required this.text, required this.time});
}

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final align = msg.fromIris ? Alignment.centerLeft : Alignment.centerRight;
    final bg = msg.fromIris ? Colors.grey.shade200 : Colors.purple.shade100;

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg.text,
          style: const TextStyle(fontSize: 14, height: 1.25),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text("Dr. Iris is typing..."),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../services/sos_service.dart';
import '../../services/three_brain_relay_service.dart';
import '../safety/sos_consent_form_screen.dart';
import 'model_compatibility_screen.dart';

class DrIrisChatScreen extends StatefulWidget {
  const DrIrisChatScreen({super.key});

  @override
  State<DrIrisChatScreen> createState() => _DrIrisChatScreenState();
}

class _DrIrisChatScreenState extends State<DrIrisChatScreen> {
  static const String _savedSnippetsKey = 'saved_chat_snippets';
  static const String _sosEligibilityStartKey =
      'sos_prompt_eligibility_start_ts';
  static const int _minDaysBeforeSosPrompt = 3;
  static const AssetImage _drIrisAvatar =
      AssetImage('assets/images/dr_iris_avatar.png');
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ThreeBrainRelayService _relay = ThreeBrainRelayService.instance;
  final stt.SpeechToText _speech = stt.SpeechToText();
  final List<RelayChatMessage> _messages = <RelayChatMessage>[];
  bool _sending = false;
  bool _isListening = false;
  bool _speechReady = false;
  bool _showSosTrustPrompt = false;
  bool _checkingSosReadiness = false;

  bool _isHindiUi(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'hi';
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _inputFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
    _controller.dispose();
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final List<RelayChatMessage> history = await _relay.getHistory();
    String introMessage = '';
    try {
      introMessage =
          (await rootBundle.loadString('assets/data/Dr_Iris.txt')).trim();
    } catch (_) {
      introMessage =
          'Hello, I am Dr Iris. I am here with you. Share what you are feeling, I will listen softly.';
    }
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(history);
      if (_messages.isNotEmpty && !_messages.first.isUser) {
        final String first = _messages.first.text.trim();
        if (first ==
                'Hello, I am Dr Iris. I am here with you while your personal intelligence gets ready.' ||
            first ==
                'Hello, I am Dr Iris. I am here with you. Share what you are feeling, I will listen softly.') {
          _messages[0] = RelayChatMessage(
            text: introMessage,
            isUser: false,
            timestamp: _messages.first.timestamp,
          );
        }
      }
      if (_messages.isEmpty) {
        _messages.add(
          RelayChatMessage(
            text: introMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }
    });
    await _refreshSosTrustPrompt();
  }

  Future<void> _send() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    _controller.clear();
    _inputFocusNode.requestFocus();

    setState(() {
      _sending = true;
      _messages.add(
        RelayChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToEnd();

    try {
      final RelayResponse response = await _relay.processTurn(userText: text);
      if (!mounted) return;
      setState(() {
        _messages.add(
          RelayChatMessage(
            text: response.replyText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToEnd();
      await _refreshSosTrustPrompt();
    } on RelayUsageLimitException catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          RelayChatMessage(
            text: e.message,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          RelayChatMessage(
            text: 'I am still organizing my thoughts. Please try again softly.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
        _inputFocusNode.requestFocus();
      }
    }
  }

  Future<void> _refreshSosTrustPrompt() async {
    if (_checkingSosReadiness) return;
    _checkingSosReadiness = true;
    try {
      final bool trusted = await _hasBuiltTrust();
      if (!trusted) {
        if (!mounted) return;
        setState(() {
          _showSosTrustPrompt = false;
        });
        return;
      }

      final bool complete = await _isSosProfileReady();
      if (!mounted) return;
      setState(() {
        _showSosTrustPrompt = !complete;
      });
    } finally {
      _checkingSosReadiness = false;
    }
  }

  Future<bool> _hasBuiltTrust() async {
    if (!Hive.isBoxOpen('appBox')) return false;
    final Box<dynamic> appBox = Hive.box('appBox');
    final bool verified = (appBox.get(
          'contact_verification_complete',
          defaultValue: false,
        ) as bool?) ??
        false;
    if (!verified) return false;

    final int userTurns =
        _messages.where((RelayChatMessage m) => m.isUser).length;
    if (userTurns < 5) return false;

    DateTime? startAt = DateTime.tryParse(
      (appBox.get('contact_verification_ts_iso', defaultValue: '')
              as String?) ??
          '',
    );
    startAt ??= DateTime.tryParse(
      (appBox.get(_sosEligibilityStartKey, defaultValue: '') as String?) ?? '',
    );

    if (startAt == null) {
      startAt = DateTime.now();
      await appBox.put(_sosEligibilityStartKey, startAt.toIso8601String());
      return false;
    }

    final int days = DateTime.now().difference(startAt).inDays;
    return days >= _minDaysBeforeSosPrompt;
  }

  Future<bool> _isSosProfileReady() async {
    final Map<String, dynamic> profile = await SOSService.getSafetyProfile();
    final String fullName = (profile['full_name'] as String?)?.trim() ?? '';
    final String city = (profile['city'] as String?)?.trim() ?? '';
    final String contactName =
        (profile['trusted_contact_name'] as String?)?.trim() ?? '';
    final String contactNumber =
        (profile['trusted_contact_number'] as String?)?.trim() ?? '';
    final bool allowTrusted =
        (profile['allow_call_trusted_contact'] as bool?) ?? false;
    final bool allowEmergency =
        (profile['allow_call_country_emergency'] as bool?) ?? false;
    final bool allowSms =
        (profile['allow_sms_alert_to_trusted_contact'] as bool?) ?? false;
    final bool hasCoreInfo = fullName.isNotEmpty && city.isNotEmpty;
    final bool hasTrustedContact =
        contactName.isNotEmpty && contactNumber.isNotEmpty;
    final bool hasCrisisPermissions =
        allowTrusted || allowEmergency || allowSms;
    return hasCoreInfo && hasTrustedContact && hasCrisisPermissions;
  }

  Future<void> _openSosConsentFromPrompt() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SosConsentFormScreen(),
      ),
    );
    await _refreshSosTrustPrompt();
  }

  Future<void> _onMicPressed() async {
    HapticFeedback.selectionClick();
    if (_sending) return;
    if (_isListening) {
      await _stopVoiceCapture(autoSend: true);
      return;
    }

    final bool ready = await _ensureSpeechReady();
    if (!ready || !mounted) return;

    try {
      await _speech.listen(
        onResult: (result) {
          final String words = result.recognizedWords.trim();
          if (!mounted || words.isEmpty) return;
          setState(() {
            _controller.text = words;
            _controller.selection = TextSelection.collapsed(
              offset: _controller.text.length,
            );
          });
          if (result.finalResult) {
            _stopVoiceCapture(autoSend: true);
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          partialResults: true,
          cancelOnError: true,
        ),
      );
      if (!mounted) return;
      setState(() {
        _isListening = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listening... speak now.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not start voice input. Please check microphone permission.',
          ),
        ),
      );
    }
  }

  Future<bool> _ensureSpeechReady() async {
    if (_speechReady) return true;
    final bool available = await _speech.initialize(
      onStatus: (String status) {
        final String lower = status.toLowerCase();
        if ((lower == 'done' || lower == 'notlistening') && _isListening) {
          _stopVoiceCapture(autoSend: true);
        }
      },
      onError: (_) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
        });
      },
    );
    if (!mounted) return false;
    setState(() {
      _speechReady = available;
    });
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition is unavailable on this device right now.',
          ),
        ),
      );
    }
    return available;
  }

  Future<void> _stopVoiceCapture({required bool autoSend}) async {
    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _isListening = false;
    });
    if (autoSend && _controller.text.trim().isNotEmpty && !_sending) {
      await _send();
    } else {
      _inputFocusNode.requestFocus();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _phaseLabel(BrainPhase phase) {
    return switch (phase) {
      BrainPhase.idle => 'Ready',
      BrainPhase.brainA => 'Brain A listening',
      BrainPhase.brain1 => 'Brain 1 analyzing',
      BrainPhase.brain2 => 'Brain 2 responding',
    };
  }

  Future<void> _copyMessage(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copied to clipboard.')),
    );
  }

  Future<void> _saveMessage(RelayChatMessage msg) async {
    if (!Hive.isBoxOpen('userBox')) return;
    final Box<dynamic> box = Hive.box('userBox');
    final List<dynamic> raw = List<dynamic>.from(
      (box.get(_savedSnippetsKey, defaultValue: <dynamic>[]) as List?) ??
          <dynamic>[],
    );
    raw.add(
      <String, dynamic>{
        'text': msg.text,
        'isUser': msg.isUser,
        'ts': msg.timestamp.toIso8601String(),
      },
    );
    await box.put(_savedSnippetsKey, raw);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message saved.')),
    );
  }

  Future<void> _deleteMessage(int index) async {
    if (index < 0 || index >= _messages.length) return;
    final RelayChatMessage removed = _messages[index];
    setState(() {
      _messages.removeAt(index);
    });
    await _relay.replaceHistory(_messages);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(removed.isUser ? 'Your message deleted.' : 'Reply deleted.'),
      ),
    );
  }

  Future<void> _showMessageActions({
    required RelayChatMessage msg,
    required int index,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copy'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _copyMessage(msg.text);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_add_outlined),
                title: const Text('Save'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _saveMessage(msg);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _deleteMessage(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openSavedMessages() async {
    if (!Hive.isBoxOpen('userBox')) return;
    final Box<dynamic> box = Hive.box('userBox');
    final List<dynamic> raw = List<dynamic>.from(
      (box.get(_savedSnippetsKey, defaultValue: <dynamic>[]) as List?) ??
          <dynamic>[],
    );
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        if (raw.isEmpty) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No saved messages yet.'),
            ),
          );
        }
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.65,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 8),
                const Text(
                  'Saved Chat Snippets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Divider(),
                Expanded(
                  child: ListView.separated(
                    itemCount: raw.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, int i) {
                      final Map<dynamic, dynamic> item =
                          Map<dynamic, dynamic>.from(raw[i] as Map);
                      final String text = (item['text'] as String?) ?? '';
                      return ListTile(
                        title: Text(
                          text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.copy_outlined),
                              onPressed: () async {
                                await _copyMessage(text);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                raw.removeAt(i);
                                await box.put(_savedSnippetsKey, raw);
                                if (sheetContext.mounted) {
                                  Navigator.of(sheetContext).pop();
                                }
                                await _openSavedMessages();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveCurrentChatSnapshot() async {
    if (!Hive.isBoxOpen('userBox')) return;
    final Box<dynamic> box = Hive.box('userBox');
    final List<dynamic> raw = List<dynamic>.from(
      (box.get(_savedSnippetsKey, defaultValue: <dynamic>[]) as List?) ??
          <dynamic>[],
    );
    if (_messages.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isHindiUi(context)
                ? 'चैट खाली है। सेव करने के लिए कुछ नहीं है।'
                : 'Chat is empty. Nothing to save.',
          ),
        ),
      );
      return;
    }

    final DateTime now = DateTime.now();
    for (final RelayChatMessage msg in _messages) {
      raw.add(
        <String, dynamic>{
          'text': msg.text,
          'isUser': msg.isUser,
          'ts': msg.timestamp.toIso8601String(),
          'snapshot_ts': now.toIso8601String(),
        },
      );
    }
    await box.put(_savedSnippetsKey, raw);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isHindiUi(context)
              ? 'पूरी चैट ऐप के लोकल स्टोरेज में सेव कर दी गई है।'
              : 'Entire chat saved in app-local storage.',
        ),
      ),
    );
  }

  Future<void> _deleteEntireChat() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(_isHindiUi(context) ? 'चैट हटाएं?' : 'Delete chat?'),
          content: Text(
            _isHindiUi(context)
                ? 'इससे इस डिवाइस की पूरी चैट हिस्ट्री हट जाएगी।'
                : 'This will delete the full chat history from this device.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_isHindiUi(context) ? 'रद्द करें' : 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(_isHindiUi(context) ? 'हटाएं' : 'Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await _relay.clearHistory();
    if (!mounted) return;
    setState(() {
      _messages.clear();
    });
    await _loadHistory();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isHindiUi(context)
              ? 'इस डिवाइस से चैट हिस्ट्री हटा दी गई है।'
              : 'Chat history deleted from this device.',
        ),
      ),
    );
  }

  Future<void> _showDataLocationInfo() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(_isHindiUi(context) ? 'डेटा स्टोरेज' : 'Data Storage'),
          content: Text(
            _isHindiUi(context)
                ? 'चैट डेटा केवल इसी ऐप के अंदर (फोन के local Hive database) में सेव होता है। '
                    'External storage permission उपयोग नहीं होती, इसलिए app के बाहर public folder में कोई file सेव नहीं होती।'
                : 'Chat data is saved only inside this app (local Hive database on your phone). '
                    'No external storage permission is used, so files are not saved in public folders outside the app.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ValueListenableBuilder<BrainPhase>(
          valueListenable: _relay.activePhase,
          builder: (_, BrainPhase phase, __) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.sync_alt, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _phaseLabel(phase),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: const Row(
            children: <Widget>[
              CircleAvatar(
                radius: 14,
                backgroundImage: _drIrisAvatar,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dr Iris: I am here with you, share at your own pace.',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: <Widget>[
              TextButton.icon(
                onPressed: _saveCurrentChatSnapshot,
                icon: const Icon(Icons.save_outlined),
                label: Text(_isHindiUi(context) ? 'चैट सेव' : 'Save Chat'),
              ),
              TextButton.icon(
                onPressed: _deleteEntireChat,
                icon: const Icon(Icons.delete_outline),
                label: Text(_isHindiUi(context) ? 'चैट हटाएं' : 'Delete Chat'),
              ),
              TextButton.icon(
                onPressed: _openSavedMessages,
                icon: const Icon(Icons.bookmark_border),
                label: Text(_isHindiUi(context) ? 'सेव्ड' : 'Saved'),
              ),
              TextButton.icon(
                onPressed: _showDataLocationInfo,
                icon: const Icon(Icons.info_outline),
                label: Text(
                    _isHindiUi(context) ? 'डेटा कहाँ सेव है' : 'Data Location'),
              ),
            ],
          ),
        ),
        if (_showSosTrustPrompt)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD4A3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Safety Setup Recommended',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You can now complete SOS permissions for trusted-contact calls, country emergency calls, and SMS alerts. Add essential safety details so Dr Iris can respond faster in crisis situations.',
                  style: TextStyle(
                      fontSize: 12, color: Colors.black87, height: 1.35),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: _openSosConsentFromPrompt,
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('Complete SOS Permissions'),
                  ),
                ),
              ],
            ),
          ),
        if (kDebugMode)
          ValueListenableBuilder<Map<String, String>>(
            valueListenable: _relay.resolvedModelPaths,
            builder: (_, Map<String, String> models, __) {
              final String a = models['brain_a'] ?? '(not resolved)';
              final String b1 = models['brain_1'] ?? '(not resolved)';
              final String b2 = models['brain_2'] ?? '(not resolved)';
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F2FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  'Debug Models\nA: $a\n1: $b1\n2: $b2',
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    fontFamily: 'Lato',
                  ),
                ),
              );
            },
          ),
        if (kDebugMode)
          ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: _relay.debugState,
            builder: (_, Map<String, dynamic> d, __) {
              final String emotion = (d['emotion'] as String?) ?? 'n/a';
              final double confidence =
                  ((d['confidence'] as num?) ?? 0).toDouble();
              final bool ambiguous = (d['ambiguous'] as bool?) ?? false;
              final String need = (d['primary_need'] as String?) ?? 'n/a';
              final double alignment =
                  ((d['alignment_score'] as num?) ?? 0).toDouble();
              final bool corrected = (d['corrected'] as bool?) ?? false;
              final int srs = ((d['srs_score'] as num?) ?? 0).toInt();
              final bool passed = (d['srs_passed'] as bool?) ?? false;
              final bool sos = (d['sos_triggered'] as bool?) ?? false;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  'Debug Quality\n'
                  'Emotion: $emotion (conf ${confidence.toStringAsFixed(2)}, ambiguous $ambiguous)\n'
                  'Need: $need | Align: ${alignment.toStringAsFixed(2)} | Corrected: $corrected\n'
                  'SRS: $srs (${passed ? "pass" : "fail"}) | SOS: $sos',
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.25,
                    fontFamily: 'Lato',
                  ),
                ),
              );
            },
          ),
        if (kDebugMode)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ModelCompatibilityScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.bug_report_outlined, size: 16),
                label: const Text('Model Check'),
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (_, int index) {
              final RelayChatMessage msg = _messages[index];
              return Align(
                alignment:
                    msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: GestureDetector(
                  onLongPress: () =>
                      _showMessageActions(msg: msg, index: index),
                  child: Row(
                    mainAxisAlignment: msg.isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (!msg.isUser) ...<Widget>[
                        const CircleAvatar(
                          radius: 12,
                          backgroundImage: _drIrisAvatar,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? const Color(0xFF5D3C8F)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: msg.isUser ? Colors.white : Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_sending)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Row(
              children: const <Widget>[
                CircleAvatar(
                  radius: 12,
                  backgroundImage: _drIrisAvatar,
                ),
                SizedBox(width: 8),
                Text(
                  'Dr Iris typing...',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: <Widget>[
                IconButton.filledTonal(
                  onPressed: _sending ? null : _onMicPressed,
                  icon: Icon(
                    _isListening
                        ? Icons.stop_circle_outlined
                        : Icons.mic_none_rounded,
                    color: _isListening ? Colors.redAccent : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _inputFocusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Share what you are feeling...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _send,
                  icon:
                      Icon(_sending ? Icons.hourglass_top : Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

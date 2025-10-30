import 'dart:async';

import 'package:flutter/material.dart';
import '../core/log_service.dart';

class LogConsoleOverlay extends StatefulWidget {
  const LogConsoleOverlay({super.key});

  @override
  State<LogConsoleOverlay> createState() => _LogConsoleOverlayState();
}

class _LogConsoleOverlayState extends State<LogConsoleOverlay> {
  final _lines = <String>[];
  late StreamSubscription<String> _sub;
  final ScrollController _scroll = ScrollController();
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _lines.addAll(LogService.instance.snapshot());
    _sub = LogService.instance.stream.listen((line) {
      setState(() {
        _lines.add(line);
        if (_lines.length > 800) {
          _lines.removeRange(0, _lines.length - 800);
        }
      });
      if (_autoScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      color: Colors.black.withValues(alpha: 0.9),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(theme),
            const Divider(height: 1, color: Colors.white24),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: _lines.length,
                itemBuilder: (context, index) {
                  final text = _lines[index];
                  final color =
                      text.contains('Error:') || text.contains('Exception')
                      ? Colors.redAccent
                      : Colors.greenAccent;
                  return Text(
                    text,
                    style: TextStyle(
                      color: color,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          const Icon(Icons.article, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          const Text(
            'Live Logs',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            onPressed: () async {
              setState(() => _autoScroll = !_autoScroll);
            },
            tooltip: _autoScroll ? 'Pause autoscroll' : 'Resume autoscroll',
            icon: Icon(
              _autoScroll ? Icons.pause_circle : Icons.play_circle,
              color: Colors.white70,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () async {
              await LogService.instance.clear();
              setState(() {
                _lines.clear();
              });
            },
            tooltip: 'Clear logs',
            icon: const Icon(
              Icons.delete_sweep,
              color: Colors.white70,
              size: 20,
            ),
          ),
          IconButton(
            onPressed: () {
              LogService.instance.overlayVisible.value = false;
            },
            tooltip: 'Close',
            icon: const Icon(Icons.close, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }
}

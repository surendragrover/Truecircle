import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Lightweight log service that writes to a file and streams live updates.
/// - Offline-first: uses local file in app documents directory
/// - Live stream: broadcast stream for UI overlays / consoles
/// - Ring buffer: keeps a small recent buffer in memory
class LogService {
  LogService._();
  static final LogService instance = LogService._();

  final ValueNotifier<bool> overlayVisible = ValueNotifier<bool>(false);
  final _controller = StreamController<String>.broadcast();
  final List<String> _buffer = <String>[];
  final int _bufferMax = 500;

  File? _file;
  IOSink? _sink;

  Future<void> init() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/truecircle_app.log';
      _file = File(path);
      _sink = _file!.openWrite(mode: FileMode.append);
      await log(
        '--- LogService initialized at ${DateTime.now().toIso8601String()} ---',
      );
    } catch (e) {
      // If file fails, still allow streaming
      if (kDebugMode) {
        // ignore: avoid_print
        print('LogService init error: $e');
      }
    }
  }

  String? get logFilePath => _file?.path;

  Stream<String> get stream => _controller.stream;

  Future<void> log(String message) async {
    final ts = DateTime.now().toIso8601String();
    final line = '[$ts] $message';
    _buffer.add(line);
    if (_buffer.length > _bufferMax) {
      _buffer.removeAt(0);
    }
    _controller.add(line);
    try {
      _sink?.writeln(line);
      await _sink?.flush();
    } catch (_) {
      // Ignore write issues; stream still works
    }
  }

  List<String> snapshot() => List.unmodifiable(_buffer);

  Future<void> clear() async {
    _buffer.clear();
    _controller.add('[${DateTime.now().toIso8601String()}] (logs cleared)');
    try {
      await _sink?.close();
      if (_file != null && await _file!.exists()) {
        await _file!.writeAsString('');
      }
      _sink = _file?.openWrite(mode: FileMode.append);
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
    await _controller.close();
  }
}

import 'package:flutter/foundation.dart';

/// Centralized logging helper that prints bilingual (English + Hindi)
/// messages with lightweight severity markers. Keeps console output
/// consistent across services while honoring the sample-mode privacy
/// guidelines (no PII).
class LoggingService {
  const LoggingService._();

  static void info(String messageEn, {String? messageHi}) {
    _print('ℹ️', messageEn, messageHi);
  }

  static void success(String messageEn, {String? messageHi}) {
    _print('✅', messageEn, messageHi);
  }

  static void warn(String messageEn, {String? messageHi}) {
    _print('⚠️', messageEn, messageHi);
  }

  static void error(String messageEn, {String? messageHi}) {
    _print('❌', messageEn, messageHi);
  }

  static void _print(String prefix, String messageEn, String? messageHi) {
    final buffer = StringBuffer()
      ..write(prefix)
      ..write(' ');
    buffer.write(messageEn.trim());
    if (messageHi != null && messageHi.trim().isNotEmpty) {
      buffer
        ..write(' | ')
        ..write(messageHi.trim());
    }
    debugPrint(buffer.toString());
  }
}

import 'dart:core';

/// Simple profanity filter to prevent offensive language from reaching on-device AI.
/// - Normalizes leetspeak (e.g., f@ck -> fuck)
/// - Strips common separators (spaces, dots, dashes, underscores) for detection
/// - Case-insensitive
class ProfanityFilter {
  static final Map<String, String> _leetMap = {
    '@': 'a',
    '4': 'a',
    '∆': 'a',
    '8': 'b',
    '(': 'c',
    '¢': 'c',
    '3': 'e',
    '€': 'e',
    '6': 'g',
    '9': 'g',
    '!': 'i',
    '1': 'i',
    '¡': 'i',
    '|': 'i',
    '0': 'o',
    '°': 'o',
    '●': 'o',
    r'$': 's',
    '5': 's',
    '§': 's',
    '7': 't',
    '+': 't',
    '2': 'z',
  };

  // Keep list compact; detection runs on normalized input.
  static final List<String> _banned = const [
    // Common English profanities & slurs (subset)
    'fuck', 'shit', 'bitch', 'bastard', 'asshole', 'dick', 'cunt', 'slut',
    'whore', 'faggot', 'retard', 'motherfucker',
  ];

  /// Returns true if text appears to contain profanity.
  static bool hasProfanity(String text) {
    if (text.trim().isEmpty) return false;

    final raw = text.toLowerCase();
    final normalized = _normalize(raw);
    // Check both normalized and raw with word-boundary regex
    for (final w in _banned) {
      final re = RegExp('\\b${RegExp.escape(w)}\\b', caseSensitive: false);
      if (re.hasMatch(raw) || re.hasMatch(normalized)) return true;
    }
    return false;
  }

  /// Replace common leet chars and strip separators to catch disguised words.
  static String _normalize(String input) {
    final sb = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      final lower = ch.toLowerCase();
      if (_leetMap.containsKey(lower)) {
        sb.write(_leetMap[lower]);
      } else if (RegExp(r'[a-z0-9]').hasMatch(lower)) {
        sb.write(lower);
      } else {
        // Drop common separators like spaces, punctuation, underscores, dashes
        // This helps catch things like f.u.c.k or f_u_c_k
      }
    }
    return sb.toString();
  }
}

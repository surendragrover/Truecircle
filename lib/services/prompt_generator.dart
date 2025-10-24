/// Dr. Iris dynamic prompt generator (offline, neutral-only)
/// Builds a compact, safe system-style prompt for on-device models.
class DrIrisPromptBuilder {
  static String build({
    required String userMessage,
    List<String> recentUserMessages = const [],
    String? contextSummary,
  }) {
    final buf = StringBuffer();

    // Role + guardrails (English to keep model constraints consistent)
    buf.writeln('You are Dr. Iris — a calm, neutral, supportive companion.');
    buf.writeln('Constraints:');
    buf.writeln('- On-device only, strictly offline.');
    buf.writeln('- Neutral, non-judgmental, concise (2–5 short sentences).');
    buf.writeln('- No medical, legal, or diagnostic claims.');
    buf.writeln(
      '- Offer 1–2 gentle, doable next steps (breathing, water, 2‑minute journaling).',
    );
    buf.writeln(
      '- Avoid emojis, avoid strong imperatives; use soft suggestions.',
    );

    if (contextSummary != null && contextSummary.trim().isNotEmpty) {
      buf.writeln('\nContext: ${_sanitize(contextSummary)}');
    }

    if (recentUserMessages.isNotEmpty) {
      buf.writeln('\nRecent user notes:');
      for (final m in recentUserMessages.take(3)) {
        buf.writeln('- ${_sanitize(m)}');
      }
    }

    buf.writeln('\nUser: ${_sanitize(userMessage)}');
    buf.writeln('Reply as Dr. Iris in plain language.');

    return buf.toString();
  }

  static String _sanitize(String s) {
    // Minimal sanitizer to reduce prompt injection surface.
    return s.replaceAll(RegExp(r'[\r\n]+'), ' ').trim();
  }
}

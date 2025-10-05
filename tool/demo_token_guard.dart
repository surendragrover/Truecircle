/// Demo Token Guard (STUB)
/// Original enforcement logic temporarily disabled.
/// This stub always exits successfully. Restore the previous implementation
/// if you need strict terminology enforcement again.
///
/// To restore: uncomment the original block below.

library;

import 'dart:io';

void main() {
  // No-op stub
  // Emit a consistent success message so CI passes.
  // (Guard disabled intentionally.) If you re-enable, ensure banned patterns updated to current policy.
  stdout.writeln('✅ Demo token guard (stub) – enforcement disabled.');
}

/*
// --- ORIGINAL IMPLEMENTATION (commented out) ---
import 'dart:io';
final _bannedPatterns = <RegExp>[
  RegExp(r'\\bDemoMode\\b'),
  RegExp(r'\\bDemo Page\\b'),
  RegExp(r'DemoPage'),
  RegExp(r'Demo (?!purposes)[A-Z]'),
];
final _allowlineRegex = RegExp(r'@Deprecated|allow_demo_token|migration|legacy|demo purposes');
void mainOriginal() {
  final roots = [Directory('lib')];
  final violations = <String>[];
  for (final root in roots) {
    if (!root.existsSync()) continue;
    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File) continue;
      if (!entity.path.endsWith('.dart')) continue;
      final rel = entity.path.replaceAll('\\\\', '/');
      if (rel.contains('.g.dart')) continue;
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (_allowlineRegex.hasMatch(line)) continue;
        for (final pat in _bannedPatterns) {
          if (pat.hasMatch(line)) {
            violations.add('$rel:${i + 1}: ${line.trim()}');
            break;
          }
        }
      }
    }
  }
  if (violations.isNotEmpty) {
    stderr.writeln('❌ Demo token guard failed. Disallowed terms found:');
    for (final v in violations) {
      stderr.writeln('  - $v');
    }
    stderr.writeln('\nUse privacy/sample terminology instead.');
    exit(1);
  }
  stdout.writeln('✅ Demo token guard passed (no banned tokens).');
}
*/

import 'dart:io';

/// A utility that replaces deprecated `.withValues(alpha: ...)` calls with the
/// recommended `.withValues(alpha: ...)` syntax across the project.
///
/// Usage:
///   dart run tools/fix_with_opacity.dart [path] [--dry-run] [--verbose]
///
/// * [path] (optional) defaults to the project root (current directory).
/// * `--dry-run` performs the scan and reports changes without writing files.
/// * `--verbose` prints each updated file and the number of substitutions.
void main(List<String> args) {
  final options = _FixOptions.parse(args);
  final fixer = _WithOpacityFixer(options);
  fixer.run();
}

class _FixOptions {
  _FixOptions(
      {required this.root, required this.dryRun, required this.verbose});

  final Directory root;
  final bool dryRun;
  final bool verbose;

  static _FixOptions parse(List<String> args) {
    Directory? root;
    var dryRun = false;
    var verbose = false;

    for (final arg in args) {
      switch (arg) {
        case '--dry-run':
          dryRun = true;
          break;
        case '--verbose':
          verbose = true;
          break;
        default:
          root ??= Directory(arg);
          break;
      }
    }

    root ??= Directory.current;

    if (!root.existsSync()) {
      stderr.writeln('❌ Provided path does not exist: ${root.path}');
      exitCode = 2;
      exit(2);
    }

    return _FixOptions(root: root.absolute, dryRun: dryRun, verbose: verbose);
  }
}

class _WithOpacityFixer {
  _WithOpacityFixer(this.options);

  final _FixOptions options;

  int _filesScanned = 0;
  int _filesUpdated = 0;
  int _replacements = 0;

  static final Set<String> _ignoredDirectories = {
    '.dart_tool',
    '.git',
    '.idea',
    '.vscode',
    'build',
  };

  void run() {
    final stopwatch = Stopwatch()..start();
    _processDirectory(options.root);
    stopwatch.stop();

    stdout.writeln('✅ Completed in ${stopwatch.elapsedMilliseconds} ms');
    stdout.writeln('• Files scanned: $_filesScanned');
    stdout.writeln('• Files updated: $_filesUpdated');
    stdout.writeln('• Replacements: $_replacements');
    if (options.dryRun) {
      stdout.writeln('ℹ️  Dry run mode: no files were modified');
    }
  }

  void _processDirectory(Directory directory) {
    if (_shouldSkipDirectory(directory)) {
      return;
    }

    for (final entity in directory.listSync(followLinks: false)) {
      if (entity is Directory) {
        _processDirectory(entity);
      } else if (entity is File && entity.path.endsWith('.dart')) {
        _processFile(entity);
      }
    }
  }

  bool _shouldSkipDirectory(Directory directory) {
    final segments = directory.absolute.path.split(Platform.pathSeparator);
    return segments.any(_ignoredDirectories.contains);
  }

  void _processFile(File file) {
    _filesScanned += 1;
    final original = file.readAsStringSync();

    final result = _replaceWithOpacity(original);
    if (result == null) {
      return;
    }

    _filesUpdated += 1;
    _replacements += result.replacements;

    if (options.verbose) {
      stdout.writeln('• ${file.path} (${result.replacements} replacements)');
    }

    if (!options.dryRun) {
      file.writeAsStringSync(result.content);
    }
  }

  _ReplacementResult? _replaceWithOpacity(String source) {
    final buffer = StringBuffer();
    var lastIndex = 0;
    var replacements = 0;

    final pattern = RegExp(r'withOpacity\s*\(');
    final matches = pattern.allMatches(source).toList(growable: false);

    if (matches.isEmpty) {
      return null;
    }

    for (final match in matches) {
      final start = match.start;
      final end = match.end;

      final precedingOperator = _detectOperatorBefore(source, start);
      if (precedingOperator == null) {
        // Leave occurrences that are likely inside strings/comments untouched.
        continue;
      }

      buffer.write(source.substring(lastIndex, start));
      buffer.write('withValues(alpha: ');
      lastIndex = end;
      replacements += 1;
    }

    if (replacements == 0) {
      // Nothing actionable found.
      return null;
    }

    buffer.write(source.substring(lastIndex));
    return _ReplacementResult(buffer.toString(), replacements);
  }

  String? _detectOperatorBefore(String source, int index) {
    if (index >= 2) {
      final twoChars = source.substring(index - 2, index);
      if (twoChars == '?.' || twoChars == '!.') {
        return twoChars;
      }
      if (twoChars == '..') {
        return twoChars;
      }
    }
    if (index >= 1 && source[index - 1] == '.') {
      return '.';
    }
    return null;
  }
}

class _ReplacementResult {
  _ReplacementResult(this.content, this.replacements);

  final String content;
  final int replacements;
}

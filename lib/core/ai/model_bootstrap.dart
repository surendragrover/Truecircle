import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ModelBootstrap {
  static const _models = [
    'Brain_A_int8.onnx',
    'model_int8.onnx',
  ];

  static Future<String> initialize() async {
    final baseDir = await getApplicationSupportDirectory();
    final modelDir = p.join(baseDir.path, 'truecircle_models');
    final dir = Directory(modelDir);

    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    bool allExist = true;

    for (final m in _models) {
      final file = File(p.join(modelDir, m));
      if (!file.existsSync() || file.lengthSync() == 0) {
        allExist = false;
        break;
      }
    }

    if (!allExist) {
      for (final m in _models) {
        try {
          final data = await rootBundle.load('assets/models/$m');
          final bytes = data.buffer.asUint8List();
          await File(p.join(modelDir, m)).writeAsBytes(bytes, flush: true);
        } catch (_) {
          // Optional model may be unavailable in current bundle.
        }
      }
    }

    return modelDir;
  }
}

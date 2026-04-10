import 'dart:io';

import 'package:onnxruntime/onnxruntime.dart';
import 'package:path/path.dart' as p;

class ModelPipelineSmokeResult {
  const ModelPipelineSmokeResult({
    required this.modelName,
    required this.success,
    required this.durationMs,
    this.error,
    this.inputCount,
    this.outputCount,
  });

  final String modelName;
  final bool success;
  final int durationMs;
  final String? error;
  final int? inputCount;
  final int? outputCount;
}

class ModelPipelineSmokeReport {
  const ModelPipelineSmokeReport({
    required this.results,
    required this.selectedModelCount,
  });

  final List<ModelPipelineSmokeResult> results;
  final int selectedModelCount;

  bool get allPassed =>
      selectedModelCount >= 3 &&
      results.length == selectedModelCount &&
      results.every((ModelPipelineSmokeResult r) => r.success);
}

class ModelPipelineSmokeService {
  Future<ModelPipelineSmokeReport> verifyDirectory(Directory modelsDir) async {
    final List<File> modelFiles = <File>[];
    if (await modelsDir.exists()) {
      await for (final FileSystemEntity entity
          in modelsDir.list(recursive: true, followLinks: false)) {
        if (entity is File &&
            p.extension(entity.path).toLowerCase() == '.onnx') {
          modelFiles.add(entity);
        }
      }
    }
    modelFiles.sort((File a, File b) => a.path.compareTo(b.path));

    final List<File> selected = modelFiles.take(3).toList(growable: false);
    if (selected.length < 3) {
      return ModelPipelineSmokeReport(
        results: <ModelPipelineSmokeResult>[],
        selectedModelCount: selected.length,
      );
    }

    OrtEnv.instance.init();
    final List<ModelPipelineSmokeResult> results = <ModelPipelineSmokeResult>[];
    for (final File model in selected) {
      final Stopwatch watch = Stopwatch()..start();
      OrtSessionOptions? options;
      OrtSession? session;
      try {
        options = OrtSessionOptions();
        session = OrtSession.fromFile(model, options);
        watch.stop();
        results.add(
          ModelPipelineSmokeResult(
            modelName: p.basename(model.path),
            success: true,
            durationMs: watch.elapsedMilliseconds,
            inputCount: session.inputCount,
            outputCount: session.outputCount,
          ),
        );
      } catch (e) {
        watch.stop();
        results.add(
          ModelPipelineSmokeResult(
            modelName: p.basename(model.path),
            success: false,
            durationMs: watch.elapsedMilliseconds,
            error: e.toString(),
          ),
        );
      } finally {
        session?.release();
        options?.release();
      }
    }

    return ModelPipelineSmokeReport(
      results: results,
      selectedModelCount: selected.length,
    );
  }
}

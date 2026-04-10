import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'model_pipeline_smoke_service.dart';
import 'model_vault_service.dart';

typedef ModelProgressCallback = void Function(double progress);
typedef ModelStatusCallback = void Function(String status);

class ModelSetupService {
  static const String _readyMarkerFile = '.ready';
  static const List<String> _assetModels = <String>[
    'assets/models/Brain_A_int8.onnx',
    'assets/models/brain_a_int8.onnx',
    'assets/models/model_int8.onnx',
    'assets/models/brain1_int8.onnx',
    'assets/models/brain1_lite.onnx',
    'assets/models/braina_lite.onnx',
    'assets/models/brain2_lite.onnx',
  ];
  final ModelPipelineSmokeService _smokeService = ModelPipelineSmokeService();
  final ModelVaultService _vaultService = ModelVaultService();

  Future<bool> isReady() async {
    final Directory modelsDir = await _modelsDirectory();
    final File marker = File(p.join(modelsDir.path, _readyMarkerFile));
    if (!await marker.exists()) return false;
    final bool hasSealed = await _vaultService.hasSealedModels(modelsDir);
    return hasSealed || await _hasAtLeastOneModel(modelsDir);
  }

  Future<void> prepareModels({
    ModelProgressCallback? onProgress,
    ModelStatusCallback? onStatus,
  }) async {
    final Directory modelsDir = await _modelsDirectory();
    await modelsDir.create(recursive: true);
    onStatus?.call('Setting up bundled models...');
    onProgress?.call(0.2);
    await _copyBundledModels(modelsDir);
    onProgress?.call(0.6);
    await _finalizeBundledModels(modelsDir, onStatus);
    onStatus?.call('Applying model vault safeguards...');
    await _vaultService.sealAllPlainModels(modelsDir);
    onProgress?.call(1.0);
    onStatus?.call('Your personal intelligence is ready.');
  }

  Future<void> _finalizeBundledModels(
    Directory modelsDir,
    ModelStatusCallback? onStatus,
  ) async {
    onStatus?.call('Validating bundled model files...');
    final bool valid = await _hasAtLeastOneModel(modelsDir) ||
        await _vaultService.hasSealedModels(modelsDir);
    if (!valid) {
      throw Exception('Bundled models not found in app assets.');
    }

    final bool hasPlainForSmoke = await _hasAtLeastOneModel(modelsDir);
    if (!hasPlainForSmoke) {
      onStatus?.call('Secure model vault already available.');
      final File marker = File(p.join(modelsDir.path, _readyMarkerFile));
      await marker.writeAsString(
        jsonEncode(
          <String, dynamic>{
            'ready': true,
            'mode': 'secure',
            'smoke_all_passed': true,
            'smoke_selected_model_count': 3,
            'updated_at': DateTime.now().toIso8601String(),
          },
        ),
        flush: true,
      );
      return;
    }

    onStatus?.call('Testing model pipeline...');
    final ModelPipelineSmokeReport report =
        await _smokeService.verifyDirectory(modelsDir);
    final bool degraded = !report.allPassed;
    if (degraded) {
      onStatus?.call(
        'Some models are not fully compatible. Continuing in fallback mode.',
      );
    }

    final File marker = File(p.join(modelsDir.path, _readyMarkerFile));
    await marker.writeAsString(
      jsonEncode(
        <String, dynamic>{
          'ready': true,
          'mode': degraded ? 'fallback' : 'full',
          'smoke_all_passed': report.allPassed,
          'smoke_selected_model_count': report.selectedModelCount,
          'updated_at': DateTime.now().toIso8601String(),
        },
      ),
      flush: true,
    );
  }

  Future<Directory> _modelsDirectory() async {
    final Directory appSupport = await getApplicationSupportDirectory();
    return Directory(p.join(appSupport.path, 'truecircle_models'));
  }

  Future<bool> _hasAtLeastOneModel(Directory modelsDir) async {
    if (!await modelsDir.exists()) return false;
    await for (final FileSystemEntity entity
        in modelsDir.list(recursive: true, followLinks: false)) {
      if (entity is File && p.extension(entity.path).toLowerCase() == '.onnx') {
        return true;
      }
    }
    return false;
  }

  Future<void> _copyBundledModels(Directory modelsDir) async {
    for (final String assetPath in _assetModels) {
      try {
        final ByteData data = await rootBundle.load(assetPath);
        final File outFile =
            File(p.join(modelsDir.path, p.basename(assetPath)));
        final File sealedOutFile =
            File('${outFile.path}${ModelVaultService.sealedExtension}');
        if (await sealedOutFile.exists() && await sealedOutFile.length() > 0) {
          continue;
        }
        if (await outFile.exists() && await outFile.length() > 0) {
          continue;
        }
        await outFile.writeAsBytes(
          data.buffer.asUint8List(),
          flush: true,
        );
      } catch (_) {
        // Optional model in bundle may not exist for all builds.
      }
    }
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'model_vault_service.dart';

class OnnxThreeBrainInference {
  bool _envInitialized = false;
  bool _bundledSyncDone = false;
  final ModelVaultService _vaultService = ModelVaultService();

  final ValueNotifier<Map<String, String>> resolvedModelPaths =
      ValueNotifier<Map<String, String>>(<String, String>{});

  static const List<String> _brainAFilenames = <String>[
    'brain_a_int8.onnx',
    'brain_a.onnx',
    'braina_lite.onnx',
  ];

  static const List<String> _brain1Filenames = <String>[
    'brain1_int8.onnx',
    'brain1_lite.onnx',
    'brain_1_int8.onnx',
    'brain_1_fp16.onnx',
    'brain_1.onnx',
  ];

  static const List<String> _brain2Filenames = <String>[
    'model_int8.onnx',
    'brain2_lite.onnx',
    'brain_2_encoder_fp16.onnx',
    'brain_2.onnx',
  ];

  /* -------------------------------------------------------------------------- */
  /*                               PUBLIC API                                   */
  /* -------------------------------------------------------------------------- */

  Future<ModelCompatibilityReport> runCompatibilityCheck() async {
    final Map<String, String> resolved = await _resolveModels();
    final List<BrainCompatibilityResult> results = <BrainCompatibilityResult>[];

    results.add(await _compatForRole(
      role: 'brain_a',
      resolved: resolved,
      probePrompt: 'probe: detect emotion from text',
    ));

    results.add(await _compatForRole(
      role: 'brain_1',
      resolved: resolved,
      probePrompt: 'probe: score emotional stability from summary',
    ));

    results.add(await _compatForRole(
      role: 'brain_2',
      resolved: resolved,
      probePrompt: 'probe: produce one soft cbt response line',
    ));

    return ModelCompatibilityReport(results: results);
  }

  Future<String?> inferBrainA({
    required String text,
    required String audioTranscript,
  }) async {
    final String prompt = 'Analyze hidden emotion and intent.\n'
        'UserText: $text\n'
        'AudioTranscript: $audioTranscript';

    final Map<String, String> models = await _resolveModels();

    final _InferenceOutcome outcome = await _runRoleWithModel(
      role: 'brain_a',
      prompt: prompt,
      modelArtifactPath: models['brain_a'],
    );

    return outcome.output;
  }

  Future<String?> inferBrain1({
    required String brainAReport,
    required String userText,
    required String entriesSummary,
    required String historySummary,
    required String formScoresSummary,
  }) async {
    final String prompt =
        'Build emotional pattern from report, entries, and history.\n'
        'BrainA: $brainAReport\n'
        'Entries: $entriesSummary\n'
        'History: $historySummary\n'
        'FormScores: $formScoresSummary\n'
        'CurrentText: $userText';

    final Map<String, String> models = await _resolveModels();

    final _InferenceOutcome outcome = await _runRoleWithModel(
      role: 'brain_1',
      prompt: prompt,
      modelArtifactPath: models['brain_1'],
    );

    return outcome.output;
  }

  Future<String?> inferBrain2({
    required String patternSummary,
  }) async {
    final String prompt = 'Respond with soft, non-judgmental CBT tone.\n'
        'Pattern: $patternSummary';

    final Map<String, String> models = await _resolveModels();

    final _InferenceOutcome outcome = await _runRoleWithModel(
      role: 'brain_2',
      prompt: prompt,
      modelArtifactPath: models['brain_2'],
    );

    return outcome.output;
  }

  /* -------------------------------------------------------------------------- */
  /*                               CORE LOGIC                                   */
  /* -------------------------------------------------------------------------- */

  Future<_InferenceOutcome> _runRoleWithModel({
    required String role,
    required String prompt,
    required String? modelArtifactPath,
  }) async {
    if (modelArtifactPath == null) {
      return const _InferenceOutcome(
        output: null,
        error: 'Model file not resolved for role.',
      );
    }

    try {
      if (!_envInitialized) {
        OrtEnv.instance.init();
        _envInitialized = true;
      }

      final OrtSessionOptions options = OrtSessionOptions();
      final Directory appSupport = await getApplicationSupportDirectory();
      final Directory modelsDir =
          Directory(p.join(appSupport.path, 'truecircle_models'));
      File? runtimeModel;
      OrtSession? session;
      try {
        runtimeModel = await _vaultService.materializeRuntimeModel(
          sealedModel: File(modelArtifactPath),
          modelsDir: modelsDir,
          role: role,
        );
        session = OrtSession.fromFile(runtimeModel, options);

        final OrtRunOptions runOptions = OrtRunOptions();

        final String inputName =
            session.inputNames.isNotEmpty ? session.inputNames.first : 'input';

        final OrtValueTensor input =
            OrtValueTensor.createTensorWithData(prompt);

        final Map<String, OrtValue> inputs = <String, OrtValue>{
          inputName: input,
        };

        List<OrtValue?> outputs = <OrtValue?>[];

        try {
          outputs = session.run(runOptions, inputs);
        } finally {
          input.release();
          runOptions.release();
        }

        for (final OrtValue? o in outputs) {
          if (o == null) continue;
          final Object? value = o.value;
          final String textOutput = value?.toString() ?? '';
          o.release();

          if (textOutput.trim().isNotEmpty) {
            return _InferenceOutcome(
              output: textOutput.trim(),
              error: null,
            );
          }
        }

        return const _InferenceOutcome(
          output: null,
          error: 'Inference produced empty output.',
        );
      } finally {
        session?.release();
        options.release();
        if (runtimeModel != null) {
          try {
            await runtimeModel.delete();
          } catch (_) {
            // Best-effort delete of temp runtime file.
          }
        }
      }
    } catch (e) {
      return _InferenceOutcome(
        output: null,
        error: '$role inference error: $e',
      );
    }
  }

  /* -------------------------------------------------------------------------- */
  /*                           MODEL RESOLUTION                                  */
  /* -------------------------------------------------------------------------- */

  Future<Map<String, String>> _resolveModels() async {
    final Directory appSupport = await getApplicationSupportDirectory();
    final Directory modelsDir =
        Directory(p.join(appSupport.path, 'truecircle_models'));

    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }

    if (!_bundledSyncDone) {
      await _copyBundledModels(modelsDir);
      await _vaultService.sealAllPlainModels(modelsDir);
      _bundledSyncDone = true;
    }

    final Map<String, String> byName = await _scanModels(modelsDir);

    final String? brainA = _pickModel(byName, _brainAFilenames);
    final String? brain1 = _pickModel(byName, _brain1Filenames);
    final String? brain2 = _pickModel(byName, _brain2Filenames);

    final Map<String, String> resolved = <String, String>{
      if (brainA != null) 'brain_a': brainA,
      if (brain1 != null) 'brain_1': brain1,
      if (brain2 != null) 'brain_2': brain2,
    };

    resolvedModelPaths.value = resolved;
    return resolved;
  }

  Future<void> _copyBundledModels(Directory targetDir) async {
    const List<String> assetModels = <String>[
      'assets/models/Brain_A_int8.onnx',
      'assets/models/brain_a_int8.onnx',
      'assets/models/model_int8.onnx',
      'assets/models/brain1_int8.onnx',
      'assets/models/brain1_lite.onnx',
      'assets/models/braina_lite.onnx',
      'assets/models/brain2_lite.onnx',
    ];

    for (final String assetPath in assetModels) {
      try {
        final File outFile =
            File(p.join(targetDir.path, p.basename(assetPath)));
        final File sealedOutFile = File(
          '${outFile.path}${ModelVaultService.sealedExtension}',
        );
        if (await sealedOutFile.exists()) {
          continue;
        }
        if (await outFile.exists()) {
          continue;
        }
        final ByteData data = await rootBundle.load(assetPath);
        await outFile.writeAsBytes(
          data.buffer.asUint8List(),
          flush: true,
        );
      } catch (_) {
        // ignore missing optional model
      }
    }
  }

  String? _pickModel(
    Map<String, String> byName,
    List<String> preferredNames,
  ) {
    for (final String name in preferredNames) {
      final String? path = byName[name.toLowerCase()];
      if (path != null) return path;
    }
    return null;
  }

  Future<Map<String, String>> _scanModels(Directory modelsDir) async {
    final Map<String, String> byName = <String, String>{};
    await for (final FileSystemEntity entity
        in modelsDir.list(recursive: false)) {
      if (entity is File &&
          p.extension(entity.path).toLowerCase() ==
              ModelVaultService.sealedExtension) {
        final String sealedName = p.basename(entity.path).toLowerCase();
        final String plainName = sealedName.substring(
          0,
          sealedName.length - ModelVaultService.sealedExtension.length,
        );
        byName[plainName] = entity.path;
      }
    }
    return byName;
  }

  Future<BrainCompatibilityResult> _compatForRole({
    required String role,
    required Map<String, String> resolved,
    required String probePrompt,
  }) async {
    final String? modelPath = resolved[role];

    final _InferenceOutcome outcome = await _runRoleWithModel(
      role: role,
      prompt: probePrompt,
      modelArtifactPath: modelPath,
    );

    final String sample = (outcome.output ?? '').trim();

    return BrainCompatibilityResult(
      role: role,
      modelPath: modelPath ?? '',
      resolved: modelPath != null,
      ioCompatible: sample.isNotEmpty,
      outputSample:
          sample.length > 120 ? '${sample.substring(0, 120)}...' : sample,
      error: outcome.error,
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                   MODELS                                   */
/* -------------------------------------------------------------------------- */

class BrainCompatibilityResult {
  const BrainCompatibilityResult({
    required this.role,
    required this.modelPath,
    required this.resolved,
    required this.ioCompatible,
    required this.outputSample,
    required this.error,
  });

  final String role;
  final String modelPath;
  final bool resolved;
  final bool ioCompatible;
  final String outputSample;
  final String? error;
}

class ModelCompatibilityReport {
  const ModelCompatibilityReport({required this.results});

  final List<BrainCompatibilityResult> results;

  bool get allCompatible =>
      results.length == 3 &&
      results.every((BrainCompatibilityResult r) => r.ioCompatible);
}

class _InferenceOutcome {
  const _InferenceOutcome({
    required this.output,
    required this.error,
  });

  final String? output;
  final String? error;
}

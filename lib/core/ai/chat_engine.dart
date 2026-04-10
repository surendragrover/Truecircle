import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:onnxruntime/onnxruntime.dart';

class InputTags {
  final bool crisis;
  final bool distress;

  const InputTags({
    required this.crisis,
    required this.distress,
  });
}

class ChatEngine {
  static bool modelReady = false;
  static bool lastReplyFromModel = false;

  static OrtSession? _session;

  // ====================================================
  // REAL MODEL INIT (PRODUCTION)
  // ====================================================
  static Future<void> initModel(String modelDir) async {
    try {
      final List<String> candidates = <String>[
        'model_int8.onnx',
        'Brain_A_int8.onnx',
        'brain_a_int8.onnx',
      ];
      String? modelPath;
      for (final String name in candidates) {
        final String candidate = '$modelDir${Platform.pathSeparator}$name';
        if (File(candidate).existsSync()) {
          modelPath = candidate;
          break;
        }
      }

      if (modelPath == null) {
        debugPrint("ONNX FILE NOT FOUND IN: $modelDir");
        modelReady = false;
        return;
      }

      OrtEnv.instance.init();

      final sessionOptions = OrtSessionOptions();
      sessionOptions.setIntraOpNumThreads(1);

      _session = OrtSession.fromFile(File(modelPath), sessionOptions);

      modelReady = true;
      debugPrint("ONNX SESSION CREATED SUCCESSFULLY");
    } catch (e) {
      debugPrint("ONNX INIT FAILED: $e");
      modelReady = false;
    }
  }

  // ====================================================
  // MAIN ENTRY
  // ====================================================
  static Future<String> generateReply(String userText) async {
    lastReplyFromModel = false;

    final tags = _tagInput(userText);

    if (modelReady && _session != null) {
      try {
        final result = await _runModel(userText);
        if (result.trim().isNotEmpty) {
          lastReplyFromModel = true;
          return result;
        }
      } catch (e) {
        debugPrint("ONNX RUN ERROR: $e");
      }
    }

    return _fallbackReply(tags);
  }

  // ====================================================
  // INPUT TAGGING
  // ====================================================
  static InputTags _tagInput(String text) {
    final t = text.toLowerCase();

    return InputTags(
      crisis: t.contains('die') ||
          t.contains('kill') ||
          t.contains('suicide') ||
          t.contains('end my life'),
      distress: t.contains('sad') ||
          t.contains('bad') ||
          t.contains('lost') ||
          t.contains('empty') ||
          t.contains('hurt'),
    );
  }

  // ====================================================
  // REAL ONNX RUN (YOU MUST REPLACE TOKEN LOGIC)
  // ====================================================
  static Future<String> _runModel(String text) async {
    if (_session == null) return "";

    // ⚠️ IMPORTANT:
    // This is placeholder tensor.
    // Replace with tokenizer → token IDs → proper tensor shape.

    final inputTensor = OrtValueTensor.createTensorWithDataList(
      [1.0], // dummy data
      [1],
    );

    final OrtRunOptions runOptions = OrtRunOptions();
    final String inputName =
        _session!.inputNames.isNotEmpty ? _session!.inputNames.first : 'input';
    final outputs = _session!.run(
      runOptions,
      <String, OrtValue>{inputName: inputTensor},
    );
    inputTensor.release();
    runOptions.release();
    for (final OrtValue? output in outputs) {
      output?.release();
    }

    // ⚠️ Replace with real decoding logic
    return "ONNX MODEL ACTIVE";
  }

  // ====================================================
  // FALLBACK
  // ====================================================
  static String _fallbackReply(InputTags tags) {
    if (tags.crisis) {
      return '''
I hear how intense this feels right now.
You are not alone.
Let us slow down together.
''';
    }

    if (tags.distress) {
      return '''
I hear you.
Something feels heavy.
We can take this step by step.
''';
    }

    return '''
I am here with you.
Tell me more.
''';
  }
}

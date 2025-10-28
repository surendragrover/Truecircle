import 'dart:io';
import 'package:flutter/services.dart';

/// Offline On-Device AI Service (for Dr. Iris)
abstract class OnDeviceAIService {
  Future<bool> isSupported();
  Future<bool> initialize();
  Future<String> generateDrIrisResponse(String prompt);

  static OnDeviceAIService instance() {
    if (Platform.isAndroid) {
      return _AndroidAltModelService();
    }
    return _NoopAIService();
  }
}

class _NoopAIService implements OnDeviceAIService {
  @override
  Future<String> generateDrIrisResponse(String prompt) async {
    throw PlatformException(
      code: 'UNSUPPORTED',
      message: 'On-device AI not available',
    );
  }

  @override
  Future<bool> initialize() async => false;

  @override
  Future<bool> isSupported() async => false;
}

class _AndroidAltModelService implements OnDeviceAIService {
  static const _channel = MethodChannel('truecircle_ai_channel');

  @override
  Future<bool> isSupported() async {
    try {
      final res = await _channel.invokeMethod<bool>('isAltModelSupported');
      return res ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> initialize() async {
    try {
      final res = await _channel.invokeMethod<bool>('initializeAltModel');
      return res ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<String> generateDrIrisResponse(String prompt) async {
    final args = <String, dynamic>{
      'type': 'dr_iris',
      'prompt': prompt,
      'mode': 'alt', // alternate low-end model
    };
    final res = await _channel.invokeMethod<String>('generateResponse', args);
    return res ?? '';
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ModelVaultService {
  static const String sealedExtension = '.menc';
  static const String integrityFilename = '.integrity.json';
  static const String runtimeDirectoryName = 'truecircle_models_runtime';

  static const String _pepper = 'truecircle-model-vault-v1';

  Future<bool> hasSealedModels(Directory modelsDir) async {
    if (!await modelsDir.exists()) return false;
    await for (final FileSystemEntity entity in modelsDir.list()) {
      if (entity is File &&
          p.extension(entity.path).toLowerCase() == sealedExtension) {
        return true;
      }
    }
    return false;
  }

  Future<void> sealAllPlainModels(Directory modelsDir) async {
    if (!await modelsDir.exists()) return;
    final Map<String, String> integrity = await _readIntegrityMap(modelsDir);
    await for (final FileSystemEntity entity in modelsDir.list()) {
      if (entity is! File) continue;
      if (p.extension(entity.path).toLowerCase() != '.onnx') continue;
      final String plainName = p.basename(entity.path);
      final List<int> plainBytes = await entity.readAsBytes();
      if (plainBytes.isEmpty) continue;
      final String digest = sha256.convert(plainBytes).toString();
      final List<int> sealed = _xorBytes(
        plainBytes,
        _deriveKey(plainName),
      );
      final File sealedFile =
          File(p.join(modelsDir.path, '$plainName$sealedExtension'));
      await sealedFile.writeAsBytes(sealed, flush: true);
      integrity[plainName] = digest;
      await _wipeAndDelete(entity);
    }
    await _writeIntegrityMap(modelsDir, integrity);
  }

  Future<File> materializeRuntimeModel({
    required File sealedModel,
    required Directory modelsDir,
    required String role,
  }) async {
    final String sealedName = p.basename(sealedModel.path);
    if (!sealedName.toLowerCase().endsWith(sealedExtension)) {
      throw StateError('Invalid sealed model artifact: $sealedName');
    }
    final String plainName =
        sealedName.substring(0, sealedName.length - sealedExtension.length);
    final Map<String, String> integrity = await _readIntegrityMap(modelsDir);
    final String? expected = integrity[plainName];
    if (expected == null || expected.isEmpty) {
      await purgeSensitiveModelData(modelsDir);
      throw StateError('Model integrity metadata missing. Vault wiped.');
    }

    final List<int> sealed = await sealedModel.readAsBytes();
    final List<int> plain = _xorBytes(sealed, _deriveKey(plainName));
    final String actual = sha256.convert(plain).toString();
    if (actual != expected) {
      await purgeSensitiveModelData(modelsDir);
      throw StateError('Model integrity mismatch detected. Vault wiped.');
    }

    final Directory supportDir = await getApplicationSupportDirectory();
    final Directory runtimeDir =
        Directory(p.join(supportDir.path, runtimeDirectoryName));
    await runtimeDir.create(recursive: true);
    final String suffix = '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}';
    final File runtimeFile = File(
      p.join(runtimeDir.path, '${role}_$suffix.onnx'),
    );
    await runtimeFile.writeAsBytes(plain, flush: true);
    return runtimeFile;
  }

  Future<void> purgeSensitiveModelData(Directory modelsDir) async {
    if (await modelsDir.exists()) {
      await for (final FileSystemEntity entity in modelsDir.list()) {
        if (entity is! File) continue;
        final String ext = p.extension(entity.path).toLowerCase();
        final String base = p.basename(entity.path);
        if (ext == '.onnx' || ext == sealedExtension || base == integrityFilename) {
          await _wipeAndDelete(entity);
        }
      }
    }
    final Directory supportDir = await getApplicationSupportDirectory();
    final Directory runtimeDir =
        Directory(p.join(supportDir.path, runtimeDirectoryName));
    if (await runtimeDir.exists()) {
      await for (final FileSystemEntity entity in runtimeDir.list()) {
        if (entity is File) {
          await _wipeAndDelete(entity);
        }
      }
    }
  }

  List<int> _xorBytes(List<int> input, List<int> key) {
    if (key.isEmpty) return input;
    final List<int> out = List<int>.filled(input.length, 0);
    for (int i = 0; i < input.length; i++) {
      out[i] = input[i] ^ key[i % key.length];
    }
    return out;
  }

  List<int> _deriveKey(String plainName) {
    final String source = '$plainName|$_pepper';
    return sha256.convert(utf8.encode(source)).bytes;
  }

  Future<Map<String, String>> _readIntegrityMap(Directory modelsDir) async {
    final File file = File(p.join(modelsDir.path, integrityFilename));
    if (!await file.exists()) return <String, String>{};
    try {
      final Object? decoded =
          jsonDecode(await file.readAsString()) as Object?;
      if (decoded is! Map) return <String, String>{};
      final Map<dynamic, dynamic> map = decoded;
      return map.map(
        (dynamic key, dynamic value) =>
            MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return <String, String>{};
    }
  }

  Future<void> _writeIntegrityMap(
    Directory modelsDir,
    Map<String, String> map,
  ) async {
    final File file = File(p.join(modelsDir.path, integrityFilename));
    await file.writeAsString(jsonEncode(map), flush: true);
  }

  Future<void> _wipeAndDelete(File file) async {
    try {
      final int len = await file.length();
      if (len > 0) {
        final RandomAccessFile raf = await file.open(mode: FileMode.writeOnly);
        try {
          await raf.writeFrom(List<int>.filled(len, 0));
          await raf.flush();
        } finally {
          await raf.close();
        }
      }
    } catch (_) {
      // Best-effort wipe.
    }
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort delete.
    }
  }
}

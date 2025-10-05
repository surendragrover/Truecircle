import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class TestHiveHarness {
  TestHiveHarness._();

  static Directory? _tempDir;
  static bool _initialized = false;
  static PathProviderPlatform? _originalPathProvider;

  static Future<void> ensureInitialized() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (_initialized) return;
    final dir = await Directory.systemTemp.createTemp('truecircle_test_hive');
    Hive.init(dir.path);
    _tempDir = dir;

    _originalPathProvider ??= PathProviderPlatform.instance;
    PathProviderPlatform.instance = _TestPathProvider(dir);

    _initialized = true;
  }

  static Future<void> resetBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box(boxName);
      await box.clear();
      await box.close();
    }
    if (_initialized) {
      try {
        await Hive.deleteBoxFromDisk(boxName);
      } catch (_) {
        // Ignore cases where the box does not yet exist on disk.
      }
    }
  }

  static Future<void> dispose() async {
    await Hive.close();
    if (_tempDir != null && await _tempDir!.exists()) {
      await _tempDir!.delete(recursive: true);
    }
    _tempDir = null;
    if (_originalPathProvider != null) {
      PathProviderPlatform.instance = _originalPathProvider!;
      _originalPathProvider = null;
    }
    _initialized = false;
  }
}

class _TestPathProvider extends PathProviderPlatform {
  _TestPathProvider(this.directory);

  final Directory directory;

  @override
  Future<String?> getApplicationDocumentsPath() async => directory.path;

  @override
  Future<String?> getApplicationSupportPath() async => directory.path;

  @override
  Future<String?> getDownloadsPath() async => directory.path;

  @override
  Future<List<String>?> getExternalCachePaths() async => <String>[directory.path];

  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) async =>
      <String>[directory.path];

  @override
  Future<String?> getLibraryPath() async => directory.path;

  @override
  Future<String?> getTemporaryPath() async => directory.path;

  @override
  Future<String?> getApplicationCachePath() async => directory.path;

  @override
  Future<String?> getExternalStoragePath() async => directory.path;
}

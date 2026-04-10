import 'package:hive_flutter/hive_flutter.dart';

import '../services/content_seed_service.dart';

class ContentRepository {
  ContentRepository._();

  static final ContentRepository instance = ContentRepository._();
  static const String _boxName = 'contentBox';

  Future<Box<dynamic>> _box() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  String keyForAsset(String assetPath) {
    return ContentSeedService.keyFromAssetPath(assetPath);
  }

  Future<bool> containsAsset(String assetPath) async {
    final Box<dynamic> box = await _box();
    return box.containsKey(keyForAsset(assetPath));
  }

  Future<dynamic> getByAsset(String assetPath) async {
    final Box<dynamic> box = await _box();
    return box.get(keyForAsset(assetPath));
  }

  Future<Map<String, dynamic>?> getMapByAsset(String assetPath) async {
    final dynamic value = await getByAsset(assetPath);
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  Future<List<dynamic>?> getListByAsset(String assetPath) async {
    final dynamic value = await getByAsset(assetPath);
    if (value is List) return List<dynamic>.from(value);
    return null;
  }

  Future<Map<String, dynamic>?> appStrings() async {
    return getMapByAsset('assets/data/app_strings.json');
  }

  Future<List<dynamic>?> faq() async {
    return getListByAsset('assets/data/faq.json');
  }

  Future<List<dynamic>?> psychologyArticles() async {
    return getListByAsset('assets/data/Psychology_Articles_En.json');
  }
}

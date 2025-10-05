import 'dart:math';
import 'package:hive/hive.dart';

/// Simple offline P2P share token service for virtual gifts.
/// Tokens never leave device; user can manually share the short code.
class VirtualGiftShareService {
  static const _boxName = 'virtual_gift_tokens';
  static VirtualGiftShareService? _instance;
  static VirtualGiftShareService get instance =>
      _instance ??= VirtualGiftShareService._();
  VirtualGiftShareService._();

  Future<Box> _open() async => await Hive.openBox(_boxName);

  String _generateToken() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<String> createTokenForGift(Map<String, dynamic> gift) async {
    final box = await _open();
    String token;
    // ensure uniqueness
    do {
      token = _generateToken();
    } while (box.containsKey(token));
    await box.put(token, {
      'giftId': gift['id'],
      'title': gift['title'],
      'titleHi': gift['titleHi'],
      'emoji': gift['emoji'],
      'basePrice': gift['basePrice'],
      'created': DateTime.now().toIso8601String(),
      'redeemed': false,
    });
    return token;
  }

  /// Returns gift map if successful; null otherwise.
  Future<Map<String, dynamic>?> redeemToken(String token) async {
    final box = await _open();
    if (!box.containsKey(token)) return null;
    final data = Map<String, dynamic>.from(box.get(token));
    if (data['redeemed'] == true) return null; // already used
    data['redeemed'] = true;
    data['redeemedAt'] = DateTime.now().toIso8601String();
    await box.put(token, data);
    return data;
  }

  Future<bool> isTokenAvailable(String token) async {
    final box = await _open();
    if (!box.containsKey(token)) return false;
    final data = box.get(token) as Map;
    return data['redeemed'] != true;
  }
}

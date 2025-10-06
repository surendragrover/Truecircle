import 'package:flutter_test/flutter_test.dart';
import 'package:truecircle/services/loyalty_points_service.dart';
import 'package:truecircle/services/virtual_gift_share_service.dart';
import 'package:hive/hive.dart';
import 'dart:io';

Future<void> _initHive() async {
  final dir = await Directory.systemTemp.createTemp('truecircle_test_hive');
  Hive.init(dir.path);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Global setup: Hive path and seed loyalty points for discount tests
  setUpAll(() async {
    await _initHive();
    final box = await Hive.openBox('loyalty_points');
    await box.put('total_points', 1000); // Ensure enough points for tests
  });

  group('LoyaltyPointsService Discount Calculation', () {
    test('Respects 15 percent cap', () async {
  const price = 100.0; // 15% => 15 points max
      // simulate having more points than allowed
      // Ensure service reads seeded points from Hive
      await LoyaltyPointsService.instance.ensureInitialized();
      final calc = LoyaltyPointsService.instance.calculateDiscount(price, 999);
      expect(calc.actualPointsToUse, 15);
      expect(calc.finalPrice, 85.0);
    });

    test('Zero points scenario', () {
  const price = 50.0;
      final calc = LoyaltyPointsService.instance.calculateDiscount(price, 0);
      expect(calc.actualPointsToUse, 0);
      expect(calc.finalPrice, price);
    });
  });

  group('VirtualGiftShareService token lifecycle', () {
    // Hive already initialized in global setUpAll

    test('Create and redeem token exactly once', () async {
      final gift = {
        'id': 'vg_card_1',
        'title': 'Festival Greeting',
        'titleHi': 'त्योहार शुभकामना',
        'emoji': '🪔',
        'basePrice': 49.0,
      };
      final service = VirtualGiftShareService.instance;
      final token = await service.createTokenForGift(gift);
      expect(token.length, 6);
      final availableBefore = await service.isTokenAvailable(token);
      expect(availableBefore, true);
      final data = await service.redeemToken(token);
      expect(data, isNotNull);
      final availableAfter = await service.isTokenAvailable(token);
      expect(availableAfter, false, reason: 'Token should not be available after redemption');
      final dataSecond = await service.redeemToken(token);
      expect(dataSecond, isNull, reason: 'Second redemption must fail');
    });
  });
}

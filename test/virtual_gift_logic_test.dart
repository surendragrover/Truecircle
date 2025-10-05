import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:truecircle/services/loyalty_points_service.dart';
import 'package:truecircle/services/virtual_gift_share_service.dart';

import 'test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await TestHiveHarness.ensureInitialized();
  });

  tearDownAll(() async {
    await TestHiveHarness.dispose();
  });

  group('LoyaltyPointsService Discount Calculation', () {
    test('Respects 15 percent cap', () async {
      await LoyaltyPointsService.configureForTest(totalPoints: 500);
      final service = LoyaltyPointsService.instance;
      const price = 100.0; // 15% => 15 points max
      // simulate having more points than allowed
      final calc = service.calculateDiscount(price, 999);
      expect(calc.actualPointsToUse, 15);
      expect(calc.finalPrice, 85.0);
    });

    test('Zero points scenario', () async {
      await LoyaltyPointsService.configureForTest(totalPoints: 0);
      const price = 50.0;
      final calc = LoyaltyPointsService.instance.calculateDiscount(price, 0);
      expect(calc.actualPointsToUse, 0);
      expect(calc.finalPrice, price);
    });
  });

  group('VirtualGiftShareService token lifecycle', () {
    setUpAll(() async {
      await TestHiveHarness.ensureInitialized();
      await TestHiveHarness.resetBox('virtual_gift_tokens');
    });

    tearDown(() async {
      if (Hive.isBoxOpen('virtual_gift_tokens')) {
        await Hive.box('virtual_gift_tokens').clear();
      }
    });

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
      expect(availableAfter, false,
          reason: 'Token should not be available after redemption');
      final dataSecond = await service.redeemToken(token);
      expect(dataSecond, isNull, reason: 'Second redemption must fail');
    });
  });
}

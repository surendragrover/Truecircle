// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:truecircle/main.dart';
import 'package:truecircle/services/loyalty_points_service.dart';

import 'test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await TestHiveHarness.ensureInitialized();
    SharedPreferences.setMockInitialValues({'is_first_time': true});
    await LoyaltyPointsService.configureForTest(totalPoints: 50);
  });

  tearDownAll(() async {
    await TestHiveHarness.dispose();
  });

  testWidgets('TrueCircle app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrueCircleApp());
    await tester.pumpAndSettle();

    // Verify that onboarding screen renders primary headline
    expect(find.textContaining('TrueCircle'), findsWidgets);
  });
}

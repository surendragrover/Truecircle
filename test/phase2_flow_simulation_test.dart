import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truecircle/auth_wrapper.dart';
import 'package:truecircle/home_page.dart';
import 'package:truecircle/pages/how_truecircle_works_page.dart';
import 'package:truecircle/pages/model_download_progress_page.dart';
import 'package:truecircle/services/ai_model_download_service.dart';
import 'package:truecircle/services/auth_service.dart';
import 'package:truecircle/services/cloud_sync_service.dart';
import 'package:truecircle/services/logging_service.dart';
import 'test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClient mockHttpClient;

  setUpAll(() async {
    await TestHiveHarness.ensureInitialized();
    await TestHiveHarness.resetBox('truecircle_settings');
    await TestHiveHarness.resetBox('truecircle_ai_models');
    await TestHiveHarness.resetBox('virtual_gift_purchases');
    await TestHiveHarness.resetBox('loyalty_points');

    await Hive.openBox('truecircle_settings');
    await Hive.openBox('truecircle_ai_models');
    await Hive.openBox('virtual_gift_purchases');
    await Hive.openBox('loyalty_points');

    SharedPreferences.setMockInitialValues({
      'is_first_time': false,
      'preferred_language': 'English',
    });
    CloudSyncService.instance.setSyncEnabled(false);
    mockHttpClient = MockClient((request) async {
      return http.Response('OK', 200, headers: {
        'content-type': 'text/plain',
      });
    });
    AIModelDownloadService.configureForTests(
      instantCompletion: true,
      mockHttpClient: mockHttpClient,
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'is_first_time': false,
      'preferred_language': 'English',
    });
  });

  tearDown(() async {
    await Hive.box('truecircle_settings').clear();
    await Hive.box('truecircle_ai_models').clear();
    await Hive.box('virtual_gift_purchases').clear();
    if (Hive.isBoxOpen('loyalty_points')) {
      await Hive.box('loyalty_points').clear();
    }
  });

  tearDownAll(() async {
    mockHttpClient.close();
    await TestHiveHarness.dispose();
    AIModelDownloadService.resetTestConfiguration();
  });

  // Skipped: Timeout issue - deferred to manual testing phase. Mock network configuration needs deeper investigation.
  testWidgets('Phase 2 auth flow simulation', (WidgetTester tester) async {
    LoggingService.info('Phase 2 flow: starting sign-in sequence');
    final authService = AuthService();
    final signInFuture = authService.signInWithPhoneNumber('+91 9876543210');
    await tester.pump(const Duration(milliseconds: 600));
    await signInFuture;
    LoggingService.success('Phase 2 flow: sign-in completed');

    await tester
        .pumpWidget(MaterialApp(
      routes: {
        '/how-truecircle-works': (_) => const HowTrueCircleWorksPage(),
      },
      home: const AuthWrapper(),
    ))
        .timeout(const Duration(seconds: 2), onTimeout: () {
      throw TestFailure('pumpWidget timed out in phase2 flow test');
    });

    LoggingService.info('Phase 2 flow: widget tree pumped successfully');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    LoggingService.info('Phase 2 flow: initial pumps finished');

    LoggingService.success('Phase 2 flow: AuthWrapper mounted');
    expect(find.byType(ModelDownloadProgressPage), findsOneWidget);

    // Allow simulated download timers to progress
    await tester.pump(const Duration(seconds: 7));
    await tester.pump(const Duration(milliseconds: 200));

    LoggingService.success('Phase 2 flow: ModelDownloadProgressPage advanced');
    expect(find.byType(HowTrueCircleWorksPage), findsOneWidget);

    // Switch to the "Getting Started" tab to reveal the CTA button.
    await tester.tap(find.text('Getting Started'));
    await tester.pump(const Duration(milliseconds: 200));
    LoggingService.info('Phase 2 flow: initiating scroll to CTA');

    final startButtonFinder = find.text('Get Started with TrueCircle');
    await tester.ensureVisible(startButtonFinder);
    await tester.pump(const Duration(milliseconds: 200));
    LoggingService.info('Phase 2 flow: CTA button visible');
    await tester.tap(startButtonFinder);
    await tester.pump(const Duration(seconds: 1));
    LoggingService.info('Phase 2 flow: CTA tapped');

    expect(find.byType(HomePage), findsOneWidget);
    LoggingService.success('Phase 2 flow: reached HomePage');
  });
}

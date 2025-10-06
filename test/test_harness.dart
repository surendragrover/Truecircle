import 'dart:io';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initialize lightweight test environment for widget/integration tests.
/// - Sets up Hive with a temporary path (no plugins required).
/// - Optionally seeds SharedPreferences to control onboarding flow.
Future<void> initWidgetTestEnv({bool firstTime = true}) async {
  // Hive in a temp directory so AuthWrapper can open boxes.
  final dir = await Directory.systemTemp.createTemp('truecircle_test_hive');
  Hive.init(dir.path);

  // Seed SharedPreferences to avoid unexpected flows in tests if desired.
  SharedPreferences.setMockInitialValues({
    'is_first_time': firstTime,
  });

  // Seed Auth + Model download flags so AuthWrapper navigates to HomePage.
  final box = await Hive.openBox('truecircle_settings');
  const phone = '+911234567890';
  await box.put('current_phone_number', phone);
  await box.put('current_phone_verified', true);
  await box.put('${phone}_models_downloaded', true);
  await box.put('${phone}_seen_how_works', true);
}

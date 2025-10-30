import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:true_circle/core/service_locator.dart';
import 'package:true_circle/iris/dr_iris_chat_page.dart';
import 'package:true_circle/services/on_device_ai_service.dart';

class _FakeAI implements OnDeviceAIService {
  @override
  Future<String> generateDrIrisResponse(String prompt) async {
    // Return a deterministic response for testing
    return 'AI: Hello, I am here for you.';
  }

  @override
  Future<bool> initialize() async => true;

  @override
  Future<bool> isSupported() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    // Initialize Hive in a temporary directory for widget tests
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tempDir.path);

    // Ensure a fresh service locator state for each test
    // Register only what DrIrisChatPage needs
    if (!ServiceLocator.instance.isRegistered<OnDeviceAIService>()) {
      ServiceLocator.instance.registerSingleton<OnDeviceAIService>(_FakeAI());
    }
  });

  tearDown(() async {
    try {
      if (Hive.isBoxOpen('dr_iris_chat')) {
        await Hive.box('dr_iris_chat').close();
      }
      await Hive.deleteBoxFromDisk('dr_iris_chat');
    } catch (_) {}
    await Hive.close();
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  testWidgets('blocks profanity before sending', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DrIrisChatPage()));

    // Initial welcome message may animate in; settle initial frames
    // Avoid pumpAndSettle due to repeating animations; just advance a bit
    await tester.pump(const Duration(milliseconds: 200));

    // Enter disguised profanity and attempt to send
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    await tester.enterText(textField, 'this is shit');

    final sendButton = find.byIcon(Icons.send);
    expect(sendButton, findsOneWidget);
    await tester.tap(sendButton);

    // Allow snackbar to show
    await tester.pump();

    expect(
      find.text('Please avoid offensive language. Your message was not sent.'),
      findsOneWidget,
    );
  });

  testWidgets('sends user message and progresses flow', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DrIrisChatPage()));

    await tester.pump(const Duration(milliseconds: 200));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'hello');

    final sendButton = find.byIcon(Icons.send);
    await tester.tap(sendButton);

    // Shortly after sending, the user's message bubble should appear
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('You'), findsOneWidget);
  });
}

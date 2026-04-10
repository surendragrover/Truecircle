import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truecircle/screens/onboarding/onboarding_screen.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: OnboardingScreen(),
    );
  }

  testWidgets('Onboarding screen renders key sections and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.text('Verify Account'), findsOneWidget);
    expect(find.text('Welcome to TrueCircle'), findsOneWidget);
    expect(find.text('Mobile Verification'), findsOneWidget);
    expect(find.text('Email Verification'), findsOneWidget);
  });

  testWidgets('Mobile OTP button changes to Resend after valid number entry', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createTestWidget());

    final Finder mobileField = find.widgetWithText(
      TextField,
      'Mobile Number',
    );
    await tester.enterText(mobileField, '9876543210');

    await tester.tap(find.text('Send OTP').first);
    await tester.pump();

    expect(find.text('Resend'), findsOneWidget);
    expect(
      find.textContaining('Mobile OTP request is routed to WhatsApp support'),
      findsOneWidget,
    );
  });
}

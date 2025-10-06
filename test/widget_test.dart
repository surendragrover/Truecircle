// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
// Use the lightweight test app to avoid heavy initialization during widget tests
import 'package:truecircle/main_simple.dart';

void main() {
  testWidgets('TrueCircle simple app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SimpleTestApp());
    // Avoid indefinite waits; a short pump is sufficient for this static UI
    await tester.pump(const Duration(milliseconds: 50));

    // Verify that app loads successfully (AppBar title)
    expect(find.text('TrueCircle - Simple Test'), findsOneWidget);
    expect(find.text('TrueCircle App Working!'), findsOneWidget);
  });
}

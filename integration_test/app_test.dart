import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:truecircle/main_simple.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Simple app integration smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SimpleTestApp());
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('TrueCircle - Simple Test'), findsOneWidget);
    expect(find.text('TrueCircle App Working!'), findsOneWidget);
  });
}

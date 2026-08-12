import 'package:flutter_test/flutter_test.dart';
import 'package:c2c/main.dart';

void main() {
  testWidgets('C2CApp smoke test builds successfully', (WidgetTester tester) async {
    // Build our C2C app and trigger a frame.
    await tester.pumpWidget(const C2CApp());

    // Allow async data fetching timers to settle
    await tester.pump(const Duration(seconds: 1));

    // Verify that C2CApp builds properly
    expect(find.byType(C2CApp), findsOneWidget);
  });
}

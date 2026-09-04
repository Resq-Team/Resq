import 'package:flutter_test/flutter_test.dart';
import 'package:resq/main.dart';

void main() {
  testWidgets('App smoke test builds cleanly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ResQApp());
    expect(find.byType(ResQApp), findsOneWidget);
  });
}

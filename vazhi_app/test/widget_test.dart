// VAZHI App Widget Tests

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vazhi_app/main.dart';

void main() {
  testWidgets('App loads with welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: VazhiApp()));

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the welcome screen shows
    expect(find.text('வணக்கம்!'), findsOneWidget);
    expect(find.text('Tamil AI Assistant'), findsOneWidget);
  });
}

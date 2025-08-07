// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:suborno_joyonti/main.dart';

void main() {
  testWidgets('Golden Jubilee App instantiation test', (
    WidgetTester tester,
  ) async {
    // Just verify that the app can be instantiated
    const app = GoldenJubileeApp();
    expect(app, isA<GoldenJubileeApp>());
  });
}

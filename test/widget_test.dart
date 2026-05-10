// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chaos_wheel_party_game/main.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';

void main() {
  testWidgets('shows splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameProvider(),
        child: const ChaosWheelApp(),
      ),
    );

    expect(find.text('CHAOS\nWHEEL'), findsOneWidget);
    expect(find.text('TRUTH  ·  DARE  ·  DRINK  ·  NO ESCAPE'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('START GAME'), findsOneWidget);
  });
}

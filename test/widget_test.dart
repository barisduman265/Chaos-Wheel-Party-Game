import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:chaos_wheel/main.dart';
import 'package:chaos_wheel/providers/game_provider.dart';

void main() {
  testWidgets('shows splash branding and opens home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GameProvider(),
        child: const ChaosWheelApp(),
      ),
    );

    expect(find.text('CHAOS\nWHEEL'), findsOneWidget);
    expect(find.text('TRUTH  .  DARE  .  DRINK  .  NO ESCAPE'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('START GAME'), findsOneWidget);
  });
}

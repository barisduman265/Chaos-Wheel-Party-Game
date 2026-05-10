import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/add_players_screen.dart';
import 'package:chaos_wheel_party_game/screens/game_screen.dart';
import 'package:chaos_wheel_party_game/screens/game_setup_screen.dart';
import 'package:chaos_wheel_party_game/screens/game_summary_screen.dart';
import 'package:chaos_wheel_party_game/screens/home_screen.dart';
import 'package:chaos_wheel_party_game/screens/how_to_play_screen.dart';
import 'package:chaos_wheel_party_game/screens/premium_screen.dart';
import 'package:chaos_wheel_party_game/screens/settings_screen.dart';
import 'package:chaos_wheel_party_game/screens/splash_screen.dart';
import 'package:chaos_wheel_party_game/screens/target_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: const ChaosWheelApp(),
    ),
  );
}

class ChaosWheelApp extends StatelessWidget {
  const ChaosWheelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return MaterialApp(
      title: 'Chaos Wheel: Party Game',
      debugShowCheckedModeBanner: false,
      themeMode: provider.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        HomeScreen.routeName: (_) => const HomeScreen(),
        HowToPlayScreen.routeName: (_) => const HowToPlayScreen(),
        AddPlayersScreen.routeName: (_) => const AddPlayersScreen(),
        GameSetupScreen.routeName: (_) => const GameSetupScreen(),
        GameScreen.routeName: (_) => const GameScreen(),
        TargetSelectionScreen.routeName: (_) => const TargetSelectionScreen(),
        GameSummaryScreen.routeName: (_) => const GameSummaryScreen(),
        PremiumScreen.routeName: (_) => const PremiumScreen(),
        SettingsScreen.routeName: (_) => const SettingsScreen(),
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'sans-serif',
    );

    const background = Color(0xFF090411);
    const surface = Color(0xFF151022);
    const primary = Color(0xFFBB29FF);
    const secondary = Color(0xFFFF3D81);
    const tertiary = Color(0xFF39D2FF);
    const accent = Color(0xFFFF6B4A);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: isDark ? surface : Colors.white,
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? background : const Color(0xFFF4F3FA),
      colorScheme: scheme,
      textTheme: base.textTheme.apply(
        bodyColor: isDark ? Colors.white : const Color(0xFF130D1D),
        displayColor: isDark ? Colors.white : const Color(0xFF130D1D),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF130D1D),
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: isDark ? surface.withValues(alpha: 0.78) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: accent,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: tertiary, width: 1.5),
        ),
      ),
    );
  }
}

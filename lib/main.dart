import 'package:chaos_wheel/providers/game_provider.dart';
import 'package:chaos_wheel/screens/add_players_screen.dart';
import 'package:chaos_wheel/screens/game_screen.dart';
import 'package:chaos_wheel/screens/game_setup_screen.dart';
import 'package:chaos_wheel/screens/game_summary_screen.dart';
import 'package:chaos_wheel/screens/home_screen.dart';
import 'package:chaos_wheel/screens/how_to_play_screen.dart';
import 'package:chaos_wheel/screens/premium_screen.dart';
import 'package:chaos_wheel/screens/settings_screen.dart';
import 'package:chaos_wheel/screens/splash_screen.dart';
import 'package:chaos_wheel/screens/target_selection_screen.dart';
import 'package:chaos_wheel/services/chaos_audio_service.dart';
import 'package:chaos_wheel/services/interstitial_ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();
  // Warm up the first interstitial so it's ready by the time gameplay needs it.
  InterstitialAdManager.instance.preload();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: const ChaosWheelApp(),
    ),
  );
}

class ChaosWheelApp extends StatefulWidget {
  const ChaosWheelApp({super.key});

  @override
  State<ChaosWheelApp> createState() => _ChaosWheelAppState();
}

class _ChaosWheelAppState extends State<ChaosWheelApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause background music whenever the app leaves the foreground (home
    // button, app switcher, another app) and resume it on return, so music
    // never keeps playing off-screen.
    switch (state) {
      case AppLifecycleState.resumed:
        ChaosAudioService.instance.resumeMusicFromBackground();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        ChaosAudioService.instance.pauseMusicForBackground();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return MaterialApp(
      title: 'Chaos Wheel: Party Game',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _ChaosScrollBehavior(),
      // The UI is laid out for the default text size. Clamp the system font
      // scale so very large accessibility font settings don't blow up the
      // tightly-designed screens (premium, game setup, player cards).
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.1,
            ),
          ),
          child: child!,
        );
      },
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
      fontFamily: GoogleFonts.fredoka().fontFamily,
    );

    const background = Color(0xFF090411);
    const surface = Color(0xFF151022);
    const primary = Color(0xFFA85BFF);
    const secondary = Color(0xFFFF3D81);
    const tertiary = Color(0xFF39D2FF);
    const accent = Color(0xFFFF5D98);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: isDark ? surface : Colors.white,
    );

    final bodyColor = isDark ? Colors.white : const Color(0xFF130D1D);
    // Fredoka is missing some Turkish glyphs (e.g. ş, ı), which made names like
    // "Barış" render as "Baris,". Fall back to Nunito Sans first, then the
    // platform fonts (all of which carry full Turkish) for those glyphs.
    final turkishFallback = <String>[
      GoogleFonts.nunitoSans().fontFamily ?? 'Roboto',
      'Roboto',
      'Noto Sans',
      'sans-serif',
    ];
    final baseTextTheme = GoogleFonts.nunitoSansTextTheme(base.textTheme);
    final textTheme = _withTurkishFallback(
      baseTextTheme.copyWith(
          displayLarge: GoogleFonts.fredoka(
            textStyle: base.textTheme.displayLarge,            fontSize: 64,
            fontWeight: FontWeight.w700,
            height: 0.92,
            letterSpacing: -0.4,
          ),
          displayMedium: GoogleFonts.fredoka(
            textStyle: base.textTheme.displayMedium,            fontWeight: FontWeight.w800,
            height: 0.96,
            letterSpacing: -0.3,
          ),
          displaySmall: GoogleFonts.fredoka(
            textStyle: base.textTheme.displaySmall,            fontWeight: FontWeight.w800,
            height: 0.98,
            letterSpacing: -0.2,
          ),
          headlineLarge: GoogleFonts.fredoka(
            textStyle: base.textTheme.headlineLarge,            fontWeight: FontWeight.w800,
            height: 1,
            letterSpacing: -0.1,
          ),
          headlineMedium: GoogleFonts.fredoka(
            textStyle: base.textTheme.headlineMedium,            fontWeight: FontWeight.w800,
            height: 1.02,
            letterSpacing: -0.1,
          ),
          headlineSmall: GoogleFonts.fredoka(
            textStyle: base.textTheme.headlineSmall,            fontWeight: FontWeight.w800,
            height: 1.02,
            letterSpacing: 0,
          ),
          titleLarge: GoogleFonts.fredoka(
            textStyle: base.textTheme.titleLarge,            fontWeight: FontWeight.w700,
            height: 1.04,
            letterSpacing: 0,
          ),
          titleMedium: GoogleFonts.nunitoSans(
            textStyle: base.textTheme.titleMedium,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: 0,
          ),
          titleSmall: GoogleFonts.nunitoSans(
            textStyle: base.textTheme.titleSmall,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: 0,
          ),
          bodyLarge: GoogleFonts.nunitoSans(
            textStyle: base.textTheme.bodyLarge,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: GoogleFonts.nunitoSans(
            textStyle: base.textTheme.bodyMedium,
            fontWeight: FontWeight.w600,
          ),
          bodySmall: GoogleFonts.nunitoSans(
            textStyle: base.textTheme.bodySmall,
            fontWeight: FontWeight.w500,
          ),
          labelLarge: GoogleFonts.nunitoSans(
            textStyle: base.textTheme.labelLarge,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
          labelMedium: GoogleFonts.nunitoSans(
            textStyle: base.textTheme.labelMedium,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
          labelSmall: GoogleFonts.nunitoSans(
            textStyle: base.textTheme.labelSmall,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        )
        .apply(bodyColor: bodyColor, displayColor: bodyColor),
      turkishFallback,
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? background : const Color(0xFFF4F3FA),
      colorScheme: scheme,
      textTheme: textTheme,
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
        // Snackbar messages frequently embed user-typed player names; use
        // Nunito Sans (full Turkish support) rather than Fredoka, whose ş/Ş
        // cedilla is malformed.
        contentTextStyle: GoogleFonts.nunitoSans(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
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

/// Adds [fallback] families to every style so glyphs missing from the primary
/// font (e.g. Turkish ş/ı in Fredoka) are drawn from a font that has them.
TextTheme _withTurkishFallback(TextTheme theme, List<String> fallback) {
  TextStyle? f(TextStyle? style) =>
      style?.copyWith(fontFamilyFallback: fallback);
  return theme.copyWith(
    displayLarge: f(theme.displayLarge),
    displayMedium: f(theme.displayMedium),
    displaySmall: f(theme.displaySmall),
    headlineLarge: f(theme.headlineLarge),
    headlineMedium: f(theme.headlineMedium),
    headlineSmall: f(theme.headlineSmall),
    titleLarge: f(theme.titleLarge),
    titleMedium: f(theme.titleMedium),
    titleSmall: f(theme.titleSmall),
    bodyLarge: f(theme.bodyLarge),
    bodyMedium: f(theme.bodyMedium),
    bodySmall: f(theme.bodySmall),
    labelLarge: f(theme.labelLarge),
    labelMedium: f(theme.labelMedium),
    labelSmall: f(theme.labelSmall),
  );
}

class _ChaosScrollBehavior extends MaterialScrollBehavior {
  const _ChaosScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_strings.dart';
import 'l10n/locale_controller.dart';
import 'screens/initial_screen.dart';
import 'services/player_connection.dart';
import 'services/ui_feedback.dart';
import 'theme/app_colors.dart';
import 'widgets/app_canvas.dart';
import 'widgets/directional_page_transitions.dart';
import 'widgets/idle_reset.dart';
import 'widgets/locale_fade.dart';
import 'widgets/mirror_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Kiosk tablet, 16:9 landscape (1920x1080 canvas): hide status + navigation bars.
  await SystemChrome.setPreferredOrientations(const [DeviceOrientation.landscapeLeft]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Images are kept at their original resolution: the masterplan render alone
  // decodes to ~133 MB (7680x4320) and the building stills to ~33 MB each. The
  // default 100 MB cache could not hold the masterplan at all, so it would be
  // decoded again on every visit.
  PaintingBinding.instance.imageCache.maximumSizeBytes = 400 << 20;
  UiFeedback.init(); // pre-load interaction sounds; never blocks startup
  await PlayerConnection.load(); // reconnects to the paired main screen, if any
  runApp(MyApp(localeController: await LocaleController.load()));
}

final _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(listenable: localeController, builder: (context, _) => _buildApp());
  }

  Widget _buildApp() {
    final locale = localeController.locale;
    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: [MirrorState.routeObserver],
      builder: (context, child) => AppCanvas(
        child: LocaleFade(
          locale: locale,
          child: IdleReset(navigatorKey: _navigatorKey, child: child!),
        ),
      ),
      title: 'Ezdihar Remote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // The screens are full-bleed photos; until one has decoded, dark shows
        // through instead of Material's near-white surface (QA: white flash).
        scaffoldBackgroundColor: AppColors.screenBackground,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: DirectionalPageTransitionsBuilder(),
            TargetPlatform.windows: DirectionalPageTransitionsBuilder(),
            TargetPlatform.iOS: DirectionalPageTransitionsBuilder(),
            TargetPlatform.linux: DirectionalPageTransitionsBuilder(),
            TargetPlatform.macOS: DirectionalPageTransitionsBuilder(),
          },
        ),
      ),
      // The locale drives text direction: ar -> RTL, en -> LTR.
      locale: locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [AppStrings.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      home: InitialScreen(locale: locale, onLocaleChanged: localeController.setLocale),
      debugShowCheckedModeBanner: false,
    );
  }
}

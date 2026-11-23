import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ezdihar_remote/l10n/app_strings.dart';
import 'package:ezdihar_remote/screens/city_context_screen.dart';
import 'package:ezdihar_remote/screens/masterplan_screen.dart';
import 'package:ezdihar_remote/services/player_connection.dart';
import 'package:ezdihar_remote/widgets/app_canvas.dart';

void main() {
  Future<Rect> pumpCity(WidgetTester tester, {String locale = 'en'}) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => AppCanvas(child: child!),
        locale: Locale(locale),
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: const [
          AppStrings.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: CityContextScreen(onLocaleChanged: (_) {}),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    final polygon = find.byWidgetPredicate(
      (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName.endsWith('site_polygon.png'),
    );
    return tester.getRect(polygon);
  }

  testWidgets('tapping the highlighted site opens the masterplan', (tester) async {
    final site = await pumpCity(tester);
    await tester.tapAt(site.topLeft + Offset(site.width * 0.6, site.height * 0.6));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MasterplanScreen), findsOneWidget);
  });

  Finder landmarkPhoto(String id) => find.byWidgetPredicate(
    (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName.endsWith('landmarks/$id.jpg'),
  );

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('a landmark tile opens its card; Next / Previous step through the landmarks', (tester) async {
    await pumpCity(tester);
    expect(find.text('Previous'), findsNothing);

    await tester.tap(find.text('Horse Racing Track'));
    await settle(tester);
    expect(landmarkPhoto('horse_racing_track'), findsOneWidget);
    expect(find.text('Previous'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await settle(tester);
    expect(landmarkPhoto('khuzam_district'), findsOneWidget);
    expect(landmarkPhoto('horse_racing_track'), findsNothing);

    await tester.tap(find.text('Previous'));
    await tester.tap(find.text('Previous'));
    await settle(tester);
    expect(landmarkPhoto('king_khalid_airport'), findsOneWidget);

    // Wraps around from the first landmark to the last.
    await tester.tap(find.text('Previous'));
    await tester.tap(find.text('Previous'));
    await tester.tap(find.text('Previous'));
    await settle(tester);
    expect(landmarkPhoto('imam_university'), findsOneWidget);
  });

  for (final locale in ['en', 'ar']) {
    testWidgets('every landmark card shows its own description without overflow ($locale)', (tester) async {
      await pumpCity(tester, locale: locale);
      final strings = await AppStrings.delegate.load(Locale(locale));
      await tester.tap(find.text(strings.horseRacingTrack));
      await settle(tester);
      const ids = [
        'horse_racing_track', 'khuzam_district', 'expo_2030', 'princess_nourah_university',
        'imam_university', 'king_salman_airport', 'equestrian_club', 'king_khalid_airport',
      ];
      final seen = <String>{};
      for (var i = 0; i < ids.length; i++) {
        final id = ids.firstWhere((id) => landmarkPhoto(id).evaluate().isNotEmpty);
        seen.add(id);
        expect(find.text(strings.landmarkDescription(id)), findsOneWidget, reason: id);
        expect(tester.takeException(), isNull, reason: id);
        await tester.tap(find.text(strings.nextLandmark));
        await settle(tester);
      }
      expect(seen, ids.toSet());
    });
  }

  testWidgets('X and Back close the landmark before leaving the screen', (tester) async {
    await pumpCity(tester);
    await tester.tap(find.text('Expo 2030 Riyadh'));
    await settle(tester);
    await tester.tap(find.byTooltip('Close'));
    await settle(tester);
    expect(landmarkPhoto('expo_2030'), findsNothing);

    await tester.tap(find.text('Expo 2030 Riyadh'));
    await settle(tester);
    final handled = await tester.binding.handlePopRoute();
    await settle(tester);
    expect(handled, isTrue);
    expect(landmarkPhoto('expo_2030'), findsNothing);
    expect(find.byType(CityContextScreen), findsOneWidget);
  });

  testWidgets('an open landmark is mirrored as a modal over city_context', (tester) async {
    final connection = PlayerConnection.instance;
    await pumpCity(tester);
    await tester.tap(find.text('Expo 2030 Riyadh'));
    await settle(tester);
    expect(connection.mirroredModal, {
      'kind': 'landmark',
      'id': 'expo_2030',
      'title': 'Expo 2030 Riyadh',
      'description': startsWith('Expo 2030 Riyadh is a global exhibition'),
      'metadata': '28 km · 26 min',
      'locale': 'en',
    });

    await tester.tap(find.text('Next'));
    await settle(tester);
    expect(connection.mirroredModal?['id'], 'princess_nourah_university');

    await tester.tap(find.byTooltip('Close'));
    await settle(tester);
    expect(connection.mirroredModal, isNull);
  });

  testWidgets('tapping the map just outside the site does nothing', (tester) async {
    final site = await pumpCity(tester);
    // Top-start corner of the image's box lies outside the polygon.
    await tester.tapAt(site.topLeft + Offset(site.width * 0.04, site.height * 0.04));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MasterplanScreen), findsNothing);
  });
}

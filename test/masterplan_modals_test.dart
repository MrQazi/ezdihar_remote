import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ezdihar_remote/data/building_data.dart';
import 'package:ezdihar_remote/l10n/app_strings.dart';
import 'package:ezdihar_remote/screens/image_modal.dart';
import 'package:ezdihar_remote/screens/masterplan_screen.dart';
import 'package:ezdihar_remote/services/player_connection.dart';
import 'package:ezdihar_remote/widgets/app_canvas.dart';
import 'package:ezdihar_remote/widgets/modal_backdrop.dart';

void main() {
  setUpAll(BuildingType.loadAll);

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> pumpMasterplan(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The test font (Ahem) is far wider than Rubik: ignore its text overflows.
    final onError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (!details.toString().contains('overflowed')) onError?.call(details);
    };
    addTearDown(() => FlutterError.onError = onError);
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => AppCanvas(child: child!),
      locale: const Locale('en'),
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MasterplanScreen(onLocaleChanged: (_) {}),
    ));
    await settle(tester);
  }

  testWidgets('tapping an amenity opens its photo over a frosted backdrop', (tester) async {
    await pumpMasterplan(tester);
    await tester.tap(find.text('Padel Court 2'));
    await settle(tester);
    expect(find.byType(ImageModal), findsOneWidget);
    expect(find.descendant(of: find.byType(ImageModal), matching: find.byType(ModalBackdrop)), findsOneWidget);
    expect(
      find.descendant(of: find.byType(ImageModal), matching: find.text('Padel Court 2')),
      findsOneWidget,
    );
    expect(PlayerConnection.instance.mirroredModal, {
      'kind': 'amenity',
      'id': 'padel_court',
      'title': 'Padel Court 2',
      'locale': 'en',
    });

    await tester.tap(find.text('Close'));
    await settle(tester);
    expect(find.byType(ImageModal), findsNothing);
    expect(PlayerConnection.instance.mirroredModal, isNull);
  });

  testWidgets('a gallery tile opens the gallery in the modal', (tester) async {
    await pumpMasterplan(tester);
    await tester.tap(find.text('Gallery').last);
    await settle(tester);
    final tiles = find.descendant(of: find.byType(ListView), matching: find.byType(GestureDetector));
    await tester.tap(tiles.at(1));
    await settle(tester);
    expect(find.byType(ImageModal), findsOneWidget);
    expect(find.text('2 / 9'), findsOneWidget);
    expect(PlayerConnection.instance.mirroredModal, {'kind': 'gallery', 'id': 'gallery_2'});

    await tester.tap(find.byTooltip('Next image'));
    await settle(tester);
    expect(find.text('3 / 9'), findsOneWidget);
    expect(PlayerConnection.instance.mirroredModal, {'kind': 'gallery', 'id': 'gallery_3'});

    await tester.tap(find.text('Close'));
    await settle(tester);
    expect(find.byType(ImageModal), findsNothing);
    expect(PlayerConnection.instance.mirroredModal, isNull);
  });
}

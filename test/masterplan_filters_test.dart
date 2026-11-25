import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ezdihar_remote/data/building_data.dart';
import 'package:ezdihar_remote/l10n/app_strings.dart';
import 'package:ezdihar_remote/screens/masterplan_screen.dart';
import 'package:ezdihar_remote/widgets/app_canvas.dart';

void main() {
  // Parsing the data needs real async; once loaded, the screen gets it at once.
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
    expect(find.text('A01'), findsOneWidget, reason: 'building data loaded');
    await tester.tap(find.text('Filters').last);
    await settle(tester);
    expect(find.text('Building Type'), findsOneWidget);
  }

  testWidgets('building type filter counts the matching buildings', (tester) async {
    await pumpMasterplan(tester);
    await tester.tap(find.text('C'));
    await settle(tester);
    expect(find.text('2 of 22 buildings match'), findsOneWidget);
    // Filtered-out ids stay on the map (dimmed, not removed) but take no taps.
    expect(find.text('A01'), findsOneWidget);
    expect(find.text('C01'), findsOneWidget);
    final a01 = tester.widget<Text>(find.text('A01')).style!.color!;
    final c01 = tester.widget<Text>(find.text('C01')).style!.color!;
    expect(a01.a, lessThan(0.5));
    expect(c01.a, 1);
    expect(find.text('A01').hitTestable(), findsNothing);
    expect(find.text('C01').hitTestable(), findsOneWidget);

    await tester.tap(find.text('C'));
    await tester.tap(find.text('A'));
    await settle(tester);
    expect(find.text('5 of 22 buildings match'), findsOneWidget);
  });

  testWidgets('the floor slider filters buildings', (tester) async {
    await pumpMasterplan(tester);
    final rect = tester.getRect(find.byType(RangeSlider).first);
    // Upper thumb (6F) down to GF: only types with apartments on the ground
    // floor stay lit (A and B; C's GF has none).
    await tester.dragFrom(Offset(rect.right - 12, rect.center.dy), Offset(-rect.width, 0));
    await settle(tester);
    expect(find.text('20 of 22 buildings match'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ezdihar_remote/data/building_data.dart';
import 'package:ezdihar_remote/l10n/app_strings.dart';
import 'package:ezdihar_remote/screens/building_detail_screen.dart';
import 'package:ezdihar_remote/widgets/app_canvas.dart';

void main() {
  late BuildingType typeC;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    typeC = (await BuildingType.loadAll()).firstWhere((t) => t.type == 'C');
  });

  Future<void> pumpBuilding(WidgetTester tester, String locale) async {
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
        home: BuildingDetailScreen(type: typeC, buildingId: 'C01', onLocaleChanged: (_) {}),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('floors use the sheet names; a floor without apartments hides the apartments panel',
      (tester) async {
    await pumpBuilding(tester, 'en');

    // Type C's GF has no apartments in the sheet; it has its own outline.
    // (Tapped first: on view C1 the apartments panel covers it once a floor
    // with apartments is selected.)
    await tester.tap(find.byTooltip('GF'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Floor Details'), findsOneWidget);
    expect(find.text('GF'), findsWidgets);
    expect(find.text('Apartments'), findsNothing);

    // 1F has apartments.
    await tester.tap(find.byTooltip('1F'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Floor Details'), findsOneWidget);
    expect(find.text('1F'), findsWidgets);
    expect(find.text('Apartments'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the building panel fades out in place when a floor is selected', (tester) async {
    await pumpBuilding(tester, 'en');
    final building = find.text('Building Details');
    final start = tester.getRect(building);

    await tester.tap(find.byTooltip('GF'));
    await tester.pump(const Duration(milliseconds: 60));
    // Mid cross-fade the outgoing panel is still where it was, not at bottom-centre.
    expect(tester.getRect(building).left, start.left);
  });

  testWidgets('rotate buttons step through the views and wrap around', (tester) async {
    await pumpBuilding(tester, 'en');
    bool showing(String view) =>
        find.byKey(ValueKey('assets/images/building/views/$view.jpg')).evaluate().isNotEmpty;
    expect(showing('c_1'), isTrue);

    // No video plugin in tests: the clip fails to load and the view is shown at once.
    await tester.tap(find.byTooltip('Rotate right'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(showing('c_2'), isTrue);
    expect(find.byTooltip('1F'), findsOneWidget);

    await tester.tap(find.byTooltip('Rotate left'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byTooltip('Rotate left'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(showing('c_4'), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Arabic floor names', (tester) async {
    await pumpBuilding(tester, 'ar');
    await tester.tap(find.byTooltip('ط1'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('تفاصيل الطابق'), findsOneWidget);
    expect(find.text('ط1'), findsWidgets);
  });
}

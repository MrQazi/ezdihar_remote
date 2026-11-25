import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ezdihar_remote/data/building_data.dart';
import 'package:ezdihar_remote/l10n/app_strings.dart';
import 'package:ezdihar_remote/screens/building_detail_screen.dart';
import 'package:ezdihar_remote/screens/compare_screen.dart';
import 'package:ezdihar_remote/screens/register_interest_screen.dart';
import 'package:ezdihar_remote/services/lead_store.dart';
import 'package:ezdihar_remote/widgets/app_canvas.dart';

/// Keeps leads in memory (widget tests cannot wait on real file IO).
class _MemoryLeadStore extends LeadStore {
  final leads = <Lead>[];

  @override
  Future<void> add(Lead lead) async => leads.add(lead);
}

void main() {
  late BuildingType typeC;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    typeC = (await BuildingType.loadAll()).firstWhere((t) => t.type == 'C');
  });

  /// Two frames: a pushed route is laid out offstage on its first (heroes).
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

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
    await settle(tester);
  }

  Finder inCompare(Finder finder) => find.descendant(of: find.byType(CompareScreen), matching: finder);

  /// Adds building type [type]'s [unitType] through the picker.
  Future<void> pick(WidgetTester tester, String type, String unitType) async {
    if (find.text('Add apartment to compare').evaluate().isNotEmpty) {
      await tester.tap(find.text('Add apartment to compare'));
      await settle(tester);
    }
    await tester.tap(find.text('Building Type $type'));
    await settle(tester);
    expect(find.text('Apartment Type'), findsOneWidget);
    await tester.tap(find.text(unitType));
    await settle(tester);
  }

  testWidgets('from the building view it starts empty, on Select Building', (tester) async {
    await pumpBuilding(tester, 'en');
    await tester.tap(find.text('Compare Apartment'));
    await settle(tester);

    expect(find.text('Compare Apartments'), findsOneWidget);
    expect(find.text('Select up to 3 apartments to compare'), findsOneWidget);
    expect(find.text('Select Building'), findsOneWidget);
    for (final type in ['A', 'B', 'C']) {
      expect(find.text('Building Type $type'), findsOneWidget);
    }
    expect(inCompare(find.text('Apartment')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('from the floor view it starts empty too', (tester) async {
    await pumpBuilding(tester, 'en');
    await tester.tap(find.byTooltip('1F'));
    await settle(tester);
    await tester.tap(find.text('Compare Apartment'));
    await settle(tester);
    expect(find.text('Select Building'), findsOneWidget);
    expect(inCompare(find.text('Apartment')), findsNothing);
  });

  testWidgets('from the apartment view it starts with that apartment', (tester) async {
    await pumpBuilding(tester, 'en');
    await tester.tap(find.byTooltip('1F'));
    await settle(tester);
    await tester.tap(find.text('1 Bedroom'));
    await settle(tester);
    expect(find.text('Apartment Details'), findsOneWidget);

    await tester.tap(find.text('Compare Apartment'));
    await settle(tester);
    expect(find.text('Select one more apartment for comparison'), findsOneWidget);
    expect(find.text('Add apartment to compare'), findsOneWidget);
    expect(inCompare(find.text('1BR')), findsOneWidget);
    expect(inCompare(find.text('1F')), findsOneWidget);
    expect(inCompare(find.text('76.88 M²')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picks up to three, then compares them with Register Interest', (tester) async {
    await pumpBuilding(tester, 'en');
    await tester.tap(find.text('Compare Apartment'));
    await settle(tester);

    // Type A has four apartment types; its 2BR is only on 6F.
    await tester.tap(find.text('Building Type A'));
    await settle(tester);
    for (final unit in ['1BR', '2BR', '3BR', '4BR']) {
      expect(find.text(unit), findsOneWidget);
    }
    await tester.tap(find.text('2BR'));
    await settle(tester);
    expect(find.text('Select one more apartment for comparison'), findsOneWidget);
    expect(inCompare(find.text('6F')), findsOneWidget);
    expect(inCompare(find.text('135.83 M²')), findsOneWidget);

    // The same type cannot be added twice.
    await tester.tap(find.text('Add apartment to compare'));
    await settle(tester);
    await tester.tap(find.text('Building Type A'));
    await settle(tester);
    await tester.tap(find.text('2BR · Added'));
    await settle(tester);
    expect(find.text('Apartment Type'), findsOneWidget);

    // Back steps out of the picker, one step at a time.
    await tester.tap(find.byTooltip('Back').last);
    await settle(tester);
    expect(find.text('Select Building'), findsOneWidget);
    await tester.tap(find.byTooltip('Back').last);
    await settle(tester);
    expect(find.text('Add apartment to compare'), findsOneWidget);

    await pick(tester, 'B', '3BR');
    expect(find.text('Select one more apartment for comparison'), findsOneWidget);
    // B's 3BR is on GF..5F.
    expect(inCompare(find.text('GF – 5F')), findsOneWidget);
    expect(find.text('Register Interest'), findsNothing);

    await pick(tester, 'C', '1BR');
    expect(find.text('Apartments Comparison'), findsOneWidget);
    expect(find.text('Add apartment to compare'), findsNothing);
    expect(find.text('Register Interest'), findsNWidgets(3));

    // Taking one out makes room again.
    await tester.tap(find.byTooltip('Remove from comparison').first);
    await settle(tester);
    expect(find.text('Compare Apartments'), findsOneWidget);
    expect(find.text('Add apartment to compare'), findsOneWidget);
    expect(inCompare(find.text('6F')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Register Interest from the comparison saves the apartment with the details',
      (tester) async {
    final store = _MemoryLeadStore();
    LeadStore.instance = store;
    addTearDown(() => LeadStore.instance = LeadStore());

    await pumpBuilding(tester, 'en');
    await tester.tap(find.text('Compare Apartment'));
    await settle(tester);
    await pick(tester, 'A', '2BR');
    await pick(tester, 'B', '3BR');
    await pick(tester, 'C', '1BR');

    await tester.tap(find.text('Register Interest').first);
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Faisal');
    await tester.enterText(find.byType(TextField).at(1), 'faisal@example.com');
    await tester.enterText(find.byType(TextField).at(2), '0512345678');
    await tester.tap(
      find.descendant(of: find.byType(RegisterInterestScreen), matching: find.text('Register Interest')),
    );
    await settle(tester);

    expect(find.byType(InterestRegisteredScreen), findsOneWidget);
    final lead = store.leads.single;
    expect(lead.name, 'Faisal');
    expect(lead.phone, '+966 0512345678');
    expect(lead.language, 'en');
    expect(lead.target!.source, InterestTarget.fromCompare);
    expect(lead.target!.buildingType, 'A');
    expect(lead.target!.unitType, '2BR');
    expect(lead.target!.floor, isNull);
  });

  testWidgets('a lead that cannot be saved keeps the form open with a message', (tester) async {
    LeadStore.instance = LeadStore(directory: () async => throw const FileSystemException('disk full'));
    addTearDown(() => LeadStore.instance = LeadStore());

    await pumpBuilding(tester, 'en');
    await tester.tap(find.byTooltip('1F'));
    await settle(tester);
    await tester.tap(find.text('1 Bedroom'));
    await settle(tester);
    await tester.tap(find.text('Register Interest'));
    await settle(tester);
    await tester.enterText(find.byType(TextField).at(0), 'Faisal');
    await tester.enterText(find.byType(TextField).at(1), 'faisal@example.com');
    await tester.enterText(find.byType(TextField).at(2), '0512345678');
    await tester.tap(
      find.descendant(of: find.byType(RegisterInterestScreen), matching: find.text('Register Interest')),
    );
    await settle(tester);

    expect(find.byType(InterestRegisteredScreen), findsNothing);
    expect(find.text('Could not save your details. Please try again.'), findsOneWidget);
  });

  testWidgets('Arabic: picker and card labels from the Arabic frames', (tester) async {
    await pumpBuilding(tester, 'ar');
    await tester.tap(find.text('مقارنة الشقق'));
    await settle(tester);
    expect(find.text('اختر المبنى'), findsOneWidget);
    await tester.tap(find.text('المبنى من النوع A'));
    await settle(tester);
    expect(find.text('نوع الشقة'), findsOneWidget);
    expect(find.text('غرفة نوم واحدة'), findsOneWidget);
    expect(find.text('غرفتا نوم'), findsOneWidget);
    await tester.tap(find.text('غرفتا نوم'));
    await settle(tester);
    expect(find.text('اختر شقة أخرى للمقارنة'), findsOneWidget);
    expect(inCompare(find.text('ط6')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

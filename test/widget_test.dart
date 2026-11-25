import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ezdihar_remote/l10n/locale_controller.dart';
import 'package:ezdihar_remote/main.dart';
import 'package:ezdihar_remote/services/storage_access.dart';

void main() {
  late LocaleController controller;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    controller = await LocaleController.load();
  });

  testWidgets('first page offers Start Journey in the default (Arabic) locale', (tester) async {
    await tester.pumpWidget(MyApp(localeController: controller));
    await tester.pump();

    expect(find.text('ابدأ الرحلة'), findsOneWidget);
  });

  group('storage access', () {
    const startJourney = 'ابدأ الرحلة';
    const allow = 'السماح بالوصول';

    testWidgets('without it the app asks first, and starts once it is granted', (tester) async {
      var asked = 0;
      var closed = false;
      final access = StorageAccess(
        granted: false,
        request: () async {
          asked++;
          return true;
        },
        close: () async => closed = true,
      );
      await tester.pumpWidget(MyApp(localeController: controller, storageAccess: access));
      await tester.pump();
      expect(find.text(startJourney), findsNothing);
      expect(find.text('اسمح بالوصول إلى التخزين'), findsOneWidget);
      expect(find.text('وحدة التخزين الداخلية › Ezdihar-Mashael Al Fursan'), findsOneWidget);

      await tester.tap(find.text(allow));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(asked, 1);
      expect(closed, isFalse);
      expect(find.text(startJourney), findsOneWidget);
      expect(find.text(allow), findsNothing);
    });

    testWidgets('refused, the app closes (and asks again on the next open)', (tester) async {
      var closed = false;
      final access = StorageAccess(granted: false, request: () async => false, close: () async => closed = true);
      await tester.pumpWidget(MyApp(localeController: controller, storageAccess: access));
      await tester.pump();

      await tester.tap(find.text(allow));
      await tester.pump();
      expect(closed, isTrue);
      expect(find.text(startJourney), findsNothing);
    });

    testWidgets('already granted, the app starts straight away', (tester) async {
      final access = StorageAccess(granted: true, request: () async => fail('asked'));
      await tester.pumpWidget(MyApp(localeController: controller, storageAccess: access));
      await tester.pump();
      expect(find.text(startJourney), findsOneWidget);
    });
  });
}

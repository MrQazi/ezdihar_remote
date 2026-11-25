import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ezdihar_remote/services/lead_store.dart';

void main() {
  late Directory dir;
  late LeadStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('leads_test');
    store = LeadStore(directory: () async => dir);
  });

  tearDown(() => dir.delete(recursive: true));

  Lead lead(String name, {InterestTarget? target, String phone = '+966 0512345678'}) => Lead(
        time: DateTime(2026, 11, 25, 14, 3, 5),
        name: name,
        email: '$name@example.com',
        phone: phone,
        language: 'ar',
        target: target,
      );

  List<List<String?>> sheetRows() {
    final book = Excel.decodeBytes(File('${dir.path}/${LeadStore.sheetName}').readAsBytesSync());
    expect(book.tables.keys, ['Leads']);
    return [
      for (final row in book.tables['Leads']!.rows) [for (final cell in row) cell?.value?.toString()],
    ];
  }

  test('every lead goes to the record and the spreadsheet, as text', () async {
    await store.add(lead(
      'فيصل',
      target: const InterestTarget(
        buildingType: 'A',
        unitType: '2BR',
        buildingId: 'A03',
        floor: '6F',
        source: InterestTarget.fromApartmentDetails,
      ),
    ));
    await store.add(lead(
      'Sara',
      phone: '+971 050 123 4567',
      target: const InterestTarget(buildingType: 'C', unitType: '1BR', source: InterestTarget.fromCompare),
    ));

    final saved = await store.readAll();
    expect(saved.map((l) => l.name), ['فيصل', 'Sara']);
    expect(saved.first.target!.buildingId, 'A03');
    expect(saved.last.target!.floor, isNull);

    final rows = sheetRows();
    expect(rows, hasLength(3));
    expect(rows[0], LeadStore.columns.map((c) => c.$1).toList());
    // Phone numbers keep the + and the leading zero; Arabic names survive.
    expect(rows[1], [
      '2026-11-25 14:03:05',
      'فيصل',
      'فيصل@example.com',
      '+966 0512345678',
      'ar',
      'A03',
      'A',
      '6F',
      '2BR',
      'apartment_details',
    ]);
    expect(rows[2].sublist(3), ['+971 050 123 4567', 'ar', null, 'C', null, '1BR', 'compare']);
  });

  test('a line cut short in the record is skipped, not fatal', () async {
    await store.add(lead('First'));
    // Power lost mid-write: the record ends in half a line.
    await File('${dir.path}/${LeadStore.logName}').writeAsString('{"time": "2026-11', mode: FileMode.append);
    await store.add(lead('Second'));

    expect((await store.readAll()).map((l) => l.name), ['First', 'Second']);
    expect(sheetRows(), hasLength(3));
  });

  group('leads saved in the previous folder (build 42)', () {
    late Directory previous;
    setUp(() async => previous = await Directory.systemTemp.createTemp('leads_previous'));
    tearDown(() async {
      if (await previous.exists()) await previous.delete(recursive: true);
    });

    test('move in once, before new ones, and the old folder goes', () async {
      await LeadStore(directory: () async => previous).add(lead('Earlier'));
      store = LeadStore(directory: () async => dir, previousDirectory: () async => previous);

      await store.prepare();
      expect(await previous.exists(), isFalse);
      expect((await store.readAll()).map((l) => l.name), ['Earlier']);
      expect(sheetRows(), hasLength(2));

      await store.add(lead('Later'));
      expect((await store.readAll()).map((l) => l.name), ['Earlier', 'Later']);
      expect(sheetRows(), hasLength(3));
    });

    test('a move cut short is finished without doubling leads', () async {
      final earlier = jsonEncode(lead('Earlier').toJson());
      // The record was copied but the old folder not yet removed.
      await File('${previous.path}/${LeadStore.logName}').writeAsString('$earlier\n');
      await File('${dir.path}/${LeadStore.logName}').writeAsString('$earlier\n');
      store = LeadStore(directory: () async => dir, previousDirectory: () async => previous);

      await store.add(lead('Later'));
      expect((await store.readAll()).map((l) => l.name), ['Earlier', 'Later']);
      expect(await previous.exists(), isFalse);
    });
  });

  test('submissions made together are all kept', () async {
    await Future.wait([for (var i = 0; i < 5; i++) store.add(lead('Visitor $i'))]);
    expect((await store.readAll()).map((l) => l.name), [for (var i = 0; i < 5; i++) 'Visitor $i']);
    expect(sheetRows(), hasLength(6));
  });
}

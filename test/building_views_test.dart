import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:ezdihar_remote/data/building_data.dart';
import 'package:ezdihar_remote/data/building_views.dart';
import 'package:ezdihar_remote/data/masterplan_data.dart';

void main() {
  late List<BuildingType> types;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    types = await BuildingType.loadAll();
  });

  const frame = Rect.fromLTWH(0, 0, BuildingView.figmaWidth, BuildingView.figmaHeight);

  test('every building type has views, each with one outline per floor in the data', () {
    for (final t in types) {
      final views = BuildingView.of(t.type);
      expect(views, isNotEmpty, reason: t.type);
      for (final v in views) {
        expect(v.floors, hasLength(t.floorDetails.length), reason: '${t.type}${v.number}');
        // Top floor first: each outline starts above the next one.
        final tops = [for (final f in v.floors) f.path().getBounds().top];
        expect(tops, orderedEquals([...tops]..sort()), reason: '${t.type}${v.number}');
        for (final f in v.floors) {
          final box = f.path().getBounds();
          expect(box.isEmpty, isFalse);
          expect(frame.inflate(1).contains(box.topLeft) && frame.inflate(1).contains(box.bottomRight), isTrue,
              reason: '${t.type}${v.number} $box');
        }
      }
    }
  });

  test('every view has its still and both transition clips', () {
    for (final t in types) {
      for (final v in BuildingView.of(t.type)) {
        for (final asset in [v.image, v.clip, v.reverseClip]) {
          expect(File(asset).existsSync(), isTrue, reason: asset);
        }
      }
    }
  });

  test('every apartment type has a floor plan', () {
    for (final t in types) {
      for (final unit in t.apartmentTypes) {
        expect(File(t.planAsset(unit)).existsSync(), isTrue, reason: t.planAsset(unit));
      }
    }
  });

  test('the masterplan shows every building in the data once', () {
    final ids = [for (final b in masterplanBuildings) b.id];
    expect(ids.toSet(), hasLength(ids.length));
    expect(ids.toSet(), {for (final t in types) ...t.buildingIds});
  });
}

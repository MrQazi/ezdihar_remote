import 'dart:ui';

import 'outline_shape.dart';

/// A building on the masterplan (Figma 648:1892, 1920x1080): its id, the
/// outline traced over it and the box of its id label.
class MasterplanBuilding {
  const MasterplanBuilding(this.id, this.outline, this.label);

  /// Building id, e.g. "A01"; its first letter is the building type.
  final String id;
  final OutlineShape outline;
  final Rect label;

  String get type => id.substring(0, 1);
}

/// Amenity kinds labelled on the masterplan; the names are in `AppStrings`.
enum AmenityKind { greenArea, playArea, padelCourt, waterFountain, sportsCourt }

/// A non-interactive amenity label: kind, number (null when unnumbered), the
/// label's centre, and its width in Figma (English 648:1892, Arabic 648:1344).
class MasterplanAmenity {
  const MasterplanAmenity(this.kind, this.number, this.center, this.widthEn, this.widthAr);

  final AmenityKind kind;
  final int? number;
  final Offset center;
  final double widthEn;
  final double widthAr;
}

/// Size of the masterplan frame everything is placed on.
const masterplanSize = Size(1920, 1080);

/// The 22 buildings along the upper lane, right to left as in Figma.
const masterplanBuildings = [
  MasterplanBuilding('A01', OutlineShape(1853.5, 413, 'M 0 27.5 L 21.5 70 L 54 71.5 L 67 43 L 44.5 0 L 10.5 0 L 0 27.5 Z'), Rect.fromLTWH(1864, 394, 54, 24)),
  MasterplanBuilding('B01', OutlineShape(1774, 406.5, 'M 70 49 L 81 23 L 70 1 L 9.5 0 L 0 26.5 L 7 49 L 70 49 Z'), Rect.fromLTWH(1788, 390, 54, 24)),
  MasterplanBuilding('B02', OutlineShape(1699, 406, 'M 6.5 0 L 67 2 L 76 22 L 67 48 L 9.5 46 L 0 22 L 6.5 0 Z'), Rect.fromLTWH(1709, 389, 56, 24)),
  MasterplanBuilding('A02', OutlineShape(1649.5, 408, 'M 0 28 L 8 0 L 41 1 L 58.5 43.5 L 49 71 L 16 71 L 0 28 Z'), Rect.fromLTWH(1646, 389, 56, 24)),
  MasterplanBuilding('B03', OutlineShape(1570, 403, 'M 6 42.5 L 0 25.5 L 7.5 0 L 68 1 L 76 22 L 68 48 L 6 47 L 6 42.5 Z'), Rect.fromLTWH(1581, 389, 56, 24)),
  MasterplanBuilding('B04', OutlineShape(1495, 401, 'M 6 45 L 0 27.5 L 6 0 L 64 1 L 70.5 24 L 64 46.5 L 6 45 Z'), Rect.fromLTWH(1505, 389, 56, 24)),
  MasterplanBuilding('A03', OutlineShape(1447, 403, 'M 10 69.5 L 0 23 L 5.5 0 L 38 0 L 50.5 43 L 43.5 70.5 L 10 69.5 Z'), Rect.fromLTWH(1439, 389, 56, 24)),
  MasterplanBuilding('B05', OutlineShape(1368, 400, 'M 4 45 L 0 27 L 5 0 L 63.5 0 L 68.5 21 L 64.5 47.5 L 4 45 Z'), Rect.fromLTWH(1371, 389, 56, 24)),
  MasterplanBuilding('C01', OutlineShape(1242.5, 394.5, 'M 79.5 0 L 89 0 L 89 3.5 L 97 3.5 L 100 25 L 97 27 L 101 29 L 97 59 L 50.5 89.5 L 3.5 89.5 L 0 67 L 2.5 47.5 L 9 48.5 L 9 45.5 L 20 46 L 20 42 L 36 42.5 L 36.5 39.5 L 43.5 35 L 50 39.5 L 54 36.5 L 57.5 38.5 L 62.5 10 L 68.5 10 L 69 7 L 78 7 L 78.5 3.5 L 79.5 3.5 L 79.5 0 Z'), Rect.fromLTWH(1282, 403, 54, 24)),
  MasterplanBuilding('C02', OutlineShape(1066.5, 388.5, 'M 0 3.5 L 7 3.5 L 7.5 0 L 16 0 L 16 3 L 18.5 3.5 L 19 7 L 24.5 7.5 L 25 11 L 32.5 11 L 33 20 L 40.5 25 L 39 43 L 48.5 38 L 53.5 40.5 L 59.5 37 L 67 42 L 67 45.5 L 82.5 45 L 83 49.5 L 92.5 49 L 93 52.5 L 99 53 L 98 92 L 52 92 L 34 79.5 L 0 58.5 Z'), Rect.fromLTWH(1053, 392, 56, 24)),
  MasterplanBuilding('B06', OutlineShape(972.5, 387, 'M 0 47.5 L 1.5 0 L 60.5 0.5 L 62.5 49.5 L 0 47.5 Z'), Rect.fromLTWH(973, 377, 56, 24)),
  MasterplanBuilding('A04', OutlineShape(923.5, 389.5, 'M 0 67.5 L 3 0 L 35 1 L 34 68.5 L 0 67.5 Z'), Rect.fromLTWH(913, 377, 56, 24)),
  MasterplanBuilding('B07', OutlineShape(853, 384, 'M 0 51 L 0 5 L 5.5 5 L 6.5 0 L 54 1 L 54 6.5 L 60.5 6.5 L 59.5 51 L 0 51 Z'), Rect.fromLTWH(855, 373, 55, 24)),
  // B08 and A05 share one vector in Figma (Vector 67); one sub-path each.
  MasterplanBuilding('B08', OutlineShape(725, 381, 'M 54 48.5 L 52.5 21.5 L 56.5 0 L 115 2.5 L 116 32.5 L 114 50.5 L 54 48.5 Z'), Rect.fromLTWH(783, 369, 56, 24)),
  MasterplanBuilding('A05', OutlineShape(725, 381, 'M 0 46 L 9 4 L 42 5 L 44 31.5 L 35.5 74.5 L 3 73.5 L 0 46 Z'), Rect.fromLTWH(723, 369, 56, 24)),
  MasterplanBuilding('B09', OutlineShape(657, 380.5, 'M 3 49.5 L 0 26.5 L 1.5 2 L 60.5 0 L 63.5 48.5 L 3 49.5 Z'), Rect.fromLTWH(655, 365, 56, 24)),
  MasterplanBuilding('B10', OutlineShape(579.5, 385, 'M 8 59 L 0 8 L 58.5 0 L 63.5 20.5 L 68 51 L 8 59 Z'), Rect.fromLTWH(582, 373, 54, 24)),
  MasterplanBuilding('B11', OutlineShape(443.5, 413, 'M 10 55 L 0 19.5 L 58 0 L 71.5 18.5 L 76.5 43.5 L 21 64 L 10 55 Z'), Rect.fromLTWH(451, 408, 51, 24)),
  MasterplanBuilding('B12', OutlineShape(322.5, 462, 'M 26 72.5 L 10.5 58.5 L 0 27 L 57 0 L 75.5 17.5 L 82.5 42.5 L 26 72.5 Z'), Rect.fromLTWH(334, 456, 53, 24)),
  MasterplanBuilding('B13', OutlineShape(251, 496, 'M 26.5 73.5 L 8.5 56 L 0 30 L 56.5 0 L 77 18 L 84.5 45.5 L 26.5 73.5 Z'), Rect.fromLTWH(260, 496, 53, 24)),
  MasterplanBuilding('B14', OutlineShape(125.5, 556.5, 'M 26 74.5 L 11 58.5 L 0 30.5 L 62 0 L 81 20 L 91 46.5 L 28.5 77.5 L 26 74.5 Z'), Rect.fromLTWH(137, 557, 54, 24)),
  MasterplanBuilding('B15', OutlineShape(43.5, 594.5, 'M 29.5 80.5 L 13 59.5 L 0 32.5 L 66.5 0 L 85 23 L 94 44.5 L 29.5 80.5 Z'), Rect.fromLTWH(57, 595, 53, 24)),
];

const masterplanAmenities = [
  MasterplanAmenity(AmenityKind.greenArea, 1, Offset(1845.5, 487), 77, 84),
  MasterplanAmenity(AmenityKind.greenArea, 2, Offset(1621, 491), 78, 86),
  MasterplanAmenity(AmenityKind.greenArea, 3, Offset(1431, 492), 78, 88),
  MasterplanAmenity(AmenityKind.greenArea, 4, Offset(1052, 474), 76, 88),
  MasterplanAmenity(AmenityKind.greenArea, 5, Offset(790.5, 467), 75, 85),
  MasterplanAmenity(AmenityKind.greenArea, 6, Offset(581.5, 495), 79, 87),
  MasterplanAmenity(AmenityKind.greenArea, 7, Offset(443.5, 543), 77, 87),
  MasterplanAmenity(AmenityKind.greenArea, 8, Offset(312.5, 603), 73, 86),
  MasterplanAmenity(AmenityKind.greenArea, 9, Offset(148.5, 675), 77, 89),
  // Figma's "Play Area" became the content doc's longer "Children's Playground":
  // 82 wide in English so "Children's" fits on one line (4 and 5 then just touch).
  MasterplanAmenity(AmenityKind.playArea, 1, Offset(1754.5, 487), 82, 78),
  MasterplanAmenity(AmenityKind.playArea, 2, Offset(1530, 491), 82, 80),
  MasterplanAmenity(AmenityKind.playArea, 3, Offset(1337, 492), 82, 82),
  MasterplanAmenity(AmenityKind.playArea, 4, Offset(961, 474), 82, 83),
  MasterplanAmenity(AmenityKind.playArea, 5, Offset(879, 467), 82, 80),
  MasterplanAmenity(AmenityKind.playArea, 6, Offset(366.5, 547), 82, 83),
  MasterplanAmenity(AmenityKind.playArea, 7, Offset(239.5, 646), 82, 83),
  MasterplanAmenity(AmenityKind.padelCourt, 1, Offset(1243, 392), 84, 84),
  MasterplanAmenity(AmenityKind.padelCourt, 2, Offset(1160.5, 392), 81, 81),
  MasterplanAmenity(AmenityKind.padelCourt, 3, Offset(536.5, 366), 79, 79),
  MasterplanAmenity(AmenityKind.waterFountain, null, Offset(1202.5, 499), 89, 89),
  MasterplanAmenity(AmenityKind.sportsCourt, null, Offset(686.5, 483), 123, 123),
];

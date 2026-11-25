import 'building_data.dart';

/// One apartment in the apartment comparison: an apartment type of a building
/// type, on a known floor of a known building when it was added from the
/// apartment details (picked in the comparison, it is any floor that has it).
class ComparedApartment {
  const ComparedApartment({required this.type, required this.unitType, this.floor, this.buildingId});

  final BuildingType type;

  /// Apartment type id, e.g. "2BR".
  final String unitType;

  /// Floor code ("GF", "3F"...), or null for every floor with this type.
  final String? floor;

  /// Building id (e.g. "A03"), or null for every building of [type].
  final String? buildingId;

  /// Area and availability from the data sheet (one per type).
  ApartmentDetails? get details => type.apartments[unitType];

  /// Floor plan image ([BuildingType.planAsset]).
  String get plan => type.planAsset(unitType);

  /// Floors of [type] with this apartment type, bottom to top.
  List<FloorDetails> get floors =>
      [for (final f in type.floorDetails) if (f.apartmentTypes.contains(unitType)) f];

  /// Same building type and apartment type: the same plan and figures, so it
  /// is not added to a comparison twice.
  bool sameKindAs(String buildingType, String unitType) =>
      type.type == buildingType && this.unitType == unitType;

  /// What the main screen is told about this apartment.
  Map<String, Object?> get mirror => {
        'buildingType': type.type,
        'apartmentType': unitType,
        'building': ?buildingId,
        'floor': ?floor,
      };
}

import 'building_data.dart';

/// One apartment in the apartment comparison: an apartment type on a given
/// floor of a given building, either the apartment of the open apartment
/// details or one picked in the comparison (building type, building number,
/// floor, apartment type).
class ComparedApartment {
  const ComparedApartment({
    required this.type,
    required this.unitType,
    required this.floor,
    required this.buildingId,
  });

  final BuildingType type;

  /// Apartment type id, e.g. "2BR".
  final String unitType;

  /// Floor code ("GF", "3F"...).
  final String floor;

  /// Building id, e.g. "A03".
  final String buildingId;

  /// Area and availability from the data sheet (one per apartment type).
  ApartmentDetails? get details => type.apartments[unitType];

  /// Floor plan image ([BuildingType.planAsset]).
  String get plan => type.planAsset(unitType);

  /// The same apartment (building, floor and type): not added twice.
  bool isSame(String buildingId, String floor, String unitType) =>
      this.buildingId == buildingId && this.floor == floor && this.unitType == unitType;

  /// What the main screen is told about this apartment.
  Map<String, Object?> get mirror => {
        'buildingType': type.type,
        'apartmentType': unitType,
        'building': buildingId,
        'floor': floor,
      };
}

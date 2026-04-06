import 'location_model.dart';

/// Returned by GET /api/v1/navigation/menu – locations grouped by floor.
class FloorSummary {
  final int floor;
  final String floorName;
  final List<LocationModel> locations;

  const FloorSummary({
    required this.floor,
    required this.floorName,
    required this.locations,
  });

  factory FloorSummary.fromJson(Map<String, dynamic> json) {
    final rawLocs = (json['locations'] as List<dynamic>? ?? []);
    return FloorSummary(
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      floorName: json['floorName'] as String? ?? 'Floor',
      locations: rawLocs
          .map((l) => LocationModel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Mirrors the Location document returned by the backend.
class LocationModel {
  final String code;
  final String name;
  final int floor;
  final String type;       // room | corridor | elevator | stairwell | entrance
  final String category;   // department | facility | transit | administrative
  final String description;
  final double x;
  final double y;
  final bool isAccessible;
  final int? ivrMenuNumber;

  const LocationModel({
    required this.code,
    required this.name,
    required this.floor,
    required this.type,
    required this.category,
    required this.description,
    required this.x,
    required this.y,
    required this.isAccessible,
    this.ivrMenuNumber,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final coords = json['coordinates'] as Map<String, dynamic>? ?? {};
    return LocationModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? 'room',
      category: json['category'] as String? ?? 'facility',
      description: json['description'] as String? ?? '',
      x: (coords['x'] as num?)?.toDouble() ?? 50,
      y: (coords['y'] as num?)?.toDouble() ?? 50,
      isAccessible: json['isAccessible'] as bool? ?? true,
      ivrMenuNumber: (json['ivrMenuNumber'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'floor': floor,
        'type': type,
        'category': category,
        'description': description,
        'coordinates': {'x': x, 'y': y},
        'isAccessible': isAccessible,
        'ivrMenuNumber': ivrMenuNumber,
      };

  String get floorLabel {
    if (floor == 0) return 'Ground Floor';
    return 'Floor $floor';
  }

  IconData get typeIcon {
    switch (type) {
      case 'elevator':
        return Icons.elevator_outlined;
      case 'stairwell':
        return Icons.stairs_outlined;
      case 'entrance':
        return Icons.door_front_door_outlined;
      case 'corridor':
        return Icons.linear_scale_outlined;
      default:
        return categoryIcon;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'department':
        return Icons.local_hospital_outlined;
      case 'facility':
        return Icons.store_outlined;
      case 'administrative':
        return Icons.business_outlined;
      case 'transit':
        return Icons.swap_horiz_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is LocationModel && other.code == code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'LocationModel($code, $name, floor:$floor)';
}

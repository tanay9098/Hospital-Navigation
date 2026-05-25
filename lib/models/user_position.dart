class UserPosition {
  final double x;
  final double y;
  final int floor;
  final double heading; // in radians
  final bool isSimulated; // if true, coordinate comes from SimulationProvider padding

  UserPosition({
    required this.x,
    required this.y,
    required this.floor,
    required this.heading,
    this.isSimulated = false,
  });

  UserPosition copyWith({
    double? x,
    double? y,
    int? floor,
    double? heading,
    bool? isSimulated,
  }) {
    return UserPosition(
      x: x ?? this.x,
      y: y ?? this.y,
      floor: floor ?? this.floor,
      heading: heading ?? this.heading,
      isSimulated: isSimulated ?? this.isSimulated,
    );
  }
}

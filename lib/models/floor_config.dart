class FloorConfig {
  final int floorIndex;
  final String jsonAsset;
  final String mapAsset;
  final String floorName;
  final String shortName;
  final double baseMapWidth;
  final double baseMapHeight;
  final double mapDrawScale;

  const FloorConfig({
    required this.floorIndex,
    required this.jsonAsset,
    required this.mapAsset,
    required this.floorName,
    required this.shortName,
    required this.baseMapWidth,
    required this.baseMapHeight,
    required this.mapDrawScale,
  });
}

// Central registry for all supported floors.
// To add a new floor, simply add a new FloorConfig entry here.
const Map<int, FloorConfig> kFloorConfigs = {
  0: FloorConfig(
    floorIndex: 0,
    jsonAsset: 'ground_floor.json',
    mapAsset: 'assets/maps/ground_floor.svg',
    floorName: 'Ground Floor',
    shortName: 'GF',
    baseMapWidth: 872.29,
    baseMapHeight: 995.83,
    mapDrawScale: 1.0,
  ),
  1: FloorConfig(
    floorIndex: 1,
    jsonAsset: 'first_floor.json',
    mapAsset: 'assets/maps/first_floor.svg',
    floorName: 'First Floor',
    shortName: 'F1',
    baseMapWidth: 847.09,
    baseMapHeight: 965.26,
    mapDrawScale: 1.0,
  ),
  2: FloorConfig(
    floorIndex: 2,
    jsonAsset: 'second_floor.json',
    mapAsset: 'assets/maps/second_floor.svg',
    floorName: 'Second Floor',
    shortName: 'F2',
    baseMapWidth: 966.47,
    baseMapHeight: 1078.22,
    mapDrawScale: 1.0,
  ),
};

import 'package:flutter/foundation.dart';
import 'package:hospital_nav/models/nav_graph.dart';
import 'package:hospital_nav/models/floor_config.dart';
import 'package:hospital_nav/services/graph_loader_service.dart';

class FloorManager extends ChangeNotifier {
  final GraphLoaderService _loader = GraphLoaderService();
  
  Map<int, NavGraph> _floorGraphs = {};
  int _activeFloor = 0;
  bool _isLoading = true;

  Map<int, NavGraph> get floorGraphs => _floorGraphs;
  int get activeFloor => _activeFloor;
  bool get isLoading => _isLoading;

  Future<void> loadFloors() async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<int, NavGraph> loadedGraphs = {};
      for (var entry in kFloorConfigs.entries) {
        final graph = await _loader.loadGraph(entry.value.jsonAsset);
        loadedGraphs[entry.key] = graph;
      }

      _floorGraphs = loadedGraphs;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void switchFloor(int floor) {
    if (_floorGraphs.containsKey(floor)) {
      _activeFloor = floor;
      notifyListeners();
    }
  }

  NavGraph? get activeGraph => _floorGraphs[_activeFloor];

  String get activeFloorName {
    return kFloorConfigs[_activeFloor]?.floorName ?? 'Floor $_activeFloor';
  }
}

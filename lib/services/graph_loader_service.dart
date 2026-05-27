import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hospital_nav/models/nav_graph.dart';

class GraphLoaderService {
  Future<NavGraph> loadGraph(String jsonAssetName) async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/$jsonAssetName');
      final data = json.decode(response);
      return NavGraph.fromJson(data);
    } catch (e) {
      // Return an empty graph on error / file not found
      debugPrint('Error loading graph $jsonAssetName, providing fallback: $e');
      return NavGraph(nodes: {}, edges: []);
    }
  }
}

import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/models/edge.dart';

class NavGraph {
  final Map<String, Node> nodes;
  final List<Edge> edges;
  final Map<String, List<Edge>> adjacencyList;
  /// Pixels per meter, sourced from JSON metadata. Used for display conversion.
  final double pixelsPerMeter;

  NavGraph({
    required this.nodes,
    required this.edges,
    this.pixelsPerMeter = 34.5,
  }) : adjacencyList = _buildAdjacencyList(nodes, edges);

  static Map<String, List<Edge>> _buildAdjacencyList(
      Map<String, Node> nodes, List<Edge> edges) {
    Map<String, List<Edge>> list = {};
    for (var node in nodes.keys) {
      list[node] = [];
    }

    for (var edge in edges) {
      list[edge.fromNode]?.add(edge);
      if (edge.bidirectional) {
        list[edge.toNode]?.add(Edge(
          fromNode: edge.toNode,
          toNode: edge.fromNode,
          distance: edge.distance,
          type: edge.type,
          bidirectional: edge.bidirectional,
        ));
      }
    }
    return list;
  }

  factory NavGraph.fromJson(Map<String, dynamic> json) {
    Map<String, Node> nodes = {};
    List<Edge> edges = [];

    // Read pixelsPerMeter from metadata block, fall back to 34.5
    final double ppm = (json['metadata']?['pixelsPerMeter'] as num?)?.toDouble() ?? 34.5;
    
    // Auto-repair: Extract true floor ID from the floors array
    int? trueFloorId;
    if (json['floors'] != null && (json['floors'] as List).isNotEmpty) {
      final floorData = json['floors'][0];
      if (floorData['id'] != null) {
        trueFloorId = floorData['id'] as int;
      }
    }

    if (json['nodes'] != null) {
      for (var item in json['nodes']) {
        if (trueFloorId != null) {
           item['floor'] = trueFloorId; // Safely force the correct floor!
        }
        final node = Node.fromJson(item);
        nodes[node.id] = node;
      }
    }

    if (json['edges'] != null) {
        for (var item in json['edges']) {
            // Auto-repair missing prefixes in edge references
            String from = item['fromNode'] ?? item['from'] ?? '';
            String to = item['toNode'] ?? item['to'] ?? '';
            
            if (from.isNotEmpty && !nodes.containsKey(from)) {
                 final match = nodes.keys.firstWhere((k) => k.endsWith('_$from'), orElse: () => from);
                 item['from'] = match;
                 item['fromNode'] = match;
            }
            if (to.isNotEmpty && !nodes.containsKey(to)) {
                 final match = nodes.keys.firstWhere((k) => k.endsWith('_$to'), orElse: () => to);
                 item['to'] = match;
                 item['toNode'] = match;
            }
            
            edges.add(Edge.fromJson(item));
        }
    }

    return NavGraph(nodes: nodes, edges: edges, pixelsPerMeter: ppm);
  }
}

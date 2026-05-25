import 'dart:convert';
import 'dart:io';
import 'package:hospital_nav/models/nav_graph.dart';
import 'package:hospital_nav/models/node.dart';
import 'package:hospital_nav/services/pathfinding_service.dart';

void main() {
  final files = ['ground_floor.json', 'first_floor.json', 'second_floor.json'];
  final graphs = <int, NavGraph>{};
  
  for (int i = 0; i < files.length; i++) {
    try {
        final text = File('assets/data/${files[i]}').readAsStringSync();
        final data = json.decode(text);
        final graph = NavGraph.fromJson(data);
        graphs[i] = graph;
    } catch(e) {}
  }
  
  print("Loaded floors: ${graphs.keys}");
  
  final startNode = graphs[0]?.nodes.values.firstWhere((n) => n.label == 'main_entrance');
  final endNode = graphs[2]?.nodes.values.firstWhere((n) => n.label == 'opthamology_ward_male');
  
  if (startNode == null || endNode == null) {
      print("Nodes not found"); return;
  }
  
  print("Start: \${startNode.id} on floor \${startNode.floor}");
  print("End: \${endNode.id} on floor \${endNode.floor}");
  
  final pf = PathfindingService();
  
  bool isMatchingVertical(String id1, String id2) {
      String cleanStr(String s) => s.replaceAll(RegExp(r'^F\\d+_'), '');
      return cleanStr(id1) == cleanStr(id2);
  }
  
  final startVerticals = graphs[startNode.floor]!.nodes.values.where((n) => n.verticalId != null && n.verticalId!.isNotEmpty).toList();
  final destVerticals = graphs[endNode.floor]!.nodes.values.where((n) => n.verticalId != null && n.verticalId!.isNotEmpty).toList();
  
  print("Start verticals: \${startVerticals.map((e) => e.verticalId)}");
  print("Dest verticals: \${destVerticals.map((e) => e.verticalId)}");
  
  for (var sv in startVerticals) {
      try {
        final dv = destVerticals.firstWhere((v) => isMatchingVertical(v.verticalId!, sv.verticalId!));
        
        final startSeg = pf.findPath(graphs[startNode.floor]!, startNode.id, sv.id);
        final destSeg = pf.findPath(graphs[endNode.floor]!, dv.id, endNode.id);
        
        print("Vertical \${sv.verticalId}: startSeg=\${startSeg?.path.length}, destSeg=\${destSeg?.path.length}");
      } catch (e) {
         print("Failed to match vertical for \${sv.verticalId} - \$e");
      }
  }
}

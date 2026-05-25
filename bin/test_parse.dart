import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/data/hospital_nav_graph.json');
  final jsonString = file.readAsStringSync();
  final data = json.decode(jsonString);
  
  try {
    print('Parsing NavGraph...');
    final ppm = (data['metadata']?['pixelsPerMeter'] as num?)?.toDouble() ?? 34.5;
    
    int floorId = 0;
    String floorName = 'Unknown Floor';
    if (data['floors'] != null && (data['floors'] as List).isNotEmpty) {
      final floorObj = data['floors'][0];
      floorId = floorObj['id'] as int? ?? 0;
      floorName = floorObj['name'] as String? ?? 'Floor $floorId';
    }
    
    print('Floor ID: $floorId, Floor Name: $floorName, PPM: $ppm');
    
    int nodesCount = 0;
    if (data['nodes'] != null) {
      for (var item in data['nodes']) {
        nodesCount++;
        // Mimic Node.fromJson
        final id = item['id'];
        if (id == null) throw Exception("Node missing ID");
      }
    }
    print('Successfully parsed $nodesCount nodes');
  } catch(e, st) {
    print('Error: $e\n$st');
  }
}

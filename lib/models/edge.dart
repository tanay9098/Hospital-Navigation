class Edge {
  final String fromNode;
  final String toNode;
  final double distance;
  final String type; // corridor, lift, stairs, ramp
  final bool bidirectional;

  Edge({
    required this.fromNode,
    required this.toNode,
    required this.distance,
    required this.type,
    this.bidirectional = true,
  });

  factory Edge.fromJson(Map<String, dynamic> json) {
    return Edge(
      fromNode: json['fromNode'] ?? json['from'],
      toNode: json['toNode'] ?? json['to'],
      distance: (json['distance'] as num).toDouble(),
      type: json['type'] ?? 'corridor',
      bidirectional: json['bidirectional'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromNode': fromNode,
      'toNode': toNode,
      'distance': distance,
      'type': type,
      'bidirectional': bidirectional,
    };
  }
}

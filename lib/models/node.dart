class Node {
  final String id;
  final String? label;
  final double x;
  final double y;
  final int floor;
  final String type; // room, junction, lift, stairs, ramp
  final bool accessible;
  final String? verticalId;

  Node({
    required this.id,
    this.label,
    required this.x,
    required this.y,
    required this.floor,
    required this.type,
    required this.accessible,
    this.verticalId,
  });

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'],
      label: json['label'],
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      floor: json['floor'] as int,
      type: json['type'] ?? 'junction',
      accessible: json['accessible'] ?? true,
      verticalId: json['vertical_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (label != null) 'label': label,
      'x': x,
      'y': y,
      'floor': floor,
      'type': type,
      'accessible': accessible,
      if (verticalId != null) 'vertical_id': verticalId,
    };
  }
}

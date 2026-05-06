class Floor {
  final int id;
  final String name;
  final String label;

  Floor({
    required this.id,
    required this.name,
    required this.label,
  });

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'] as int,
      name: json['name'] as String,
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'label': label,
    };
  }
}

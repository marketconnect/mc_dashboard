class Charc {
  final int id;
  final String subjectName;
  final String name;
  final String dataType;
  final String unit;

  Charc({
    required this.id,
    required this.subjectName,
    required this.name,
    required this.dataType,
    required this.unit,
  });

  factory Charc.fromJson(Map<String, dynamic> json) {
    return Charc(
      id: (json['charcID'] ?? 0) as int,
      subjectName: json['subjectName'] as String? ?? '',
      name: json['name'] as String? ?? '',
      dataType:
          (json['charcType'] ?? '').toString(), // charcType приводим к строке
      unit: json['unitName'] as String? ?? '',
    );
  }
}

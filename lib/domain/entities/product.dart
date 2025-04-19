class ProductData {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final double width;
  final double height;
  final double length;
  final double weightKg;
  final String country;

  ProductData({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.width,
    required this.height,
    required this.length,
    required this.weightKg,
    required this.country,
  });

  factory ProductData.fromCsv(List<String> row) {
    return ProductData(
      id: row[0],
      title: row[1],
      description: row[2],
      images: row[3].split(';').map((e) => e.trim()).toList(),
      width: double.tryParse(row[4]) ?? 0,
      height: double.tryParse(row[5]) ?? 0,
      length: double.tryParse(row[6]) ?? 0,
      weightKg: double.tryParse(row[7]) ?? 0,
      country: row[8],
    );
  }
}

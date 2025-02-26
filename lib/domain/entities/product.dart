class Product {
  final String zipFileName;
  final String url;
  final String title;
  final String description;
  final Map<String, String> properties;

  Product({
    required this.zipFileName,
    required this.url,
    required this.title,
    required this.description,
    required this.properties,
  });

  factory Product.fromJson(String zipFileName, Map<String, dynamic> json) {
    return Product(
      zipFileName: zipFileName,
      url: json['url'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      properties: (json['properties'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value.toString())),
    );
  }
}

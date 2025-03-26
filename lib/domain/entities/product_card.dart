import 'package:mc_dashboard/domain/entities/size.dart';

class ProductCard {
  final int nmID;
  final int imtID;
  final int subjectID;
  final String title;
  final String subjectName;
  final String vendorCode;
  final String photoUrl;
  final int length;
  final int width;
  final int height;
  final bool isValidDimensions;
  final List<WbProductSize> sizes;

  ProductCard({
    required this.nmID,
    required this.imtID,
    required this.subjectID,
    required this.title,
    required this.subjectName,
    required this.vendorCode,
    required this.photoUrl,
    required this.length,
    required this.width,
    required this.height,
    required this.isValidDimensions,
    required this.sizes,
  });

  factory ProductCard.fromJson(Map<String, dynamic> json) {
    final dimensions = json['dimensions'] ?? {};
    final photos = json['photos'] as List<dynamic>? ?? [];
    String photoUrl = '';

    if (photos.isNotEmpty) {
      photoUrl = photos.first['big'] ?? '';
    }

    final sizesList = (json['sizes'] as List<dynamic>?)
            ?.map((sizeJson) => WbProductSize.fromJson(sizeJson))
            .toList() ??
        [];

    return ProductCard(
      nmID: json['nmID'] as int? ?? 0,
      imtID: json['imtID'] as int? ?? 0,
      subjectID: json['subjectID'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      vendorCode: json['vendorCode'] as String? ?? '',
      photoUrl: photoUrl,
      length: dimensions['length'] as int? ?? 0,
      width: dimensions['width'] as int? ?? 0,
      height: dimensions['height'] as int? ?? 0,
      isValidDimensions: dimensions['isValid'] as bool? ?? false,
      sizes: sizesList,
    );
  }
}

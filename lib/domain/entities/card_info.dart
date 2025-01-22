class CardInfo {
  final String imtName;
  final int imtId;
  final int supplierId;
  final int photoCount;
  final int subjId;
  final String subjName;

  final String brand;
  final String description;
  final String characteristicValues;
  final String characteristicFull;

  CardInfo({
    required this.imtName,
    required this.imtId,
    required this.supplierId,
    required this.photoCount,
    required this.subjId,
    required this.subjName,
    required this.brand,
    required this.description,
    required this.characteristicValues,
    required this.characteristicFull,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    final media = json['media'];

    final optionsText = (json['options'] as List<dynamic>?)
            ?.map((option) => option['value'] as String)
            .join('; ') ??
        '';

    final compositionsText = (json['compositions'] as List<dynamic>?)
            ?.map((composition) => composition['name'] as String)
            .join('; ') ??
        '';

    final groupedOptionsText = (json['grouped_options'] as List<dynamic>?)
            ?.expand((group) =>
                (group['options'] as List<dynamic>?)
                    ?.map((option) => option['value'] as String) ??
                [])
            .join('; ') ??
        '';

    final characteristics = [optionsText, compositionsText, groupedOptionsText]
        .where((text) => text.isNotEmpty)
        .join('; ');

    final Map<String, String> uniqueCharacteristics = {};

    (json['options'] as List<dynamic>?)?.forEach((option) {
      final name = option['name'] as String? ?? '';
      final value = option['value'] as String? ?? '';
      if (name.isNotEmpty && value.isNotEmpty) {
        uniqueCharacteristics[name] = value;
      }
    });

    (json['grouped_options'] as List<dynamic>?)?.forEach((group) {
      (group['options'] as List<dynamic>?)?.forEach((option) {
        final name = option['name'] as String? ?? '';
        final value = option['value'] as String? ?? '';
        if (name.isNotEmpty && value.isNotEmpty) {
          uniqueCharacteristics[name] = value;
        }
      });
    });

    final characteristicFull = uniqueCharacteristics.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('; ');

    String brand = "";
    if (json['selling'] != null) {
      brand = json['selling']['brand_name'];
    }

    return CardInfo(
      imtName: json['imt_name'],
      imtId: json['imt_id'],
      supplierId: json['selling']['supplier_id'],
      subjName: json['subj_name'],
      subjId: json['data']['subject_id'],
      brand: brand,
      description: json['description'],
      photoCount: media['photo_count'],
      characteristicValues: characteristics,
      characteristicFull: characteristicFull,
    );
  }
}

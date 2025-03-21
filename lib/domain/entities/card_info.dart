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

  final String packageLength;
  final String packageHeight;
  final String packageWidth;

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
    required this.packageLength,
    required this.packageHeight,
    required this.packageWidth,
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

    // Извлекаем параметры "Длина упаковки", "Высота упаковки", "Ширина упаковки"
    String packageLength = "";
    String packageHeight = "";
    String packageWidth = "";

    (json['grouped_options'] as List<dynamic>?)?.forEach((group) {
      if (group['group_name'] == "Габариты") {
        for (var option in (group['options'] as List<dynamic>? ?? [])) {
          if (option['name'] == "Длина упаковки") {
            packageLength = option['value'] ?? "";
          } else if (option['name'] == "Высота упаковки") {
            packageHeight = option['value'] ?? "";
          } else if (option['name'] == "Ширина упаковки") {
            packageWidth = option['value'] ?? "";
          }
        }
      }
    });

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
      packageLength: packageLength,
      packageHeight: packageHeight,
      packageWidth: packageWidth,
    );
  }

  double calculateVolumeInLiters() {
    print("packageLength: $packageLength");
    print("packageHeight: $packageHeight");
    print("packageWidth: $packageWidth");
    try {
      final length =
          double.parse(packageLength.replaceAll(RegExp(r'[^0-9.]'), ''));
      final height =
          double.parse(packageHeight.replaceAll(RegExp(r'[^0-9.]'), ''));
      final width =
          double.parse(packageWidth.replaceAll(RegExp(r'[^0-9.]'), ''));

      return (length * height * width) / 1000;
    } catch (e) {
      return 0.0;
    }
  }
}

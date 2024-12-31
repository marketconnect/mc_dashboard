class CardInfo {
  final String imtName;
  final int imtId;
  final int photoCount;
  final String subjName;
  final String description;
  final String characteristics;

  CardInfo({
    required this.imtName,
    required this.imtId,
    required this.photoCount,
    required this.subjName,
    required this.description,
    required this.characteristics,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    final media = json['media'];

    // Сбор текстовых данных из options
    final optionsText = (json['options'] as List<dynamic>?)
            ?.map((option) => option['value'] as String)
            .join('; ') ??
        '';

    // Сбор текстовых данных из compositions
    final compositionsText = (json['compositions'] as List<dynamic>?)
            ?.map((composition) => composition['name'] as String)
            .join('; ') ??
        '';

    // Сбор текстовых данных из grouped_options
    final groupedOptionsText = (json['grouped_options'] as List<dynamic>?)
            ?.expand((group) =>
                (group['options'] as List<dynamic>?)
                    ?.map((option) => option['value'] as String) ??
                [])
            .join('; ') ??
        '';

    // Объединение всех характеристик
    final characteristics = [optionsText, compositionsText, groupedOptionsText]
        .where((text) => text.isNotEmpty)
        .join('; ');

    return CardInfo(
      imtName: json['imt_name'],
      imtId: json['imt_id'],
      subjName: json['subj_name'],
      description: json['description'],
      photoCount: media['photo_count'],
      characteristics: characteristics,
    );
  }
}

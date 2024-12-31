class KwLemmaItem {
  final int kwId;
  final List<String> lemmas;

  KwLemmaItem({
    required this.kwId,
    required this.lemmas,
  });

  factory KwLemmaItem.fromJson(Map<String, dynamic> json) {
    return KwLemmaItem(
      kwId: json['kw_id'] as int,
      lemmas:
          (json['lemmas'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kw_id': kwId,
      'lemmas': lemmas,
    };
  }

  KwLemmaItem copyWith({
    int? kwId,
    List<String>? lemmas,
  }) {
    return KwLemmaItem(
      kwId: kwId ?? this.kwId,
      lemmas: lemmas ?? this.lemmas,
    );
  }
}

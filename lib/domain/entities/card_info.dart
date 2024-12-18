class CardInfo {
  final String imtName;
  final int imtId;
  final int photoCount;
  final String subjName;

  CardInfo({
    required this.imtName,
    required this.imtId,
    required this.photoCount,
    required this.subjName,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    final media = json['media'];
    return CardInfo(
        imtName: json['imt_name'],
        imtId: json['imt_id'],
        subjName: json['subj_name'],
        photoCount: media['photo_count']);
  }
}

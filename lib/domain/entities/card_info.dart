class CardInfo {
  final String imtName;
  final int imtId;
  final int photoCount;

  CardInfo(
      {required this.imtName, required this.imtId, required this.photoCount});

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    final media = json['media'];
    return CardInfo(
        imtName: json['imt_name'],
        imtId: json['imt_id'],
        photoCount: media['photo_count']);
  }
}

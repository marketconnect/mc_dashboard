class WbTariff {
  final double kgvpMarketplace;
  final double kgvpSupplier;
  final double kgvpSupplierExpress;
  final double paidStorageKgvp;
  final int parentID;
  final String parentName;
  final int subjectID;
  final String subjectName;

  WbTariff({
    required this.kgvpMarketplace,
    required this.kgvpSupplier,
    required this.kgvpSupplierExpress,
    required this.paidStorageKgvp,
    required this.parentID,
    required this.parentName,
    required this.subjectID,
    required this.subjectName,
  });

  factory WbTariff.fromJson(Map<String, dynamic> json) {
    return WbTariff(
      kgvpMarketplace: (json['kgvpMarketplace'] as num).toDouble(),
      kgvpSupplier: (json['kgvpSupplier'] as num).toDouble(),
      kgvpSupplierExpress: (json['kgvpSupplierExpress'] as num).toDouble(),
      paidStorageKgvp: (json['paidStorageKgvp'] as num).toDouble(),
      parentID: json['parentID'] as int,
      parentName: json['parentName'] as String,
      subjectID: json['subjectID'] as int,
      subjectName: json['subjectName'] as String,
    );
  }
}

import 'dart:math';

class Normquery {
  final int normqueryId;
  final String normquery;
  final String kw;
  final int total;
  final int freq;

  Normquery({
    required this.normqueryId,
    required this.normquery,
    required this.kw,
    required this.total,
    required this.freq,
  });

  factory Normquery.fromJson(Map<String, dynamic> json) {
    return Normquery(
      normqueryId: json['normquery_id'] as int,
      normquery: json['normquery'] as String,
      kw: json['kw'] as String,
      total: json['total'] as int,
      freq: json['freq'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'normquery_id': normqueryId,
      'normquery': normquery,
      'kw': kw,
      'total': total,
      'freq': freq,
    };
  }
}

List<Normquery> generateRandomNormqueries(int count) {
  final random = Random();
  final List<Normquery> products = [];

  for (int i = 0; i < count; i++) {
    final normqueryId = random.nextInt(10000);
    final kw = 'KW $normqueryId';
    final normquery = 'Query $normqueryId';
    final freq = random.nextInt(1000) + 1;
    final total = random.nextInt(10000) + 1;

    products.add(Normquery(
      normqueryId: normqueryId,
      normquery: normquery,
      kw: kw,
      total: total,
      freq: freq,
    ));
  }

  return products;
}

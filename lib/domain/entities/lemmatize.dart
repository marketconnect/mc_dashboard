class LemmatizeRequest {
  final String title;
  final String characteristics;
  final String description;

  LemmatizeRequest({
    required this.title,
    required this.characteristics,
    required this.description,
  });

  factory LemmatizeRequest.fromJson(Map<String, dynamic> json) {
    return LemmatizeRequest(
      title: json['title'] as String,
      characteristics: json['characteristics'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'characteristics': characteristics,
      'description': description,
    };
  }

  @override
  String toString() => toJson().toString();
}

class LemmatizeResponse {
  final String title;
  final String characteristics;
  final String description;

  LemmatizeResponse({
    required this.title,
    required this.characteristics,
    required this.description,
  });

  factory LemmatizeResponse.fromJson(Map<String, dynamic> json) {
    return LemmatizeResponse(
      title: json['title'] as String,
      characteristics: json['characteristics'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'characteristics': characteristics,
      'description': description,
    };
  }
}

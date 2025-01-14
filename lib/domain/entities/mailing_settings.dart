import 'package:hive/hive.dart';

part 'mailing_settings.g.dart';

@HiveType(typeId: 3)
class DynamicMailingSettings {
  @HiveField(0)
  final Map<String, dynamic> settings;

  DynamicMailingSettings({required this.settings});

  factory DynamicMailingSettings.fromJson(Map<String, dynamic> json) {
    return DynamicMailingSettings(settings: json);
  }

  Map<String, dynamic> toJson() => settings;

  DynamicMailingSettings copyWith(Map<String, dynamic> updates) {
    return DynamicMailingSettings(settings: {...settings, ...updates});
  }
}

class Setting {
  final String key;
  final String value;

  Setting({
    required this.key,
    required this.value,
  });

  factory Setting.fromJson(Map<String, dynamic> json) => Setting(
        key: json['key'] as String,
        value: json['value'] as String,
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}

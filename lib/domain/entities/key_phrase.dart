import 'package:hive/hive.dart';

part 'key_phrase.g.dart';

@HiveType(typeId: 1)
class KeyPhrase {
  @HiveField(0)
  final String phraseText;

  @HiveField(1)
  final String marketPlace;

  KeyPhrase({
    required this.phraseText,
    required this.marketPlace,
  });
}

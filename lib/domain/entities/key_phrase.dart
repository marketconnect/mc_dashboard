import 'package:hive/hive.dart';

part 'key_phrase.g.dart';

@HiveType(typeId: 1)
class KeyPhrase {
  @HiveField(0)
  final String phraseText;

  KeyPhrase({
    required this.phraseText,
  });
}

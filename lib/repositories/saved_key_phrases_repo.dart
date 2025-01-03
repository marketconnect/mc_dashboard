import 'package:hive/hive.dart';
import 'package:mc_dashboard/domain/entities/key_phrase.dart';
import 'package:mc_dashboard/domain/services/saved_key_phrases_service.dart';

class SavedKeyPhrasesRepo implements SavedKeyPhrasesRepository {
  @override
  Future<void> saveKeyPhrase(KeyPhrase keyPhrase) async {
    final box = await Hive.openBox<KeyPhrase>('keyPhrases');

    if (!box.containsKey(keyPhrase.phraseText)) {
      await box.put(keyPhrase.phraseText, keyPhrase);
    }
  }

  @override
  Future<void> deleteKeyPhrase(String phraseText) async {
    final box = await Hive.openBox<KeyPhrase>('keyPhrases');

    if (box.containsKey(phraseText)) {
      await box.delete(phraseText);
    }
  }

  @override
  Future<List<KeyPhrase>> getAllKeyPhrases() async {
    final box = await Hive.openBox<KeyPhrase>('keyPhrases');
    return box.values.toList();
  }
}

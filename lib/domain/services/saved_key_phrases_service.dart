import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/domain/entities/key_phrase.dart';

import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:mc_dashboard/presentation/mailing_screen/saved_key_phrases_view_model.dart';

abstract class SavedKeyPhrasesRepository {
  Future<void> saveKeyPhrase(KeyPhrase keyPhrase);
  Future<void> deleteKeyPhrase(String phraseText);
  Future<List<KeyPhrase>> getAllKeyPhrases();
}

class SavedKeyPhrasesService
    implements
        ProductViewModelSavedKeyPhrasesService,
        SavedKeyPhrasesKeyPhrasesService {
  SavedKeyPhrasesService({
    required this.savedKeyPhrasesRepo,
  });

  final SavedKeyPhrasesRepository savedKeyPhrasesRepo;

  @override
  Future<Either<AppErrorBase, void>> saveKeyPhrases(
    List<KeyPhrase> keyPhrases,
  ) async {
    try {
      // TODO: send to server

      for (var keyPhrase in keyPhrases) {
        await savedKeyPhrasesRepo.saveKeyPhrase(keyPhrase);
      }
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'saveKeyPhrases',
        sendTo: true,
        source: 'SavedKeyPhrasesService',
      ));
    }
    return right(null);
  }

  @override
  Future<Either<AppErrorBase, List<KeyPhrase>>> loadKeyPhrases() async {
    // TODO: send to server

    try {
      final keyPhrases = await savedKeyPhrasesRepo.getAllKeyPhrases();

      return right(keyPhrases);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'loadKeyPhrases',
        sendTo: true,
        source: 'SavedKeyPhrasesService',
      ));
    }
  }

  @override
  Future<Either<AppErrorBase, void>> deleteKeyPhrase(
    String phraseText,
  ) async {
    try {
      // TODO: send to server

      await savedKeyPhrasesRepo.deleteKeyPhrase(phraseText);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'deleteKeyPhrase',
        sendTo: true,
        source: 'SavedKeyPhrasesService',
      ));
    }
    return right(null);
  }
}

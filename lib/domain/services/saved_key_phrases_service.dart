import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/domain/entities/key_phrase.dart';
import 'package:mc_dashboard/domain/services/saved_products_service.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:mc_dashboard/presentation/saved_key_phrases_screen/saved_key_phrases_view_model.dart';

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
  Future<Either<AppError, void>> saveKeyPhrases(
      List<KeyPhrase> keyPhrases) async {
    try {
      for (var keyPhrase in keyPhrases) {
        await savedKeyPhrasesRepo.saveKeyPhrase(keyPhrase);
      }
    } catch (e) {
      return left(AppError());
    }
    return right(null);
  }

  @override
  Future<Either<AppError, List<KeyPhrase>>> loadKeyPhrases() async {
    try {
      final keyPhrases = await savedKeyPhrasesRepo.getAllKeyPhrases();

      return right(keyPhrases);
    } catch (e) {
      return left(AppError());
    }
  }

  @override
  Future<Either<AppError, void>> deleteKeyPhrase(String phraseText) async {
    try {
      await savedKeyPhrasesRepo.deleteKeyPhrase(phraseText);
    } catch (e) {
      return left(AppError());
    }
    return right(null);
  }
}

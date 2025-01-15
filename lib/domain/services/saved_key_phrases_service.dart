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

abstract class SavedKeyPhrasesApiClient {
  Future<List<KeyPhrase>> findUserSearchQueries({
    required String token,
  });
  Future<void> deleteUserSearchQueries({
    required String token,
    required List<KeyPhrase> phrases,
  });
  Future<void> saveUserSearchQueries({
    required String token,
    required List<KeyPhrase> phrases,
  });
}

class SavedKeyPhrasesService
    implements
        ProductViewModelSavedKeyPhrasesService,
        SavedKeyPhrasesKeyPhrasesService {
  SavedKeyPhrasesService({
    required this.savedKeyPhrasesRepo,
    required this.savedKeyPhrasesApiClient,
  });

  final SavedKeyPhrasesRepository savedKeyPhrasesRepo;
  final SavedKeyPhrasesApiClient savedKeyPhrasesApiClient;

  /// Синхронизация ключевых фраз между сервером и локальным хранилищем
  @override
  Future<Either<AppErrorBase, void>> syncKeyPhrases({
    required String token,
    required List<KeyPhrase> newPhrases,
  }) async {
    try {
      final currentPhrases = await savedKeyPhrasesRepo.getAllKeyPhrases();

      // Фразы для добавления или обновления
      final addedOrUpdatedPhrases = newPhrases
          .where((phrase) =>
              !currentPhrases.any((p) => p.phraseText == phrase.phraseText))
          .toList();

      // Фразы для удаления
      final removedPhrases = currentPhrases
          .where((phrase) =>
              !newPhrases.any((p) => p.phraseText == phrase.phraseText))
          .toList();

      if (addedOrUpdatedPhrases.isNotEmpty) {
        final saveResult = await _saveKeyPhrases(
          token: token,
          phrases: addedOrUpdatedPhrases,
        );
        if (saveResult.isLeft()) {
          return saveResult;
        }
      }

      if (removedPhrases.isNotEmpty) {
        final deleteResult = await deleteKeyPhrases(
          token: token,
          phrases: removedPhrases,
        );
        if (deleteResult.isLeft()) {
          return deleteResult;
        }
      }
      return right(null);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'syncKeyPhrases',
        sendTo: true,
        source: 'SavedKeyPhrasesService',
      ));
    }
  }

  /// Сохранение новых ключевых фраз на сервере и локально
  Future<Either<AppErrorBase, void>> _saveKeyPhrases({
    required String token,
    required List<KeyPhrase> phrases,
  }) async {
    try {
      await savedKeyPhrasesApiClient.saveUserSearchQueries(
        token: token,
        phrases: phrases,
      );
      for (final phrase in phrases) {
        await savedKeyPhrasesRepo.saveKeyPhrase(phrase);
      }
      return right(null);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: '_saveKeyPhrases',
        sendTo: true,
        source: 'SavedKeyPhrasesService',
      ));
    }
  }

  @override
  Future<Either<AppErrorBase, void>> deleteKeyPhrases({
    required String token,
    required List<KeyPhrase> phrases,
  }) async {
    try {
      // Server
      await savedKeyPhrasesApiClient.deleteUserSearchQueries(
        token: token,
        phrases: phrases,
      );

      // Local
      for (final phrase in phrases) {
        await savedKeyPhrasesRepo.deleteKeyPhrase(phrase.phraseText);
      }
      return right(null);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: '_deleteKeyPhrases',
        sendTo: true,
        source: 'SavedKeyPhrasesService',
      ));
    }
  }

  @override
  Future<Either<AppErrorBase, List<KeyPhrase>>> getKeyPhrases({
    required String token,
  }) async {
    try {
      // Server
      final serverPhrases =
          await savedKeyPhrasesApiClient.findUserSearchQueries(
        token: token,
      );

      // Local
      final localPhrases = await savedKeyPhrasesRepo.getAllKeyPhrases();
      bool localStorageUpdated = false;

      // Add or update
      for (final phrase in serverPhrases) {
        if (!localPhrases.any((p) => p.phraseText == phrase.phraseText)) {
          await savedKeyPhrasesRepo.saveKeyPhrase(phrase);
          localStorageUpdated = true;
        }
      }

      // Delete
      for (final phrase in localPhrases) {
        if (!serverPhrases.any((p) => p.phraseText == phrase.phraseText)) {
          await savedKeyPhrasesRepo.deleteKeyPhrase(phrase.phraseText);
          localStorageUpdated = true;
        }
      }

      // Update
      final updatedPhrases = localStorageUpdated
          ? await savedKeyPhrasesRepo.getAllKeyPhrases()
          : localPhrases;

      return right(updatedPhrases);
    } catch (e) {
      return left(AppErrorBase(
        'Caught error: $e',
        name: 'getKeyPhrases',
        sendTo: true,
        source: 'SavedKeyPhrasesService',
      ));
    }
  }
}

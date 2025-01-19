import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/key_phrase.dart';
import 'package:mc_dashboard/domain/entities/token_info.dart';

abstract class SavedKeyPhrasesKeyPhrasesService {
  Future<Either<AppErrorBase, List<KeyPhrase>>> getKeyPhrases({
    required String token,
  });
  Future<Either<AppErrorBase, void>> deleteKeyPhrases({
    required String token,
    required List<KeyPhrase> phrases,
  });
}

// auth service
abstract class SavedKeyPhrasesAuthService {
  // User? getFirebaseAuthUserInfo();
  Future<Either<AppErrorBase, TokenInfo>> getTokenInfo();

  // logout();
}

class SavedKeyPhrasesViewModel extends ViewModelBase {
  SavedKeyPhrasesViewModel({
    required super.context,
    required this.keyPhrasesService,
    required this.authService,
  });
  final SavedKeyPhrasesKeyPhrasesService keyPhrasesService;
  final SavedKeyPhrasesAuthService authService;

  List<KeyPhrase> _keyPhrases = [];
  List<KeyPhrase> get keyPhrases => _keyPhrases;

  final double tableRowHeight = 60.0;
  TokenInfo? tokenInfo;
  // methods ///////////////////////////////////////////////////////////////////
  @override
  Future<void> asyncInit() async {
    //Token
    final tokenInfoOrEither = await authService.getTokenInfo();
    if (tokenInfoOrEither.isLeft()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Не удалось получить токен"),
          ),
        );
      }

      return;
    }

    tokenInfo =
        tokenInfoOrEither.fold((l) => throw UnimplementedError(), (r) => r);
    if (tokenInfo == null || tokenInfo!.type == "free") {
      return;
    }

    final phrasesOrEither =
        await keyPhrasesService.getKeyPhrases(token: tokenInfo!.token);

    if (phrasesOrEither.isRight()) {
      _keyPhrases =
          phrasesOrEither.fold((l) => throw UnimplementedError(), (r) => r);
    }
  }

  Future<void> deleteKeyPhrases(List<String> phrases, bool isSubscribed) async {
    if (!isSubscribed) {
      return;
    }
    if (tokenInfo == null || tokenInfo!.type == "free") {
      return;
    }
    for (var phraseText in phrases) {
      final resultOrEither = await keyPhrasesService
          .deleteKeyPhrases(token: tokenInfo!.token, phrases: [
        KeyPhrase(phraseText: phraseText, marketPlace: "wb"),
      ]);
      if (resultOrEither.isRight()) {
        _keyPhrases.removeWhere((phrase) => phrase.phraseText == phraseText);
      }
    }
    notifyListeners();
  }
}

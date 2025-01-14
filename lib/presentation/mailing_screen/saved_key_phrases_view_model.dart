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
  String? token;
  // methods ///////////////////////////////////////////////////////////////////
  @override
  Future<void> asyncInit() async {
    //Token
    final tokenOrEither = await authService.getTokenInfo();
    if (tokenOrEither.isLeft()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Не удалось получить токен"),
          ),
        );
      }

      return;
    }

    token =
        tokenOrEither.fold((l) => throw UnimplementedError(), (r) => r.token);
    if (token == null) {
      return;
    }

    final phrasesOrEither =
        await keyPhrasesService.getKeyPhrases(token: token!);

    if (phrasesOrEither.isRight()) {
      _keyPhrases =
          phrasesOrEither.fold((l) => throw UnimplementedError(), (r) => r);
    }
  }

  Future<void> deleteKeyPhrases(List<String> phrases, bool isSubscribed) async {
    if (!isSubscribed) {
      return;
    }
    for (var phraseText in phrases) {
      final resultOrEither =
          await keyPhrasesService.deleteKeyPhrases(token: token!, phrases: [
        KeyPhrase(phraseText: phraseText, marketPlace: "wb"),
      ]);
      if (resultOrEither.isRight()) {
        _keyPhrases.removeWhere((phrase) => phrase.phraseText == phraseText);
      }
    }
    notifyListeners();
  }
}

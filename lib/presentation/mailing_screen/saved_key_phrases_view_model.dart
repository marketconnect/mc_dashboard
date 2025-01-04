import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/app_error_base_class.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/key_phrase.dart';

abstract class SavedKeyPhrasesKeyPhrasesService {
  Future<Either<AppErrorBase, List<KeyPhrase>>> loadKeyPhrases();
  Future<Either<AppErrorBase, void>> deleteKeyPhrase(String phraseText);
}

class SavedKeyPhrasesViewModel extends ViewModelBase {
  SavedKeyPhrasesViewModel({
    required super.context,
    required this.keyPhrasesService,
  });
  final SavedKeyPhrasesKeyPhrasesService keyPhrasesService;

  List<KeyPhrase> _keyPhrases = [];
  List<KeyPhrase> get keyPhrases => _keyPhrases;

  final double tableRowHeight = 60.0;

  // methods ///////////////////////////////////////////////////////////////////
  @override
  Future<void> asyncInit() async {
    final phrasesOrEither = await keyPhrasesService.loadKeyPhrases();

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
          await keyPhrasesService.deleteKeyPhrase(phraseText);
      if (resultOrEither.isRight()) {
        _keyPhrases.removeWhere((phrase) => phrase.phraseText == phraseText);
      }
    }
    notifyListeners();
  }
}

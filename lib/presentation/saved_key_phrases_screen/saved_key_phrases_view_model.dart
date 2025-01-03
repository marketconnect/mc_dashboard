import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mc_dashboard/core/base_classes/view_model_base_class.dart';
import 'package:mc_dashboard/domain/entities/key_phrase.dart';
import 'package:mc_dashboard/domain/services/saved_products_service.dart';

abstract class SavedKeyPhrasesKeyPhrasesService {
  Future<Either<AppError, List<KeyPhrase>>> loadKeyPhrases();
  Future<Either<AppError, void>> deleteKeyPhrase(String phraseText);
}

class SavedKeyPhrasesViewModel extends ViewModelBase {
  SavedKeyPhrasesViewModel({
    required super.context,
    required this.keyPhrasesService,
  }) {
    _asyncInit();
  }

  final SavedKeyPhrasesKeyPhrasesService keyPhrasesService;

  List<KeyPhrase> _keyPhrases = [];
  List<KeyPhrase> get keyPhrases => _keyPhrases;

  final double tableRowHeight = 60.0;

  Future<void> _asyncInit() async {
    setLoading();
    final phrasesOrError = await keyPhrasesService.loadKeyPhrases();
    phrasesOrError.fold(
      // Ошибка
      (error) {
        // Обработайте ошибку по-своему
        debugPrint('Ошибка при загрузке: $error');
      },
      // Успешная загрузка
      (phrases) {
        _keyPhrases = phrases;
      },
    );
    setLoaded();
  }
}

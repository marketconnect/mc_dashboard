import 'package:flutter/material.dart';

abstract class ScreenFactory {
  Widget makeChoosingNicheScreen(
      {required void Function(int subjectId, String subjectName)
          onNavigateToSubjectProducts});

  Widget makeSubjectProductsScreen(
      {required int subjectId,
      required String subjectName,
      required void Function(int productId, int productPrice)
          onNavigateToProductScreen,
      required void Function() onNavigateToEmptySubject,
      required void Function(List<int>) onNavigateToSeoRequestsExtendScreen,
      required void Function(List<int> productIds) onSaveProductsToTrack,
      required void Function() onNavigateBack});
  Widget makeEmptySubjectProductsScreen(
      {required void Function(int subjectId, String subjectName)
          onNavigateToSubjectProducts,
      required void Function() onNavigateBack});

  Widget makeEmptyProductScreen(
      {required void Function(int productId, int? productPrice)
          onNavigateToProductScreen,
      required void Function() onNavigateBack});
  Widget makeProductScreen(
      {required int productId,
      required int productPrice,
      required void Function() onNavigateToEmptyProductScreen,
      required void Function(List<String> keyPhrases) onSaveKeyPhrasesToTrack,
      required void Function() onNavigateBack});

  Widget makeSeoRequestsExtendScreen({
    required List<int> productIds,
    required void Function() onNavigateBack,
  });

  Widget makeMailingScreen();

  Widget makeLoginScreen();
}

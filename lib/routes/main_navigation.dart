import 'package:flutter/material.dart';

abstract class ScreenFactory {
  Widget makeChoosingNicheScreen(
      {required void Function(int subjectId, String subjectName)
          onNavigateToSubjectProducts});

  Widget makeSubjectProductsScreen({
    required int subjectId,
    required String subjectName,
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
    required void Function(List<String> productIds) onSaveProductsToTrack,
  });
  Widget makeEmptySubjectProductsScreen({
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
  });

  Widget makeEmptyProductScreen({
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
  });
  Widget makeProductScreen({
    required int productId,
    required int productPrice,
    required String prevScreen,
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
    required void Function(List<String> keyPhrases) onSaveKeyPhrasesToTrack,
  });

  Widget makeSeoRequestsExtendScreen({
    required List<int> productIds,
    required List<String> charactiristics,
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
  });

  Widget makeMailingScreen({
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
  });

  Widget makeSubscriptionScreen();

  Widget makeLoginScreen();

  Widget makeApiKeysScreen();

  Widget makePromotionsScreen();
}

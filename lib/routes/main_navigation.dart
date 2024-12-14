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
      required void Function() onNavigateToEmptySubject});
  Widget makeEmptySubjectProductsScreen(
      {required void Function(int subjectId, String subjectName)
          onNavigateToSubjectProducts});
  Widget makeProductScreen({required int productId, required int productPrice});
}

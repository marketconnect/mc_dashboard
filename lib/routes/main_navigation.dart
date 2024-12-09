import 'package:flutter/material.dart';

abstract class ScreenFactory {
  Widget makeChoosingNicheScreen(
      {required void Function(int subjectId, String subjectName)
          onNavigateToSubjectProducts});

  Widget makeSubjectProductsScreen(int subjectId, String subjectName);
}

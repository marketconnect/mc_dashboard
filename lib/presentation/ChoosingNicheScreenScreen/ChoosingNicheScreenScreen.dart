import 'package:flutter/material.dart';
import 'package:mc_dashboard/presentation/ChoosingNicheScreenScreen/ChoosingNicheViewModel.dart';
import 'package:provider/provider.dart';

class ChoosingNicheScreenScreen extends StatelessWidget {
  const ChoosingNicheScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ChoosingNicheViewModel>();
    final subjectsSummary = model.subjectsSummary;
    return Scaffold(
        body: ListView.builder(
      itemCount: subjectsSummary.length,
      itemBuilder: (context, index) {
        return Text(subjectsSummary[index].subjectId.toString());
      },
    ));
  }
}

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:mc_dashboard/api/subjects_summary.dart';
import 'package:mc_dashboard/core/dio/setup.dart';
import 'package:mc_dashboard/domain/services/subjects_summary_service.dart';
import 'package:mc_dashboard/main.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_screen.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';
import 'package:mc_dashboard/presentation/app/app.dart';
import 'package:mc_dashboard/routes/main_navigation.dart';
import 'package:provider/provider.dart';

AppFactory makeAppFactory() => _AppFactoryDefault();

class _AppFactoryDefault implements AppFactory {
  final _diContainer = _DIContainer();

  @override
  Future<Widget> makeApp() async {
    final screenFactory = _diContainer._makeScreenFactory();
    await _diContainer._initializeDio();
    return App(screenFactory: screenFactory);
  }
}

class _DIContainer {
  late final Dio dio;
  _DIContainer();
  Future<void> _initializeDio() async {
    dio = await setupDio();
  }

  ScreenFactory _makeScreenFactory() => ScreenFactoryDefault(this);

  SubjectsSummaryService _makeSubjectsSummaryService() =>
      SubjectsSummaryService(
          subjectsSummaryApiClient: SubjectsSummaryApiClient(dio));

  ChoosingNicheViewModel _makeChoosingNicheViewModel(BuildContext context) =>
      ChoosingNicheViewModel(
          context: context,
          subjectsSummaryService: _makeSubjectsSummaryService());
}

class ScreenFactoryDefault implements ScreenFactory {
  final _DIContainer _diContainer;

  // ignore: library_private_types_in_public_api
  const ScreenFactoryDefault(this._diContainer);

  @override
  Widget makeChoosingNicheScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeChoosingNicheViewModel(context),
      child: const ChoosingNicheScreen(),
    );
  }
}

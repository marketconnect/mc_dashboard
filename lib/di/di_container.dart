import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:mc_dashboard/api/subjects_summary.dart';
import 'package:mc_dashboard/domain/services/SubjectsSummaryService.dart';
import 'package:mc_dashboard/main.dart';
import 'package:mc_dashboard/presentation/ChoosingNicheScreenScreen/ChoosingNicheScreenScreen.dart';
import 'package:mc_dashboard/presentation/ChoosingNicheScreenScreen/ChoosingNicheViewModel.dart';
import 'package:mc_dashboard/presentation/app/app.dart';
import 'package:mc_dashboard/routes/main_navigation.dart';
import 'package:provider/provider.dart';

AppFactory makeAppFactory() => _AppFactoryDefault();

class _AppFactoryDefault implements AppFactory {
  final _diContainer = _DIContainer();

  @override
  Widget makeApp() {
    final screenFactory = _diContainer._makeScreenFactory();
    return App(screenFactory: screenFactory);
  }
}

class _DIContainer {
  _DIContainer();

  ScreenFactory _makeScreenFactory() => ScreenFactoryDefault(this);

  final dio = Dio()
    ..interceptors.add(
      DioCacheInterceptor(options: cacheOptions),
    );

  SubjectsSummaryService _makeSubjectsSummaryService() =>
      SubjectsSummaryService(
          subjectsSummaryApiClient: SubjectsSummaryApiClient(dio));

  ChoosingNicheViewModel _makeChoosingNicheViewModel() =>
      ChoosingNicheViewModel(
          subjectsSummaryService: _makeSubjectsSummaryService());
}

class ScreenFactoryDefault implements ScreenFactory {
  final _DIContainer _diContainer;

  // ignore: library_private_types_in_public_api
  const ScreenFactoryDefault(this._diContainer);

  @override
  Widget makeChoosingNicheScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeChoosingNicheViewModel(),
      child: const ChoosingNicheScreenScreen(),
    );
  }
}

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:mc_dashboard/api/detailed_orders.dart';
import 'package:mc_dashboard/api/subjects_summary.dart';
import 'package:mc_dashboard/core/dio/setup.dart';
import 'package:mc_dashboard/domain/services/detailed_orders_service.dart';
import 'package:mc_dashboard/domain/services/subjects_summary_service.dart';
import 'package:mc_dashboard/main.dart';

import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_screen.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';
import 'package:mc_dashboard/presentation/app/app.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_screen.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';
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

  DetailedOrdersService _makeDetailedOrdersService() => DetailedOrdersService(
      detailedOrdersApiClient: DetailedOrdersApiClient(dio));

  ChoosingNicheViewModel _makeChoosingNicheViewModel(
          BuildContext context,
          void Function(int subjectId, String subjectName)
              onNavigateToSubjectProducts) =>
      ChoosingNicheViewModel(
          context: context,
          subjectsSummaryService: _makeSubjectsSummaryService(),
          onNavigateToSubjectProducts: onNavigateToSubjectProducts);

  SubjectProductsViewModel _makeSubjectProductsViewModel(
          BuildContext context, int subjectId, String subjectName) =>
      SubjectProductsViewModel(
          subjectId: subjectId,
          subjectName: subjectName,
          context: context,
          detailedOrdersService: _makeDetailedOrdersService());
}

class ScreenFactoryDefault implements ScreenFactory {
  final _DIContainer _diContainer;

  // ignore: library_private_types_in_public_api
  const ScreenFactoryDefault(this._diContainer);

  @override
  Widget makeChoosingNicheScreen(
      {required void Function(int subjectId, String subjectName)
          onNavigateToSubjectProducts}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeChoosingNicheViewModel(
          context, onNavigateToSubjectProducts),
      child: const ChoosingNicheScreen(),
    );
  }

  @override
  Widget makeSubjectProductsScreen(int subjectId, String subjectName) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSubjectProductsViewModel(
          context, subjectId, subjectName),
      child: const SubjectProductsScreen(),
    );
  }
}

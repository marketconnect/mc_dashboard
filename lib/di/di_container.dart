import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:mc_dashboard/api/auth.dart';
import 'package:mc_dashboard/api/detailed_orders.dart';
import 'package:mc_dashboard/api/orders.dart';
import 'package:mc_dashboard/api/stocks.dart';
import 'package:mc_dashboard/api/subjects_summary.dart';
import 'package:mc_dashboard/api/warehouses.dart';
import 'package:mc_dashboard/core/dio/setup.dart';
import 'package:mc_dashboard/domain/services/auth_service.dart';
import 'package:mc_dashboard/domain/services/detailed_orders_service.dart';
import 'package:mc_dashboard/domain/services/orders_service.dart';
import 'package:mc_dashboard/domain/services/stocks_service.dart';
import 'package:mc_dashboard/domain/services/subjects_summary_service.dart';
import 'package:mc_dashboard/domain/services/warehouses_service.dart';
import 'package:mc_dashboard/main.dart';

import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_screen.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';
import 'package:mc_dashboard/presentation/app/app.dart';
import 'package:mc_dashboard/presentation/empty_subjects_screen/empty_subjects_screen.dart';
import 'package:mc_dashboard/presentation/empty_subjects_screen/empty_subjects_view_model.dart';
import 'package:mc_dashboard/presentation/login_screen/login_screen.dart';
import 'package:mc_dashboard/presentation/login_screen/login_view_model.dart';
import 'package:mc_dashboard/presentation/product_screen/product_screen.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_screen.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';
import 'package:mc_dashboard/repositories/cookies.dart';
import 'package:mc_dashboard/repositories/local_storage.dart';
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

  // Repositories //////////////////////////////////////////////////////////////
  // CookiesRepo _makeCookiesRepo() => const CookiesRepo();

  LocalStorageRepo _makeLocalStorageRepo() => LocalStorageRepo();
  // Api clients ///////////////////////////////////////////////////////////////
  AuthApiClient _makeAuthApiClient() => const AuthApiClient();
  // Services //////////////////////////////////////////////////////////////////
  SubjectsSummaryService _makeSubjectsSummaryService() =>
      SubjectsSummaryService(
          subjectsSummaryApiClient: SubjectsSummaryApiClient(dio));

  DetailedOrdersService _makeDetailedOrdersService() => DetailedOrdersService(
      detailedOrdersApiClient: DetailedOrdersApiClient(dio));

  StocksService _makeStocksService() =>
      StocksService(stocksApiClient: StocksApiClient(dio));

  OrderService _makeOrdersService() =>
      OrderService(ordersApiClient: OrdersApiClient(dio));

  WhService _makeWhService() =>
      WhService(whApiClient: WarehousesApiClient(dio));

  AuthService _makeAuthService() => AuthService(
        apiClient: _makeAuthApiClient(),
        authServiceStorage: _makeLocalStorageRepo(),
      );
  // ViewModels ////////////////////////////////////////////////////////////////
  ChoosingNicheViewModel _makeChoosingNicheViewModel(
          BuildContext context,
          void Function(int subjectId, String subjectName)
              onNavigateToSubjectProducts) =>
      ChoosingNicheViewModel(
          context: context,
          subjectsSummaryService: _makeSubjectsSummaryService(),
          onNavigateToSubjectProducts: onNavigateToSubjectProducts);

  SubjectProductsViewModel _makeSubjectProductsViewModel(
    BuildContext context,
    int subjectId,
    String subjectName,
    void Function() onNavigateToEmptySubject,
    void Function() onNavigateBack,
    void Function(int productId, int productPrice) onNavigateToProductScreen,
  ) =>
      SubjectProductsViewModel(
          subjectId: subjectId,
          subjectName: subjectName,
          context: context,
          onNavigateToEmptySubject: onNavigateToEmptySubject,
          onNavigateToProductScreen: onNavigateToProductScreen,
          onNavigateBack: onNavigateBack,
          detailedOrdersService: _makeDetailedOrdersService());

  EmptySubjectViewModel _makeEmptySubjectProductsViewModel(
          BuildContext context,
          void Function(int subjectId, String subjectName)
              onNavigateToSubjectProducts,
          void Function() onNavigateBack) =>
      EmptySubjectViewModel(
          context: context,
          onNavigateToSubjectProducts: onNavigateToSubjectProducts,
          onNavigateBack: onNavigateBack,
          subjectsSummaryService: _makeSubjectsSummaryService());

  ProductViewModel _makeProductViewModel(BuildContext context, int productId,
          int productPrice, void Function() onNavigateBack) =>
      ProductViewModel(
        context: context,
        productId: productId,
        ordersService: _makeOrdersService(),
        stocksService: _makeStocksService(),
        onNavigateBack: onNavigateBack,
        whService: _makeWhService(),
        productPrice: productPrice,
      );

  LoginViewModel _makeLoginViewModel(BuildContext context) => LoginViewModel(
        context: context,
        authService: _makeAuthService(),
      );
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
  Widget makeSubjectProductsScreen(
      {required int subjectId,
      required String subjectName,
      required void Function(int productId, int productPrice)
          onNavigateToProductScreen,
      required void Function() onNavigateToEmptySubject,
      required void Function() onNavigateBack}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSubjectProductsViewModel(
          context,
          subjectId,
          subjectName,
          onNavigateToEmptySubject,
          onNavigateBack,
          onNavigateToProductScreen),
      child: const SubjectProductsScreen(),
    );
  }

  @override
  Widget makeEmptySubjectProductsScreen(
      {required void Function(int subjectId, String subjectName)
          onNavigateToSubjectProducts,
      required void Function() onNavigateBack}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeEmptySubjectProductsViewModel(
          context, onNavigateToSubjectProducts, onNavigateBack),
      child: const EmptySubjectProductsScreen(),
    );
  }

  @override
  Widget makeProductScreen(
      {required int productId,
      required int productPrice,
      required void Function() onNavigateBack}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeProductViewModel(
          context, productId, productPrice, onNavigateBack),
      child: const ProductScreen(),
    );
  }

  @override
  Widget makeLoginScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeLoginViewModel(
        context,
      ),
      child: const LoginScreen(),
    );
  }
}

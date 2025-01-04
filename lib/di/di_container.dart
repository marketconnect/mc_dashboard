import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:mc_dashboard/api/auth.dart';
import 'package:mc_dashboard/api/detailed_orders.dart';
import 'package:mc_dashboard/api/kw_lemmas.dart';
import 'package:mc_dashboard/api/lemmatize.dart';
import 'package:mc_dashboard/api/normqueries.dart';
import 'package:mc_dashboard/api/orders.dart';
import 'package:mc_dashboard/api/stocks.dart';
import 'package:mc_dashboard/api/subjects_summary.dart';
import 'package:mc_dashboard/api/warehouses.dart';
import 'package:mc_dashboard/core/dio/setup.dart';
import 'package:mc_dashboard/domain/services/auth_service.dart';
import 'package:mc_dashboard/domain/services/detailed_orders_service.dart';
import 'package:mc_dashboard/domain/services/kw_lemmas_service.dart';
import 'package:mc_dashboard/domain/services/lemmatize_service.dart';
import 'package:mc_dashboard/domain/services/mail_settings_service.dart';
import 'package:mc_dashboard/domain/services/normqueries_service.dart';
import 'package:mc_dashboard/domain/services/orders_service.dart';
import 'package:mc_dashboard/domain/services/saved_key_phrases_service.dart';
import 'package:mc_dashboard/domain/services/saved_products_service.dart';
import 'package:mc_dashboard/domain/services/stocks_service.dart';
import 'package:mc_dashboard/domain/services/subjects_summary_service.dart';
import 'package:mc_dashboard/domain/services/user_emails_service.dart';
import 'package:mc_dashboard/domain/services/warehouses_service.dart';
import 'package:mc_dashboard/main.dart';

import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_screen.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';
import 'package:mc_dashboard/presentation/app/app.dart';
import 'package:mc_dashboard/presentation/empty_products_screen/empty_product_screen.dart';
import 'package:mc_dashboard/presentation/empty_products_screen/empty_product_view_model.dart';
import 'package:mc_dashboard/presentation/empty_subjects_screen/empty_subjects_screen.dart';
import 'package:mc_dashboard/presentation/empty_subjects_screen/empty_subjects_view_model.dart';
import 'package:mc_dashboard/presentation/login_screen/login_screen.dart';
import 'package:mc_dashboard/presentation/login_screen/login_view_model.dart';
import 'package:mc_dashboard/presentation/mailing_screen/mailing_screen.dart';
import 'package:mc_dashboard/presentation/mailing_screen/mailing_view_model.dart';
import 'package:mc_dashboard/presentation/product_screen/product_screen.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

import 'package:mc_dashboard/presentation/mailing_screen/saved_key_phrases_view_model.dart';

import 'package:mc_dashboard/presentation/mailing_screen/saved_products_view_model.dart';
import 'package:mc_dashboard/presentation/seo_requests_extend_screen/seo_requests_extend_screen.dart';
import 'package:mc_dashboard/presentation/seo_requests_extend_screen/seo_requests_extend_view_model.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_screen.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';

import 'package:mc_dashboard/repositories/local_storage.dart';
import 'package:mc_dashboard/repositories/mailing_settings_repo.dart';
import 'package:mc_dashboard/repositories/saved_key_phrases_repo.dart';
import 'package:mc_dashboard/repositories/saved_products_repo.dart';
import 'package:mc_dashboard/repositories/user_email_repo.dart';
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

  SavedProductsRepo _makeSavedProductsRepo() => SavedProductsRepo();

  SavedKeyPhrasesRepo _makeSavedKeyPhrasesRepo() => SavedKeyPhrasesRepo();

  UserEmailsRepo _makeUserEmailsRepo() => UserEmailsRepo();

  MailingSettingsRepo _makeMailingSettingsRepo() => MailingSettingsRepo();
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

  NormqueryService _makeNormqueryService() =>
      NormqueryService(NormqueriesApiClient(dio));

  KwLemmaService _makeKwLemmaService() =>
      KwLemmaService(KwLemmasApiClient(dio));

  LemmatizeService _makeLemmatizeService() => LemmatizeService(
        apiClient: LemmatizeApiClient(dio),
      );

  SavedProductsService _makeSavedProductsService() => SavedProductsService(
        savedProductsRepo: _makeSavedProductsRepo(),
      );

  SavedKeyPhrasesService _makeSavedKeyPhrasesService() =>
      SavedKeyPhrasesService(
        savedKeyPhrasesRepo: _makeSavedKeyPhrasesRepo(),
      );

  UserEmailsService _makeUserEmailsService() => UserEmailsService(
        userEmailsRepoRepo: _makeUserEmailsRepo(),
      );

  MailingSettingsService _makeMailingSettingsService() =>
      MailingSettingsService(
        mailingSettingsRepo: _makeMailingSettingsRepo(),
      );
  // ViewModels ////////////////////////////////////////////////////////////////
  ChoosingNicheViewModel _makeChoosingNicheViewModel(
          BuildContext context,
          void Function(int subjectId, String subjectName)
              onNavigateToSubjectProducts) =>
      ChoosingNicheViewModel(
          context: context,
          subjectsSummaryService: _makeSubjectsSummaryService(),
          authService: _makeAuthService(),
          onNavigateToSubjectProducts: onNavigateToSubjectProducts);

  SubjectProductsViewModel _makeSubjectProductsViewModel(
    BuildContext context,
    int subjectId,
    String subjectName,
    void Function() onNavigateToEmptySubject,
    void Function() onNavigateBack,
    void Function(int productId, int productPrice) onNavigateToProductScreen,
    void Function(List<int>) onNavigateToSeoRequestsExtendScreen,
    void Function(List<int> productIds) onSaveProductsToTrack,
  ) =>
      SubjectProductsViewModel(
          subjectId: subjectId,
          subjectName: subjectName,
          context: context,
          onNavigateToEmptySubject: onNavigateToEmptySubject,
          onNavigateToProductScreen: onNavigateToProductScreen,
          onNavigateBack: onNavigateBack,
          onSaveProductsToTrack: onSaveProductsToTrack,
          onNavigateToSeoRequestsExtendScreen:
              onNavigateToSeoRequestsExtendScreen,
          detailedOrdersService: _makeDetailedOrdersService(),
          savedProductsService: _makeSavedProductsService(),
          authService: _makeAuthService());

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

  EmptyProductViewModel _makeEmptyProductViewModel(
          BuildContext context,
          void Function(int productId, int productPrice)
              onNavigateToProductScreen,
          void Function() onNavigateBack) =>
      EmptyProductViewModel(
          context: context,
          onNavigateToProductScreen: onNavigateToProductScreen,
          onNavigateBack: onNavigateBack);

  ProductViewModel _makeProductViewModel(
          BuildContext context,
          int productId,
          int productPrice,
          void Function() onNavigateToEmptyProductScreen,
          void Function(List<String> keyPhrasesStr) onSaveKeyPhraseToTrack,
          void Function() onNavigateBack) =>
      ProductViewModel(
        context: context,
        productId: productId,
        ordersService: _makeOrdersService(),
        stocksService: _makeStocksService(),
        normqueryService: _makeNormqueryService(),
        kwLemmaService: _makeKwLemmaService(),
        onNavigateBack: onNavigateBack,
        detailedOrdersService: _makeDetailedOrdersService(),
        savedKeyPhrasesService: _makeSavedKeyPhrasesService(),
        onNavigateToEmptyProductScreen: onNavigateToEmptyProductScreen,
        whService: _makeWhService(),
        authService: _makeAuthService(),
        lemmatizeService: _makeLemmatizeService(),
        onSaveKeyPhrasesToTrack: onSaveKeyPhraseToTrack,
        productPrice: productPrice,
      );

  SeoRequestsExtendViewModel _makeSeoRequestsExtendViewModel(
          BuildContext context,
          void Function() onNavigateBack,
          List<int> productIds) =>
      SeoRequestsExtendViewModel(
          context: context,
          onNavigateBack: onNavigateBack,
          normqueryService: _makeNormqueryService(),
          authService: _makeAuthService(),
          productIds: productIds);

  MailingSettingsViewModel _makeMailingSettingsViewModel(
          BuildContext context) =>
      MailingSettingsViewModel(
        context: context,
        userEmailsService: _makeUserEmailsService(),
        settingsService: _makeMailingSettingsService(),
        authService: _makeAuthService(),
      );

  SavedProductsViewModel _makeSavedProductsViewModel(BuildContext context) =>
      SavedProductsViewModel(
        context: context,
        savedProductsService: _makeSavedProductsService(),
      );

  SavedKeyPhrasesViewModel _makeSavedKeyPhrasesViewModel(
          BuildContext context) =>
      SavedKeyPhrasesViewModel(
        context: context,
        keyPhrasesService: _makeSavedKeyPhrasesService(),
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
      required void Function(List<int>) onNavigateToSeoRequestsExtendScreen,
      required void Function(List<int> productIds) onSaveProductsToTrack,
      required void Function() onNavigateBack}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSubjectProductsViewModel(
          context,
          subjectId,
          subjectName,
          onNavigateToEmptySubject,
          onNavigateBack,
          onNavigateToProductScreen,
          onNavigateToSeoRequestsExtendScreen,
          onSaveProductsToTrack),
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
  Widget makeEmptyProductScreen(
      {required void Function(int productId, int productPrice)
          onNavigateToProductScreen,
      required void Function() onNavigateBack}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeEmptyProductViewModel(
          context, onNavigateToProductScreen, onNavigateBack),
      child: const EmptyProductScreen(),
    );
  }

  @override
  Widget makeProductScreen(
      {required int productId,
      required int productPrice,
      required void Function() onNavigateToEmptyProductScreen,
      required void Function(List<String> keyPhrasesStr)
          onSaveKeyPhrasesToTrack,
      required void Function() onNavigateBack}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeProductViewModel(
          context,
          productId,
          productPrice,
          onNavigateToEmptyProductScreen,
          onSaveKeyPhrasesToTrack,
          onNavigateBack),
      child: const ProductScreen(),
    );
  }

  @override
  Widget makeSeoRequestsExtendScreen(
      {required void Function() onNavigateBack,
      required List<int> productIds}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSeoRequestsExtendViewModel(
        context,
        onNavigateBack,
        productIds,
      ),
      child: const SeoRequestsExtendScreen(),
    );
  }

  @override
  Widget makeMailingScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => _diContainer._makeMailingSettingsViewModel(
            context,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => _diContainer._makeSavedProductsViewModel(
            context,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => _diContainer._makeSavedKeyPhrasesViewModel(
            context,
          ),
        ),
      ],
      child: const MailingScreen(),
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

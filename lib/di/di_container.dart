import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

import 'package:mc_dashboard/infrastructure/api/auth.dart';
import 'package:mc_dashboard/infrastructure/api/detailed_orders.dart';
import 'package:mc_dashboard/infrastructure/api/kw_lemmas.dart';
import 'package:mc_dashboard/infrastructure/api/lemmatize.dart';
import 'package:mc_dashboard/infrastructure/api/normqueries.dart';
import 'package:mc_dashboard/infrastructure/api/orders.dart';
import 'package:mc_dashboard/infrastructure/api/stocks.dart';

import 'package:mc_dashboard/infrastructure/api/user_emails_api.dart';
import 'package:mc_dashboard/infrastructure/api/user_search_queries_api.dart';
import 'package:mc_dashboard/infrastructure/api/user_settings_api.dart';
import 'package:mc_dashboard/infrastructure/api/user_skus_api.dart';
import 'package:mc_dashboard/infrastructure/api/warehouses.dart';
import 'package:mc_dashboard/core/dio/setup.dart';
import 'package:mc_dashboard/domain/services/auth_service.dart';
import 'package:mc_dashboard/domain/services/detailed_orders_service.dart';
import 'package:mc_dashboard/domain/services/kw_lemmas_service.dart';
import 'package:mc_dashboard/domain/services/lemmatize_service.dart';
import 'package:mc_dashboard/domain/services/user_sub_settings_service.dart';
import 'package:mc_dashboard/domain/services/normqueries_service.dart';
import 'package:mc_dashboard/domain/services/orders_service.dart';
import 'package:mc_dashboard/domain/services/saved_key_phrases_service.dart';
import 'package:mc_dashboard/domain/services/saved_products_service.dart';
import 'package:mc_dashboard/domain/services/stocks_service.dart';
import 'package:mc_dashboard/domain/services/subjects_summary_service.dart';
import 'package:mc_dashboard/domain/services/tinkoff_payment_service.dart';
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
import 'package:mc_dashboard/presentation/subscription_screen/subscription_screen.dart';
import 'package:mc_dashboard/presentation/subscription_screen/subscription_view_model.dart';

import 'package:mc_dashboard/infrastructure/repositories/local_storage.dart';
import 'package:mc_dashboard/infrastructure/repositories/mailing_settings_repo.dart';
import 'package:mc_dashboard/infrastructure/repositories/saved_key_phrases_repo.dart';
import 'package:mc_dashboard/infrastructure/repositories/saved_products_repo.dart';
import 'package:mc_dashboard/infrastructure/repositories/user_email_repo.dart';
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

  UserSkusApiClient _makeUserSkusApiClient() => UserSkusApiClient();
  // Api clients ///////////////////////////////////////////////////////////////
  AuthApiClient _makeAuthApiClient() => const AuthApiClient();
  UserEmailsApiClient _makeUserEmailsApiClient() => UserEmailsApiClient();
  UserSearchQueriesApiClient _makeUserSearchQueriesApiClient() =>
      UserSearchQueriesApiClient();
  // Services //////////////////////////////////////////////////////////////////

  DetailedOrdersService _makeDetailedOrdersService() => DetailedOrdersService(
      detailedOrdersApiClient: DetailedOrdersApiClient(dio));

  // Why singleton? This is a workaround . Because we need to fetch subjects summary only once
  // despite it is used in multiple screens simultaneously when app is loading
  // (choose niche, subject products, empty subjects)
  final SubjectsSummaryService _makeSubjectsSummaryService =
      SubjectsSummaryService.instance;

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

  UserEmailsService _makeUserEmailsService() => UserEmailsService(
        userEmailsRepoRepo: _makeUserEmailsRepo(),
        userEmailsApiClient: _makeUserEmailsApiClient(),
      );
  SavedProductsService _makeSavedProductsService() => SavedProductsService(
        savedProductsRepo: _makeSavedProductsRepo(),
        savedProductsApiClient: _makeUserSkusApiClient(),
        // suppliersApiClient: SuppliersApiClient(dio),
      );

  SavedKeyPhrasesService _makeSavedKeyPhrasesService() =>
      SavedKeyPhrasesService(
        savedKeyPhrasesRepo: _makeSavedKeyPhrasesRepo(),
        savedKeyPhrasesApiClient: _makeUserSearchQueriesApiClient(),
      );

  UserSubSettingsService _makeMailingSettingsService() =>
      UserSubSettingsService(
        mailingSettingsRepo: _makeMailingSettingsRepo(),
        userSettingsApiClient: UserSettingsApiClient(),
      );

  // SuppliersService _makeSuppliersService() => SuppliersService(
  //       suppliersApiClient: SuppliersApiClient(dio),
  //     );

  TinkoffPaymentService _makeTinkoffPaymentService() => TinkoffPaymentService();
  // ViewModels ////////////////////////////////////////////////////////////////
  ChoosingNicheViewModel _makeChoosingNicheViewModel(
          BuildContext context,
          void Function(int subjectId, String subjectName)
              onNavigateToSubjectProducts) =>
      ChoosingNicheViewModel(
          context: context,
          subjectsSummaryService: _makeSubjectsSummaryService,
          // authService: _makeAuthService(),
          onNavigateToSubjectProducts: onNavigateToSubjectProducts);

  SubjectProductsViewModel _makeSubjectProductsViewModel(
    BuildContext context,
    int subjectId,
    String subjectName,
    void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
    void Function(List<String> productIds) onSaveProductsToTrack,
  ) =>
      SubjectProductsViewModel(
          subjectId: subjectId,
          subjectName: subjectName,
          context: context,
          onNavigateTo: onNavigateTo,
          subjectSummaryService: _makeSubjectsSummaryService,
          onSaveProductsToTrack: onSaveProductsToTrack,
          detailedOrdersService: _makeDetailedOrdersService(),
          savedProductsService: _makeSavedProductsService(),
          authService: _makeAuthService());

  EmptySubjectViewModel _makeEmptySubjectProductsViewModel(
    BuildContext context,
    void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
  ) =>
      EmptySubjectViewModel(
          context: context,
          onNavigateTo: onNavigateTo,
          subjectsSummaryService: _makeSubjectsSummaryService);

  EmptyProductViewModel _makeEmptyProductViewModel(
    BuildContext context,
    void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
  ) =>
      EmptyProductViewModel(context: context, onNavigateTo: onNavigateTo);

  ProductViewModel _makeProductViewModel(
    BuildContext context,
    int productId,
    int productPrice,
    String prevScreen,
    void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
    void Function(List<String> keyPhrasesStr) onSaveKeyPhraseToTrack,
  ) =>
      ProductViewModel(
        context: context,
        productId: productId,
        ordersService: _makeOrdersService(),
        stocksService: _makeStocksService(),
        normqueryService: _makeNormqueryService(),
        kwLemmaService: _makeKwLemmaService(),
        onNavigateTo: onNavigateTo,
        detailedOrdersService: _makeDetailedOrdersService(),
        savedKeyPhrasesService: _makeSavedKeyPhrasesService(),
        whService: _makeWhService(),
        prevScreen: prevScreen,
        savedProductsService: _makeSavedProductsService(),
        authService: _makeAuthService(),
        lemmatizeService: _makeLemmatizeService(),
        onSaveKeyPhrasesToTrack: onSaveKeyPhraseToTrack,
        productPrice: productPrice,
      );

  SeoRequestsExtendViewModel _makeSeoRequestsExtendViewModel(
          BuildContext context,
          void Function({
            required String routeName,
            Map<String, dynamic>? params,
          }) onNavigateTo,
          List<int> productIds) =>
      SeoRequestsExtendViewModel(
          context: context,
          onNavigateTo: onNavigateTo,
          normqueryService: _makeNormqueryService(),
          authService: _makeAuthService(),
          productIds: productIds);

  MailingSettingsViewModel _makeMailingSettingsViewModel(
    BuildContext context,
    void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
  ) =>
      MailingSettingsViewModel(
        context: context,
        userEmailsService: _makeUserEmailsService(),
        settingsService: _makeMailingSettingsService(),
        authService: _makeAuthService(),
        onNavigateTo: onNavigateTo,
      );

  SavedProductsViewModel _makeSavedProductsViewModel(BuildContext context) =>
      SavedProductsViewModel(
        context: context,
        savedProductsService: _makeSavedProductsService(),
        authService: _makeAuthService(),
      );

  SavedKeyPhrasesViewModel _makeSavedKeyPhrasesViewModel(
          BuildContext context) =>
      SavedKeyPhrasesViewModel(
        context: context,
        keyPhrasesService: _makeSavedKeyPhrasesService(),
        authService: _makeAuthService(),
      );

  SubscriptionViewModel _makeSubscriptionViewModel(BuildContext context) =>
      SubscriptionViewModel(
        context: context,
        authService: _makeAuthService(),
        tinkoffPaymentService: _makeTinkoffPaymentService(),
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
  Widget makeSubjectProductsScreen({
    required int subjectId,
    required String subjectName,
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
    required void Function(List<String> productIds) onSaveProductsToTrack,
  }) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSubjectProductsViewModel(
          context, subjectId, subjectName, onNavigateTo, onSaveProductsToTrack),
      child: const SubjectProductsScreen(),
    );
  }

  @override
  Widget makeEmptySubjectProductsScreen({
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
  }) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeEmptySubjectProductsViewModel(
          context, onNavigateTo),
      child: const EmptySubjectProductsScreen(),
    );
  }

  @override
  Widget makeEmptyProductScreen({
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
  }) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeEmptyProductViewModel(context, onNavigateTo),
      child: const EmptyProductScreen(),
    );
  }

  @override
  Widget makeProductScreen({
    required int productId,
    required int productPrice,
    required String prevScreen,
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
    required void Function(List<String> keyPhrasesStr) onSaveKeyPhrasesToTrack,
  }) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeProductViewModel(
          context,
          productId,
          productPrice,
          prevScreen,
          onNavigateTo,
          onSaveKeyPhrasesToTrack),
      child: const ProductScreen(),
    );
  }

  @override
  Widget makeSeoRequestsExtendScreen(
      {required void Function({
        required String routeName,
        Map<String, dynamic>? params,
      }) onNavigateTo,
      required List<int> productIds}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSeoRequestsExtendViewModel(
        context,
        onNavigateTo,
        productIds,
      ),
      child: const SeoRequestsExtendScreen(),
    );
  }

  @override
  Widget makeMailingScreen({
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => _diContainer._makeMailingSettingsViewModel(
            context,
            onNavigateTo,
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
  Widget makeSubscriptionScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSubscriptionViewModel(
        context,
      ),
      child: const SubscriptionScreen(),
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

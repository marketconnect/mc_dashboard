import 'package:flutter/material.dart';
import 'package:mc_dashboard/domain/entities/product.dart';
import 'package:mc_dashboard/domain/services/api_products_service.dart';
import 'package:mc_dashboard/domain/services/card_info_service.dart';
import 'package:mc_dashboard/domain/services/goods_service.dart';
import 'package:mc_dashboard/domain/services/product_cost_service.dart';
import 'package:mc_dashboard/domain/services/product_service.dart';

import 'package:mc_dashboard/domain/services/tariff_service.dart';
import 'package:mc_dashboard/domain/services/token_service.dart';
import 'package:mc_dashboard/domain/services/wb_api_content_service.dart';
import 'package:mc_dashboard/domain/services/wb_products_service.dart';
import 'package:mc_dashboard/domain/services/wb_tariffs_service.dart';

import 'package:mc_dashboard/infrastructure/api/auth.dart';
import 'package:mc_dashboard/infrastructure/api/card_info_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/detailed_orders.dart';
import 'package:mc_dashboard/infrastructure/api/goods_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/kw_lemmas.dart';
import 'package:mc_dashboard/infrastructure/api/lemmatize.dart';
import 'package:mc_dashboard/infrastructure/api/normqueries.dart';
import 'package:mc_dashboard/infrastructure/api/orders.dart';
import 'package:mc_dashboard/infrastructure/api/products_api_client.dart';

import 'package:mc_dashboard/infrastructure/api/stocks.dart';
import 'package:mc_dashboard/infrastructure/api/tariffs_api_client.dart';

import 'package:mc_dashboard/infrastructure/api/warehouses.dart';

import 'package:mc_dashboard/domain/services/auth_service.dart';
import 'package:mc_dashboard/domain/services/detailed_orders_service.dart';
import 'package:mc_dashboard/domain/services/kw_lemmas_service.dart';
import 'package:mc_dashboard/domain/services/lemmatize_service.dart';

import 'package:mc_dashboard/domain/services/normqueries_service.dart';
import 'package:mc_dashboard/domain/services/orders_service.dart';

import 'package:mc_dashboard/domain/services/stocks_service.dart';
import 'package:mc_dashboard/domain/services/subjects_summary_service.dart';
import 'package:mc_dashboard/domain/services/tinkoff_payment_service.dart';

import 'package:mc_dashboard/domain/services/warehouses_service.dart';
import 'package:mc_dashboard/infrastructure/api/wb_content_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/wb_products_api_client.dart';
import 'package:mc_dashboard/infrastructure/repositories/card_source_repo.dart';
import 'package:mc_dashboard/infrastructure/repositories/product_cost_repo.dart';
import 'package:mc_dashboard/infrastructure/repositories/secure_token_storage_repo.dart';

import 'package:mc_dashboard/main.dart';
import 'package:mc_dashboard/presentation/add_cards_screen/add_cards_screen.dart';
import 'package:mc_dashboard/presentation/add_cards_screen/add_cards_view_model.dart';

import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_screen.dart';
import 'package:mc_dashboard/presentation/choosing_niche_screen/choosing_niche_view_model.dart';
import 'package:mc_dashboard/presentation/app/app.dart';
import 'package:mc_dashboard/presentation/empty_products_screen/empty_product_screen.dart';
import 'package:mc_dashboard/presentation/empty_products_screen/empty_product_view_model.dart';
import 'package:mc_dashboard/presentation/empty_subjects_screen/empty_subjects_screen.dart';
import 'package:mc_dashboard/presentation/empty_subjects_screen/empty_subjects_view_model.dart';
import 'package:mc_dashboard/presentation/login_screen/login_screen.dart';
import 'package:mc_dashboard/presentation/login_screen/login_view_model.dart';
import 'package:mc_dashboard/presentation/market_screen/market_screen.dart';
import 'package:mc_dashboard/presentation/market_screen/market_view_model.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_screen.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_screen.dart';
import 'package:mc_dashboard/presentation/product_cards_screen/product_cards_view_model.dart';
import 'package:mc_dashboard/presentation/product_cost_import_screen/product_cost_import_screen.dart';
import 'package:mc_dashboard/presentation/product_cost_import_screen/product_cost_import_view_model.dart';
import 'package:mc_dashboard/presentation/product_detail_screen/product_detail_screen.dart';
import 'package:mc_dashboard/presentation/product_detail_screen/product_detail_view_model.dart';

import 'package:mc_dashboard/presentation/product_screen/product_screen.dart';
import 'package:mc_dashboard/presentation/product_screen/product_view_model.dart';

import 'package:mc_dashboard/presentation/seo_requests_extend_screen/seo_requests_extend_screen.dart';
import 'package:mc_dashboard/presentation/seo_requests_extend_screen/seo_requests_extend_view_model.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_screen.dart';
import 'package:mc_dashboard/presentation/subject_products_screen/subject_products_view_model.dart';
import 'package:mc_dashboard/presentation/subscription_screen/subscription_screen.dart';
import 'package:mc_dashboard/presentation/subscription_screen/subscription_view_model.dart';

import 'package:mc_dashboard/infrastructure/repositories/local_storage.dart';
import 'package:mc_dashboard/presentation/tokens_screen/tokens_screen.dart';
import 'package:mc_dashboard/presentation/tokens_screen/tokens_view_model.dart';

import 'package:mc_dashboard/routes/main_navigation.dart';
import 'package:provider/provider.dart';

AppFactory makeAppFactory() => _AppFactoryDefault();

class _AppFactoryDefault implements AppFactory {
  final _diContainer = _DIContainer();

  @override
  Future<Widget> makeApp() async {
    final screenFactory = _diContainer._makeScreenFactory();

    return App(screenFactory: screenFactory);
  }
}

class _DIContainer {
  _DIContainer();

  ScreenFactory _makeScreenFactory() => ScreenFactoryDefault(this);

  // Repositories //////////////////////////////////////////////////////////////
  // CookiesRepo _makeCookiesRepo() => const CookiesRepo();
  ProductCostRepository get productCostRepo => const ProductCostRepository();
  McAuthRepo _makeLocalStorageRepo() => McAuthRepo();
  CardSourceRepo get cardSourceRepo => const CardSourceRepo();
  // WbTokenRepo _makeApiKeyRepo() => WbTokenRepo();
  SecureTokenStorageRepo get secureTokenRepo => SecureTokenStorageRepo();
  // Api clients ///////////////////////////////////////////////////////////////
  AuthApiClient _makeAuthApiClient() => const AuthApiClient();
  ProductsApiClient get productSource => const ProductsApiClient();
  // TariffsApiClient _makeTariffsApiClient() => TariffsApiClient();
  TariffsApiClient tariffsApiClient = TariffsApiClient.instance;

  WbProductsApiClient _makeWbProductsApiClient() => WbProductsApiClient();

  WbGoodsApiClient _makeWbGoodsApiClient() => const WbGoodsApiClient();
  // Services //////////////////////////////////////////////////////////////////

  DetailedOrdersService _makeDetailedOrdersService() =>
      DetailedOrdersService(detailedOrdersApiClient: DetailedOrdersApiClient());

  // Why singleton? This is a workaround . Because we need to fetch subjects summary only once
  // despite it is used in multiple screens simultaneously when app is loading
  // (choose niche, subject products, empty subjects)
  final SubjectsSummaryService _makeSubjectsSummaryService =
      SubjectsSummaryService.instance;

  StocksService _makeStocksService() =>
      StocksService(stocksApiClient: StocksApiClient());

  OrderService _makeOrdersService() =>
      OrderService(ordersApiClient: OrdersApiClient());

  WhService _makeWhService() => WhService(whApiClient: WarehousesApiClient());

  AuthService _makeAuthService() => AuthService(
        apiClient: _makeAuthApiClient(),
        authServiceStorage: _makeLocalStorageRepo(),
      );

  NormqueryService _makeNormqueryService() =>
      NormqueryService(NormqueriesApiClient());

  KwLemmaService _makeKwLemmaService() => KwLemmaService(KwLemmasApiClient());

  LemmatizeService _makeLemmatizeService() => LemmatizeService(
        apiClient: LemmatizeApiClient(),
      );

  // WbTokenService _makeApiKeyService() =>
  //     WbTokenService(storage: _makeApiKeyRepo());

  TinkoffPaymentService _makeTinkoffPaymentService() => TinkoffPaymentService();

  TariffsServiceImpl _makeTariffsService() =>
      TariffsServiceImpl(apiClient: tariffsApiClient);

  WbProductsServiceImpl _makeWbProductsService() =>
      WbProductsServiceImpl(apiClient: _makeWbProductsApiClient());
  TokenService get tokenService => TokenService(tokenStorage: secureTokenRepo);

  ProductCostService get productCostService => ProductCostService(
        storage: productCostRepo,
      );

  final wbTariffsService = WbTariffsService();
  WbApiContentService get wbApiContentService => WbApiContentService(
        apiClient: WbContentApiClient(),
        wbTokenRepo: secureTokenRepo,
      );

  ApiProductService get apiProductService => ApiProductService(
        productsApiClient: productSource,
      );

  CardInfoService get cardInfoService => CardInfoService(
        apiClient: CardInfoApiClient(),
      );

  ProductService get productService =>
      ProductService(productSource: cardSourceRepo);

  WbGoodsService get wbGoodsService => WbGoodsService(
        apiClient: _makeWbGoodsApiClient(),
        wbTokenRepo: secureTokenRepo,
      );
  // ViewModels ////////////////////////////////////////////////////////////////
  ChoosingNicheViewModel _makeChoosingNicheViewModel(
          BuildContext context,
          void Function(int subjectId, String subjectName)
              onNavigateToSubjectProducts) =>
      ChoosingNicheViewModel(
        context: context,
        subjectsSummaryService: _makeSubjectsSummaryService,
        // authService: _makeAuthService(),
      );

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
          authService: _makeAuthService());

  EmptySubjectViewModel _makeEmptySubjectProductsViewModel(
    BuildContext context,
  ) =>
      EmptySubjectViewModel(
          context: context,
          subjectsSummaryService: _makeSubjectsSummaryService);

  EmptyProductViewModel _makeEmptyProductViewModel(
    BuildContext context,
  ) =>
      EmptyProductViewModel(
        context: context,
      );

  ProductViewModel _makeProductViewModel(
    BuildContext context,
    int productId,
    int productPrice,
  ) =>
      ProductViewModel(
        context: context,
        productId: productId,
        ordersService: _makeOrdersService(),
        stocksService: _makeStocksService(),
        normqueryService: _makeNormqueryService(),
        kwLemmaService: _makeKwLemmaService(),
        detailedOrdersService: _makeDetailedOrdersService(),
        whService: _makeWhService(),
        authService: _makeAuthService(),
        lemmatizeService: _makeLemmatizeService(),
        wbProductsService: _makeWbProductsService(),
        productPrice: productPrice,
        tariffsService: _makeTariffsService(),
        apiKeyService: tokenService,
      );

  SeoRequestsExtendViewModel _makeSeoRequestsExtendViewModel(
          BuildContext context,
          List<int> productIds,
          List<String> charactiristics) =>
      SeoRequestsExtendViewModel(
          context: context,
          normqueryService: _makeNormqueryService(),
          authService: _makeAuthService(),
          productIds: productIds,
          charactiristics: charactiristics);

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

  // ApiKeyViewModel _makeApiKeyViewModel(BuildContext context) => ApiKeyViewModel(
  //       context: context,
  //       apiKeyStorageService: _makeApiKeyService(),
  //     );

  AddCardsViewModel _makeAddCardsViewModel(BuildContext context) =>
      AddCardsViewModel(cardsService: productService, context: context);

  ProductDetailViewModel _makeProductDetailViewModel(
      BuildContext context, Product product) {
    return ProductDetailViewModel(
      wbApiContentService: wbApiContentService,
      product: product,
      productSource: apiProductService,
      cardInfoService: cardInfoService,
      context: context,
    );
  }

  ProductCardsViewModel _makeProductCardsViewModel(BuildContext context) {
    return ProductCardsViewModel(
      wbApiContentService: wbApiContentService,
      wbProductCostService: productCostService,
      wbTariffsService: wbTariffsService,
      goodsService: wbGoodsService,
      context: context,
    );
  }

  ProductCardViewModel _makeProductCardViewModel(
      BuildContext context, int imtID, int nmID) {
    return ProductCardViewModel(
      contentApiService: wbApiContentService,
      tariffsService: wbTariffsService,
      imtID: imtID,
      productCostService: productCostService,
      nmID: nmID,
      context: context,
    );
  }

  ProductCostImportViewModel _makeProductCostImportViewModel(
      BuildContext context) {
    return ProductCostImportViewModel(
      productCostService: productCostService,
      context: context,
    );
  }

  TokensViewModel _makeTokensViewModel(BuildContext context) {
    return TokensViewModel(
      tokensService: tokenService,
      context: context,
    );
  }

  MarketViewModel _makeMarketViewModel(BuildContext context) {
    return MarketViewModel(
      tokensService: tokenService,
      context: context,
    );
  }
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
  Widget makeEmptySubjectProductsScreen() {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeEmptySubjectProductsViewModel(context),
      child: const EmptySubjectProductsScreen(),
    );
  }

  @override
  Widget makeEmptyProductScreen({
    nNavigateTo,
  }) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeEmptyProductViewModel(
        context,
      ),
      child: const EmptyProductScreen(),
    );
  }

  @override
  Widget makeProductScreen({
    required int productId,
    required int productPrice,
  }) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeProductViewModel(context, productId, productPrice),
      child: const ProductScreen(),
    );
  }

  @override
  Widget makeSeoRequestsExtendScreen({
    required List<int> productIds,
    required List<String> characteristics,
  }) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSeoRequestsExtendViewModel(
        context,
        productIds,
        characteristics,
      ),
      child: const SeoRequestsExtendScreen(),
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

  @override
  Widget makeMarketScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeMarketViewModel(context),
      child: const MarketScreen(),
    );
  }

  // @override
  // Widget makeApiKeysScreen() {
  //   return ChangeNotifierProvider(
  //     create: (context) => _diContainer._makeApiKeyViewModel(
  //       context,
  //     ),
  //     child: const ApiKeyScreen(),
  //   );
  // }

  @override
  Widget makeProductDetailScreen({required Product product}) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeProductDetailViewModel(context, product),
      child: ProductDetailScreen(product: product),
    );
  }

  @override
  Widget makeAddCardsScreen() {
    print("makeAddCardsScreen");
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeAddCardsViewModel(context),
      child: const AddCardsScreen(),
    );
  }

  @override
  Widget makeProductCardsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeProductCardsViewModel(context),
      child: const ProductCardsScreen(),
    );
  }

  @override
  Widget makeProductCardScreen({required int imtID, required int nmID}) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeProductCardViewModel(context, imtID, nmID),
      child: const ProductCardScreen(),
    );
  }

  @override
  Widget makeProductCostImportScreen() {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeProductCostImportViewModel(context),
      child: const ProductCostImportScreen(),
    );
  }

  @override
  Widget makeTokensScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeTokensViewModel(context),
      child: const TokensScreen(),
    );
  }
}

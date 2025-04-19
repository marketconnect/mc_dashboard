import 'package:flutter/material.dart';
import 'package:mc_dashboard/domain/entities/product.dart';
import 'package:mc_dashboard/domain/services/api_products_service.dart';
import 'package:mc_dashboard/domain/services/card_info_service.dart';
import 'package:mc_dashboard/domain/services/goods_service.dart';
import 'package:mc_dashboard/domain/services/ozon_price_service.dart';
import 'package:mc_dashboard/domain/services/ozon_product_info_service.dart';
import 'package:mc_dashboard/domain/services/product_cost_service.dart';
import 'package:mc_dashboard/domain/services/product_service.dart';

import 'package:mc_dashboard/domain/services/tariff_service.dart';
import 'package:mc_dashboard/domain/services/token_service.dart';
import 'package:mc_dashboard/domain/services/wb_api_content_service.dart';
import 'package:mc_dashboard/domain/services/wb_price_service.dart';
import 'package:mc_dashboard/domain/services/wb_products_service.dart';
import 'package:mc_dashboard/domain/services/wb_seller_warehouses_service.dart';
import 'package:mc_dashboard/domain/services/wb_stats_keywords_service.dart';
import 'package:mc_dashboard/domain/services/wb_stocks_service.dart';
import 'package:mc_dashboard/domain/services/wb_tariffs_service.dart';
import 'package:mc_dashboard/domain/services/wb_warehouse_stocks_service.dart';

import 'package:mc_dashboard/infrastructure/api/auth.dart';
import 'package:mc_dashboard/infrastructure/api/card_info_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/detailed_orders.dart';
import 'package:mc_dashboard/infrastructure/api/goods_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/kw_lemmas.dart';
import 'package:mc_dashboard/infrastructure/api/lemmatize.dart';
import 'package:mc_dashboard/infrastructure/api/normqueries.dart';
import 'package:mc_dashboard/infrastructure/api/orders.dart';
import 'package:mc_dashboard/infrastructure/api/ozon_price_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/ozon_product_info_api_client.dart';
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
import 'package:mc_dashboard/infrastructure/api/wb_price_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/wb_products_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/wb_seller_warehouses_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/wb_stats_keywords_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/wb_stocks_api_client.dart';
import 'package:mc_dashboard/infrastructure/api/wb_warehouse_stocks_api_client.dart';
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
import 'package:mc_dashboard/presentation/ozon_product_card_screen/ozon_product_card_screen.dart';
import 'package:mc_dashboard/presentation/ozon_product_card_screen/ozon_product_card_view_model.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_screen.dart';
import 'package:mc_dashboard/presentation/product_card_screen/product_card_view_model.dart';

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
import 'package:mc_dashboard/presentation/wb_stats_keywords_screen/wb_stats_keywords_screen.dart';
import 'package:mc_dashboard/presentation/wb_stats_keywords_screen/wb_stats_keywords_view_model.dart';

import 'package:mc_dashboard/routes/main_navigation.dart';
import 'package:provider/provider.dart';
import 'package:mc_dashboard/presentation/product_cards_container/product_cards_container_screen.dart';
import 'package:mc_dashboard/domain/services/ozon_products_service.dart';
import 'package:mc_dashboard/infrastructure/api/ozon_products_api_client.dart';
import 'package:mc_dashboard/presentation/ozon_product_cards_screen/ozon_product_cards_view_model.dart';
import 'package:mc_dashboard/domain/services/ozon_prices_service.dart';
import 'package:mc_dashboard/infrastructure/api/ozon_prices_api_client.dart';
import 'package:mc_dashboard/domain/services/ozon_fbo_stocks_service.dart';
import 'package:mc_dashboard/infrastructure/api/ozon_fbo_stocks_api_client.dart';
import 'package:mc_dashboard/domain/services/ozon_fbs_stocks_service.dart';
import 'package:mc_dashboard/infrastructure/api/ozon_fbs_stocks_api_client.dart';

import 'package:mc_dashboard/domain/services/wb_stocks_reports_service.dart';
import 'package:mc_dashboard/infrastructure/api/wb_stocks_reports_api_client.dart';

import 'package:mc_dashboard/domain/entities/product_cost_data_details.dart';
import 'package:mc_dashboard/domain/repositories/product_cost_details_repository.dart';
import 'package:mc_dashboard/domain/services/product_cost_details_service.dart';
import 'package:mc_dashboard/infrastructure/repositories/product_cost_details_repo.dart';
import 'package:mc_dashboard/infrastructure/services/product_cost_details_service.dart';

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
  ProductCostRepository _makeProductCostRepo() => const ProductCostRepository();
  McAuthRepo _makeLocalStorageRepo() => McAuthRepo();
  CardSourceRepo _makeCardSourceRepo() => const CardSourceRepo();
  SecureTokenStorageRepo _makeSecureTokenRepo() => SecureTokenStorageRepo();

  // Api clients ///////////////////////////////////////////////////////////////
  // Singleton instance since we need to cache data
  TariffsApiClient tariffsApiClient = TariffsApiClient.instance;
  WbProductsApiClient productsApiClient = WbProductsApiClient.instance;
  WarehousesApiClient whApiClient = WarehousesApiClient.instance;
  DetailedOrdersApiClient detailedOrdersApiClient =
      DetailedOrdersApiClient.instance;
  StocksApiClient stocksApiClient = StocksApiClient.instance;
  OrdersApiClient ordersApiClient = OrdersApiClient.instance;

  AuthApiClient _makeAuthApiClient() => const AuthApiClient();
  ProductsApiClient _makeProductSource() => const ProductsApiClient();
  WbGoodsApiClient _makeWbGoodsApiClient() => const WbGoodsApiClient();
  WbPriceApiServiceApiClient _makeWbPriceApiServiceApiClient() =>
      const WbPriceApiClient();
  WbStatsKeywordsApiClient _makeWbStatsKeywordsApiClient() =>
      const WbStatsKeywordsApiClient();
  WbSellerWarehousesApiClient _makeWbSellerWarehousesApiClient() =>
      const WbSellerWarehousesApiClient();
  WbStocksApiClient _makeWbStocksApiClient() => const WbStocksApiClient();
  OzonProductsApiClient _makeOzonProductsApiClient() =>
      const OzonProductsApiClient();
  OzonPricesApiClient _makeOzonPricesApiClient() => const OzonPricesApiClient();
  OzonFboStocksApiClient _makeOzonFboStocksApiClient() =>
      const OzonFboStocksApiClient();
  OzonFbsStocksApiClient _makeOzonFbsStocksApiClient() =>
      const OzonFbsStocksApiClient();

  WbWarehouseStocksApiClient _makeWbWarehouseStocksApiClient() =>
      const WbWarehouseStocksApiClient();

  OzonProductInfoApiClient _makeOzonProductInfoApiClient() =>
      const OzonProductInfoApiClient();

  WbStocksReportsApiClient _makeWbStocksReportsApiClient() =>
      const WbStocksReportsApiClient();

  OzonPriceApiClient _makeOzonPriceApiClient() => const OzonPriceApiClient();
  // Services //////////////////////////////////////////////////////////////////
  // Why singleton? This is a workaround . Because we need to fetch subjects summary only once
  // despite it is used in multiple screens simultaneously when app is loading
  // (choose niche, subject products, empty subjects)
  final SubjectsSummaryService _makeSubjectsSummaryService =
      SubjectsSummaryService.instance;
  DetailedOrdersService _makeDetailedOrdersService() =>
      DetailedOrdersService(detailedOrdersApiClient: detailedOrdersApiClient);

  StocksService _makeStocksService() =>
      StocksService(stocksApiClient: stocksApiClient);

  OrderService _makeOrdersService() =>
      OrderService(ordersApiClient: ordersApiClient);

  WhService _makeWhService() => WhService(whApiClient: whApiClient);

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

  WbStocksService _makeWbStocksService() => WbStocksService(
        apiClient: _makeWbStocksApiClient(),
        wbTokenRepo: _makeSecureTokenRepo(),
      );

  OzonProductInfoService _makeOzonProductInfoService() =>
      OzonProductInfoService(
          apiClient: _makeOzonProductInfoApiClient(),
          tokenRepo: _makeSecureTokenRepo());

  TinkoffPaymentService _makeTinkoffPaymentService() => TinkoffPaymentService();

  TariffsServiceImpl _makeTariffsService() =>
      TariffsServiceImpl(apiClient: tariffsApiClient);

  WbProductsServiceImpl _makeWbProductsService() =>
      WbProductsServiceImpl(apiClient: productsApiClient);
  TokenService _makeTokenService() =>
      TokenService(tokenStorage: _makeSecureTokenRepo());

  ProductCostService _makeProductCostService() => ProductCostService(
        storage: _makeProductCostRepo(),
      );

  final wbTariffsService = WbTariffsService();
  WbApiContentService _makeWbApiContentService() => WbApiContentService(
        apiClient: WbContentApiClient(),
        wbTokenRepo: _makeSecureTokenRepo(),
      );

  ApiProductService _makeApiProductService() => ApiProductService(
        productsApiClient: _makeProductSource(),
      );

  CardInfoService _makeCardInfoService() => CardInfoService(
        apiClient: CardInfoApiClient(),
      );

  ProductService _makeProductService() =>
      ProductService(productSource: _makeCardSourceRepo());

  WbGoodsService _makeWbGoodsService() => WbGoodsService(
        apiClient: _makeWbGoodsApiClient(),
        wbTokenRepo: _makeSecureTokenRepo(),
      );

  WbApiPriceService _makeWbPriceService() => WbApiPriceService(
        apiClient: _makeWbPriceApiServiceApiClient(),
        wbTokenRepo: _makeSecureTokenRepo(),
      );
  WbStatsKeywordsService _makeWbStatsKeywordsService() =>
      WbStatsKeywordsService(
        apiClient: _makeWbStatsKeywordsApiClient(),
        wbTokenRepo: _makeSecureTokenRepo(),
      );

  WbWarehouseStocksService _makeWbWarehouseStocksService() =>
      WbWarehouseStocksService(
          apiClient: _makeWbWarehouseStocksApiClient(),
          wbTokenRepo: _makeSecureTokenRepo());

  WbSellerWarehousesService _makeWbSellerWarehousesService() =>
      WbSellerWarehousesService(
        apiClient: _makeWbSellerWarehousesApiClient(),
        wbTokenRepo: _makeSecureTokenRepo(),
      );

  OzonProductsService _makeOzonProductsService() => OzonProductsService(
        apiClient: _makeOzonProductsApiClient(),
        tokenRepo: _makeSecureTokenRepo(),
      );

  WbStocksReportsService _makeWbStocksReportsService() =>
      WbStocksReportsService(
        apiClient: _makeWbStocksReportsApiClient(),
        wbTokenRepo: _makeSecureTokenRepo(),
      );

  OzonPriceService _makeOzonPriceService() => OzonPriceService(
        apiClient: _makeOzonPriceApiClient(),
        tokenRepository: _makeSecureTokenRepo(),
      );

  // Репозиторий для деталей расходов
  ProductCostDetailsRepository _makeProductCostDetailsRepository() {
    return const ProductCostDetailsRepo();
  }

  // Сервис для деталей расходов
  ProductCostDetailsService _makeProductCostDetailsService() {
    return ProductCostDetailsServiceImpl(_makeProductCostDetailsRepository());
  }

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
        apiKeyService: _makeTokenService(),
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
      AddCardsViewModel(cardsService: _makeProductService(), context: context);

  ProductDetailViewModel _makeProductDetailViewModel(
      BuildContext context, ProductData product) {
    return ProductDetailViewModel(
      wbApiContentService: _makeWbApiContentService(),
      product: product,
      productSource: _makeApiProductService(),
      cardInfoService: _makeCardInfoService(),
      context: context,
    );
  }

  ProductCardsViewModel _makeProductCardsViewModel(BuildContext context) {
    return ProductCardsViewModel(
      wbApiContentService: _makeWbApiContentService(),
      wbProductCostService: _makeProductCostService(),
      wbTariffsService: wbTariffsService,
      warehouseStocksService: _makeWbWarehouseStocksService(),
      goodsService: _makeWbGoodsService(),
      sellerWarehousesService: _makeWbSellerWarehousesService(),
      wbStocksService: _makeWbStocksService(),
      wbStocksReportsService: _makeWbStocksReportsService(),
      context: context,
    );
  }

  ProductCardViewModel _makeProductCardViewModel(
    BuildContext context,
    Map<String, dynamic> arguments,
  ) {
    final imtID = arguments['imtID'] as int;
    final nmID = arguments['nmID'] as int;
    final allImtIDs = arguments['allImtIDs'] as List<int>;
    final allNmIDs = arguments['allNmIDs'] as List<int>;
    final currentIndex = arguments['currentIndex'] as int;

    return ProductCardViewModel(
      contentApiService: _makeWbApiContentService(),
      tariffsService: wbTariffsService,
      productCostService: _makeProductCostService(),
      wbPriceService: _makeWbPriceService(),
      goodsService: _makeWbGoodsService(),
      costDetailsService: _makeProductCostDetailsService(),
      imtID: imtID,
      nmID: nmID,
      context: context,
      allImtIDs: allImtIDs,
      allNmIDs: allNmIDs,
      currentIndex: currentIndex,
    );
  }

  ProductCostImportViewModel _makeProductCostImportViewModel(
      BuildContext context) {
    return ProductCostImportViewModel(
      productCostService: _makeProductCostService(),
      productCardsService: _makeWbApiContentService(),
      ozonProductsService: _makeOzonProductsService(),
      context: context,
    );
  }

  TokensViewModel _makeTokensViewModel(BuildContext context) {
    return TokensViewModel(
      tokensService: _makeTokenService(),
      context: context,
    );
  }

  MarketViewModel _makeMarketViewModel(BuildContext context) {
    return MarketViewModel(
      tokensService: _makeTokenService(),
      context: context,
    );
  }

  WbStatsKeywordsViewModel _makeWbStatsKeywordsViewModel(BuildContext context) {
    return WbStatsKeywordsViewModel(
      wbStatsKeywordsService: _makeWbStatsKeywordsService(),
      context: context,
    );
  }

  OzonProductCardsViewModel _makeOzonProductCardsViewModel(
      BuildContext context) {
    return OzonProductCardsViewModel(
      productsService: _makeOzonProductsService(),
      pricesService: OzonPricesServiceImpl(
          apiClient: _makeOzonPricesApiClient(),
          tokenRepo: _makeSecureTokenRepo()),
      fboStocksService: OzonFboStocksService(
          apiClient: _makeOzonFboStocksApiClient(),
          tokenRepo: _makeSecureTokenRepo()),
      fbsStocksService: OzonFbsStocksServiceImpl(
          apiClient: _makeOzonFbsStocksApiClient(),
          tokenRepo: _makeSecureTokenRepo()),
      productInfoService: _makeOzonProductInfoService(),
      productCostService: _makeProductCostService(),
      wbViewModel: _makeProductCardsViewModel(context),
      context: context,
    );
  }

  OzonProductCardViewModel _makeOzonProductCardViewModel(
      BuildContext context, int productId, String offerId, int sku) {
    return OzonProductCardViewModel(
      context: context,
      productsService: _makeOzonProductsService(),
      pricesService: OzonPricesServiceImpl(
          apiClient: _makeOzonPricesApiClient(),
          tokenRepo: _makeSecureTokenRepo()),
      productInfoService: _makeOzonProductInfoService(),
      productCostService: _makeProductCostService(),
      ozonPriceService: _makeOzonPriceService(),
      offerId: offerId,
      sku: sku,
      productId: productId,
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

  @override
  Widget makeWbStatsKeywordsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeWbStatsKeywordsViewModel(
        context,
      ),
      child: const WbStatsKeywordsScreen(),
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
  Widget makeProductDetailScreen({required ProductData product}) {
    return ChangeNotifierProvider(
      create: (context) =>
          _diContainer._makeProductDetailViewModel(context, product),
      child: ProductDetailScreen(product: product),
    );
  }

  @override
  Widget makeAddCardsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeAddCardsViewModel(context),
      child: const AddCardsScreen(),
    );
  }

  @override
  Widget makeProductCardScreen(
      {required int imtID,
      required int nmID,
      List<int>? allImtIDs,
      List<int>? allNmIDs,
      int currentIndex = -1}) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeProductCardViewModel(context, {
        'imtID': imtID,
        'nmID': nmID,
        'allImtIDs': allImtIDs,
        'allNmIDs': allNmIDs,
        'currentIndex': currentIndex
      }),
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

  @override
  Widget makeProductCardsContainerScreen() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => _diContainer._makeProductCardsViewModel(context),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              _diContainer._makeOzonProductCardsViewModel(context),
        ),
      ],
      child: const ProductCardsContainerScreen(),
    );
  }

  @override
  Widget makeOzonProductCardScreen({
    required int productId,
    required String offerId,
    required int sku,
  }) {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeOzonProductCardViewModel(
        context,
        productId,
        offerId,
        sku,
      ),
      child: const OzonProductCardScreen(),
    );
  }
}

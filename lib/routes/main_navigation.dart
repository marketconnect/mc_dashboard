import 'package:flutter/material.dart';
import 'package:mc_dashboard/domain/entities/product.dart';

import 'package:mc_dashboard/presentation/app/app.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';

abstract class ScreenFactory {
  Widget makeMarketScreen();
  Widget makeChoosingNicheScreen(
      {required void Function(int subjectId, String subjectName)
          onNavigateToSubjectProducts});
  Widget makeProductDetailScreen({required Product product});
  Widget makeAddCardsScreen();

  Widget makeProductCardsContainerScreen();
  Widget makeProductCardScreen({required int imtID, required int nmID});
  Widget makeProductCostImportScreen();
  Widget makeTokensScreen();
  Widget makeSubjectProductsScreen({
    required int subjectId,
    required String subjectName,
    required void Function({
      required String routeName,
      Map<String, dynamic>? params,
    }) onNavigateTo,
    required void Function(List<String> productIds) onSaveProductsToTrack,
  });
  Widget makeEmptySubjectProductsScreen();

  Widget makeEmptyProductScreen();
  Widget makeProductScreen({
    required int productId,
    required int productPrice,
  });

  Widget makeSeoRequestsExtendScreen({
    required List<int> productIds,
    required List<String> characteristics,
  });

  Widget makeSubscriptionScreen();

  Widget makeLoginScreen();

  Widget makeWbStatsKeywordsScreen();

  Widget makeOzonProductCardScreen({
    required int productId,
    required String offerId,
    required int sku,
  });
}

class MainNavigation implements AppNavigation {
  final ScreenFactory screenFactory;

  MainNavigation(this.screenFactory);

  @override
  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.home:
        return MaterialPageRoute(
          builder: (context) => MainScreen(
            screenFactory: screenFactory,
          ),
        );
      case MainNavigationRouteNames.marketScreen:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeMarketScreen(),
        );
      case MainNavigationRouteNames.login:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeLoginScreen(),
        );

      case MainNavigationRouteNames.productDetail:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeProductDetailScreen(
            product: settings.arguments as Product,
          ),
        );
      case MainNavigationRouteNames.choosingNicheScreen:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeChoosingNicheScreen(
            onNavigateToSubjectProducts: (int subjectId, String subjectName) {
              Navigator.pushReplacementNamed(
                context,
                MainNavigationRouteNames.subjectProductsScreen,
                arguments: {'subjectId': subjectId, 'subjectName': subjectName},
              );
            },
          ),
        );
      case MainNavigationRouteNames.emptyProductScreen:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeEmptyProductScreen(),
        );

      case MainNavigationRouteNames.emptySubjectsScreen:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeEmptySubjectProductsScreen(),
        );

      case MainNavigationRouteNames.subjectProductsScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeSubjectProductsScreen(
            subjectId: args['subjectId'] as int,
            subjectName: args['subjectName'] as String,
            onSaveProductsToTrack: (List<String> productIds) {
              // Реализуйте сохранение, если нужно.
            },
            onNavigateTo: (
                {required String routeName, Map<String, dynamic>? params}) {
              Navigator.pushReplacementNamed(context, routeName,
                  arguments: params);
            },
          ),
        );
      case MainNavigationRouteNames.productScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeProductScreen(
            productId: args['productId'] as int,
            productPrice: args['productPrice'] as int,
          ),
        );
      case MainNavigationRouteNames.seoRequestsExtend:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeSeoRequestsExtendScreen(
            productIds: args['productIds'] as List<int>,
            characteristics: args['characteristics'] as List<String>,
          ),
        );
      case MainNavigationRouteNames.subscriptionScreen:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeSubscriptionScreen(),
        );
      case MainNavigationRouteNames.addCards:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeAddCardsScreen(),
        );

      case MainNavigationRouteNames.productCardsContainer:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeProductCardsContainerScreen(),
        );

      case MainNavigationRouteNames.productCard:
        final args = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (context) => screenFactory.makeProductCardScreen(
            imtID: args['imtID'] as int,
            nmID: args['nmID'] as int,
          ),
        );

      case MainNavigationRouteNames.productCostImportScreen:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeProductCostImportScreen(),
        );
      case MainNavigationRouteNames.wbStatsKeywordsScreen:
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeWbStatsKeywordsScreen(),
        );

      case MainNavigationRouteNames.ozonProductCardScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => screenFactory.makeOzonProductCardScreen(
            productId: args['productId'] as int,
            offerId: args['offerId'] as String,
            sku: args['sku'] as int,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => MainScreen(
            screenFactory: screenFactory,
          ),
        );
    }
  }
}

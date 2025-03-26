// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:mc_dashboard/infrastructure/repositories/local_storage.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';
import 'package:mc_dashboard/routes/main_navigation.dart';

import 'package:mc_dashboard/theme/color_schemes.dart';

import 'package:mc_dashboard/widgets/logo.dart';
import 'package:mc_dashboard/widgets/speed_dial_menu.dart';
import 'package:provider/provider.dart';

abstract class AppNavigation {
  Route<Object> onGenerateRoute(RouteSettings settings);
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkTheme = McAuthRepo.getTheme();

  bool get isDarkTheme => _isDarkTheme;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    McAuthRepo.setTheme(_isDarkTheme);
    notifyListeners();
  }
}

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}

class App extends StatelessWidget {
  final ScreenFactory screenFactory;

  const App({super.key, required this.screenFactory});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<NavigationProvider>(
            create: (_) => NavigationProvider()),
      ],
      child: Consumer2<ThemeProvider, NavigationProvider>(
        builder: (context, themeProvider, navigationProvider, child) {
          return MaterialApp(
            title: 'MarketConnect',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lightColorScheme,
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkColorScheme,
            ),
            themeMode:
                themeProvider.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData) {
                  final authToken = McAuthRepo.getTokenStatic();
                  if (authToken != null && authToken.isNotEmpty) {
                    return MainScreen(screenFactory: screenFactory);
                  }
                }
                return screenFactory.makeLoginScreen();
              },
            ),
            onGenerateRoute: MainNavigation(screenFactory).onGenerateRoute,
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final ScreenFactory screenFactory;

  const MainScreen({super.key, required this.screenFactory});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      widget.screenFactory.makeMarketScreen(),
      widget.screenFactory.makeChoosingNicheScreen(
        onNavigateToSubjectProducts: (int subjectId, String subjectName) {
          Navigator.pushReplacementNamed(
            context,
            MainNavigationRouteNames.subjectProductsScreen,
            arguments: {'subjectId': subjectId, 'subjectName': subjectName},
          );
        },
      ),
      widget.screenFactory.makeSubscriptionScreen(),
      widget.screenFactory.makeTokensScreen(),
    ];
  }

  final List<SpeedDialOption> choosingNicheSpeedDialOptions = [
    SpeedDialOption(
      label: 'Поиск по артикулу WB',
      icon: Icons.search,
      route: MainNavigationRouteNames.emptyProductScreen,
    ),
    SpeedDialOption(
        label: 'Поиск по названию категории',
        icon: Icons.store,
        route: MainNavigationRouteNames.emptySubjectsScreen),
  ];

  final List<SpeedDialOption> marketScreenSpeedDialOptions = [
    SpeedDialOption(
      label: 'Wildberries',
      icon: Icons.shopping_bag,
      url: 'https://www.wildberries.ru/',
    ),
    SpeedDialOption(
      label: 'Wildberries Seller',
      icon: Icons.store,
      url: 'https://seller.wildberries.ru/',
    ),
    SpeedDialOption(
      label: 'Ozon',
      icon: Icons.shopping_cart,
      url: 'https://www.ozon.ru/',
    ),
    SpeedDialOption(
      label: 'Ozon Seller',
      icon: Icons.business,
      url: 'https://seller.ozon.ru/app/dashboard/main',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final navigationProvider = Provider.of<NavigationProvider>(context);
    bool isMobile = Responsive.isMobile(context);
    return Scaffold(
      floatingActionButton: SpeedDialMenu(
        options: navigationProvider.selectedIndex == 0
            ? marketScreenSpeedDialOptions
            : choosingNicheSpeedDialOptions,
      ),
      appBar: isMobile
          ? AppBar(
              actions: [
                IconButton(
                  icon: Icon(
                    themeProvider.isDarkTheme
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  onPressed:
                      themeProvider.toggleTheme, // Теперь меняем тему прямо тут
                ),
              ],
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            )
          : null,
      drawer: isMobile ? Drawer(child: _buildMobileSideMenu(context)) : null,
      body: isMobile ? _buildMobileBody() : _buildDesktopBody(),
    );
  }

  Widget _buildDesktopBody() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);
    return Row(
      children: [
        // Боковая панель
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border(
              right: BorderSide(
                width: 0.5,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(51),
              ),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Logo(theme: Theme.of(context)),
              const SizedBox(height: 40),
              Expanded(
                child: NavigationRail(
                  selectedIndex: navigationProvider.selectedIndex,
                  onDestinationSelected: (int index) {
                    navigationProvider.setIndex(index);
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      selectedIcon: Icon(Icons.home_filled,
                          color: Theme.of(context).colorScheme.onPrimary),
                      label: Text('Главная'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.leaderboard),
                      selectedIcon: Icon(Icons.leaderboard_outlined,
                          color: Theme.of(context).colorScheme.onPrimary),
                      label: Text(
                        'Обзор',
                      ),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.card_travel_outlined),
                      selectedIcon: Icon(Icons.card_travel,
                          color: Theme.of(context).colorScheme.onPrimary),
                      label: Text('Подписка'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.security_outlined),
                      selectedIcon: Icon(Icons.security,
                          color: Theme.of(context).colorScheme.onPrimary),
                      label: Text('Токены'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: Icon(
                    themeProvider.isDarkTheme
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed:
                      themeProvider.toggleTheme, // Теперь меняем тему прямо тут
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
            child: _screens[navigationProvider.selectedIndex],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileBody() {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
      child: _screens[navigationProvider.selectedIndex],
    );
  }

  Widget _buildMobileSideMenu(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final navigationProvider = Provider.of<NavigationProvider>(context);
    return ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Logo(theme: Theme.of(context)), // Логотип для мобильной версии
        ),
        ListTile(
          leading: Icon(
            themeProvider.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
          ),
          title: const Text('Переключить тему'),
          onTap: themeProvider.toggleTheme, // Теперь меняем тему прямо тут
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Главная'),
          selected: navigationProvider.selectedIndex == 0,
          onTap: () {
            navigationProvider.setIndex(0);
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.shopping_cart),
          title: const Text('Товары'),
          selected: navigationProvider.selectedIndex == 1,
          onTap: () {
            navigationProvider.setIndex(1);
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.shopping_cart),
          title: const Text('Карточки'),
          selected: navigationProvider.selectedIndex == 2,
          onTap: () {
            navigationProvider.setIndex(2);
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.upload),
          title: const Text('Загрузить'),
          selected: navigationProvider.selectedIndex == 3,
          onTap: () {
            navigationProvider.setIndex(3);
            Navigator.of(context).pop();
          },
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Токены'),
          selected: navigationProvider.selectedIndex == 4,
          onTap: () {
            navigationProvider.setIndex(4);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

/// Утилита для определения мобильных устройств.
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 900;
}

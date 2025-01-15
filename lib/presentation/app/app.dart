// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:mc_dashboard/core/config.dart';

import 'package:mc_dashboard/infrastructure/repositories/local_storage.dart';

import 'package:mc_dashboard/routes/main_navigation.dart';
import 'package:mc_dashboard/routes/main_navigation_route_names.dart';
import 'package:mc_dashboard/theme/text_theme.dart';
import 'package:mc_dashboard/theme/color_schemes.dart';
import 'package:mc_dashboard/theme/dialog_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class App extends StatefulWidget {
  final ScreenFactory screenFactory;

  const App({super.key, required this.screenFactory});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            final authToken = LocalStorageRepo.getTokenStatic();

            if (authToken != null && authToken.isNotEmpty) {
              return MainScreen(
                screenFactory: widget.screenFactory,
              );
            }
          }
          return widget.screenFactory.makeLoginScreen();
        });
  }
}

class MainScreen extends StatefulWidget {
  final ScreenFactory screenFactory;
  const MainScreen({
    super.key,
    required this.screenFactory,
  });

  @override
  // ignore: duplicate_ignore
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isDarkTheme = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarketConnect',
      theme: ThemeData(
        useMaterial3: true,
        dialogTheme: dialogTheme,
        textTheme: buildAdaptiveTextTheme(
          context,
          baseTextTheme: ThemeData.light().textTheme,
        ),
        colorScheme: lightColorScheme,
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          dialogTheme: dialogTheme,
          textTheme: buildAdaptiveTextTheme(
            context,
            baseTextTheme: ThemeData.dark()
                .textTheme, // Используем тему для тёмного режима
          ),
          fontFamily: GoogleFonts.roboto().fontFamily),
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: _Scaffold(
        isDarkTheme: _isDarkTheme,
        screenFactory: widget.screenFactory,
        onThemeChanged: (value) {
          setState(() {
            _isDarkTheme = value;
          });
        },
      ),
    );
  }
}

class _Scaffold extends StatefulWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;
  final ScreenFactory screenFactory;
  const _Scaffold({
    required this.isDarkTheme,
    required this.onThemeChanged,
    required this.screenFactory,
  });

  @override
  State<_Scaffold> createState() => __ScaffoldState();
}

class __ScaffoldState extends State<_Scaffold> {
  List<ExpansionTileController> _controllers = [];
  int _selectedSectionIndex = 0;
  int? _selectedSubsectionIndex; // Stores the selected subsection index

  int?
      _currentSubjectId; // Stores the selected subject ID (for SubjectProductsScreen) look _buildBodyContent
  String?
      _currentSubjectName; // Stores the selected subject Name (for SubjectProductsScreen) look _buildBodyContent

  int? _currentProductId; // Stores the selected product ID (for ProductScreen)
  int?
      _currentProductPrice; // Stores the selected product price (for ProductScreen)

  List<int>?
      _selectedProductIds; // List to store selected product IDs for SeoRequestsExtendScreen
  List<String> _savedProductIds =
      []; // List to store saved to track product IDs

  List<String> _keyPhrases = [];

  final List<_Section> sections = [
    _Section(
      title: 'Анализ рынка',
      icon: Icons.leaderboard,
      subsections: [
        _Subsection(title: 'Выбор ниши'),
        _Subsection(title: 'Категория'),
        _Subsection(title: 'Товары'),
        // _Subsection(title: 'Бренды'),
      ],
    ),
    _Section(title: 'SEO', icon: Icons.query_stats, subsections: [
      _Subsection(title: 'Расширение запросов'),
    ]),
    _Section(title: 'Рассылка', icon: Icons.mail, subsections: []),
    // _Section(title: 'Поиск по SKU', icon: Icons.search, subsections: []),
    // _Section(        title: 'Настройка рассылок', icon: Icons.settings, subsections: []),
    // Section(title: 'Настройка', icon: Icons.settings, subsections: []),
    // Section(title: 'Помощь', icon: Icons.help, subsections: []),
    _Section(title: 'Подписка', icon: Icons.lock_open, subsections: []),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      sections.length,
      (_) => ExpansionTileController(),
    );
  }

  void _onNavigate(
    String routeName,
  ) {
    switch (routeName) {
      case MainNavigationRouteNames.choosingNicheScreen:
        _onNavigateToChoosingNicheScreen();
        break;
      case MainNavigationRouteNames.productScreen:
        _onNavigateToProductScreen();
        break;
      case MainNavigationRouteNames.seoRequestsExtend:
        _onNavigateToSeoRequestsExtendScreen();
        break;
      case MainNavigationRouteNames.emptySubjectsScreen:
        _onNavigateToEmptySubjectScreen();
        break;
      case MainNavigationRouteNames.emptyProductScreen:
        _onNavigateToEmptyProductScreen();
        break;
      case MainNavigationRouteNames.subjectProductsScreen:
        _onNavigateToSubjectProductsScreen();
        break;
      case MainNavigationRouteNames.subscriptionScreen:
        _onNavigateToSubscriptionScreen();
        break;
      default:
        throw Exception('Unknown route: $routeName');
    }
  }

  void _onNavigateToChoosingNicheScreen() {
    setState(() {
      _selectedSectionIndex = 0;
      _selectedSubsectionIndex = 0;
    });
  }

  void _onNavigateToEmptySubjectScreen() {
    setState(() {
      _currentSubjectId = null;
      _selectedSectionIndex = 0;
      _selectedSubsectionIndex = 1;
    });
  }

  void _onNavigateToSubjectProductsScreen() {
    setState(() {
      _selectedSectionIndex = 0;
      _selectedSubsectionIndex = 1;
    });
  }

  void _onNavigateToProductScreen() {
    setState(() {
      _selectedSectionIndex = 0;
      _selectedSubsectionIndex = 2;
    });
  }

  void _onNavigateToEmptyProductScreen() {
    setState(() {
      _currentProductId = null;
      _selectedSectionIndex = 0;
      _selectedSubsectionIndex = 2;
    });
  }

  void _onNavigateToSeoRequestsExtendScreen() {
    setState(() {
      _selectedSectionIndex = 1;
      _selectedSubsectionIndex = 0;
      _controllers[1].expand();
    });
  }

  void _onNavigateToSubscriptionScreen() {
    setState(() {
      _selectedSectionIndex = 3;
      _selectedSubsectionIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: Responsive.isMobile(context)
          ? AppBar(
              scrolledUnderElevation: 2,
              shadowColor: Colors.black,
              surfaceTintColor: Colors.transparent,
            )
          : null,
      drawer: Responsive.isMobile(context)
          ? Drawer(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: buildSideMenu())
          : null,
      body: Row(
        children: [
          if (!Responsive.isMobile(context))
            Container(
              // Side Menu =============================================
              width: AppConfig.sideMenuWidth,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  right: BorderSide(
                    width: 0.5,
                    color: theme.colorScheme.onSurface
                        .withAlpha((0.2 * 255).toInt()),
                  ),
                ),
              ),
              child: buildSideMenu(),
            ),
          Expanded(
            // Body =====================================================
            child: Container(
              padding: const EdgeInsets.all(8),
              child: IndexedStack(
                index: _getCurrentIndex(),
                children: [
                  widget.screenFactory.makeChoosingNicheScreen(
                    // 0 ChoosingNicheScreen /////////////////////////// ChoosingNicheScreen
                    // 0 ChoosingNicheScreen
                    onNavigateToSubjectProducts:
                        (int subjectId, String subjectName) {
                      setState(() {
                        _selectedSectionIndex = 0;
                        _selectedSubsectionIndex = 1;
                        _currentSubjectId = subjectId;
                        _currentSubjectName = subjectName;
                      });
                    },
                  ),
                  (_currentSubjectId != null &&
                          _currentSubjectName !=
                              null) // 1 SubjectProducts //////////////////////////////////////// SubjectProductsScreen 0
                      ? KeyedSubtree(
                          key: ValueKey(_currentSubjectId),
                          child: widget.screenFactory.makeSubjectProductsScreen(
                              subjectId: _currentSubjectId!,
                              subjectName: _currentSubjectName!,
                              onSaveProductsToTrack: (List<String> productIds) {
                                setState(() {
                                  _savedProductIds = List.from(_savedProductIds)
                                    ..addAll(productIds);
                                });
                              },
                              onNavigateTo: ({
                                required String routeName,
                                Map<String, dynamic>? params,
                              }) {
                                if (params != null) {
                                  if (params.containsKey('subjectId')) {
                                    _currentSubjectId = params['subjectId'];
                                  }
                                  if (params.containsKey('subjectName')) {
                                    _currentSubjectName = params['subjectName'];
                                  }
                                  if (params.containsKey('productId')) {
                                    _currentProductId = params['productId'];
                                  }
                                  if (params.containsKey('productPrice')) {
                                    _currentProductPrice =
                                        params['productPrice'];
                                  }
                                  if (params.containsKey('productIds')) {
                                    _selectedProductIds = params['productIds'];
                                  }
                                }
                                _onNavigate(routeName);
                                // if (routeName ==
                                //     MainNavigationRouteNames
                                //         .seoRequestsExtend) {
                                //   _onNavigateToSeoRequestsExtendScreen();
                                // } else if (routeName ==
                                //     MainNavigationRouteNames.productScreen) {
                                //   _onNavigateToProductScreen();
                                // } else if (routeName ==
                                //     MainNavigationRouteNames
                                //         .choosingNicheScreen) {
                                //   _onNavigateToChoosingNicheScreen();
                                // } else if (routeName ==
                                //     MainNavigationRouteNames
                                //         .emptySubjectsScreen) {
                                //   _currentSubjectId = null;
                                //   _currentSubjectName = null;
                                //   _onNavigateToEmptySubjectScreen();
                                // } else if (routeName ==
                                //     MainNavigationRouteNames
                                //         .subscriptionScreen) {
                                //   _onNavigateToSubscriptionScreen();
                                // }
                              }),
                        )
                      : widget.screenFactory.makeEmptySubjectProductsScreen(
                          // 1 SubjectProducts //////////////////////////////////////// EmptySubjectProducts 1

                          onNavigateTo: ({
                            required String routeName,
                            Map<String, dynamic>? params,
                          }) {
                            if (params != null) {
                              if (params.containsKey('subjectId')) {
                                _currentSubjectId = params['subjectId'];
                              }
                              if (params.containsKey('subjectName')) {
                                _currentSubjectName = params['subjectName'];
                              }
                            }
                            _onNavigate(routeName);
                            //   if (routeName ==
                            //       MainNavigationRouteNames
                            //           .subjectProductsScreen) {
                            //     _onNavigateToSubjectProductsScreen();

                            //     _controllers[1].expand();
                            //   } else if (routeName ==
                            //       MainNavigationRouteNames.choosingNicheScreen) {
                            //     _onNavigateToChoosingNicheScreen();
                            //   }
                          },
                        ),

                  (_currentProductId != null &&
                          _currentProductPrice !=
                              null) // 2 Product //////////////////////////////////////// ProductScreen 0
                      ? KeyedSubtree(
                          key: ValueKey(_currentProductId),
                          child: widget.screenFactory.makeProductScreen(
                            productId: _currentProductId!,
                            productPrice: _currentProductPrice!,
                            onNavigateTo: ({
                              required String routeName,
                              Map<String, dynamic>? params,
                            }) {
                              if (params != null) {
                                if (params.containsKey('productId')) {
                                  _currentProductId = params['productId'];
                                }
                                if (params.containsKey('productPrice')) {
                                  _currentProductPrice = params['productPrice'];
                                }
                              }
                              _onNavigate(routeName);
                            },
                            onSaveKeyPhrasesToTrack: (List<String> keyPhrases) {
                              setState(() {
                                _keyPhrases = List.from(_keyPhrases)
                                  ..addAll(keyPhrases);
                              });
                            },
                          ),
                        )
                      : widget.screenFactory.makeEmptyProductScreen(
                          // 2 Product ////////////////////////// EmptyProductScreen
                          onNavigateTo: ({
                          required String routeName,
                          Map<String, dynamic>? params,
                        }) {
                          if (params != null) {
                            if (params.containsKey('productId')) {
                              _currentProductId = params['productId'];
                            }
                            if (params.containsKey('productPrice')) {
                              _currentProductPrice = params['productPrice'];
                            }
                          }
                          _onNavigate(routeName);
                        }),
                  (_selectedProductIds != null)
                      ? KeyedSubtree(
                          key: ValueKey(_selectedProductIds.hashCode),
                          child: widget.screenFactory.makeSeoRequestsExtendScreen(
                              // 3 SeoRequestsExtendScreen //////////////////////////
                              productIds: _selectedProductIds!,
                              onNavigateTo: ({
                                required String routeName,
                                Map<String, dynamic>? params,
                              }) {
                                _onNavigate(routeName);
                              }),
                        )
                      : Center(
                          child: Text(
                            'Вы не выбрали товары',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                  KeyedSubtree(
                      key: ValueKey(
                          _savedProductIds.hashCode + _keyPhrases.hashCode),
                      child: widget.screenFactory.makeMailingScreen(
                          onNavigateTo: ({
                        required String routeName,
                        Map<String, dynamic>? params,
                      }) {
                        _onNavigate(routeName);
                      })), // MailingSettings
                  widget.screenFactory.makeSubscriptionScreen(), // Subscription
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex() {
    if (_selectedSectionIndex == 0 && _selectedSubsectionIndex == 1) {
      return 1;
    } else if (_selectedSectionIndex == 0 && _selectedSubsectionIndex == 2) {
      return 2;
    } else if (_selectedSectionIndex == 1 && _selectedSubsectionIndex == 0) {
      return 3;
    } else if (_selectedSectionIndex == 2) {
      return 4;
    } else if (_selectedSectionIndex == 3) {
      return 5;
    }
    return 0;
  }

  Widget buildSideMenu() {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    // link to google.com
                    launchUrl(Uri.parse('https://marketconnect.ru'));
                  },
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConfig.sideMenuWidth * 0.2,
                        vertical: AppConfig.sideMenuWidth * 0.1),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'M',
                              style: TextStyle(
                                fontSize: 24,
                                fontFamily:
                                    GoogleFonts.alikeAngular().fontFamily,
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ARKET',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: GoogleFonts.waitingForTheSunrise()
                                    .fontFamily,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 20,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 30),
                            child: Text(
                              'CONNECT',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: GoogleFonts.waitingForTheSunrise()
                                    .fontFamily,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _SideMenuDivider(theme: theme),
              ...sections.asMap().entries.map((entry) {
                int sectionIndex = entry.key;
                _Section section = entry.value;

                if (section.subsections.isEmpty) {
                  return ListTile(
                    leading: Icon(
                      section.icon,
                      size: 18,
                      color: sectionIndex == _selectedSectionIndex
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                    title: Text(section.title,
                        style: TextStyle(
                          color: sectionIndex == _selectedSectionIndex
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        )),
                    selected: _selectedSectionIndex == sectionIndex,
                    onTap: () {
                      // ROUTE /////////////////////////////////////////// ROUTE
                      setState(() {
                        _selectedSectionIndex = sectionIndex;
                        _selectedSubsectionIndex = null;
                      });
                      if (Responsive.isMobile(context)) Navigator.pop(context);
                    },
                  );
                } else {
                  return ExpansionTile(
                    controller: _controllers[sectionIndex],
                    leading: Icon(
                      section.icon,
                      size: 18,
                      color: sectionIndex == _selectedSectionIndex
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                    title: Text(section.title,
                        style: TextStyle(
                          color: sectionIndex == _selectedSectionIndex
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        )),
                    initiallyExpanded: _selectedSectionIndex == sectionIndex,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                    ),
                    collapsedShape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.zero),
                    ),
                    children:
                        section.subsections.asMap().entries.map((subEntry) {
                      int subIndex = subEntry.key;
                      _Subsection subsection = subEntry.value;

                      return ListTile(
                        selectedTileColor: theme.colorScheme.surfaceBright,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        title: Text(
                          subsection.title,
                          style: const TextStyle(fontSize: 14),
                        ),
                        selected: _selectedSectionIndex == sectionIndex &&
                            _selectedSubsectionIndex == subIndex,
                        onTap: () {
                          setState(() {
                            _selectedSectionIndex = sectionIndex;
                            _selectedSubsectionIndex = subIndex;
                          });
                          if (Responsive.isMobile(context)) {
                            Navigator.pop(context);
                          }
                        },
                      );
                    }).toList(),
                  );
                }
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                  value: widget.isDarkTheme,
                  onChanged: (a) => widget.onThemeChanged(!widget.isDarkTheme)),
              Icon(
                widget.isDarkTheme ? Icons.brightness_2 : Icons.wb_sunny,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SideMenuDivider extends StatelessWidget {
  const _SideMenuDivider({
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Divider(
        thickness: 0.5,
        color: theme.colorScheme.onSurface.withAlpha((0.2 * 255).toInt()),
      ),
    );
  }
}

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;
}

class _Section {
  final String title;
  final IconData icon;
  final List<_Subsection> subsections;

  _Section(
      {required this.title, required this.icon, required this.subsections});
}

class _Subsection {
  final String title;

  _Subsection({required this.title});
}

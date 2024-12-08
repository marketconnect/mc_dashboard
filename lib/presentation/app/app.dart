import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:mc_dashboard/core/config.dart';

import 'package:mc_dashboard/routes/main_navigation.dart';
import 'package:mc_dashboard/theme/text_theme.dart';
import 'package:mc_dashboard/theme/color_schemes.dart';
import 'package:mc_dashboard/theme/dialog_theme.dart';

class App extends StatefulWidget {
  final ScreenFactory screenFactory;

  const App({Key? key, required this.screenFactory}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        dialogTheme: dialogTheme,
        textTheme: buildAdaptiveTextTheme(
          context,
          baseTextTheme:
              ThemeData.light().textTheme, // Используем текущую тему как основу
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
      home: MainScreen(
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

class Section {
  final String title;
  final IconData icon;
  final List<Subsection> subsections;

  Section({required this.title, required this.icon, required this.subsections});
}

class Subsection {
  final String title;

  Subsection({required this.title});
}

class MainScreen extends StatefulWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onThemeChanged;
  final ScreenFactory screenFactory;
  const MainScreen({
    super.key,
    required this.isDarkTheme,
    required this.onThemeChanged,
    required this.screenFactory,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedSectionIndex = 0;
  int? _selectedSubsectionIndex;

  final List<Section> sections = [
    Section(
      title: 'Анализ рынка',
      icon: Icons.leaderboard,
      subsections: [
        Subsection(title: 'Выбор ниши'),
        Subsection(title: 'Категории'),
        Subsection(title: 'Продавцы'),
        Subsection(title: 'Бренды'),
      ],
    ),
    Section(
      title: 'Рейтинги',
      icon: Icons.star,
      subsections: [
        Subsection(title: 'Рейтинг брендов'),
        Subsection(title: 'Рейтинг продавцов'),
      ],
    ),
    Section(title: 'Поиск по SKU', icon: Icons.search, subsections: []),
    Section(title: 'SEO', icon: Icons.query_stats, subsections: []),
    Section(title: 'Настройка рассылок', icon: Icons.settings, subsections: []),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: Responsive.isMobile(context)
          ? AppBar(
              elevation: 0,
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
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                  ),
                ),
              ),
              child: buildSideMenu(),
            ),
          Expanded(
            // Body =====================================================
            child: Container(
              padding: const EdgeInsets.all(8),
              child: _buildBodyContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    // Если выбрана "Выбор ниши" (0-й раздел, 0-й подраздел)
    if (_selectedSectionIndex == 0 && _selectedSubsectionIndex == 0) {
      // Создаем экран через фабрику, которая уже внутри себя
      // оборачивает экран в ChangeNotifierProvider с ViewModel
      return widget.screenFactory.makeChoosingNicheScreen();
    }

    if (_selectedSubsectionIndex != null) {
      return Text(
        'Раздел: ${sections[_selectedSectionIndex].title} > ${sections[_selectedSectionIndex].subsections[_selectedSubsectionIndex!].title}',
        style: const TextStyle(fontSize: 24),
      );
    } else {
      return Text(
        'Раздел: ${sections[_selectedSectionIndex].title}',
        style: const TextStyle(fontSize: 24),
      );
    }
  }

  Widget buildSideMenu() {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListView(
            children: [
              Container(
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
                            fontFamily: GoogleFonts.alikeAngular().fontFamily,
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ARKET',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily:
                                GoogleFonts.waitingForTheSunrise().fontFamily,
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
                            fontFamily:
                                GoogleFonts.waitingForTheSunrise().fontFamily,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _SideMenuDivider(theme: theme),
              ...sections.asMap().entries.map((entry) {
                int sectionIndex = entry.key;
                Section section = entry.value;

                if (section.subsections.isEmpty) {
                  return ListTile(
                    leading: Icon(
                      section.icon,
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
                      setState(() {
                        _selectedSectionIndex = sectionIndex;
                        _selectedSubsectionIndex = null;
                      });
                      if (Responsive.isMobile(context)) Navigator.pop(context);
                    },
                  );
                } else {
                  return ExpansionTile(
                    leading: Icon(
                      section.icon,
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
                      Subsection subsection = subEntry.value;

                      return ListTile(
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
        color: theme.colorScheme.onSurface.withOpacity(0.2),
      ),
    );
  }
}

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;
}

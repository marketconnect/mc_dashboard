import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mc_dashboard/.env.dart';
import 'package:mc_dashboard/core/config.dart';
import 'package:url_launcher/url_launcher.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
    required this.theme,
  });

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            launchUrl(Uri.parse(Env.mcUrl));
          },
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfig.sideMenuWidth * 0.04,
            ),
            child: SizedBox(
              width: 120,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Text(
                      'M',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: GoogleFonts.alikeAngular().fontFamily,
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 7,
                    left: 16, // Смещение для эффекта наложения
                    child: Text(
                      'ARKET',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily:
                            GoogleFonts.waitingForTheSunrise().fontFamily,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14, // Смещение вниз для наложения
                    left: 10,
                    child: Text(
                      'CONNECT',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily:
                            GoogleFonts.waitingForTheSunrise().fontFamily,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

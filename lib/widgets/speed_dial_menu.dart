import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';

class SpeedDialOption {
  final String label;
  final IconData icon;
  final String? url;
  final String? route;

  SpeedDialOption({
    required this.label,
    required this.icon,
    this.url,
    this.route,
  }) : assert(url != null || route != null,
            'Необходимо указать либо url, либо route');
}

class SpeedDialMenu extends StatelessWidget {
  final List<SpeedDialOption> options;

  const SpeedDialMenu({super.key, required this.options});

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Не удалось открыть $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      overlayOpacity: 0.0, // или 0.0 чтобы не блокировать ввод
      renderOverlay: false, // отключает отрисовку overlay
      children: options.map((option) {
        return SpeedDialChild(
          child: Icon(option.icon),
          label: option.label,
          onTap: () {
            if (option.url != null) {
              _openUrl(option.url!);
            } else if (option.route != null) {
              Navigator.of(context).pushNamed(option.route!);
            }
          },
        );
      }).toList(),
    );
  }
}

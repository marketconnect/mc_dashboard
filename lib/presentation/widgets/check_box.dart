import 'package:flutter/material.dart';

class McCheckBox extends StatelessWidget {
  const McCheckBox(
      {super.key,
      required this.value,
      required this.theme,
      required this.onChanged});
  final bool value;
  final ThemeData theme;
  final void Function(bool?)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      checkColor: theme.colorScheme.onSecondary,
      activeColor: theme.colorScheme.secondary,
      side: BorderSide(
        color: theme.colorScheme.onSurface
            .withAlpha((0.5 * 255).toInt()), // Цвет границы, когда неактивен
        width: 2, // Толщина границы
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

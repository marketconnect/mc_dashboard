extension StringFormatting on String {
  String formatWithThousands() {
    return replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match match) => '${match.group(1)} ',
    );
  }

  bool isNumeric() {
    final numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(this);
  }
}

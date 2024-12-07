extension StringFormatting on String {
  String formatWithThousands() {
    return replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match match) => '${match.group(1)} ',
    );
  }
}

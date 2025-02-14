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

String getTomorrowDate() {
  final tomorrow = DateTime.now().add(Duration(days: 1));
  return "${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}";
}

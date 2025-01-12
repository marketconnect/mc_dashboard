String monthFullName(int month) {
  switch (month) {
    case 1:
      return 'января';
    case 2:
      return 'февраля';
    case 3:
      return 'марта';
    case 4:
      return 'апр еля';
    case 5:
      return 'мая';
    case 6:
      return 'июня';
    case 7:
      return 'июля';
    case 8:
      return 'августа';
    case 9:
      return 'сентября';
    case 10:
      return 'октября';
    case 11:
      return 'ноября';
    case 12:
      return 'декабря';
    default:
      return '';
  }
}

String monthName(int month) {
  switch (month) {
    case 1:
      return 'янв';
    case 2:
      return 'фев';
    case 3:
      return 'мар';
    case 4:
      return 'апр';
    case 5:
      return 'мая';
    case 6:
      return 'июн';
    case 7:
      return 'июл';
    case 8:
      return 'авг';
    case 9:
      return 'сен';
    case 10:
      return 'окт';
    case 11:
      return 'ноя';
    case 12:
      return 'дек';
    default:
      return '';
  }
}

String formatRuFullDate(String date) {
  final parts = date.split("-");
  final day = parts[2];
  final year = parts[0];
  final month = monthFullName(int.parse(parts[1]));
  return "$day $month $year";
}

String formatDate(String date) {
  final parts = date.split("-");
  final day = parts[2];
  final month = monthFullName(int.parse(parts[1]));
  return "$day $month";
}

String formatDateTimeToDayMonthYearHourMinute(DateTime dateTime) {
  final day = _twoDigits(dateTime.day);
  final month = _twoDigits(dateTime.month);
  final year = dateTime.year;
  final hour = _twoDigits(dateTime.hour);
  final minute = _twoDigits(dateTime.minute);

  return '$day.$month.${year}_$hour.$minute';
}

String _twoDigits(int value) => value < 10 ? '0$value' : value.toString();

DateTime parseDateYYYYMMDD(String date) {
  final parts = date.split("-");
  final day = int.parse(parts[2]);
  final month = int.parse(parts[1]);
  final year = int.parse(parts[0]);

  return DateTime(year, month, day);
}

String weekStringPeriod(String weekString) {
  final parts = weekString.split('_');
  final year = int.parse('20${parts[0]}');
  final week = int.parse(parts[1]);

  final firstDayOfYear = DateTime(year, 1, 1);
  final daysToMonday = (firstDayOfYear.weekday == DateTime.sunday)
      ? 0
      : (8 - firstDayOfYear.weekday);

  // Previous week
  final mondayDate =
      firstDayOfYear.add(Duration(days: daysToMonday + (week - 2) * 7));
  final sundayDate = mondayDate.add(const Duration(days: 6));

  final formattedDate =
      '${mondayDate.day.toString().padLeft(2, '0')} ${monthName(mondayDate.month)} - ${sundayDate.day.toString().padLeft(2, '0')} ${monthName(sundayDate.month)}';
  return formattedDate;
}

String weekStringToMondayDate(String weekString) {
  final parts = weekString.split('_');
  final year = int.parse('20${parts[0]}');
  final week = int.parse(parts[1]);

  final firstDayOfYear = DateTime(year, 1, 1);
  final daysToMonday = (firstDayOfYear.weekday == DateTime.sunday)
      ? 0
      : (8 - firstDayOfYear.weekday);
  final firstMonday = firstDayOfYear.add(Duration(days: daysToMonday));

  // final sundayDate = firstMonday.add(Duration(days: (week - 1) * 7 + 6));
  final mondayDate = firstMonday.add(Duration(days: (week - 1) * 7));

  final formattedDate =
      '${mondayDate.day.toString().padLeft(2, '0')} ${monthName(mondayDate.month)}';
  return formattedDate;
}

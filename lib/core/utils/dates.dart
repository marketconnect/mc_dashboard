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

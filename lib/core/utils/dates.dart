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

String formatDate(String date) {
  final parts = date.split("-");
  final day = parts[2];
  final month = monthName(int.parse(parts[1]));
  return "$day $month";
}

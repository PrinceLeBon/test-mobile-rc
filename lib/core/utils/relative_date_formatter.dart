import 'package:intl/intl.dart';

abstract final class RelativeDateFormatter {
  static const String _locale = 'fr_FR';
  static const String _nonBreakingSpace = '\u00A0';

  static String format(DateTime date, {DateTime? now}) {
    final localDate = date.toLocal();
    final localNow = (now ?? DateTime.now()).toLocal();
    final elapsed = localNow.difference(localDate);

    if (elapsed.inSeconds < 60) {
      return 'à l’instant';
    }
    if (elapsed.inMinutes < 60) {
      return 'il y a ${elapsed.inMinutes}${_nonBreakingSpace}min';
    }
    if (_isSameDay(localDate, localNow)) {
      return 'il y a ${elapsed.inHours}${_nonBreakingSpace}h';
    }
    final yesterday = DateTime(localNow.year, localNow.month, localNow.day - 1);
    if (_isSameDay(localDate, yesterday)) {
      return 'hier';
    }
    if (localDate.year == localNow.year) {
      return DateFormat('d MMM', _locale).format(localDate);
    }
    return DateFormat('d MMM y', _locale).format(localDate);
  }

  static bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

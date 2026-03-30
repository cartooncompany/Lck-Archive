extension DateX on DateTime {
  String toKoreanDate() {
    final local = toLocal();
    return '${local.year}.${_twoDigits(local.month)}.${_twoDigits(local.day)}';
  }

  String toKoreanMonthDayTime() {
    final local = toLocal();
    return '${_twoDigits(local.month)}.${_twoDigits(local.day)} '
        '(${_weekdayLabel(local.weekday)}) '
        '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '월';
      case DateTime.tuesday:
        return '화';
      case DateTime.wednesday:
        return '수';
      case DateTime.thursday:
        return '목';
      case DateTime.friday:
        return '금';
      case DateTime.saturday:
        return '토';
      default:
        return '일';
    }
  }
}

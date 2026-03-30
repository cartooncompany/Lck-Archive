extension DateX on DateTime {
  String toKoreanDate() {
    return '$year.${_twoDigits(month)}.${_twoDigits(day)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

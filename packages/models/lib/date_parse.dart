class DateParse {
  static DateTime? parse(value) {
    if (value is String) {
      return DateTime?.tryParse(value);
    } else if (value is int) {
      return DateTime.fromMicrosecondsSinceEpoch(value);
    } else {
      return value as DateTime?;
    }
  }
}

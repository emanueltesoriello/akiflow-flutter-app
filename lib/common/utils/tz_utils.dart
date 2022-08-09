class TzUtils {
  static String? toUtcStringIfNotNull(DateTime? date) {
    if (date == null) {
      return null;
    }

    return date.toUtc().toIso8601String();
  }
}

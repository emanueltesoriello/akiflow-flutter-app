class UpsertDatabaseException implements Exception {
  final String message;

  UpsertDatabaseException(this.message);

  @override
  String toString() {
    return 'UpsertDatabaseException{message: $message}';
  }
}

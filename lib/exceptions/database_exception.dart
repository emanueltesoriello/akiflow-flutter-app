class DatabaseRepositoryException implements Exception {
  final String message;

  DatabaseRepositoryException(this.message);

  @override
  String toString() {
    return 'DatabaseException{message: $message}';
  }
}

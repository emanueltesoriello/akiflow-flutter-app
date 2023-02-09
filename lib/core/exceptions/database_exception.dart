class DatabaseRepositoryException implements Exception {
  final String message;

  DatabaseRepositoryException(this.message);

  @override
  String toString() {
    return 'DatabaseException{message: $message}';
  }
}

class DatabaseItemNotFoundException implements Exception {
  final String message;

  DatabaseItemNotFoundException(this.message);

  @override
  String toString() {
    return 'ItemNotFoundException{message: $message}';
  }
}

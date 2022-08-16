class PostUnsyncedExcepotion implements Exception {
  final String message;

  PostUnsyncedExcepotion(this.message);

  @override
  String toString() {
    return 'PostUnsyncedExcepotion{message: $message}';
  }
}

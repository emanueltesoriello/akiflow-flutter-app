class ApiException implements Exception {
  final String message;
  final List<dynamic> errors;

  ApiException(Map<String, dynamic> response)
      : message = response["message"],
        errors = response["errors"];

  @override
  String toString() {
    return 'ApiException{message: $message, errors: $errors}';
  }
}

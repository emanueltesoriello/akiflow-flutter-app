class GmailUnstarException implements Exception {
  final String message;
  final String request;
  final String response;
  GmailUnstarException(this.message, this.request, this.response);

  @override
  String toString() {
    return "GmailUnstarException: $message\nRequest: $request\nResponse: $response";
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error occurred.']);
  @override
  String toString() => 'NetworkException: $message';
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

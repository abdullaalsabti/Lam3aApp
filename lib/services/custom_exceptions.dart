class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}
class NetworkException implements Exception {
  final String message;
  final NetworkErrorType type;
  
  NetworkException(this.message, this.type);
  
  @override
  String toString() => message;
}

enum NetworkErrorType {
  noInternet,
  timeout,
  serverError,
  hostLookupFailed,
  unknown
}
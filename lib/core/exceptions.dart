class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => 'AppException: $message ${code != null ? '($code)' : ''}';
}

class NetworkException extends AppException {
  NetworkException([super.message = 'No internet connection', super.code]);
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error occurred', super.code]);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Unauthorized access', super.code]);
}

class ValidationException extends AppException {
  ValidationException([super.message = 'Validation failed', super.code]);
}

class AppException implements Exception {
  const AppException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class ApiException extends AppException {
  const ApiException({
    required String message,
    required this.statusCode,
    this.responseBody,
  }) : super(message);

  final int statusCode;
  final Object? responseBody;
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

final class DataParsingException extends AppException {
  const DataParsingException(super.message, {super.cause});
}

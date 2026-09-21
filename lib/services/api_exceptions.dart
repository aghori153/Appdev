sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  String get title;

  @override
  String toString() => '$runtimeType: $message';
}

class NoInternetException extends ApiException {
  const NoInternetException([
    super.message = 'Check your Wi-Fi or mobile data and try again.',
  ]);
  @override
  String get title => 'No internet connection';
}

class RequestTimeoutException extends ApiException {
  const RequestTimeoutException([
    super.message =
        'The server took too long to respond. Your connection may be slow.',
  ]);
  @override
  String get title => 'Request timed out';
}

class ServerException extends ApiException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
  @override
  String get title =>
      'Server error${statusCode != null ? ' ($statusCode)' : ''}';
}

class DataParsingException extends ApiException {
  const DataParsingException([
    super.message = 'The server sent data in an unexpected format.',
  ]);
  @override
  String get title => 'Invalid data received';
}

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:inventory_management_app/core/constants/api_constants.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';

class ApiClient {
  factory ApiClient({
    required http.Client client,
    String baseUrl = ApiConstants.baseUrl,
    Duration timeout = ApiConstants.requestTimeout,
  }) {
    return ApiClient._(client, _parseBaseUri(baseUrl), timeout);
  }

  ApiClient._(this._client, this._baseUri, this._timeout);

  static const Map<String, String> _jsonHeaders = <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  final http.Client _client;
  final Duration _timeout;
  final Uri _baseUri;

  Future<Object?> get(String path, {Map<String, String>? queryParameters}) {
    final Uri uri = _buildUri(path, queryParameters: queryParameters);
    return _send(() => _client.get(uri, headers: _jsonHeaders));
  }

  Future<Object?> post(String path, {required Map<String, Object?> body}) {
    final Uri uri = _buildUri(path);
    return _send(
      () => _client.post(uri, headers: _jsonHeaders, body: jsonEncode(body)),
    );
  }

  Future<Object?> put(String path, {required Map<String, Object?> body}) {
    final Uri uri = _buildUri(path);
    return _send(
      () => _client.put(uri, headers: _jsonHeaders, body: jsonEncode(body)),
    );
  }

  Future<Object?> delete(String path) {
    final Uri uri = _buildUri(path);
    return _send(() => _client.delete(uri, headers: _jsonHeaders));
  }

  Future<Object?> _send(Future<http.Response> Function() request) async {
    late final http.Response response;

    try {
      response = await request().timeout(_timeout);
    } on TimeoutException catch (error) {
      throw NetworkException('The request timed out.', cause: error);
    } on http.ClientException catch (error) {
      throw NetworkException('Unable to connect to the server.', cause: error);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final Object? responseBody = _tryDecode(response.body);
      throw ApiException(
        message: _readErrorMessage(responseBody),
        statusCode: response.statusCode,
        responseBody: responseBody,
      );
    }

    if (response.body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body) as Object?;
    } on FormatException catch (error) {
      throw DataParsingException(
        'The server returned invalid JSON.',
        cause: error,
      );
    }
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final String normalizedPath = path.startsWith('/')
        ? path.substring(1)
        : path;
    final Uri uri = _baseUri.resolve(normalizedPath);

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        ...queryParameters,
      },
    );
  }

  static Uri _parseBaseUri(String baseUrl) {
    final Uri? uri = Uri.tryParse(baseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'Must be an absolute URL.');
    }

    final String normalizedPath = uri.path.endsWith('/')
        ? uri.path
        : '${uri.path}/';
    return uri.replace(path: normalizedPath);
  }

  static Object? _tryDecode(String body) {
    if (body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body) as Object?;
    } on FormatException {
      return body;
    }
  }

  static String _readErrorMessage(Object? responseBody) {
    if (responseBody is Map<String, dynamic>) {
      final Object? message = responseBody['message'] ?? responseBody['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    return 'The server could not complete the request.';
  }
}

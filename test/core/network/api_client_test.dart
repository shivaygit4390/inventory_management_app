import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/core/network/api_client.dart';

void main() {
  const String baseUrl = 'https://example.com/api/v1';

  group('ApiClient', () {
    test('GET builds the URL and decodes a successful response', () async {
      final MockClient httpClient = MockClient((http.Request request) async {
        expect(request.method, 'GET');
        expect(
          request.url.toString(),
          '$baseUrl/products?category=Electronics',
        );
        expect(request.headers['Accept'], 'application/json');
        return http.Response('[{"id":"1"}]', 200);
      });
      final ApiClient apiClient = ApiClient(
        client: httpClient,
        baseUrl: baseUrl,
      );

      final Object? response = await apiClient.get(
        'products',
        queryParameters: const <String, String>{'category': 'Electronics'},
      );

      expect(response, <Object?>[
        <String, Object?>{'id': '1'},
      ]);
    });

    test('POST sends JSON with the required headers', () async {
      final MockClient httpClient = MockClient((http.Request request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), '$baseUrl/products');
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body), <String, Object?>{'name': 'Mouse'});
        return http.Response('{"id":"4","name":"Mouse"}', 201);
      });
      final ApiClient apiClient = ApiClient(
        client: httpClient,
        baseUrl: baseUrl,
      );

      final Object? response = await apiClient.post(
        'products',
        body: const <String, Object?>{'name': 'Mouse'},
      );

      expect(response, <String, Object?>{'id': '4', 'name': 'Mouse'});
    });

    test('throws ApiException for a non-success status code', () async {
      final MockClient httpClient = MockClient(
        (_) async => http.Response('{"message":"Product not found"}', 404),
      );
      final ApiClient apiClient = ApiClient(
        client: httpClient,
        baseUrl: baseUrl,
      );

      expect(
        apiClient.get('products/999'),
        throwsA(
          isA<ApiException>()
              .having(
                (ApiException error) => error.statusCode,
                'statusCode',
                404,
              )
              .having(
                (ApiException error) => error.message,
                'message',
                'Product not found',
              ),
        ),
      );
    });

    test('throws DataParsingException for invalid successful JSON', () async {
      final MockClient httpClient = MockClient(
        (_) async => http.Response('not-json', 200),
      );
      final ApiClient apiClient = ApiClient(
        client: httpClient,
        baseUrl: baseUrl,
      );

      expect(apiClient.get('products'), throwsA(isA<DataParsingException>()));
    });

    test('converts client failures into NetworkException', () async {
      final MockClient httpClient = MockClient(
        (_) async => throw http.ClientException('Connection failed'),
      );
      final ApiClient apiClient = ApiClient(
        client: httpClient,
        baseUrl: baseUrl,
      );

      expect(apiClient.get('products'), throwsA(isA<NetworkException>()));
    });
  });
}

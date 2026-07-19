import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/core/network/api_client.dart';
import 'package:inventory_management_app/features/inventory/data/data_sources/inventory_remote_data_source.dart';
import 'package:inventory_management_app/features/inventory/data/models/product_model.dart';

void main() {
  const String baseUrl = 'https://example.com/api/v1';
  const ProductModel product = ProductModel(
    id: '1',
    name: 'Wireless Mouse',
    description: 'Ergonomic wireless mouse',
    category: 'Electronics',
    price: 799,
    stockQuantity: 25,
    sku: 'WM-001',
    imageUrl: 'https://cdn.example.com/wireless_mouse.png',
  );

  Map<String, Object?> productJson({String id = '1'}) {
    return <String, Object?>{'id': id, ...product.toJson()};
  }

  InventoryRemoteDataSource createDataSource(MockClient httpClient) {
    return InventoryRemoteDataSourceImpl(
      apiClient: ApiClient(client: httpClient, baseUrl: baseUrl),
    );
  }

  group('InventoryRemoteDataSource', () {
    test('fetchProducts maps a JSON array into models', () async {
      final MockClient httpClient = MockClient((http.Request request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/products');
        return http.Response(jsonEncode(<Object?>[productJson()]), 200);
      });
      final InventoryRemoteDataSource dataSource = createDataSource(httpClient);

      final List<ProductModel> result = await dataSource.fetchProducts();

      expect(result, <ProductModel>[product]);
    });

    test('fetchProduct requests and maps one product by ID', () async {
      final MockClient httpClient = MockClient((http.Request request) async {
        expect(request.url.toString(), '$baseUrl/products/1');
        return http.Response(jsonEncode(productJson()), 200);
      });
      final InventoryRemoteDataSource dataSource = createDataSource(httpClient);

      expect(await dataSource.fetchProduct('1'), product);
    });

    test('createProduct posts writable fields and maps the response', () async {
      final MockClient httpClient = MockClient((http.Request request) async {
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), product.toJson());
        return http.Response(jsonEncode(productJson()), 201);
      });
      final InventoryRemoteDataSource dataSource = createDataSource(httpClient);

      final ProductModel created = await dataSource.createProduct(
        ProductModel(
          name: product.name,
          description: product.description,
          category: product.category,
          price: product.price,
          stockQuantity: product.stockQuantity,
          sku: product.sku,
          imageUrl: product.imageUrl,
        ),
      );

      expect(created, product);
    });

    test('updateProduct puts writable fields at the item URL', () async {
      final MockClient httpClient = MockClient((http.Request request) async {
        expect(request.method, 'PUT');
        expect(request.url.toString(), '$baseUrl/products/1');
        expect(jsonDecode(request.body), product.toJson());
        return http.Response(jsonEncode(productJson()), 200);
      });
      final InventoryRemoteDataSource dataSource = createDataSource(httpClient);

      expect(await dataSource.updateProduct(product), product);
    });

    test('deleteProduct sends DELETE to the item URL', () async {
      final MockClient httpClient = MockClient((http.Request request) async {
        expect(request.method, 'DELETE');
        expect(request.url.toString(), '$baseUrl/products/1');
        return http.Response(jsonEncode(productJson()), 200);
      });
      final InventoryRemoteDataSource dataSource = createDataSource(httpClient);

      await dataSource.deleteProduct('1');
    });

    test('wraps invalid product data in DataParsingException', () async {
      final MockClient httpClient = MockClient(
        (_) async => http.Response('[{"id":"1"}]', 200),
      );
      final InventoryRemoteDataSource dataSource = createDataSource(httpClient);

      expect(dataSource.fetchProducts(), throwsA(isA<DataParsingException>()));
    });
  });
}

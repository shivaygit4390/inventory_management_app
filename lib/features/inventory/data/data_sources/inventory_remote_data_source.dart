import 'package:inventory_management_app/core/constants/api_constants.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/core/network/api_client.dart';
import 'package:inventory_management_app/features/inventory/data/models/product_model.dart';

abstract interface class InventoryRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();

  Future<ProductModel> fetchProduct(String id);

  Future<ProductModel> createProduct(ProductModel product);

  Future<ProductModel> updateProduct(ProductModel product);

  Future<void> deleteProduct(String id);
}

final class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  factory InventoryRemoteDataSourceImpl({required ApiClient apiClient}) {
    return InventoryRemoteDataSourceImpl._(apiClient);
  }

  const InventoryRemoteDataSourceImpl._(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final Object? response = await _apiClient.get(ApiConstants.productsPath);
    if (response is! List<dynamic>) {
      throw const DataParsingException(
        'Expected the products response to be a JSON array.',
      );
    }

    return response.map<ProductModel>(_parseProduct).toList(growable: false);
  }

  @override
  Future<ProductModel> fetchProduct(String id) async {
    _validateId(id);
    final Object? response = await _apiClient.get(_productPath(id));
    return _parseProduct(response);
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final Object? response = await _apiClient.post(
      ApiConstants.productsPath,
      body: product.toJson(),
    );
    return _parseProduct(response);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    _validateId(product.id);
    final Object? response = await _apiClient.put(
      _productPath(product.id),
      body: product.toJson(),
    );
    return _parseProduct(response);
  }

  @override
  Future<void> deleteProduct(String id) async {
    _validateId(id);
    await _apiClient.delete(_productPath(id));
  }

  static ProductModel _parseProduct(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const DataParsingException(
        'Expected a product to be a JSON object.',
      );
    }

    try {
      return ProductModel.fromJson(value);
    } on FormatException catch (error) {
      throw DataParsingException(
        'A product contains invalid or missing data.',
        cause: error,
      );
    }
  }

  static String _productPath(String id) {
    return '${ApiConstants.productsPath}/${Uri.encodeComponent(id)}';
  }

  static void _validateId(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'A product ID is required.');
    }
  }
}

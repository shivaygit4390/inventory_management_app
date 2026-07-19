import 'package:inventory_management_app/features/inventory/data/data_sources/inventory_remote_data_source.dart';
import 'package:inventory_management_app/features/inventory/data/models/product_model.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';

final class InventoryRepositoryImpl implements InventoryRepository {
  const InventoryRepositoryImpl(this._remoteDataSource);

  final InventoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<Product>> getProducts() async {
    final List<ProductModel> models = await _remoteDataSource.fetchProducts();
    return List<Product>.unmodifiable(models);
  }

  @override
  Future<Product> getProduct(String id) {
    return _remoteDataSource.fetchProduct(id);
  }

  @override
  Future<Product> createProduct(Product product) {
    return _remoteDataSource.createProduct(ProductModel.fromEntity(product));
  }

  @override
  Future<Product> updateProduct(Product product) {
    return _remoteDataSource.updateProduct(ProductModel.fromEntity(product));
  }

  @override
  Future<void> deleteProduct(String id) {
    return _remoteDataSource.deleteProduct(id);
  }
}

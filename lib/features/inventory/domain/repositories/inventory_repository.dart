import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

abstract interface class InventoryRepository {
  Future<List<Product>> getProducts();

  Future<Product> getProduct(String id);

  Future<Product> createProduct(Product product);

  Future<Product> updateProduct(Product product);

  Future<void> deleteProduct(String id);
}

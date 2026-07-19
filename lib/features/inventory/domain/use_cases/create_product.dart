import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';

final class CreateProduct {
  const CreateProduct(this._repository);

  final InventoryRepository _repository;

  Future<Product> call(Product product) {
    return _repository.createProduct(product);
  }
}

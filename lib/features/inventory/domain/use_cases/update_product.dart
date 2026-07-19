import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/product_id_validator.dart';

final class UpdateProduct {
  const UpdateProduct(this._repository);

  final InventoryRepository _repository;

  Future<Product> call(Product product) {
    validateProductId(product.id, parameterName: 'product.id');
    return _repository.updateProduct(product);
  }
}

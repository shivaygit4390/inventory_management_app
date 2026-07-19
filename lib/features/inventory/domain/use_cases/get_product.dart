import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/product_id_validator.dart';

final class GetProduct {
  const GetProduct(this._repository);

  final InventoryRepository _repository;

  Future<Product> call(String id) {
    validateProductId(id);
    return _repository.getProduct(id);
  }
}

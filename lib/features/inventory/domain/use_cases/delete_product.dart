import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/product_id_validator.dart';

final class DeleteProduct {
  const DeleteProduct(this._repository);

  final InventoryRepository _repository;

  Future<void> call(String id) {
    validateProductId(id);
    return _repository.deleteProduct(id);
  }
}

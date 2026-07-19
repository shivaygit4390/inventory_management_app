import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';

final class GetProducts {
  const GetProducts(this._repository);

  final InventoryRepository _repository;

  Future<List<Product>> call() => _repository.getProducts();
}

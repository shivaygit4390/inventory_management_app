import 'package:equatable/equatable.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

sealed class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object> get props => const <Object>[];
}

final class InventoryProductsRequested extends InventoryEvent {
  const InventoryProductsRequested();
}

final class InventoryProductCreationRequested extends InventoryEvent {
  const InventoryProductCreationRequested(this.product);

  final Product product;

  @override
  List<Object> get props => <Object>[product];
}

final class InventoryProductUpdateRequested extends InventoryEvent {
  const InventoryProductUpdateRequested(this.product);

  final Product product;

  @override
  List<Object> get props => <Object>[product];
}

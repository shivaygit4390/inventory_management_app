import 'package:equatable/equatable.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

sealed class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object> get props => const <Object>[];
}

final class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

final class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

final class InventoryLoaded extends InventoryState {
  InventoryLoaded(List<Product> products)
    : products = List<Product>.unmodifiable(products);

  final List<Product> products;

  @override
  List<Object> get props => <Object>[products];
}

final class InventoryEmpty extends InventoryState {
  const InventoryEmpty();
}

final class InventoryFailure extends InventoryState {
  const InventoryFailure(this.message);

  final String message;

  @override
  List<Object> get props => <Object>[message];
}

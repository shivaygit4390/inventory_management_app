import 'package:equatable/equatable.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

sealed class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object> get props => const <Object>[];
}

enum InventoryMutationType { create, update }

final class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

final class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

sealed class InventoryProductsState extends InventoryState {
  InventoryProductsState(List<Product> products)
    : products = List<Product>.unmodifiable(products);

  final List<Product> products;

  @override
  List<Object> get props => <Object>[products];
}

final class InventoryLoaded extends InventoryProductsState {
  InventoryLoaded(super.products);
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

final class InventoryMutationInProgress extends InventoryProductsState {
  InventoryMutationInProgress(super.products, this.mutationType);

  final InventoryMutationType mutationType;

  @override
  List<Object> get props => <Object>[...super.props, mutationType];
}

final class InventoryMutationSuccess extends InventoryProductsState {
  InventoryMutationSuccess(
    super.products, {
    required this.product,
    required this.mutationType,
  });

  final Product product;
  final InventoryMutationType mutationType;

  @override
  List<Object> get props => <Object>[...super.props, product, mutationType];
}

final class InventoryMutationFailure extends InventoryProductsState {
  InventoryMutationFailure(
    super.products, {
    required this.message,
    required this.mutationType,
  });

  final String message;
  final InventoryMutationType mutationType;

  @override
  List<Object> get props => <Object>[...super.props, message, mutationType];
}

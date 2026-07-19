import 'package:equatable/equatable.dart';

sealed class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object> get props => const <Object>[];
}

final class InventoryProductsRequested extends InventoryEvent {
  const InventoryProductsRequested();
}

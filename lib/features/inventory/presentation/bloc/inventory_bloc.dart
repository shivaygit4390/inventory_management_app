import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_products.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_state.dart';

final class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc(this._getProducts) : super(const InventoryInitial()) {
    on<InventoryProductsRequested>(_onProductsRequested);
  }

  final GetProducts _getProducts;

  Future<void> _onProductsRequested(
    InventoryProductsRequested event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoading) {
      return;
    }

    emit(const InventoryLoading());

    try {
      final List<Product> products = await _getProducts();
      if (products.isEmpty) {
        emit(const InventoryEmpty());
        return;
      }
      emit(InventoryLoaded(products));
    } on AppException catch (error) {
      emit(InventoryFailure(error.message));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        const InventoryFailure('Unable to load inventory. Please try again.'),
      );
    }
  }
}

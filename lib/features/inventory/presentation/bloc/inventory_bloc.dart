import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/create_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/delete_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_products.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/update_product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_state.dart';

final class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc(
    this._getProducts,
    this._createProduct,
    this._updateProduct,
    this._deleteProduct,
  ) : super(const InventoryInitial()) {
    on<InventoryProductsRequested>(_onProductsRequested);
    on<InventoryProductsRefreshRequested>(_onProductsRefreshRequested);
    on<InventoryProductCreationRequested>(_onProductCreationRequested);
    on<InventoryProductUpdateRequested>(_onProductUpdateRequested);
    on<InventoryProductDeletionRequested>(_onProductDeletionRequested);
  }

  final GetProducts _getProducts;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;

  Future<void> _onProductsRequested(
    InventoryProductsRequested event,
    Emitter<InventoryState> emit,
  ) async {
    if (_isBusy) {
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

  Future<void> _onProductsRefreshRequested(
    InventoryProductsRefreshRequested event,
    Emitter<InventoryState> emit,
  ) async {
    if (_isBusy) {
      return;
    }

    final List<Product> previousProducts = _visibleProducts;
    emit(InventoryRefreshing(previousProducts));

    try {
      final List<Product> products = await _getProducts();
      emit(
        products.isEmpty ? const InventoryEmpty() : InventoryLoaded(products),
      );
    } on AppException catch (error) {
      emit(InventoryRefreshFailure(previousProducts, error.message));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        InventoryRefreshFailure(
          previousProducts,
          'Unable to refresh inventory. Please try again.',
        ),
      );
    }
  }

  Future<void> _onProductCreationRequested(
    InventoryProductCreationRequested event,
    Emitter<InventoryState> emit,
  ) async {
    await _performMutation(
      mutationType: InventoryMutationType.create,
      mutate: () => _createProduct(event.product),
      emit: emit,
    );
  }

  Future<void> _onProductUpdateRequested(
    InventoryProductUpdateRequested event,
    Emitter<InventoryState> emit,
  ) async {
    await _performMutation(
      mutationType: InventoryMutationType.update,
      mutate: () => _updateProduct(event.product),
      emit: emit,
    );
  }

  Future<void> _onProductDeletionRequested(
    InventoryProductDeletionRequested event,
    Emitter<InventoryState> emit,
  ) async {
    if (_isBusy) {
      return;
    }

    final List<Product> previousProducts = _visibleProducts;
    emit(
      InventoryMutationInProgress(
        previousProducts,
        InventoryMutationType.delete,
      ),
    );

    try {
      await _deleteProduct(event.product.id);
      final List<Product> refreshedProducts = await _refreshAfterMutation(
        affectedProduct: event.product,
        previousProducts: previousProducts,
        mutationType: InventoryMutationType.delete,
      );
      emit(
        InventoryMutationSuccess(
          refreshedProducts,
          product: event.product,
          mutationType: InventoryMutationType.delete,
        ),
      );
    } on AppException catch (error) {
      emit(
        InventoryMutationFailure(
          previousProducts,
          message: error.message,
          mutationType: InventoryMutationType.delete,
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        InventoryMutationFailure(
          previousProducts,
          message: 'Unable to delete product. Please try again.',
          mutationType: InventoryMutationType.delete,
        ),
      );
    }
  }

  Future<void> _performMutation({
    required InventoryMutationType mutationType,
    required Future<Product> Function() mutate,
    required Emitter<InventoryState> emit,
  }) async {
    if (_isBusy) {
      return;
    }

    final List<Product> previousProducts = _visibleProducts;
    emit(InventoryMutationInProgress(previousProducts, mutationType));

    try {
      final Product savedProduct = await mutate();
      final List<Product> refreshedProducts = await _refreshAfterMutation(
        affectedProduct: savedProduct,
        previousProducts: previousProducts,
        mutationType: mutationType,
      );
      emit(
        InventoryMutationSuccess(
          refreshedProducts,
          product: savedProduct,
          mutationType: mutationType,
        ),
      );
    } on AppException catch (error) {
      emit(
        InventoryMutationFailure(
          previousProducts,
          message: error.message,
          mutationType: mutationType,
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        InventoryMutationFailure(
          previousProducts,
          message: switch (mutationType) {
            InventoryMutationType.create =>
              'Unable to add product. Please try again.',
            InventoryMutationType.update =>
              'Unable to update product. Please try again.',
            InventoryMutationType.delete =>
              'Unable to delete product. Please try again.',
          },
          mutationType: mutationType,
        ),
      );
    }
  }

  Future<List<Product>> _refreshAfterMutation({
    required Product affectedProduct,
    required List<Product> previousProducts,
    required InventoryMutationType mutationType,
  }) async {
    try {
      return await _getProducts();
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      return _reconcileLocally(
        affectedProduct: affectedProduct,
        previousProducts: previousProducts,
        mutationType: mutationType,
      );
    }
  }

  List<Product> _reconcileLocally({
    required Product affectedProduct,
    required List<Product> previousProducts,
    required InventoryMutationType mutationType,
  }) {
    return switch (mutationType) {
      InventoryMutationType.create => <Product>[
        affectedProduct,
        ...previousProducts,
      ],
      InventoryMutationType.update =>
        previousProducts
            .map(
              (Product product) =>
                  product.id == affectedProduct.id ? affectedProduct : product,
            )
            .toList(growable: false),
      InventoryMutationType.delete =>
        previousProducts
            .where((Product product) => product.id != affectedProduct.id)
            .toList(growable: false),
    };
  }

  List<Product> get _visibleProducts {
    final InventoryState currentState = state;
    return currentState is InventoryProductsState
        ? currentState.products
        : const <Product>[];
  }

  bool get _isBusy =>
      state is InventoryLoading ||
      state is InventoryRefreshing ||
      state is InventoryMutationInProgress;
}

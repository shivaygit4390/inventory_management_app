import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/create_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_products.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/update_product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_state.dart';

void main() {
  const Product product = Product(
    id: '1',
    name: 'Wireless Mouse',
    description: 'Ergonomic wireless mouse',
    category: 'Electronics',
    price: 799,
    stockQuantity: 25,
    sku: 'WM-001',
    imageUrl: 'assets/images/wireless_mouse.png',
  );

  InventoryBloc createBloc(InventoryRepository repository) {
    return InventoryBloc(
      GetProducts(repository),
      CreateProduct(repository),
      UpdateProduct(repository),
    );
  }

  group('InventoryBloc', () {
    test('starts in InventoryInitial', () async {
      final InventoryBloc bloc = createBloc(
        StubInventoryRepository(result: <Product>[product]),
      );

      expect(bloc.state, const InventoryInitial());

      await bloc.close();
    });

    test('emits loading then loaded when products exist', () async {
      final InventoryBloc bloc = createBloc(
        StubInventoryRepository(result: <Product>[product]),
      );
      final Future<void> expectation = expectLater(
        bloc.stream,
        emitsInOrder(<InventoryState>[
          const InventoryLoading(),
          InventoryLoaded(<Product>[product]),
        ]),
      );

      bloc.add(const InventoryProductsRequested());

      await expectation;
      await bloc.close();
    });

    test('emits loading then empty when no products exist', () async {
      final InventoryBloc bloc = createBloc(
        StubInventoryRepository(result: const <Product>[]),
      );
      final Future<void> expectation = expectLater(
        bloc.stream,
        emitsInOrder(<InventoryState>[
          const InventoryLoading(),
          const InventoryEmpty(),
        ]),
      );

      bloc.add(const InventoryProductsRequested());

      await expectation;
      await bloc.close();
    });

    test('emits a typed application failure message', () async {
      final InventoryBloc bloc = createBloc(
        StubInventoryRepository(
          error: const NetworkException('No internet connection.'),
        ),
      );
      final Future<void> expectation = expectLater(
        bloc.stream,
        emitsInOrder(const <InventoryState>[
          InventoryLoading(),
          InventoryFailure('No internet connection.'),
        ]),
      );

      bloc.add(const InventoryProductsRequested());

      await expectation;
      await bloc.close();
    });

    test('hides unexpected internal error details from the UI state', () async {
      final InventoryBloc bloc = createBloc(
        StubInventoryRepository(error: StateError('Sensitive internal detail')),
      );
      final Future<void> expectation = expectLater(
        bloc.stream,
        emitsInOrder(const <InventoryState>[
          InventoryLoading(),
          InventoryFailure('Unable to load inventory. Please try again.'),
        ]),
      );

      bloc.add(const InventoryProductsRequested());

      await expectation;
      await bloc.close();
    });

    test('loaded state protects its product list from mutation', () {
      final InventoryLoaded state = InventoryLoaded(<Product>[product]);

      expect(() => state.products.add(product), throwsUnsupportedError);
    });

    test('creates a product and refreshes the visible inventory', () async {
      const Product draftProduct = Product(
        name: 'USB-C Hub',
        description: '6-in-1 USB-C Hub',
        category: 'Accessories',
        price: 1499,
        stockQuantity: 18,
        sku: 'HUB-003',
        imageUrl: 'assets/images/usb_c_hub.png',
      );
      const Product createdProduct = Product(
        id: '3',
        name: 'USB-C Hub',
        description: '6-in-1 USB-C Hub',
        category: 'Accessories',
        price: 1499,
        stockQuantity: 18,
        sku: 'HUB-003',
        imageUrl: 'assets/images/usb_c_hub.png',
      );
      final MutationInventoryRepository repository =
          MutationInventoryRepository(
            products: <Product>[product],
            createdProduct: createdProduct,
          );
      final InventoryBloc bloc = createBloc(repository);
      bloc.add(const InventoryProductsRequested());
      await bloc.stream.firstWhere(
        (InventoryState state) => state is InventoryLoaded,
      );

      final Future<void> expectation = expectLater(
        bloc.stream,
        emitsInOrder(<InventoryState>[
          InventoryMutationInProgress(<Product>[
            product,
          ], InventoryMutationType.create),
          InventoryMutationSuccess(
            <Product>[product, createdProduct],
            product: createdProduct,
            mutationType: InventoryMutationType.create,
          ),
        ]),
      );

      bloc.add(const InventoryProductCreationRequested(draftProduct));

      await expectation;
      expect(repository.createCalls, 1);
      expect(repository.getCalls, 2);
      await bloc.close();
    });

    test('updates a product and refreshes the visible inventory', () async {
      const Product updatedProduct = Product(
        id: '1',
        name: 'Wireless Mouse Pro',
        description: 'Ergonomic wireless mouse',
        category: 'Electronics',
        price: 999,
        stockQuantity: 20,
        sku: 'WM-001',
        imageUrl: 'assets/images/wireless_mouse.png',
      );
      final MutationInventoryRepository repository =
          MutationInventoryRepository(products: <Product>[product]);
      final InventoryBloc bloc = createBloc(repository);
      bloc.add(const InventoryProductsRequested());
      await bloc.stream.firstWhere(
        (InventoryState state) => state is InventoryLoaded,
      );

      final Future<void> expectation = expectLater(
        bloc.stream,
        emitsInOrder(<InventoryState>[
          InventoryMutationInProgress(<Product>[
            product,
          ], InventoryMutationType.update),
          InventoryMutationSuccess(
            <Product>[updatedProduct],
            product: updatedProduct,
            mutationType: InventoryMutationType.update,
          ),
        ]),
      );

      bloc.add(const InventoryProductUpdateRequested(updatedProduct));

      await expectation;
      expect(repository.updateCalls, 1);
      expect(repository.getCalls, 2);
      await bloc.close();
    });

    test(
      'keeps existing products and exposes a typed mutation failure',
      () async {
        final MutationInventoryRepository repository =
            MutationInventoryRepository(
              products: <Product>[product],
              mutationError: const NetworkException('Save failed.'),
            );
        final InventoryBloc bloc = createBloc(repository);
        bloc.add(const InventoryProductsRequested());
        await bloc.stream.firstWhere(
          (InventoryState state) => state is InventoryLoaded,
        );

        final Future<void> expectation = expectLater(
          bloc.stream,
          emitsInOrder(<InventoryState>[
            InventoryMutationInProgress(<Product>[
              product,
            ], InventoryMutationType.create),
            InventoryMutationFailure(
              <Product>[product],
              message: 'Save failed.',
              mutationType: InventoryMutationType.create,
            ),
          ]),
        );

        bloc.add(const InventoryProductCreationRequested(product));

        await expectation;
        await bloc.close();
      },
    );
  });
}

final class StubInventoryRepository implements InventoryRepository {
  const StubInventoryRepository({this.result, this.error});

  final List<Product>? result;
  final Object? error;

  @override
  Future<List<Product>> getProducts() async {
    final Object? currentError = error;
    if (currentError != null) {
      throw currentError;
    }
    return result ?? const <Product>[];
  }

  @override
  Future<Product> getProduct(String id) => throw UnimplementedError();

  @override
  Future<Product> createProduct(Product product) => throw UnimplementedError();

  @override
  Future<Product> updateProduct(Product product) => throw UnimplementedError();

  @override
  Future<void> deleteProduct(String id) => throw UnimplementedError();
}

final class MutationInventoryRepository implements InventoryRepository {
  MutationInventoryRepository({
    required List<Product> products,
    this.createdProduct,
    this.mutationError,
  }) : _products = List<Product>.of(products);

  final List<Product> _products;
  final Product? createdProduct;
  final Object? mutationError;
  int getCalls = 0;
  int createCalls = 0;
  int updateCalls = 0;

  @override
  Future<List<Product>> getProducts() async {
    getCalls += 1;
    return List<Product>.of(_products);
  }

  @override
  Future<Product> createProduct(Product product) async {
    createCalls += 1;
    final Object? currentError = mutationError;
    if (currentError != null) {
      throw currentError;
    }
    final Product savedProduct = createdProduct ?? product;
    _products.add(savedProduct);
    return savedProduct;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    updateCalls += 1;
    final Object? currentError = mutationError;
    if (currentError != null) {
      throw currentError;
    }
    final int index = _products.indexWhere(
      (Product currentProduct) => currentProduct.id == product.id,
    );
    if (index >= 0) {
      _products[index] = product;
    }
    return product;
  }

  @override
  Future<Product> getProduct(String id) => throw UnimplementedError();

  @override
  Future<void> deleteProduct(String id) => throw UnimplementedError();
}

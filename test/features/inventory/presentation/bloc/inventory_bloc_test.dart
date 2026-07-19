import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_products.dart';
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
    return InventoryBloc(GetProducts(repository));
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

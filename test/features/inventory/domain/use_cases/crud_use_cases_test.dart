import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/create_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/delete_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_products.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/update_product.dart';

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

  late RecordingInventoryRepository repository;

  setUp(() {
    repository = RecordingInventoryRepository(product);
  });

  group('inventory CRUD use cases', () {
    test('GetProducts returns products from the repository', () async {
      final GetProducts useCase = GetProducts(repository);

      expect(await useCase(), <Product>[product]);
      expect(repository.getProductsCallCount, 1);
    });

    test('GetProduct forwards a valid ID', () async {
      final GetProduct useCase = GetProduct(repository);

      expect(await useCase('1'), product);
      expect(repository.requestedProductId, '1');
    });

    test('GetProduct rejects an empty ID before calling the repository', () {
      final GetProduct useCase = GetProduct(repository);

      expect(() => useCase('  '), throwsArgumentError);
      expect(repository.requestedProductId, isNull);
    });

    test('CreateProduct forwards the product', () async {
      final CreateProduct useCase = CreateProduct(repository);

      expect(await useCase(product), product);
      expect(repository.createdProduct, product);
    });

    test('UpdateProduct forwards a product with an ID', () async {
      final UpdateProduct useCase = UpdateProduct(repository);

      expect(await useCase(product), product);
      expect(repository.updatedProduct, product);
    });

    test('UpdateProduct rejects a product without an ID', () {
      const Product newProduct = Product(
        name: 'New Product',
        description: 'Description',
        category: 'Category',
        price: 100,
        stockQuantity: 1,
        sku: 'NEW-001',
        imageUrl: 'assets/images/wireless_mouse.png',
      );
      final UpdateProduct useCase = UpdateProduct(repository);

      expect(() => useCase(newProduct), throwsArgumentError);
      expect(repository.updatedProduct, isNull);
    });

    test('DeleteProduct forwards a valid ID', () async {
      final DeleteProduct useCase = DeleteProduct(repository);

      await useCase('1');

      expect(repository.deletedProductId, '1');
    });

    test('DeleteProduct rejects an empty ID', () {
      final DeleteProduct useCase = DeleteProduct(repository);

      expect(() => useCase(''), throwsArgumentError);
      expect(repository.deletedProductId, isNull);
    });
  });
}

final class RecordingInventoryRepository implements InventoryRepository {
  RecordingInventoryRepository(this.product);

  final Product product;
  int getProductsCallCount = 0;
  String? requestedProductId;
  Product? createdProduct;
  Product? updatedProduct;
  String? deletedProductId;

  @override
  Future<Product> createProduct(Product product) async {
    createdProduct = product;
    return this.product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    deletedProductId = id;
  }

  @override
  Future<Product> getProduct(String id) async {
    requestedProductId = id;
    return product;
  }

  @override
  Future<List<Product>> getProducts() async {
    getProductsCallCount += 1;
    return <Product>[product];
  }

  @override
  Future<Product> updateProduct(Product product) async {
    updatedProduct = product;
    return this.product;
  }
}

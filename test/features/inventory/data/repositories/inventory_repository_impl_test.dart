import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/inventory/data/data_sources/inventory_remote_data_source.dart';
import 'package:inventory_management_app/features/inventory/data/models/product_model.dart';
import 'package:inventory_management_app/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';

void main() {
  const ProductModel model = ProductModel(
    id: '1',
    name: 'Wireless Mouse',
    description: 'Ergonomic wireless mouse',
    category: 'Electronics',
    price: 799,
    stockQuantity: 25,
    sku: 'WM-001',
    imageUrl: 'assets/images/wireless_mouse.png',
  );

  late RecordingRemoteDataSource remoteDataSource;
  late InventoryRepository repository;

  setUp(() {
    remoteDataSource = RecordingRemoteDataSource(model);
    repository = InventoryRepositoryImpl(remoteDataSource);
  });

  group('InventoryRepositoryImpl', () {
    test('returns remote models as domain products', () async {
      final List<Product> products = await repository.getProducts();

      expect(products, <Product>[model]);
      expect(() => products.add(model), throwsUnsupportedError);
    });

    test('forwards an item lookup to the remote data source', () async {
      expect(await repository.getProduct('1'), model);
      expect(remoteDataSource.requestedId, '1');
    });

    test('maps a domain product before creation', () async {
      const Product newProduct = Product(
        name: 'USB-C Hub',
        description: '6-in-1 USB-C Hub',
        category: 'Accessories',
        price: 1499,
        stockQuantity: 18,
        sku: 'HUB-003',
        imageUrl: 'assets/images/usb_c_hub.png',
      );

      await repository.createProduct(newProduct);

      expect(remoteDataSource.createdProduct, isA<ProductModel>());
      expect(remoteDataSource.createdProduct?.sku, 'HUB-003');
    });

    test('maps a domain product before update', () async {
      const Product updatedProduct = Product(
        id: '1',
        name: 'Wireless Mouse',
        description: 'Updated description',
        category: 'Electronics',
        price: 899,
        stockQuantity: 20,
        sku: 'WM-001',
        imageUrl: 'assets/images/wireless_mouse.png',
      );

      await repository.updateProduct(updatedProduct);

      expect(remoteDataSource.updatedProduct, isA<ProductModel>());
      expect(
        remoteDataSource.updatedProduct?.description,
        'Updated description',
      );
    });

    test('forwards deletion by ID', () async {
      await repository.deleteProduct('1');

      expect(remoteDataSource.deletedId, '1');
    });
  });
}

final class RecordingRemoteDataSource implements InventoryRemoteDataSource {
  RecordingRemoteDataSource(this.model);

  final ProductModel model;
  String? requestedId;
  ProductModel? createdProduct;
  ProductModel? updatedProduct;
  String? deletedId;

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    createdProduct = product;
    return model;
  }

  @override
  Future<void> deleteProduct(String id) async {
    deletedId = id;
  }

  @override
  Future<ProductModel> fetchProduct(String id) async {
    requestedId = id;
    return model;
  }

  @override
  Future<List<ProductModel>> fetchProducts() async => <ProductModel>[model];

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    updatedProduct = product;
    return model;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/app/app.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/create_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_products.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/update_product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/product_image.dart';

void main() {
  const Product product = Product(
    id: '1',
    name: 'Wireless Mouse',
    description: 'Ergonomic wireless mouse',
    category: 'Electronics',
    price: 799,
    stockQuantity: 25,
    sku: 'WM-001',
    imageUrl: 'https://cdn.example.com/wireless_mouse.png',
  );

  Future<void> pumpInventoryApp(
    WidgetTester tester,
    InventoryRepository repository,
  ) {
    return tester.pumpWidget(
      InventoryApp(
        inventoryBloc: InventoryBloc(
          GetProducts(repository),
          CreateProduct(repository),
          UpdateProduct(repository),
        ),
      ),
    );
  }

  Future<void> tapFormSubmit(WidgetTester tester) async {
    final Finder submitButton = find.byKey(const Key('product-form-submit'));
    final FilledButton button = tester.widget<FilledButton>(submitButton);
    expect(button.onPressed, isNotNull);
    button.onPressed!();
    await tester.pump();
  }

  testWidgets('shows loading while products are pending', (
    WidgetTester tester,
  ) async {
    final Completer<List<Product>> completer = Completer<List<Product>>();
    final ControlledInventoryRepository repository =
        ControlledInventoryRepository(completer.future);

    await pumpInventoryApp(tester, repository);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(<Product>[product]);
    await tester.pumpAndSettle();
  });

  testWidgets('shows the empty state', (WidgetTester tester) async {
    await pumpInventoryApp(
      tester,
      ControlledInventoryRepository(Future<List<Product>>.value(<Product>[])),
    );
    await tester.pumpAndSettle();

    expect(find.text('No products yet'), findsOneWidget);
  });

  testWidgets('shows a failure message and retry action', (
    WidgetTester tester,
  ) async {
    await pumpInventoryApp(
      tester,
      const FailingInventoryRepository(
        NetworkException('No internet connection.'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load inventory'), findsOneWidget);
    expect(find.text('No internet connection.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('renders products using their hosted image URLs', (
    WidgetTester tester,
  ) async {
    await pumpInventoryApp(
      tester,
      ControlledInventoryRepository(
        Future<List<Product>>.value(<Product>[product]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wireless Mouse'), findsOneWidget);
    expect(find.text('₹799.00'), findsOneWidget);
    final ProductImage image = tester.widget<ProductImage>(
      find.byType(ProductImage).first,
    );
    expect(image.imageUrl, product.imageUrl);
  });

  testWidgets('opens details and receives the selected product', (
    WidgetTester tester,
  ) async {
    await pumpInventoryApp(
      tester,
      ControlledInventoryRepository(
        Future<List<Product>>.value(<Product>[product]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wireless Mouse'));
    await tester.pumpAndSettle();

    expect(find.text('Product details'), findsOneWidget);
    expect(find.text('WM-001'), findsOneWidget);
    expect(find.text('Ergonomic wireless mouse'), findsOneWidget);
    expect(find.text('In stock'), findsOneWidget);
  });

  testWidgets('fits a narrow phone viewport without layout errors', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpInventoryApp(
      tester,
      ControlledInventoryRepository(
        Future<List<Product>>.value(<Product>[product]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wireless Mouse'), findsOneWidget);
    expect(find.byType(SafeArea), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates a product, disables submit, and refreshes the list', (
    WidgetTester tester,
  ) async {
    final PendingCreateInventoryRepository repository =
        PendingCreateInventoryRepository();
    await pumpInventoryApp(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add product'));
    await tester.pumpAndSettle();

    final Finder fields = find.byType(TextFormField);
    final List<String> values = <String>[
      'USB-C Hub',
      '6-in-1 USB-C Hub',
      'Accessories',
      'HUB-003',
      '1499',
      '18',
      'https://cdn.example.com/usb_c_hub.png',
    ];
    for (int index = 0; index < values.length; index++) {
      await tester.enterText(fields.at(index), values[index]);
    }

    await tapFormSubmit(tester);
    await tester.pump();

    final FilledButton disabledButton = tester.widget<FilledButton>(
      find.byKey(const Key('product-form-submit')),
    );
    expect(disabledButton.onPressed, isNull);
    expect(find.text('Saving…'), findsOneWidget);

    repository.completeCreate();
    await tester.pumpAndSettle();

    expect(find.text('USB-C Hub'), findsOneWidget);
    expect(find.text('USB-C Hub was added.'), findsOneWidget);
    expect(repository.getCalls, 2);
  });

  testWidgets('prefills, updates, and refreshes a selected product', (
    WidgetTester tester,
  ) async {
    final MutableInventoryRepository repository = MutableInventoryRepository(
      <Product>[product],
    );
    await pumpInventoryApp(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wireless Mouse'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit product'));
    await tester.pumpAndSettle();

    expect(find.text('Edit product'), findsOneWidget);
    expect(find.text('Wireless Mouse'), findsOneWidget);
    expect(find.text('WM-001'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Wireless Mouse Pro',
    );
    await tapFormSubmit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Product details'), findsOneWidget);
    expect(find.text('Wireless Mouse Pro'), findsOneWidget);
    expect(find.text('Wireless Mouse Pro was updated.'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Wireless Mouse Pro'), findsOneWidget);
    expect(repository.getCalls, 2);
  });
}

final class ControlledInventoryRepository implements InventoryRepository {
  const ControlledInventoryRepository(this.products);

  final Future<List<Product>> products;

  @override
  Future<List<Product>> getProducts() => products;

  @override
  Future<Product> getProduct(String id) => throw UnimplementedError();

  @override
  Future<Product> createProduct(Product product) => throw UnimplementedError();

  @override
  Future<Product> updateProduct(Product product) => throw UnimplementedError();

  @override
  Future<void> deleteProduct(String id) => throw UnimplementedError();
}

final class FailingInventoryRepository implements InventoryRepository {
  const FailingInventoryRepository(this.error);

  final Object error;

  @override
  Future<List<Product>> getProducts() async => throw error;

  @override
  Future<Product> getProduct(String id) => throw UnimplementedError();

  @override
  Future<Product> createProduct(Product product) => throw UnimplementedError();

  @override
  Future<Product> updateProduct(Product product) => throw UnimplementedError();

  @override
  Future<void> deleteProduct(String id) => throw UnimplementedError();
}

class MutableInventoryRepository implements InventoryRepository {
  MutableInventoryRepository(List<Product> products)
    : products = List<Product>.of(products);

  final List<Product> products;
  int getCalls = 0;

  @override
  Future<List<Product>> getProducts() async {
    getCalls += 1;
    return List<Product>.of(products);
  }

  @override
  Future<Product> createProduct(Product product) async {
    final Product savedProduct = _withId(product, '${products.length + 1}');
    products.add(savedProduct);
    return savedProduct;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final int index = products.indexWhere(
      (Product currentProduct) => currentProduct.id == product.id,
    );
    products[index] = product;
    return product;
  }

  static Product _withId(Product product, String id) {
    return Product(
      id: id,
      name: product.name,
      description: product.description,
      category: product.category,
      price: product.price,
      stockQuantity: product.stockQuantity,
      sku: product.sku,
      imageUrl: product.imageUrl,
    );
  }

  @override
  Future<Product> getProduct(String id) => throw UnimplementedError();

  @override
  Future<void> deleteProduct(String id) => throw UnimplementedError();
}

final class PendingCreateInventoryRepository
    extends MutableInventoryRepository {
  PendingCreateInventoryRepository() : super(<Product>[]);

  final Completer<Product> _createCompleter = Completer<Product>();
  Product? _draftProduct;

  @override
  Future<Product> createProduct(Product product) async {
    _draftProduct = product;
    final Product savedProduct = await _createCompleter.future;
    products.add(savedProduct);
    return savedProduct;
  }

  void completeCreate() {
    final Product draftProduct = _draftProduct!;
    _createCompleter.complete(
      MutableInventoryRepository._withId(draftProduct, '1'),
    );
  }
}

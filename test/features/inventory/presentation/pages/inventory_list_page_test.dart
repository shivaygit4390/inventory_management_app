import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/app/app.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/create_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/delete_product.dart';
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
  const Product keyboard = Product(
    id: '2',
    name: 'Mechanical Keyboard',
    description: 'RGB mechanical keyboard',
    category: 'Electronics',
    price: 2499,
    stockQuantity: 12,
    sku: 'KB-002',
    imageUrl: 'https://cdn.example.com/keyboard.png',
  );
  const Product hub = Product(
    id: '3',
    name: 'USB-C Hub',
    description: '6-in-1 USB-C Hub',
    category: 'Accessories',
    price: 1499,
    stockQuantity: 18,
    sku: 'HUB-003',
    imageUrl: 'https://cdn.example.com/hub.png',
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
          DeleteProduct(repository),
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

  Future<void> selectProductCategory(
    WidgetTester tester,
    String category,
  ) async {
    await tester.tap(find.byKey(const Key('product-category-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(category).last);
    await tester.pumpAndSettle();
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

  testWidgets('opens statistics from an explicit blocking header action', (
    WidgetTester tester,
  ) async {
    await pumpInventoryApp(
      tester,
      ControlledInventoryRepository(
        Future<List<Product>>.value(<Product>[product, keyboard, hub]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Inventory overview'), findsNothing);

    await tester.tap(find.byKey(const Key('inventory-statistics-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('inventory-statistics-dialog')),
      findsOneWidget,
    );
    expect(find.text('Inventory statistics'), findsOneWidget);
    expect(find.text('Inventory overview'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Units'), findsOneWidget);
    final ModalBarrier barrier = tester.widget<ModalBarrier>(
      find.byType(ModalBarrier).last,
    );
    expect(barrier.dismissible, isFalse);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Inventory overview'), findsNothing);
    expect(find.text('Wireless Mouse'), findsOneWidget);

    await tester.tap(find.byKey(const Key('inventory-statistics-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('close-inventory-statistics')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('inventory-statistics-dialog')), findsNothing);
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
    expect(
      tester.getSize(find.byKey(const Key('inventory-home-header'))).height,
      62,
    );
    expect(
      tester.getSize(find.byType(ListView)).height,
      greaterThanOrEqualTo(525),
    );
    final BuildContext productContext = tester.element(
      find.text('Wireless Mouse'),
    );
    expect(Theme.of(productContext).textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(tester.takeException(), isNull);
  });

  testWidgets('adapts the inventory list to phone landscape', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(700, 360);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpInventoryApp(
      tester,
      ControlledInventoryRepository(
        Future<List<Product>>.value(<Product>[product, keyboard, hub]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Inventory overview'), findsNothing);
    expect(find.text('Wireless Mouse'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses a three-column product grid on wide layouts', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpInventoryApp(
      tester,
      ControlledInventoryRepository(
        Future<List<Product>>.value(<Product>[product, keyboard, hub]),
      ),
    );
    await tester.pumpAndSettle();

    final GridView grid = tester.widget<GridView>(find.byType(GridView));
    final SliverGridDelegateWithFixedCrossAxisCount delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 3);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Inventory overview'), findsNothing);
    expect(find.text('Wireless Mouse'), findsOneWidget);
    expect(find.text('Mechanical Keyboard'), findsOneWidget);
    expect(find.text('USB-C Hub'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adapts product details to a tablet layout', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 768);
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
    await tester.tap(find.text('Wireless Mouse'));
    await tester.pumpAndSettle();

    expect(find.text('Product details'), findsOneWidget);
    expect(find.text('About this product'), findsOneWidget);
    expect(find.text('WM-001'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses a two-plus-one details grid on narrow phones', (
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
    await tester.tap(find.text('Wireless Mouse'));
    await tester.pumpAndSettle();

    final Offset skuPosition = tester.getTopLeft(find.text('SKU'));
    final Offset stockPosition = tester.getTopLeft(find.text('Stock quantity'));
    final Offset availabilityPosition = tester.getTopLeft(
      find.text('Availability'),
    );
    expect(skuPosition.dy, stockPosition.dy);
    expect(availabilityPosition.dy, greaterThan(stockPosition.dy));
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

    await selectProductCategory(tester, 'Accessories');

    final Finder fields = find.byType(TextFormField);
    final List<String> values = <String>[
      'USB-C Hub',
      '6-in-1 USB-C Hub',
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

  testWidgets('searches across product fields and clears the query', (
    WidgetTester tester,
  ) async {
    await pumpInventoryApp(
      tester,
      ControlledInventoryRepository(
        Future<List<Product>>.value(<Product>[product, keyboard, hub]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('inventory-search-field')),
      'KB-002',
    );
    await tester.pump();

    expect(find.text('Mechanical Keyboard'), findsOneWidget);
    expect(find.text('Wireless Mouse'), findsNothing);
    expect(find.text('USB-C Hub'), findsNothing);
    expect(find.text('1 of 3 products'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text('Wireless Mouse'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -360));
    await tester.pump();
    expect(find.text('USB-C Hub'), findsOneWidget);
  });

  testWidgets('keeps header and filters visible while scrolling', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpInventoryApp(
      tester,
      ControlledInventoryRepository(
        Future<List<Product>>.value(<Product>[product, keyboard, hub]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stats'), findsOneWidget);
    expect(find.byKey(const Key('inventory-search-field')), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();
    expect(find.text('Stats'), findsOneWidget);
    expect(find.byKey(const Key('inventory-search-field')), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, 24));
    await tester.pumpAndSettle();
    expect(find.text('Stats'), findsOneWidget);
    expect(find.byKey(const Key('inventory-search-field')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('combines category filtering with the current search', (
    WidgetTester tester,
  ) async {
    await pumpInventoryApp(
      tester,
      ControlledInventoryRepository(
        Future<List<Product>>.value(<Product>[product, keyboard, hub]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('inventory-category-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accessories').last);
    await tester.pumpAndSettle();

    expect(find.text('USB-C Hub'), findsOneWidget);
    expect(find.text('Wireless Mouse'), findsNothing);
    expect(find.text('1 of 3 products'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('inventory-search-field')),
      'mouse',
    );
    await tester.pump();

    expect(find.text('No matching products'), findsOneWidget);
    expect(find.text('0 of 3 products'), findsNothing);
  });

  testWidgets('cancels deletion without changing inventory', (
    WidgetTester tester,
  ) async {
    final MutableInventoryRepository repository = MutableInventoryRepository(
      <Product>[product],
    );
    await pumpInventoryApp(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wireless Mouse'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete product'));
    await tester.pumpAndSettle();

    expect(find.text('Delete product?'), findsOneWidget);
    expect(find.textContaining('cannot be undone'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Product details'), findsOneWidget);
    expect(repository.deleteCalls, 0);
  });

  testWidgets('confirms deletion and refreshes the list', (
    WidgetTester tester,
  ) async {
    final MutableInventoryRepository repository = MutableInventoryRepository(
      <Product>[product, keyboard],
    );
    await pumpInventoryApp(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wireless Mouse'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete product'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-product-deletion')));
    await tester.pumpAndSettle();

    expect(find.text('Wireless Mouse'), findsNothing);
    expect(find.text('Mechanical Keyboard'), findsOneWidget);
    expect(find.text('Wireless Mouse was deleted.'), findsOneWidget);
    expect(repository.deleteCalls, 1);
    expect(repository.getCalls, 2);
  });

  testWidgets('pull-to-refresh fetches and displays the latest products', (
    WidgetTester tester,
  ) async {
    final MutableInventoryRepository repository = MutableInventoryRepository(
      <Product>[product],
    );
    await pumpInventoryApp(tester, repository);
    await tester.pumpAndSettle();
    repository.products.add(hub);

    await tester.drag(find.byType(ListView).first, const Offset(0, 320));
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -220));
    await tester.pump();
    expect(find.text('USB-C Hub'), findsOneWidget);
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
  int deleteCalls = 0;

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
  Future<void> deleteProduct(String id) async {
    deleteCalls += 1;
    products.removeWhere((Product product) => product.id == id);
  }
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

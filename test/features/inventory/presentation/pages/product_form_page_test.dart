import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/core/constants/product_image_constants.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/create_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/delete_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_products.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/update_product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/pages/product_form_page.dart';

void main() {
  const Product existingProduct = Product(
    id: '1',
    name: 'Wireless Mouse',
    description: 'Ergonomic wireless mouse',
    category: 'Electronics',
    price: 799,
    stockQuantity: 25,
    sku: 'WM-001',
    imageUrl: 'https://cdn.example.com/wireless_mouse.png',
  );

  Future<void> pumpForm(
    WidgetTester tester,
    FormInventoryRepository repository, {
    Product? initialProduct,
  }) async {
    final InventoryBloc bloc = InventoryBloc(
      GetProducts(repository),
      CreateProduct(repository),
      UpdateProduct(repository),
      DeleteProduct(repository),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider<InventoryBloc>.value(
        value: bloc,
        child: MaterialApp(
          home: ProductFormPage(initialProduct: initialProduct),
        ),
      ),
    );
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    final Finder submitButton = find.byKey(const Key('product-form-submit'));
    final FilledButton button = tester.widget<FilledButton>(submitButton);
    expect(button.onPressed, isNotNull);
    button.onPressed!();
    await tester.pump();
  }

  Future<void> selectCategory(WidgetTester tester, String category) async {
    await tester.tap(find.byKey(const Key('product-category-dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(category).last);
    await tester.pumpAndSettle();
  }

  testWidgets('shows add mode with the default hosted image URL', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester, FormInventoryRepository());

    expect(find.text('Add product'), findsNWidgets(2));
    expect(find.widgetWithText(TextFormField, 'Product name'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
    expect(find.byKey(const Key('product-category-dropdown')), findsOneWidget);
    expect(find.text(ProductImageConstants.defaultImageUrl), findsOneWidget);
    expect(find.text('Image preview'), findsOneWidget);
  });

  testWidgets('shows required errors and does not submit an invalid form', (
    WidgetTester tester,
  ) async {
    final FormInventoryRepository repository = FormInventoryRepository();
    await pumpForm(tester, repository);

    await tester.enterText(find.byType(TextFormField).last, '');

    await tapSubmit(tester);
    await tester.pump();

    expect(find.text('Product name is required.'), findsOneWidget);
    expect(find.text('Description is required.'), findsOneWidget);
    expect(find.text('Category is required.'), findsOneWidget);
    expect(find.text('Price is required.'), findsOneWidget);
    expect(find.text('Stock quantity is required.'), findsOneWidget);
    expect(find.text('SKU is required.'), findsOneWidget);
    expect(find.text('Image URL is required.'), findsOneWidget);
    expect(repository.createdProduct, isNull);
  });

  testWidgets('trims valid values and creates a domain Product', (
    WidgetTester tester,
  ) async {
    final FormInventoryRepository repository = FormInventoryRepository();
    await pumpForm(tester, repository);

    await selectCategory(tester, 'Electronics');

    final List<String> values = <String>[
      '  Wireless Mouse  ',
      '  Ergonomic wireless mouse  ',
      '  WM-001  ',
      '799.50',
      '25',
      '  https://cdn.example.com/wireless_mouse.png  ',
    ];
    final Finder fields = find.byType(TextFormField);
    for (int index = 0; index < values.length; index++) {
      await tester.enterText(fields.at(index), values[index]);
    }

    await tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(
      repository.createdProduct,
      const Product(
        name: 'Wireless Mouse',
        description: 'Ergonomic wireless mouse',
        category: 'Electronics',
        price: 799.5,
        stockQuantity: 25,
        sku: 'WM-001',
        imageUrl: 'https://cdn.example.com/wireless_mouse.png',
      ),
    );
  });

  testWidgets('prefills edit mode and preserves the product ID', (
    WidgetTester tester,
  ) async {
    final FormInventoryRepository repository = FormInventoryRepository(
      products: <Product>[existingProduct],
    );
    await pumpForm(tester, repository, initialProduct: existingProduct);

    expect(find.text('Edit product'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Wireless Mouse'), findsOneWidget);
    expect(find.text('WM-001'), findsOneWidget);

    await tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(repository.updatedProduct, existingProduct);
  });

  testWidgets('fits a narrow phone viewport without layout errors', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpForm(tester, FormInventoryRepository());
    await tester.pump();

    expect(find.byType(SafeArea), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a wide desktop viewport without layout errors', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpForm(tester, FormInventoryRepository());
    await tester.pump();

    expect(find.text('Product identity'), findsOneWidget);
    expect(find.text('Price and stock'), findsOneWidget);
    expect(find.text('Product image'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows mutation errors and keeps the form open for retry', (
    WidgetTester tester,
  ) async {
    final FormInventoryRepository repository = FormInventoryRepository(
      mutationError: const NetworkException('Unable to reach the server.'),
    );
    await pumpForm(tester, repository);

    await selectCategory(tester, 'Accessories');

    final List<String> values = <String>[
      'USB-C Hub',
      '6-in-1 USB-C Hub',
      'HUB-003',
      '1499',
      '18',
      'https://cdn.example.com/usb_c_hub.png',
    ];
    final Finder fields = find.byType(TextFormField);
    for (int index = 0; index < values.length; index++) {
      await tester.enterText(fields.at(index), values[index]);
    }

    await tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(find.text('Unable to reach the server.'), findsOneWidget);
    expect(find.text('Add product'), findsNWidgets(2));
    expect(find.text('USB-C Hub'), findsOneWidget);
  });
}

final class FormInventoryRepository implements InventoryRepository {
  FormInventoryRepository({List<Product>? products, this.mutationError})
    : _products = <Product>[...?products];

  final List<Product> _products;
  final Object? mutationError;
  Product? createdProduct;
  Product? updatedProduct;

  @override
  Future<List<Product>> getProducts() async => List<Product>.of(_products);

  @override
  Future<Product> createProduct(Product product) async {
    createdProduct = product;
    final Object? currentError = mutationError;
    if (currentError != null) {
      throw currentError;
    }
    final Product savedProduct = Product(
      id: 'created-id',
      name: product.name,
      description: product.description,
      category: product.category,
      price: product.price,
      stockQuantity: product.stockQuantity,
      sku: product.sku,
      imageUrl: product.imageUrl,
    );
    _products.add(savedProduct);
    return savedProduct;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    updatedProduct = product;
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

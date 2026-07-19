import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/app/app.dart';
import 'package:inventory_management_app/core/errors/app_exception.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_products.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';

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

  Future<void> pumpInventoryApp(
    WidgetTester tester,
    InventoryRepository repository,
  ) {
    return tester.pumpWidget(
      InventoryApp(inventoryBloc: InventoryBloc(GetProducts(repository))),
    );
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

  testWidgets('renders products using their local asset paths', (
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
    final Image image = tester.widget<Image>(find.byType(Image).first);
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, product.imageUrl);
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

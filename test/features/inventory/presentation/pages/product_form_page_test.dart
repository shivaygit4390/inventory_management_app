import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
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
    imageUrl: 'assets/images/wireless_mouse.png',
  );

  Future<void> pumpForm(
    WidgetTester tester, {
    Product? initialProduct,
    ValueChanged<Product>? onSubmit,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: ProductFormPage(
          initialProduct: initialProduct,
          onSubmit: onSubmit ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('shows add mode with empty fields', (WidgetTester tester) async {
    await pumpForm(tester);

    expect(find.text('Add product'), findsNWidgets(2));
    expect(find.widgetWithText(TextFormField, 'Product name'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(7));
  });

  testWidgets('shows required errors and does not submit an invalid form', (
    WidgetTester tester,
  ) async {
    Product? submittedProduct;
    await pumpForm(
      tester,
      onSubmit: (Product value) => submittedProduct = value,
    );

    await tester.tap(find.byKey(const Key('product-form-submit')));
    await tester.pump();

    expect(find.text('Product name is required.'), findsOneWidget);
    expect(find.text('Description is required.'), findsOneWidget);
    expect(find.text('Category is required.'), findsOneWidget);
    expect(find.text('Price is required.'), findsOneWidget);
    expect(find.text('Stock quantity is required.'), findsOneWidget);
    expect(find.text('SKU is required.'), findsOneWidget);
    expect(find.text('Image path is required.'), findsOneWidget);
    expect(submittedProduct, isNull);
  });

  testWidgets('trims valid values and submits a domain Product', (
    WidgetTester tester,
  ) async {
    Product? submittedProduct;
    await pumpForm(
      tester,
      onSubmit: (Product value) => submittedProduct = value,
    );

    final List<String> values = <String>[
      '  Wireless Mouse  ',
      '  Ergonomic wireless mouse  ',
      '  Electronics  ',
      '  WM-001  ',
      '799.50',
      '25',
      '  assets/images/wireless_mouse.png  ',
    ];
    final Finder fields = find.byType(TextFormField);
    for (int index = 0; index < values.length; index++) {
      await tester.enterText(fields.at(index), values[index]);
    }

    await tester.tap(find.byKey(const Key('product-form-submit')));
    await tester.pump();

    expect(
      submittedProduct,
      const Product(
        name: 'Wireless Mouse',
        description: 'Ergonomic wireless mouse',
        category: 'Electronics',
        price: 799.5,
        stockQuantity: 25,
        sku: 'WM-001',
        imageUrl: 'assets/images/wireless_mouse.png',
      ),
    );
  });

  testWidgets('uses one form in edit mode and preserves the product ID', (
    WidgetTester tester,
  ) async {
    Product? submittedProduct;
    await pumpForm(
      tester,
      initialProduct: existingProduct,
      onSubmit: (Product value) => submittedProduct = value,
    );

    expect(find.text('Edit product'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Wireless Mouse'), findsOneWidget);
    expect(find.text('WM-001'), findsOneWidget);

    await tester.tap(find.byKey(const Key('product-form-submit')));
    await tester.pump();

    expect(submittedProduct, existingProduct);
  });

  testWidgets('fits a narrow phone viewport without layout errors', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpForm(tester);
    await tester.pump();

    expect(find.byType(SafeArea), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}

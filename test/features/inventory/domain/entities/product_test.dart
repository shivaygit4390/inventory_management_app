import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

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

  group('Product', () {
    test('uses value equality', () {
      const Product matchingProduct = Product(
        id: '1',
        name: 'Wireless Mouse',
        description: 'Ergonomic wireless mouse',
        category: 'Electronics',
        price: 799,
        stockQuantity: 25,
        sku: 'WM-001',
        imageUrl: 'https://cdn.example.com/wireless_mouse.png',
      );

      expect(product, matchingProduct);
    });

    test('reports whether stock is available', () {
      const Product outOfStockProduct = Product(
        name: 'USB-C Hub',
        description: '6-in-1 USB-C Hub',
        category: 'Accessories',
        price: 1499,
        stockQuantity: 0,
        sku: 'HUB-003',
        imageUrl: 'https://cdn.example.com/usb_c_hub.png',
      );

      expect(product.isInStock, isTrue);
      expect(outOfStockProduct.isInStock, isFalse);
    });
  });
}

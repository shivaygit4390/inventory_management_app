import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/inventory/data/models/product_model.dart';

void main() {
  group('ProductModel', () {
    test('maps API JSON and preserves the local image asset path', () {
      final ProductModel product = ProductModel.fromJson(<String, dynamic>{
        'createdAt': '2026-07-18T05:10:28.002Z',
        'id': '1',
        'name': 'Wireless Mouse',
        'description': 'Ergonomic wireless mouse',
        'category': 'Electronics',
        'price': 799,
        'stockQuantity': 25,
        'sku': 'WM-001',
        'imageUrl': 'assets/images/wireless_mouse.png',
      });

      expect(product.id, '1');
      expect(product.price, 799.0);
      expect(product.stockQuantity, 25);
      expect(product.imageUrl, 'assets/images/wireless_mouse.png');
    });

    test('accepts numeric strings returned by compatible mock APIs', () {
      final ProductModel product = ProductModel.fromJson(<String, dynamic>{
        'id': '2',
        'name': 'Mechanical Keyboard',
        'description': 'RGB mechanical keyboard',
        'category': 'Electronics',
        'price': '2499.0',
        'stockQuantity': '12',
        'sku': 'KB-002',
        'imageUrl': 'assets/images/mechanical_keyboard.png',
      });

      expect(product.price, 2499.0);
      expect(product.stockQuantity, 12);
    });

    test('toJson includes writable fields but excludes server fields', () {
      const ProductModel product = ProductModel(
        id: '3',
        name: 'USB-C Hub',
        description: '6-in-1 USB-C Hub',
        category: 'Accessories',
        price: 1499,
        stockQuantity: 18,
        sku: 'HUB-003',
        imageUrl: 'assets/images/usb_c_hub.png',
      );

      expect(product.toJson(), <String, Object?>{
        'name': 'USB-C Hub',
        'description': '6-in-1 USB-C Hub',
        'category': 'Accessories',
        'price': 1499.0,
        'stockQuantity': 18,
        'sku': 'HUB-003',
        'imageUrl': 'assets/images/usb_c_hub.png',
      });
      expect(product.toJson(), isNot(contains('id')));
      expect(product.toJson(), isNot(contains('createdAt')));
    });

    test('rejects a fractional stock quantity', () {
      expect(
        () => ProductModel.fromJson(<String, dynamic>{
          'id': '1',
          'name': 'Mouse',
          'description': 'Description',
          'category': 'Electronics',
          'price': 799,
          'stockQuantity': 2.5,
          'sku': 'WM-001',
          'imageUrl': 'assets/images/wireless_mouse.png',
        }),
        throwsFormatException,
      );
    });
  });
}

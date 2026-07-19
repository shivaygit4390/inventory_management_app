import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/inventory/data/models/product_model.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';

void main() {
  group('ProductModel', () {
    test('maps API JSON and preserves the hosted image URL', () {
      final ProductModel product = ProductModel.fromJson(<String, dynamic>{
        'createdAt': '2026-07-18T05:10:28.002Z',
        'id': '1',
        'name': 'Wireless Mouse',
        'description': 'Ergonomic wireless mouse',
        'category': 'Electronics',
        'price': 799,
        'stockQuantity': 25,
        'sku': 'WM-001',
        'imageUrl': 'https://cdn.example.com/wireless_mouse.png',
      });

      expect(product.id, '1');
      expect(product.price, 799.0);
      expect(product.stockQuantity, 25);
      expect(product.imageUrl, 'https://cdn.example.com/wireless_mouse.png');
      expect(product, isA<Product>());
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
        'imageUrl': 'https://cdn.example.com/mechanical_keyboard.png',
      });

      expect(product.price, 2499.0);
      expect(product.stockQuantity, 12);
    });

    test('maps a domain entity into an API model', () {
      const Product entity = Product(
        id: '3',
        name: 'USB-C Hub',
        description: '6-in-1 USB-C Hub',
        category: 'Accessories',
        price: 1499,
        stockQuantity: 18,
        sku: 'HUB-003',
        imageUrl: 'https://cdn.example.com/usb_c_hub.png',
      );

      final ProductModel model = ProductModel.fromEntity(entity);

      expect(model.id, entity.id);
      expect(model.toJson(), <String, Object?>{
        'name': 'USB-C Hub',
        'description': '6-in-1 USB-C Hub',
        'category': 'Accessories',
        'price': 1499.0,
        'stockQuantity': 18,
        'sku': 'HUB-003',
        'imageUrl': 'https://cdn.example.com/usb_c_hub.png',
      });
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
        imageUrl: 'https://cdn.example.com/usb_c_hub.png',
      );

      expect(product.toJson(), <String, Object?>{
        'name': 'USB-C Hub',
        'description': '6-in-1 USB-C Hub',
        'category': 'Accessories',
        'price': 1499.0,
        'stockQuantity': 18,
        'sku': 'HUB-003',
        'imageUrl': 'https://cdn.example.com/usb_c_hub.png',
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
          'imageUrl': 'https://cdn.example.com/wireless_mouse.png',
        }),
        throwsFormatException,
      );
    });
  });
}

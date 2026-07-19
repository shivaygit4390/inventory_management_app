import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/features/inventory/presentation/validation/product_form_validators.dart';

void main() {
  group('ProductFormValidators', () {
    test('requires every text field and trims whitespace', () {
      expect(ProductFormValidators.name('   '), 'Product name is required.');
      expect(
        ProductFormValidators.description(null),
        'Description is required.',
      );
      expect(ProductFormValidators.category(''), 'Category is required.');
      expect(ProductFormValidators.sku(' '), 'SKU is required.');
      expect(ProductFormValidators.imageUrl(null), 'Image path is required.');
    });

    test('validates positive finite prices', () {
      expect(ProductFormValidators.price(''), 'Price is required.');
      expect(ProductFormValidators.price('free'), 'Enter a valid price.');
      expect(
        ProductFormValidators.price('0'),
        'Price must be greater than zero.',
      );
      expect(ProductFormValidators.price('799.50'), isNull);
    });

    test('validates non-negative whole-number stock', () {
      expect(
        ProductFormValidators.stockQuantity(''),
        'Stock quantity is required.',
      );
      expect(
        ProductFormValidators.stockQuantity('1.5'),
        'Enter a whole number.',
      );
      expect(
        ProductFormValidators.stockQuantity('-1'),
        'Stock quantity cannot be negative.',
      );
      expect(ProductFormValidators.stockQuantity('0'), isNull);
      expect(ProductFormValidators.stockQuantity('25'), isNull);
    });

    test('rejects text longer than its field limit', () {
      expect(
        ProductFormValidators.name('a' * 101),
        'Product name must be 100 characters or fewer.',
      );
      expect(ProductFormValidators.name('Mouse'), isNull);
    });
  });
}

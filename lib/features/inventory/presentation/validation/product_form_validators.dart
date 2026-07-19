abstract final class ProductFormValidators {
  static String? name(String? value) =>
      _requiredText(value, fieldName: 'Product name', maximumLength: 100);

  static String? description(String? value) =>
      _requiredText(value, fieldName: 'Description', maximumLength: 500);

  static String? category(String? value) =>
      _requiredText(value, fieldName: 'Category', maximumLength: 50);

  static String? sku(String? value) =>
      _requiredText(value, fieldName: 'SKU', maximumLength: 50);

  static String? imageUrl(String? value) =>
      _requiredText(value, fieldName: 'Image path', maximumLength: 250);

  static String? price(String? value) {
    final String normalizedValue = value?.trim() ?? '';
    if (normalizedValue.isEmpty) {
      return 'Price is required.';
    }

    final double? parsedPrice = double.tryParse(normalizedValue);
    if (parsedPrice == null || !parsedPrice.isFinite) {
      return 'Enter a valid price.';
    }
    if (parsedPrice <= 0) {
      return 'Price must be greater than zero.';
    }

    return null;
  }

  static String? stockQuantity(String? value) {
    final String normalizedValue = value?.trim() ?? '';
    if (normalizedValue.isEmpty) {
      return 'Stock quantity is required.';
    }

    final int? parsedQuantity = int.tryParse(normalizedValue);
    if (parsedQuantity == null) {
      return 'Enter a whole number.';
    }
    if (parsedQuantity < 0) {
      return 'Stock quantity cannot be negative.';
    }

    return null;
  }

  static String? _requiredText(
    String? value, {
    required String fieldName,
    required int maximumLength,
  }) {
    final String normalizedValue = value?.trim() ?? '';
    if (normalizedValue.isEmpty) {
      return '$fieldName is required.';
    }
    if (normalizedValue.length > maximumLength) {
      return '$fieldName must be $maximumLength characters or fewer.';
    }

    return null;
  }
}

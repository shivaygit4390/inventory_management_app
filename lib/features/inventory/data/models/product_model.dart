import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  const ProductModel({
    this.id = '',
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.sku,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      description: _readString(json, 'description'),
      category: _readString(json, 'category'),
      price: _readDouble(json, 'price'),
      stockQuantity: _readInt(json, 'stockQuantity'),
      sku: _readString(json, 'sku'),
      imageUrl: _readString(json, 'imageUrl'),
    );
  }

  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stockQuantity;
  final String sku;
  final String imageUrl;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stockQuantity': stockQuantity,
      'sku': sku,
      'imageUrl': imageUrl,
    };
  }

  @override
  List<Object> get props => <Object>[
    id,
    name,
    description,
    category,
    price,
    stockQuantity,
    sku,
    imageUrl,
  ];

  static String _readString(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is String) {
      return value;
    }
    throw FormatException('Expected "$key" to be a string.');
  }

  static double _readDouble(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    throw FormatException('Expected "$key" to be a number.');
  }

  static int _readInt(Map<String, dynamic> json, String key) {
    final Object? value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num && value == value.roundToDouble()) {
      return value.toInt();
    }
    if (value is String) {
      final int? parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    throw FormatException('Expected "$key" to be a whole number.');
  }
}

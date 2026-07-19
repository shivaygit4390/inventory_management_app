import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    this.id = '',
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.sku,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stockQuantity;
  final String sku;
  final String imageUrl;

  bool get isInStock => stockQuantity > 0;

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
}

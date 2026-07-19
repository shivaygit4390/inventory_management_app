import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/app/app.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/create_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/delete_product.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/get_products.dart';
import 'package:inventory_management_app/features/inventory/domain/use_cases/update_product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';

void main() {
  testWidgets('starts the inventory application', (WidgetTester tester) async {
    final InventoryBloc bloc = InventoryBloc(
      GetProducts(const EmptyInventoryRepository()),
      CreateProduct(const EmptyInventoryRepository()),
      UpdateProduct(const EmptyInventoryRepository()),
      DeleteProduct(const EmptyInventoryRepository()),
    );

    await tester.pumpWidget(InventoryApp(inventoryBloc: bloc));
    await tester.pumpAndSettle();

    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('No products yet'), findsOneWidget);
  });
}

final class EmptyInventoryRepository implements InventoryRepository {
  const EmptyInventoryRepository();

  @override
  Future<List<Product>> getProducts() async => const <Product>[];

  @override
  Future<Product> getProduct(String id) => throw UnimplementedError();

  @override
  Future<Product> createProduct(Product product) => throw UnimplementedError();

  @override
  Future<Product> updateProduct(Product product) => throw UnimplementedError();

  @override
  Future<void> deleteProduct(String id) => throw UnimplementedError();
}

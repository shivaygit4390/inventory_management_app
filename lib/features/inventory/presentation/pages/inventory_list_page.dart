import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:inventory_management_app/features/inventory/presentation/pages/product_details_page.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/inventory_status_view.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/product_card.dart';

class InventoryListPage extends StatefulWidget {
  const InventoryListPage({super.key});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(const InventoryProductsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (BuildContext context, InventoryState state) {
          return switch (state) {
            InventoryInitial() || InventoryLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            InventoryLoaded(:final List<Product> products) => _ProductList(
              products: products,
            ),
            InventoryEmpty() => const InventoryStatusView(
              icon: Icons.inventory_2_outlined,
              title: 'No products yet',
              message: 'Products added to your inventory will appear here.',
            ),
            InventoryFailure(:final String message) => InventoryStatusView(
              icon: Icons.cloud_off_outlined,
              title: 'Unable to load inventory',
              message: message,
              actionLabel: 'Try again',
              onAction: () => context.read<InventoryBloc>().add(
                const InventoryProductsRequested(),
              ),
            ),
          };
        },
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: products.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final Product product = products[index];
              return ProductCard(
                key: ValueKey<String>(product.id),
                product: product,
                onTap: () => _openDetails(context, product),
              );
            },
          ),
        ),
      ),
    );
  }

  static Future<void> _openDetails(BuildContext context, Product product) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ProductDetailsPage(product: product),
      ),
    );
  }
}

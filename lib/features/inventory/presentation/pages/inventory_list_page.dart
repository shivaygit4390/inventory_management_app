import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:inventory_management_app/features/inventory/presentation/pages/product_details_page.dart';
import 'package:inventory_management_app/features/inventory/presentation/pages/product_form_page.dart';
import 'package:inventory_management_app/features/inventory/presentation/utils/inventory_product_filter.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/inventory_filter_bar.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/inventory_status_view.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/product_card.dart';

class InventoryListPage extends StatefulWidget {
  const InventoryListPage({super.key});

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends State<InventoryListPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<InventoryBloc>().add(const InventoryProductsRequested());
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddProduct(context),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listenWhen: (InventoryState previous, InventoryState current) =>
            current is InventoryRefreshFailure,
        listener: (BuildContext context, InventoryState state) {
          if (state case InventoryRefreshFailure(:final String message)) {
            final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
              context,
            );
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (BuildContext context, InventoryState state) {
          return switch (state) {
            InventoryInitial() || InventoryLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            InventoryProductsState(:final List<Product> products) =>
              _InventoryContent(
                products: products,
                searchController: _searchController,
                selectedCategory: _selectedCategory,
                onCategoryChanged: _onCategoryChanged,
                onRefresh: _refreshProducts,
                onProductTap: _openDetails,
              ),
            InventoryEmpty() => _RefreshableStatus(
              onRefresh: _refreshProducts,
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

  void _onSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onCategoryChanged(String? category) {
    setState(() => _selectedCategory = category);
  }

  Future<void> _refreshProducts() async {
    final InventoryBloc bloc = context.read<InventoryBloc>();
    if (bloc.state is InventoryRefreshing ||
        bloc.state is InventoryMutationInProgress ||
        bloc.state is InventoryLoading) {
      return;
    }

    final Future<InventoryState> completion = bloc.stream.firstWhere(
      (InventoryState state) =>
          state is InventoryLoaded ||
          state is InventoryEmpty ||
          state is InventoryRefreshFailure,
    );
    bloc.add(const InventoryProductsRefreshRequested());
    await completion;
  }

  Future<void> _openAddProduct(BuildContext context) async {
    final Product? createdProduct = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (BuildContext context) => const ProductFormPage(),
      ),
    );
    if (!context.mounted || createdProduct == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${createdProduct.name} was added.')),
    );
  }

  Future<void> _openDetails(Product product) async {
    final Product? deletedProduct = await Navigator.of(context).push<Product>(
      MaterialPageRoute<Product>(
        builder: (BuildContext context) => ProductDetailsPage(product: product),
      ),
    );
    if (!mounted || deletedProduct == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${deletedProduct.name} was deleted.')),
    );
  }
}

class _InventoryContent extends StatelessWidget {
  const _InventoryContent({
    required this.products,
    required this.searchController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onRefresh,
    required this.onProductTap,
  });

  final List<Product> products;
  final TextEditingController searchController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final RefreshCallback onRefresh;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return _RefreshableStatus(
        onRefresh: onRefresh,
        icon: Icons.inventory_2_outlined,
        title: 'No products yet',
        message: 'Products added to your inventory will appear here.',
      );
    }

    final List<String> categories = InventoryProductFilter.categories(products);
    final List<Product> visibleProducts = InventoryProductFilter.apply(
      products: products,
      query: searchController.text,
      category: selectedCategory,
    );

    return Column(
      children: [
        InventoryFilterBar(
          searchController: searchController,
          categories: categories,
          selectedCategory: selectedCategory,
          onCategoryChanged: onCategoryChanged,
          visibleProductCount: visibleProducts.length,
          totalProductCount: products.length,
        ),
        Expanded(
          child: visibleProducts.isEmpty
              ? _RefreshableStatus(
                  onRefresh: onRefresh,
                  icon: Icons.search_off_outlined,
                  title: 'No matching products',
                  message: 'Try a different search or category filter.',
                )
              : _ProductList(
                  products: visibleProducts,
                  onRefresh: onRefresh,
                  onProductTap: onProductTap,
                ),
        ),
      ],
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.products,
    required this.onRefresh,
    required this.onProductTap,
  });

  final List<Product> products;
  final RefreshCallback onRefresh;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              itemCount: products.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                final Product product = products[index];
                return ProductCard(
                  key: ValueKey<String>(product.id),
                  product: product,
                  onTap: () => onProductTap(product),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _RefreshableStatus extends StatelessWidget {
  const _RefreshableStatus({
    required this.onRefresh,
    required this.icon,
    required this.title,
    required this.message,
  });

  final RefreshCallback onRefresh;
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: InventoryStatusView(
                  icon: icon,
                  title: title,
                  message: message,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_management_app/app/layout/app_breakpoints.dart';
import 'package:inventory_management_app/app/theme/app_theme.dart';
import 'package:inventory_management_app/app/widgets/inventory_scaffold.dart';
import 'package:inventory_management_app/features/inventory/domain/entities/product.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:inventory_management_app/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:inventory_management_app/features/inventory/presentation/pages/product_details_page.dart';
import 'package:inventory_management_app/features/inventory/presentation/pages/product_form_page.dart';
import 'package:inventory_management_app/features/inventory/presentation/utils/inventory_product_filter.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/inventory_feedback.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/inventory_filter_bar.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/inventory_loading_view.dart';
import 'package:inventory_management_app/features/inventory/presentation/widgets/inventory_overview.dart';
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
    return InventoryScaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: BlocBuilder<InventoryBloc, InventoryState>(
          buildWhen: (InventoryState previous, InventoryState current) =>
              previous.runtimeType != current.runtimeType ||
              previous is InventoryProductsState ||
              current is InventoryProductsState,
          builder: (BuildContext context, InventoryState state) {
            final List<Product>? products = switch (state) {
              InventoryProductsState(:final List<Product> products) => products,
              _ => null,
            };
            return InventoryAppBar(
              title: 'Inventory',
              subtitle: 'Product catalog and stock',
              showBrandMark: true,
              automaticallyImplyLeading: false,
              height: 62,
              useGradientBackground: true,
              headerKey: const Key('inventory-home-header'),
              actions: <Widget>[
                _StatisticsButton(
                  onPressed: products == null
                      ? null
                      : () => _showStatistics(products),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: GradientActionButton(
        onPressed: () => _openAddProduct(context),
        icon: Icons.add_rounded,
        label: 'Add product',
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listenWhen: (InventoryState previous, InventoryState current) =>
            current is InventoryRefreshFailure,
        listener: (BuildContext context, InventoryState state) {
          if (state case InventoryRefreshFailure(:final String message)) {
            InventoryFeedback.error(context, message);
          }
        },
        builder: (BuildContext context, InventoryState state) {
          return switch (state) {
            InventoryInitial() ||
            InventoryLoading() => const InventoryLoadingView(),
            InventoryProductsState(:final List<Product> products) =>
              _InventoryContent(
                products: products,
                isRefreshing: state is InventoryRefreshing,
                searchController: _searchController,
                selectedCategory: _selectedCategory,
                onCategoryChanged: _onCategoryChanged,
                onResetFilters: _resetFilters,
                onRefresh: _refreshProducts,
                onProductTap: _openDetails,
              ),
            InventoryEmpty() => _RefreshableStatus(
              onRefresh: _refreshProducts,
              icon: Icons.inventory_2_outlined,
              title: 'No products yet',
              message: 'Your catalog is ready for its first product.',
              supportingMessage:
                  'Use “Add product” to begin, or pull down to refresh.',
            ),
            InventoryFailure(:final String message) => InventoryStatusView(
              icon: Icons.cloud_off_rounded,
              title: 'Unable to load inventory',
              message: message,
              supportingMessage:
                  'Check your connection. Your data is safe on the server.',
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

  Future<void> _showStatistics(List<Product> products) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xA617203D),
      builder: (BuildContext dialogContext) => _StatisticsDialog(
        products: products,
        onClose: () => Navigator.of(dialogContext).pop(),
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

  void _resetFilters() {
    _searchController.clear();
    if (_selectedCategory != null) {
      setState(() => _selectedCategory = null);
    }
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

    InventoryFeedback.success(context, '${createdProduct.name} was added.');
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

    InventoryFeedback.success(context, '${deletedProduct.name} was deleted.');
  }
}

class _StatisticsButton extends StatelessWidget {
  const _StatisticsButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 9, bottom: 9),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: 'Open inventory statistics',
        child: Material(
          color: Colors.white.withValues(alpha: enabled ? 0.22 : 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: Colors.white.withValues(alpha: enabled ? 0.36 : 0.14),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: const Key('inventory-statistics-button'),
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    size: 18,
                    color: Colors.white.withValues(alpha: enabled ? 1 : 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Stats',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: enabled ? 1 : 0.5),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatisticsDialog extends StatelessWidget {
  const _StatisticsDialog({required this.products, required this.onClose});

  final List<Product> products;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    return SafeArea(
      child: Dialog(
        key: const Key('inventory-statistics-dialog'),
        insetPadding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 920,
            maxHeight: screenSize.height - 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 10, 4),
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: context.inventoryTheme.accentGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const SizedBox.square(
                          dimension: 38,
                          child: Icon(
                            Icons.analytics_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          'Inventory statistics',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        key: const Key('close-inventory-statistics'),
                        tooltip: 'Close statistics',
                        onPressed: onClose,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                InventoryOverview(products: products),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InventoryContent extends StatelessWidget {
  const _InventoryContent({
    required this.products,
    required this.isRefreshing,
    required this.searchController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onResetFilters,
    required this.onRefresh,
    required this.onProductTap,
  });

  final List<Product> products;
  final bool isRefreshing;
  final TextEditingController searchController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onResetFilters;
  final RefreshCallback onRefresh;
  final ValueChanged<Product> onProductTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return _RefreshableStatus(
        onRefresh: onRefresh,
        icon: Icons.inventory_2_outlined,
        title: 'No products yet',
        message: 'Your catalog is ready for its first product.',
        supportingMessage:
            'Use “Add product” to begin, or pull down to refresh.',
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isRefreshing
              ? const LinearProgressIndicator(
                  key: Key('inventory-refresh-progress'),
                  minHeight: 3,
                )
              : const SizedBox(key: Key('inventory-refresh-idle'), height: 3),
        ),
        InventoryFilterBar(
          searchController: searchController,
          categories: categories,
          selectedCategory: selectedCategory,
          onCategoryChanged: onCategoryChanged,
          onReset: onResetFilters,
        ),
        Expanded(
          child: visibleProducts.isEmpty
              ? _RefreshableStatus(
                  onRefresh: onRefresh,
                  icon: Icons.search_off_rounded,
                  title: 'No matching products',
                  message: 'Nothing matches the current search and category.',
                  supportingMessage: 'Reset the filters or try a broader term.',
                )
              : _ProductCollection(
                  products: visibleProducts,
                  onRefresh: onRefresh,
                  onProductTap: onProductTap,
                ),
        ),
      ],
    );
  }
}

class _ProductCollection extends StatelessWidget {
  const _ProductCollection({
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
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.maxContentWidth,
          ),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < AppBreakpoints.medium) {
                return RefreshIndicator(
                  onRefresh: onRefresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 104),
                    itemCount: products.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(height: 13),
                    itemBuilder: (BuildContext context, int index) {
                      final Product product = products[index];
                      return ProductCard(
                        key: ValueKey<String>(product.id),
                        product: product,
                        onTap: () => onProductTap(product),
                      );
                    },
                  ),
                );
              }

              final int columnCount =
                  constraints.maxWidth >= AppBreakpoints.expanded ? 3 : 2;
              return RefreshIndicator(
                onRefresh: onRefresh,
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 2, 24, 104),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columnCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 360,
                  ),
                  itemCount: products.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Product product = products[index];
                    return ProductCard(
                      key: ValueKey<String>(product.id),
                      product: product,
                      layout: ProductCardLayout.vertical,
                      onTap: () => onProductTap(product),
                    );
                  },
                ),
              );
            },
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
    this.supportingMessage,
  });

  final RefreshCallback onRefresh;
  final IconData icon;
  final String title;
  final String message;
  final String? supportingMessage;

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
                  supportingMessage: supportingMessage,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

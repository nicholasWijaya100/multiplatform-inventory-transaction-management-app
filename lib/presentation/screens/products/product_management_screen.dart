import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/products/add_product.dart';
import '../../widgets/products/edit_product.dart';
import '../../widgets/products/product_filters.dart';
import '../../widgets/products/product_list.dart';
import '../../widgets/products/product_stats_card.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showInactive = false;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load products when screen is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(LoadProducts());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddProductDialog(),
    );
  }

  void _showEditProductDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => EditProductDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState is Authenticated && authState.user.role == UserRole.administrator.name;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen && isAdmin)
                  ElevatedButton.icon(
                    onPressed: _showAddProductDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Cards
            const ProductStatsCards(),
            const SizedBox(height: 24),

            // Filters
            BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductsLoaded) {
                  return ProductFilters(
                    searchController: _searchController,
                    selectedCategory: _selectedCategory,
                    categories: state.categories,
                    showInactive: _showInactive,
                    onSearchChanged: (value) {
                      context.read<ProductBloc>().add(SearchProducts(value));
                    },
                    onCategoryChanged: (category) {
                      setState(() => _selectedCategory = category);
                      context.read<ProductBloc>().add(
                        FilterProductsByCategory(category),
                      );
                    },
                    onShowInactiveChanged: (value) {
                      setState(() => _showInactive = value);
                      context.read<ProductBloc>().add(
                        ShowInactiveProducts(value),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),

            // Product List
            Expanded(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is ProductError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (state is ProductsLoaded) {
                    if (state.products.isEmpty) {
                      return const Center(
                        child: Text('No products found'),
                      );
                    }
                    return ProductList(
                      products: state.products,
                      onEdit: _showEditProductDialog,
                      onStatusChange: (product, status) {
                        context.read<ProductBloc>().add(
                          UpdateProductStatus(product.id, status),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isSmallScreen && isAdmin
          ? FloatingActionButton(
        onPressed: _showAddProductDialog,
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
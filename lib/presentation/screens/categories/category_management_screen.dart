import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/category/category_bloc.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/categories/add_category_dialog.dart';
import '../../widgets/categories/category_filters.dart';
import '../../widgets/categories/category_list.dart';
import '../../widgets/categories/category_stats_cards.dart';
import '../../widgets/categories/edit_category_dialog.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({Key? key}) : super(key: key);

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  void _showEditCategoryDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen && isAdmin)
                  ElevatedButton.icon(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
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
            const CategoryStatsCards(),
            const SizedBox(height: 24),

            // Filters
            CategoryFilters(
              searchController: _searchController,
              showInactive: _showInactive,
              onSearchChanged: (value) {
                context.read<CategoryBloc>().add(SearchCategories(value));
              },
              onShowInactiveChanged: (value) {
                setState(() => _showInactive = value);
                context.read<CategoryBloc>().add(ShowInactiveCategories(value));
              },
            ),
            const SizedBox(height: 16),

            // Category List
            Expanded(
              child: BlocConsumer<CategoryBloc, CategoryState>(
                listener: (context, state) {
                  if (state is CategoryError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CategoriesLoaded) {
                    if (state.categories.isEmpty) {
                      return const Center(child: Text('No categories found'));
                    }

                    return CategoryList(
                      categories: state.categories,
                      onEdit: _showEditCategoryDialog,
                      onStatusChange: (category, status) {
                        context.read<CategoryBloc>().add(
                          UpdateCategoryStatus(category.id, status),
                        );
                      },
                      onDelete: (category) {
                        context.read<CategoryBloc>().add(
                          DeleteCategory(category.id),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isSmallScreen && isAdmin
          ? FloatingActionButton(
        onPressed: _showAddCategoryDialog,
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
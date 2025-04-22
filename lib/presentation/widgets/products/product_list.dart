import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_app_revised/presentation/widgets/products/product_mobile_card.dart';
import '../../../../data/models/product_model.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../utils/formatter.dart';

class ProductList extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel) onEdit;
  final Function(ProductModel, bool) onStatusChange;

  const ProductList({
    Key? key,
    required this.products,
    required this.onEdit,
    required this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use different layouts based on screen width
    if (MediaQuery.of(context).size.width < 600) {
      return _buildMobileLayout();
    }
    return _buildDesktopLayout();
  }

  Widget _buildMobileLayout() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onEdit: onEdit,
          onStatusChange: onStatusChange,
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    // Your existing desktop table layout
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: products.map((product) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            product.name[0].toUpperCase(),
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (product.description != null)
                            Text(
                              product.description!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Authenticated && state.user.role == UserRole.administrator.name) {
                      return Text(
                        Formatters.formatCurrency(product.price),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      );
                    } else {
                      return const Text('***', style: TextStyle(fontWeight: FontWeight.w500));
                    }
                  },
                )),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStockColor(product.quantity),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${product.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  Switch(
                    value: product.isActive,
                    onChanged: (value) => onStatusChange(product, value),
                  ),
                ),
                DataCell(
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isAdmin = state is Authenticated && state.user.role == UserRole.administrator.name;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // All users can view/edit the product, but non-admins will see a limited interface
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => onEdit(product),
                            tooltip: isAdmin ? 'Edit Product' : 'Update Stock',
                            color: Colors.blue[700],
                          ),
                          // Only admins can change status
                          if (isAdmin)
                            IconButton(
                              icon: Icon(
                                product.isActive
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () => onStatusChange(product, !product.isActive),
                              tooltip: product.isActive ? 'Deactivate' : 'Activate',
                              color: product.isActive ? Colors.green : Colors.grey,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStockColor(int quantity) {
    if (quantity <= 0) return Colors.red;
    if (quantity < 10) return Colors.orange;
    return Colors.green;
  }
}
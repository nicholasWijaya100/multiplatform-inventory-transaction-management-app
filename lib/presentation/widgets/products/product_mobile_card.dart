import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/product_model.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../utils/formatter.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final Function(ProductModel) onEdit;
  final Function(ProductModel, bool) onStatusChange;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onEdit,
    required this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStockColor(product.quantity).withOpacity(0.1),
          child: Text(
            product.name[0].toUpperCase(),
            style: TextStyle(
              color: _getStockColor(product.quantity),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated && state.user.role == UserRole.administrator.name) {
              return Text(
                Formatters.formatCurrency(product.price),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              );
            } else {
              return const Text(
                "",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              );
            }
          },
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStockColor(product.quantity).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStockLabel(product.quantity),
            style: TextStyle(
              color: _getStockColor(product.quantity),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Category', product.category),
                const SizedBox(height: 8),
                _buildInfoRow('Stock', product.quantity.toString()),
                if (product.description != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Description', product.description!),
                ],
                const SizedBox(height: 16),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isAdmin = state is Authenticated && state.user.role == UserRole.administrator.name;

                    return Row(
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: product.isActive,
                          onChanged: isAdmin ? (value) => onStatusChange(product, value) : null,
                        ),
                      ],
                    );
                  },
                ),
                const Divider(),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isAdmin = state is Authenticated && state.user.role == UserRole.administrator.name;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => onEdit(product),
                          icon: const Icon(Icons.edit),
                          label: Text(isAdmin ? 'Edit' : 'Update Stock'),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => onStatusChange(product, !product.isActive),
                            icon: Icon(product.isActive ? Icons.visibility_off : Icons.visibility),
                            label: Text(product.isActive ? 'Deactivate' : 'Activate'),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Color _getStockColor(int quantity) {
    if (quantity <= 0) return Colors.red;
    if (quantity < 10) return Colors.orange;
    return Colors.green;
  }

  String _getStockLabel(int quantity) {
    if (quantity <= 0) return 'Out of Stock';
    if (quantity < 10) return 'Low Stock';
    return 'In Stock';
  }
}
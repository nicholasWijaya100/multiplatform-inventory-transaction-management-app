import 'package:flutter/material.dart';
import 'package:inventory_app_revised/presentation/widgets/sales/sales_order_details_dialog.dart';
import '../../../data/models/sales_order_model.dart';
import '../../../utils/formatter.dart';

class SalesOrderCard extends StatelessWidget {
  final SalesOrderModel order;
  final Function(SalesOrderModel, String) onStatusUpdate;

  const SalesOrderCard({
    Key? key,
    required this.order,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '#${order.id}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(order.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(order.customerName),
            Text(
              Formatters.formatDateTime(order.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderItems(),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      Formatters.formatCurrency(order.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showOrderDetails(context),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('View Details'),
                    ),
                    if (_getNextPossibleStatuses(order.status).isNotEmpty) ...[
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        child: TextButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.update),
                          label: const Text('Update Status'),
                        ),
                        itemBuilder: (context) {
                          return _getNextPossibleStatuses(order.status)
                              .map((status) => PopupMenuItem(
                            value: status,
                            child: Text(_formatStatus(status)),
                          ))
                              .toList();
                        },
                        onSelected: (newStatus) => onStatusUpdate(order, newStatus),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: order.items.length,
          itemBuilder: (context, index) {
            final item = order.items[index];
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(item.productName),
              subtitle: Text(
                '${item.quantity} x ${Formatters.formatCurrency(item.unitPrice)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              trailing: Text(
                Formatters.formatCurrency(item.totalPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showOrderDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SalesOrderDetailsDialog(order: order),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<String> _getNextPossibleStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'draft':
        return ['pending', 'cancelled'];
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['shipped', 'cancelled'];
      case 'shipped':
        return ['delivered', 'cancelled'];
      case 'delivered':
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }
}
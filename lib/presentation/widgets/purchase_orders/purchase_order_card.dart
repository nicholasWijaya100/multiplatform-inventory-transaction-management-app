import 'package:flutter/material.dart';
import 'package:inventory_app_revised/presentation/widgets/purchase_orders/purchase_order_details_dialog.dart';
import 'package:inventory_app_revised/presentation/widgets/purchase_orders/confirm_order_dialog.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../../utils/formatter.dart';

class PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrderModel order;
  final Function(PurchaseOrderModel, String) onStatusUpdate;
  final Function(PurchaseOrderModel) onViewDetails;

  const PurchaseOrderCard({
    Key? key,
    required this.order,
    required this.onStatusUpdate,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
          child: Icon(
            Icons.shopping_bag_outlined,
            color: _getStatusColor(order.status),
          ),
        ),
        title: Text(
          '#${order.id}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(order.supplierName),
            const SizedBox(height: 4),
            _buildStatusBadge(context, order.status),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  title: 'Created',
                  value: Formatters.formatDateTime(order.createdAt),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  title: 'Items',
                  value: order.items.length.toString(),
                ),
                if (order.notes != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    title: 'Notes',
                    value: order.notes!,
                  ),
                ],
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
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => PurchaseOrderDetailsDialog(
                          order: order,
                        ),
                      ),
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
                            child: Text(
                              status[0].toUpperCase() + status.substring(1),
                            ),
                          ))
                              .toList();
                        },
                        onSelected: (newStatus) {
                          // Show warehouse selection dialog for confirming order
                          if (order.status == 'pending' && newStatus == 'confirmed') {
                            showDialog(
                              context: context,
                              builder: (_) => ConfirmOrderDialog(order: order),
                            );
                          } else {
                            onStatusUpdate(order, newStatus);
                          }
                        },
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

  Widget _buildInfoRow({
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          color: color,
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
      case 'received':
        return Colors.green;
      case 'completed':
        return Colors.purple;
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
        return ['cancelled']; // Can only be cancelled now, received happens automatically
      case 'received':
        return [];
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }
}
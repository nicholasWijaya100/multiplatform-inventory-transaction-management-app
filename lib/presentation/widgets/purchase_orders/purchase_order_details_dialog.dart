import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_app_revised/presentation/widgets/purchase_orders/receive_order_dialog.dart';
import '../../../blocs/purchase/purchase_bloc.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../../utils/formatter.dart';

class PurchaseOrderDetailsDialog extends StatelessWidget {
  final PurchaseOrderModel order;

  const PurchaseOrderDetailsDialog({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Use Expanded to prevent overflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchase Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 18, // Reduced from 20 for mobile
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Handle overflow with ellipsis
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Created on ${Formatters.formatDateTime(order.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12, // Reduced from 14 for mobile
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Keep close button separate
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getStatusColor(order.status).withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        order.status[0].toUpperCase() + order.status.substring(1),
                        style: TextStyle(
                          color: _getStatusColor(order.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Supplier Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Supplier',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(order.supplierName),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Order Details
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    'Payment Terms',
                                    order.paymentTerms ?? 'N/A',
                                  ),
                                ),
                                if (!isSmallScreen) ...[
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _buildDetailItem(
                                      'Payment Status',
                                      order.isPaid ? 'Paid' : 'Unpaid',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (isSmallScreen) ...[
                              const SizedBox(height: 16),
                              _buildDetailItem(
                                'Payment Status',
                                order.isPaid ? 'Paid' : 'Unpaid',
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDetailItem(
                                    'Expected Delivery',
                                    order.deliveryDate != null
                                        ? Formatters.formatDate(order.deliveryDate!)
                                        : 'Not set',
                                  ),
                                ),
                                if (!isSmallScreen) ...[
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: _buildDetailItem(
                                      'Received Date',
                                      order.receivedDate != null
                                          ? Formatters.formatDate(order.receivedDate!)
                                          : 'Not received',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (isSmallScreen) ...[
                              const SizedBox(height: 16),
                              _buildDetailItem(
                                'Received Date',
                                order.receivedDate != null
                                    ? Formatters.formatDate(order.receivedDate!)
                                    : 'Not received',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Items List
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Items',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.items.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                final item = order.items[index];
                                return ListTile(
                                  title: Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${item.quantity} x ${Formatters.formatCurrency(item.unitPrice)}',
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
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      Formatters.formatCurrency(order.totalAmount),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (order.notes?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(order.notes!),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer Actions
            const SizedBox(height: 24),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (order.status == 'completed' || order.status == 'cancelled') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        const SizedBox(width: 16),
        _buildStatusUpdateButton(context),
      ],
    );
  }

  Widget _buildStatusUpdateButton(BuildContext context) {
    final nextStatuses = _getNextPossibleStatuses(order.status);
    if (nextStatuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      child: ElevatedButton.icon(
        onPressed: null,
        icon: const Icon(Icons.update),
        label: const Text('Update Status'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[100],
        ),
      ),
      itemBuilder: (context) {
        return nextStatuses.map((status) {
          final statusName = status[0].toUpperCase() + status.substring(1);
          return PopupMenuItem(
            value: status,
            child: Text(statusName),
          );
        }).toList();
      },
      onSelected: (newStatus) {
        // Show warehouse selection dialog for receiving goods
        if (order.status == 'confirmed' && newStatus == 'received') {
          showDialog(
            context: context,
            builder: (context) => ReceiveOrderDialog(order: order),
          );
        } else {
          context.read<PurchaseBloc>().add(
            UpdatePurchaseOrderStatus(order.id, newStatus),
          );
          Navigator.pop(context);
        }
      },
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
        return ['received', 'cancelled'];
      case 'received':
        return ['completed', 'cancelled'];
      case 'completed':
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }
}
import 'package:flutter/material.dart';
import 'package:inventory_app_revised/presentation/widgets/purchase_orders/purchase_order_details_dialog.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../../utils/formatter.dart';
import 'purchase_order_card.dart';

class PurchaseOrderList extends StatelessWidget {
  final List<PurchaseOrderModel> orders;
  final Function(PurchaseOrderModel, String) onStatusUpdate;
  final Function(PurchaseOrderModel) onViewDetails;

  const PurchaseOrderList({
    Key? key,
    required this.orders,
    required this.onStatusUpdate,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return PurchaseOrderCard(
            order: orders[index],
            onStatusUpdate: onStatusUpdate,
            onViewDetails: onViewDetails,
          );
        },
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          horizontalMargin: 24,
          columnSpacing: 32,
          dataRowHeight: 72,
          headingRowHeight: 56,
          columns: const [
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Order ID'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Supplier'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Items'),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Total'),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Status'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Created'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Actions'),
              ),
            ),
          ],
          rows: orders.map((order) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '#${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Text(order.supplierName),
                ),
                DataCell(
                  Text(order.items.length.toString()),
                ),
                DataCell(
                  Text(
                    Formatters.formatCurrency(order.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  _buildStatusBadge(context, order.status),
                ),
                DataCell(
                  Text(
                    Formatters.formatDate(order.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => PurchaseOrderDetailsDialog(
                            order: order,
                          ),
                        ),
                        tooltip: 'View Details',
                      ),
                      // Only show status update button if order is not completed or cancelled
                      if (order.status != 'completed' && order.status != 'cancelled')
                        PopupMenuButton<String>(
                          tooltip: 'Update Status',
                          itemBuilder: (context) {
                            return _getNextPossibleStatuses(order.status)
                                .map((status) => PopupMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                                .toList();
                          },
                          onSelected: (newStatus) {
                            onStatusUpdate(order, newStatus);
                          },
                          icon: const Icon(Icons.update),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    switch (status) {
      case 'draft':
        color = Colors.grey;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'received':
        color = Colors.green;
        break;
      case 'completed':
        color = Colors.purple;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
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
          fontSize: 14,
        ),
      ),
    );
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
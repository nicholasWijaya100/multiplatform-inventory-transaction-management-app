import 'package:flutter/material.dart';
import 'package:inventory_app_revised/presentation/widgets/sales/sales_order_card.dart';
import 'package:inventory_app_revised/presentation/widgets/sales/ship_order_dialog.dart';
import '../../../data/models/sales_order_model.dart';
import '../../../utils/formatter.dart';
import 'sales_order_details_dialog.dart';

class SalesOrderList extends StatelessWidget {
  final List<SalesOrderModel> orders;
  final Function(SalesOrderModel, String) onStatusUpdate;

  const SalesOrderList({
    Key? key,
    required this.orders,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return SalesOrderCard(
            order: orders[index],
            onStatusUpdate: onStatusUpdate,
          );
        },
      );
    }

    return Scrollbar(
      thumbVisibility: true,
      controller: ScrollController(),
      child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.minWidth),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Items')),
                      DataColumn(label: Text('Total')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Created')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: orders.map((order) {
                      return DataRow(
                        cells: [
                          DataCell(Text('#${order.id}')),
                          DataCell(Text(order.customerName)),
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
                          DataCell(_buildStatusBadge(order.status)),
                          DataCell(Text(Formatters.formatDate(order.createdAt))),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined),
                                  onPressed: () => _showOrderDetails(context, order),
                                  tooltip: 'View Details',
                                ),
                                if (_getNextPossibleStatuses(order.status).isNotEmpty)
                                  PopupMenuButton<String>(
                                    tooltip: 'Update Status',
                                    itemBuilder: (context) {
                                      return _getNextPossibleStatuses(order.status)
                                          .map((status) => PopupMenuItem(
                                        value: status,
                                        child: Text(_formatStatus(status)),
                                      ))
                                          .toList();
                                    },
                                    onSelected: (newStatus) {
                                      // Show warehouse selection dialog for shipping order
                                      if (order.status == 'confirmed' && newStatus == 'shipped') {
                                        showDialog(
                                          context: context,
                                          builder: (_) => ShipOrderDialog(order: order),
                                        );
                                      } else {
                                        onStatusUpdate(order, newStatus);
                                      }
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
              ),
            );
          }
      ),
    );
  }

  void _showOrderDetails(BuildContext context, SalesOrderModel order) {
    showDialog(
      context: context,
      builder: (context) => SalesOrderDetailsDialog(order: order),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.5),
        ),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w500,
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
        return []; // Remove all manual transitions - only warehouse documents can change this
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
import 'package:flutter/material.dart';
import 'package:inventory_app_revised/presentation/widgets/purchase_orders/purchase_order_details_dialog.dart';
import 'package:inventory_app_revised/presentation/widgets/purchase_orders/confirm_order_dialog.dart';
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

    return Scrollbar(
      thumbVisibility: true,
      controller: ScrollController(),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
                  child: Text('Created'),
                ),
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
                  child: Text('Actions'),
                ),
              ),
            ],
            rows: orders.map((order) {
              return DataRow(
                cells: [
                  DataCell(
                    InkWell(
                      onTap: () => onViewDetails(order),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '#${order.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            order.supplierName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${order.supplierId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${order.items.length}',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      Formatters.formatCurrency(order.totalAmount),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  DataCell(
                    Text(
                      Formatters.formatDate(order.createdAt),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  DataCell(
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
                          fontSize: 12,
                        ),
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
                                  builder: (context) => ConfirmOrderDialog(order: order),
                                );
                              } else {
                                onStatusUpdate(order, newStatus);
                              }
                            },
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
import 'package:flutter/material.dart';
import '../../../data/models/purchase_invoice_model.dart';
import '../../../utils/formatter.dart';
import 'purchase_invoice_details_dialog.dart';

class PurchaseInvoiceList extends StatelessWidget {
  final List<PurchaseInvoiceModel> invoices;
  final Function(PurchaseInvoiceModel, String) onStatusUpdate;

  const PurchaseInvoiceList({
    Key? key,
    required this.invoices,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          return _PurchaseInvoiceCard(
            invoice: invoices[index],
            onStatusUpdate: onStatusUpdate,
          );
        },
      );
    }

    // Fixed column widths for better layout in web view
    return Card(
      child: SingleChildScrollView(
        child: PaginatedDataTable(
          header: const Text('Purchase Invoices'),
          rowsPerPage: 10,
          columns: [
            const DataColumn(label: Text('Invoice #')),
            const DataColumn(label: Text('Supplier')),
            const DataColumn(label: Text('Amount')),
            const DataColumn(label: Text('Due Date')),
            const DataColumn(label: Text('Status')),
            const DataColumn(label: Text('Payment')),
            const DataColumn(label: Text('Actions')),
          ],
          source: _PurchaseInvoiceDataSource(
            invoices: invoices,
            onStatusUpdate: onStatusUpdate,
            onViewDetails: (invoice) => _showInvoiceDetails(context, invoice),
          ),
        ),
      ),
    );
  }

  void _showInvoiceDetails(BuildContext context, PurchaseInvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (context) => PurchaseInvoiceDetailsDialog(invoice: invoice),
    );
  }
}

class _PurchaseInvoiceDataSource extends DataTableSource {
  final List<PurchaseInvoiceModel> invoices;
  final Function(PurchaseInvoiceModel, String) onStatusUpdate;
  final Function(PurchaseInvoiceModel) onViewDetails;

  _PurchaseInvoiceDataSource({
    required this.invoices,
    required this.onStatusUpdate,
    required this.onViewDetails,
  });

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= invoices.length) return const DataRow(cells: []);
    final invoice = invoices[index];
    return DataRow(
      cells: [
        DataCell(Text('#${invoice.id}')),
        DataCell(
          Tooltip(
            message: invoice.supplierName,
            child: Text(
              invoice.supplierName,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(
          Text(
            Formatters.formatCurrency(invoice.total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(
          Text(
            Formatters.formatDate(invoice.dueDate),
            style: TextStyle(
              color: invoice.isOverdue && !invoice.isPaid
                  ? Colors.red
                  : null,
              fontWeight: invoice.isOverdue && !invoice.isPaid
                  ? FontWeight.bold
                  : null,
            ),
          ),
        ),
        DataCell(_buildStatusBadge(invoice.status)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              invoice.isPaid
                  ? Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 16,
              )
                  : Icon(
                Icons.pending_outlined,
                color: Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                invoice.isPaid
                    ? (invoice.paidDate != null
                    ? Formatters.formatDate(invoice.paidDate!)
                    : 'Paid')
                    : 'Unpaid',
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                onPressed: () => onViewDetails(invoice),
                tooltip: 'View Details',
              ),
              if (_getNextPossibleStatuses(invoice.status).isNotEmpty)
                PopupMenuButton<String>(
                  tooltip: 'Update Status',
                  itemBuilder: (context) {
                    return _getNextPossibleStatuses(invoice.status)
                        .map((status) => PopupMenuItem(
                      value: status,
                      child: Text(_formatStatus(status)),
                    ))
                        .toList();
                  },
                  onSelected: (newStatus) =>
                      onStatusUpdate(invoice, newStatus),
                  icon: const Icon(Icons.update),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => invoices.length;

  @override
  int get selectedRowCount => 0;

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
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
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'disputed':
        return Colors.deepPurple;
      case 'refunded':
        return Colors.blue;
      case 'cancelled':
        return Colors.red[300]!;
      default:
        return Colors.grey;
    }
  }

  List<String> _getNextPossibleStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'draft':
        return ['pending', 'cancelled'];
      case 'pending':
        return ['paid', 'overdue', 'disputed', 'cancelled'];
      case 'overdue':
        return ['paid', 'disputed', 'cancelled'];
      case 'disputed':
        return ['pending', 'paid', 'cancelled'];
      case 'paid':
        return ['refunded']; // Only paid invoices can be refunded
      case 'refunded':
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

class _PurchaseInvoiceCard extends StatelessWidget {
  final PurchaseInvoiceModel invoice;
  final Function(PurchaseInvoiceModel, String) onStatusUpdate;

  const _PurchaseInvoiceCard({
    required this.invoice,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              '#${invoice.id}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(invoice.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(invoice.supplierName),
            Text(
              'Due: ${Formatters.formatDate(invoice.dueDate)}',
              style: TextStyle(
                fontSize: 12,
                color: invoice.isOverdue && !invoice.isPaid ? Colors.red : Colors.grey[600],
                fontWeight: invoice.isOverdue && !invoice.isPaid ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
        trailing: Text(
          Formatters.formatCurrency(invoice.total),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Purchase Order', '#${invoice.purchaseOrderId}'),
                const SizedBox(height: 8),
                _buildInfoRow('Created', Formatters.formatDate(invoice.createdAt)),
                const SizedBox(height: 8),
                _buildInfoRow('Payment Terms', invoice.paymentTerms ?? 'N/A'),
                const SizedBox(height: 8),
                _buildInfoRow('Payment Status', invoice.isPaid ? 'Paid' : 'Unpaid'),
                if (invoice.isPaid && invoice.paidDate != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Paid On', Formatters.formatDate(invoice.paidDate!)),
                ],

                const Divider(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subtotal:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(invoice.subtotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tax:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(invoice.tax),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(invoice.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Divider(height: 24),

                // Changed to use Wrap instead of Row for better responsiveness
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showInvoiceDetails(context),
                      icon: const Icon(Icons.visibility_outlined),
                      label: const Text('View Details'),
                    ),
                    if (_getNextPossibleStatuses(invoice.status).isNotEmpty)
                      PopupMenuButton<String>(
                        child: TextButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.update),
                          label: const Text('Update Status'),
                        ),
                        itemBuilder: (context) {
                          return _getNextPossibleStatuses(invoice.status)
                              .map((status) => PopupMenuItem(
                            value: status,
                            child: Text(_formatStatus(status)),
                          ))
                              .toList();
                        },
                        onSelected: (newStatus) => onStatusUpdate(invoice, newStatus),
                      ),
                  ],
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
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showInvoiceDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PurchaseInvoiceDetailsDialog(invoice: invoice),
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
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'disputed':
        return Colors.deepPurple;
      case 'refunded':
        return Colors.blue;
      case 'cancelled':
        return Colors.red[300]!;
      default:
        return Colors.grey;
    }
  }

  List<String> _getNextPossibleStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'draft':
        return ['pending', 'cancelled'];
      case 'pending':
        return ['paid', 'overdue', 'disputed', 'cancelled'];
      case 'overdue':
        return ['paid', 'disputed', 'cancelled'];
      case 'disputed':
        return ['pending', 'paid', 'cancelled'];
      case 'paid':
        return ['refunded']; // Only paid invoices can be refunded
      case 'refunded':
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
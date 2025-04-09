import 'package:flutter/material.dart';
import '../../../data/models/purchase_invoice_model.dart';
import '../../../utils/formatter.dart';

class PurchaseInvoiceDetailsDialog extends StatelessWidget {
  final PurchaseInvoiceModel invoice;

  const PurchaseInvoiceDetailsDialog({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchase Invoice #${invoice.id}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Created on ${Formatters.formatDateTime(invoice.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(invoice.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(invoice.status).withOpacity(0.5),
                ),
              ),
              child: Text(
                invoice.status[0].toUpperCase() + invoice.status.substring(1),
                style: TextStyle(
                  color: _getStatusColor(invoice.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier Info
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Supplier Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(invoice.supplierName),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Related Order
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Related Purchase Order',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Purchase Order #${invoice.purchaseOrderId}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Invoice Details
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Invoice Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              'Invoice Number',
                              invoice.invoiceNumber ?? 'N/A',
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              'Payment Terms',
                              invoice.paymentTerms ?? 'N/A',
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              'Due Date',
                              Formatters.formatDate(invoice.dueDate),
                              valueStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: invoice.isOverdue && !invoice.isPaid ? Colors.red : null,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow(
                              'Payment Status',
                              invoice.isPaid ? 'Paid' : 'Unpaid',
                              valueStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: invoice.isPaid ? Colors.green : null,
                              ),
                            ),
                            if (invoice.isPaid && invoice.paidDate != null) ...[
                              const SizedBox(height: 16),
                              _buildDetailRow(
                                'Paid On',
                                Formatters.formatDate(invoice.paidDate!),
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
                              itemCount: invoice.items.length,
                              separatorBuilder: (context, index) =>
                              const Divider(),
                              itemBuilder: (context, index) {
                                final item = invoice.items[index];
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
                                    Formatters.formatCurrency(item.total),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 32),

                            // Summary
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Column(
                                    children: [
                                      _buildSummaryRow('Subtotal', Formatters.formatCurrency(invoice.subtotal)),
                                      const SizedBox(height: 8),
                                      _buildSummaryRow('Tax', Formatters.formatCurrency(invoice.tax)),
                                      const Divider(),
                                      _buildSummaryRow(
                                        'Total',
                                        Formatters.formatCurrency(invoice.total),
                                        valueStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (invoice.notes?.isNotEmpty ?? false) ...[
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
                              Text(invoice.notes!),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Placeholder for printing invoice functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Print functionality not implemented yet'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Print Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: valueStyle ?? const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: valueStyle ?? const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'received':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'disputed':
        return Colors.deepPurple;
      case 'cancelled':
        return Colors.red[300]!;
      default:
        return Colors.grey;
    }
  }
}
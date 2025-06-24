import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/warehouse_documents/warehouse_document_bloc.dart';
import '../../../data/models/warehouse_document_model.dart';
import '../../../utils/formatter.dart';

class WarehouseDocumentDetailsDialog extends StatelessWidget {
  final WarehouseDocumentModel document;

  const WarehouseDocumentDetailsDialog({
    Key? key,
    required this.document,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildDocumentInfo(),
            const SizedBox(height: 24),
            _buildItemsList(),
            const SizedBox(height: 24),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  document.type == WarehouseDocumentType.entryWaybill
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: document.type == WarehouseDocumentType.entryWaybill
                      ? Colors.green
                      : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  document.documentNumber,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              document.type == WarehouseDocumentType.entryWaybill
                  ? 'Entry Waybill'
                  : 'Delivery Note',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildDocumentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('Warehouse', document.warehouseName),
          const SizedBox(height: 8),
          _buildInfoRow('Status', _getStatusLabel(document.status),
              valueColor: _getStatusColor(document.status)),
          const SizedBox(height: 8),
          _buildInfoRow('Created', Formatters.formatDateTime(document.createdAt)),
          if (document.completedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Completed', Formatters.formatDateTime(document.completedAt!)),
          ],
          if (document.relatedOrderNumber != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              document.type == WarehouseDocumentType.entryWaybill
                  ? 'Purchase Order'
                  : 'Sales Order',
              document.relatedOrderNumber!,
            ),
          ],
          if (document.notes != null && document.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Notes', document.notes!),
          ],
          if (document.metadata != null && document.metadata!.isNotEmpty) ...[
            const SizedBox(height: 8),
            if (document.metadata!['supplierName'] != null)
              _buildInfoRow('Supplier', document.metadata!['supplierName']),
            if (document.metadata!['customerName'] != null)
              _buildInfoRow('Customer', document.metadata!['customerName']),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontWeight: valueColor != null ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Unit')),
                DataColumn(label: Text('Batch #')),
                DataColumn(label: Text('Expiry')),
              ],
              rows: document.items.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item.productName)),
                    DataCell(Text(item.productSku)),
                    DataCell(Text(item.quantity.toString())),
                    DataCell(Text(item.unit)),
                    DataCell(Text(item.batchNumber ?? '-')),
                    DataCell(Text(
                      item.expiryDate != null
                          ? Formatters.formatDate(item.expiryDate!)
                          : '-',
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (document.status != WarehouseDocumentStatus.completed &&
            document.status != WarehouseDocumentStatus.cancelled) ...[
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              _showStatusUpdateDialog(context);
            },
            icon: const Icon(Icons.update),
            label: const Text('Update Status'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade100,
            ),
          ),
        ],
      ],
    );
  }

  void _showStatusUpdateDialog(BuildContext context) {
    final nextStatuses = _getNextStatuses(document.status);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Document Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: nextStatuses.map((status) {
            return ListTile(
              title: Text(_getStatusLabel(status)),
              leading: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
              ),
              onTap: () {
                context.read<WarehouseDocumentBloc>().add(
                  UpdateWarehouseDocumentStatus(document.id, status),
                );
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(WarehouseDocumentStatus status) {
    switch (status) {
      case WarehouseDocumentStatus.draft:
        return 'Draft';
      case WarehouseDocumentStatus.pending:
        return 'Pending';
      case WarehouseDocumentStatus.completed:
        return 'Completed';
      case WarehouseDocumentStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(WarehouseDocumentStatus status) {
    switch (status) {
      case WarehouseDocumentStatus.draft:
        return Colors.grey;
      case WarehouseDocumentStatus.pending:
        return Colors.orange;
      case WarehouseDocumentStatus.completed:
        return Colors.green;
      case WarehouseDocumentStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(WarehouseDocumentStatus status) {
    switch (status) {
      case WarehouseDocumentStatus.draft:
        return Icons.edit;
      case WarehouseDocumentStatus.pending:
        return Icons.pending_actions;
      case WarehouseDocumentStatus.completed:
        return Icons.check_circle;
      case WarehouseDocumentStatus.cancelled:
        return Icons.cancel;
    }
  }

  List<WarehouseDocumentStatus> _getNextStatuses(WarehouseDocumentStatus current) {
    switch (current) {
      case WarehouseDocumentStatus.draft:
        return [WarehouseDocumentStatus.pending, WarehouseDocumentStatus.cancelled];
      case WarehouseDocumentStatus.pending:
        return [WarehouseDocumentStatus.completed, WarehouseDocumentStatus.cancelled];
      case WarehouseDocumentStatus.completed:
      case WarehouseDocumentStatus.cancelled:
        return [];
    }
  }
}
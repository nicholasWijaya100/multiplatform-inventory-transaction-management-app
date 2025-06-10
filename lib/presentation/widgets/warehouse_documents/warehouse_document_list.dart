import 'package:flutter/material.dart';
import '../../../data/models/warehouse_document_model.dart';
import '../../../utils/formatter.dart';

class WarehouseDocumentList extends StatelessWidget {
  final List<WarehouseDocumentModel> documents;
  final Function(WarehouseDocumentModel) onViewDetails;
  final Function(WarehouseDocumentModel, WarehouseDocumentStatus) onStatusUpdate;

  const WarehouseDocumentList({
    Key? key,
    required this.documents,
    required this.onViewDetails,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          return _buildDocumentCard(documents[index], context);
        },
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Document #')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Warehouse')),
            DataColumn(label: Text('Related Order')),
            DataColumn(label: Text('Items')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Created')),
            DataColumn(label: Text('Actions')),
          ],
          rows: documents.map((document) => _buildDataRow(document, context)).toList(),
        ),
      ),
    );
  }

  Widget _buildDocumentCard(WarehouseDocumentModel document, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onViewDetails(document),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.documentNumber,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildTypeChip(document.type),
                            const SizedBox(width: 8),
                            _buildStatusChip(document.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    document.type == WarehouseDocumentType.entryWaybill
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: document.type == WarehouseDocumentType.entryWaybill
                        ? Colors.green
                        : Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Warehouse: ${document.warehouseName}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Text(
                '${document.items.length} items',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Created: ${Formatters.formatDate(document.createdAt)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              if (document.relatedOrderNumber != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Order: ${document.relatedOrderNumber}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(WarehouseDocumentModel document, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            document.documentNumber,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(_buildTypeChip(document.type)),
        DataCell(Text(document.warehouseName)),
        DataCell(
          Text(document.relatedOrderNumber ?? '-'),
        ),
        DataCell(
          Text('${document.items.length} items'),
        ),
        DataCell(_buildStatusChip(document.status)),
        DataCell(
          Text(Formatters.formatDate(document.createdAt)),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                onPressed: () => onViewDetails(document),
                tooltip: 'View Details',
              ),
              if (document.status != WarehouseDocumentStatus.completed &&
                  document.status != WarehouseDocumentStatus.cancelled)
                PopupMenuButton<WarehouseDocumentStatus>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => _getNextStatuses(document.status)
                      .map((status) => PopupMenuItem(
                    value: status,
                    child: Text(_getStatusLabel(status)),
                  ))
                      .toList(),
                  onSelected: (status) => onStatusUpdate(document, status),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(WarehouseDocumentType type) {
    final isEntry = type == WarehouseDocumentType.entryWaybill;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isEntry ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isEntry ? Colors.green.shade300 : Colors.blue.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEntry ? Icons.arrow_downward : Icons.arrow_upward,
            size: 12,
            color: isEntry ? Colors.green.shade700 : Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            isEntry ? 'Entry' : 'Delivery',
            style: TextStyle(
              fontSize: 12,
              color: isEntry ? Colors.green.shade700 : Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(WarehouseDocumentStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case WarehouseDocumentStatus.draft:
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
        break;
      case WarehouseDocumentStatus.pending:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case WarehouseDocumentStatus.completed:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case WarehouseDocumentStatus.cancelled:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
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
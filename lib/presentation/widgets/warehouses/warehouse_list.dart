import 'package:flutter/material.dart';
import 'package:inventory_app_revised/presentation/widgets/warehouses/warehouse_inventory_dialog.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../utils/formatter.dart';
import 'warehouse_mobile_card.dart';

class WarehouseList extends StatelessWidget {
  final List<WarehouseModel> warehouses;
  final Function(WarehouseModel) onEdit;
  final Function(WarehouseModel, bool) onStatusChange;
  final Function(WarehouseModel) onDelete;

  const WarehouseList({
    Key? key,
    required this.warehouses,
    required this.onEdit,
    required this.onStatusChange,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return ListView.builder(
        itemCount: warehouses.length,
        padding: const EdgeInsets.only(bottom: 80), // Space for FAB
        itemBuilder: (context, index) {
          return WarehouseMobileCard(
            warehouse: warehouses[index],
            onEdit: onEdit,
            onStatusChange: onStatusChange,
            onDelete: onDelete,
          );
        },
      );
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Warehouse')),
            DataColumn(label: Text('Location')),
            DataColumn(label: Text('Contact')),
            DataColumn(label: Text('Products')),
            DataColumn(label: Text('Value')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: warehouses.map((warehouse) {
            return DataRow(
              cells: [
                DataCell(_buildWarehouseCell(warehouse)),
                DataCell(_buildLocationCell(warehouse)),
                DataCell(_buildContactCell(warehouse)),
                DataCell(_buildProductsCell(warehouse)),
                DataCell(_buildValueCell(warehouse)),
                DataCell(_buildStatusCell(warehouse)),
                DataCell(_buildActionsCell(context, warehouse)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWarehouseCell(WarehouseModel warehouse) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: warehouse.isActive ? Colors.blue[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.warehouse_outlined,
              color: warehouse.isActive ? Colors.blue[700] : Colors.grey[400],
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              warehouse.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (warehouse.description != null)
              Text(
                warehouse.description!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationCell(WarehouseModel warehouse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          warehouse.city,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          warehouse.address,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCell(WarehouseModel warehouse) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          warehouse.phone,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        if (warehouse.email != null)
          Text(
            warehouse.email!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildProductsCell(WarehouseModel warehouse) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        warehouse.totalProducts.toString(),
        style: TextStyle(
          color: Colors.blue[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildValueCell(WarehouseModel warehouse) {
    return Text(
      Formatters.formatCurrency(warehouse.totalValue),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatusCell(WarehouseModel warehouse) {
    return Switch(
      value: warehouse.isActive,
      onChanged: (value) => onStatusChange(warehouse, value),
    );
  }

  Widget _buildActionsCell(BuildContext context, WarehouseModel warehouse) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.inventory_2_outlined),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => WarehouseInventoryDialog(warehouse: warehouse),
            );
          },
          tooltip: 'View Inventory',
          color: Colors.blue[700],
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => onEdit(warehouse),
          tooltip: 'Edit Warehouse',
          color: Colors.blue[700],
        ),
        if (warehouse.totalProducts == 0)
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onPressed: () => _showDeleteConfirmation(context, warehouse),
            tooltip: 'Delete Warehouse',
          ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context,
      WarehouseModel warehouse,
      ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Warehouse'),
          content: Text(
            'Are you sure you want to delete "${warehouse.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(warehouse);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:inventory_app_revised/presentation/widgets/warehouses/warehouse_inventory_dialog.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../utils/formatter.dart';

class WarehouseMobileCard extends StatelessWidget {
  final WarehouseModel warehouse;
  final Function(WarehouseModel) onEdit;
  final Function(WarehouseModel, bool) onStatusChange;
  final Function(WarehouseModel) onDelete;

  const WarehouseMobileCard({
    Key? key,
    required this.warehouse,
    required this.onEdit,
    required this.onStatusChange,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: warehouse.isActive ? Colors.blue[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.warehouse_outlined,
            color: warehouse.isActive ? Colors.blue[700] : Colors.grey[400],
          ),
        ),
        title: Text(
          warehouse.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          warehouse.city,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  title: 'Location',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(warehouse.city),
                      Text(
                        warehouse.address,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                _buildInfoSection(
                  title: 'Contact',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(warehouse.phone),
                      if (warehouse.email != null)
                        Text(
                          warehouse.email!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                _buildInfoSection(
                  title: 'Statistics',
                  content: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          label: 'Products',
                          value: warehouse.totalProducts.toString(),
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[300],
                      ),
                      Expanded(
                        child: _buildStatItem(
                          label: 'Value',
                          value: Formatters.formatCurrency(warehouse.totalValue),
                          icon: Icons.attach_money_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Text('Status'),
                    const Spacer(),
                    Switch(
                      value: warehouse.isActive,
                      onChanged: (value) => onStatusChange(warehouse, value),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => onEdit(warehouse),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                    ),
                    if (warehouse.totalProducts == 0) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => onDelete(warehouse),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                    TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => WarehouseInventoryDialog(warehouse: warehouse),
                        );
                      },
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('View Inventory'),
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

  Widget _buildInfoSection({
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.blue[700],
          size: 20,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
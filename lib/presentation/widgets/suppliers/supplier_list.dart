import 'package:flutter/material.dart';
import '../../../data/models/supplier_model.dart';
import '../../../utils/formatter.dart';

class SupplierList extends StatelessWidget {
  final List<SupplierModel> suppliers;
  final Function(SupplierModel) onEdit;
  final Function(SupplierModel, bool) onStatusChange;
  final Function(SupplierModel) onDelete;

  const SupplierList({
    Key? key,
    required this.suppliers,
    required this.onEdit,
    required this.onStatusChange,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return _SupplierCard(
            supplier: supplier,
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
          horizontalMargin: 24,
          columnSpacing: 32,
          dataRowHeight: 72,
          headingRowHeight: 56,
          columns: const [
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Supplier'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Contact'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Location'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Orders'),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Total Value'),
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
                child: Text('Actions'),
              ),
            ),
          ],
          rows: suppliers.map((supplier) {
            return DataRow(
              cells: [
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          backgroundColor: supplier.isActive ? Colors.blue[900] : Colors.grey,
                          child: Text(
                            supplier.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              supplier.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (supplier.description != null)
                              Text(
                                supplier.description!,
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
                    ),
                  ),
                ),
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(supplier.phone),
                        if (supplier.email != null)
                          Text(
                            supplier.email!,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(supplier.city),
                        Text(
                          supplier.address,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      supplier.totalOrders.toString(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    Formatters.formatCurrency(supplier.totalPurchases),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(
                  Switch(
                    value: supplier.isActive,
                    onChanged: (value) => onStatusChange(supplier, value),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEdit(supplier),
                        tooltip: 'Edit Supplier',
                      ),
                      if (supplier.totalOrders == 0)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => _showDeleteConfirmation(
                            context,
                            supplier,
                          ),
                          tooltip: 'Delete Supplier',
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

  Future<void> _showDeleteConfirmation(
      BuildContext context,
      SupplierModel supplier,
      ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Supplier'),
          content: Text(
            'Are you sure you want to delete "${supplier.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(supplier);
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

class _SupplierCard extends StatelessWidget {
  final SupplierModel supplier;
  final Function(SupplierModel) onEdit;
  final Function(SupplierModel, bool) onStatusChange;
  final Function(SupplierModel) onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.onEdit,
    required this.onStatusChange,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: supplier.isActive ? Colors.blue[900] : Colors.grey,
          child: Text(
            supplier.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(supplier.city),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  title: 'Contact',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supplier.phone),
                      if (supplier.email != null)
                        Text(
                          supplier.email!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  title: 'Location',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supplier.city),
                      Text(
                        supplier.address,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  title: 'Statistics',
                  content: Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          label: 'Orders',
                          value: supplier.totalOrders.toString(),
                          icon: Icons.shopping_cart_outlined,
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
                          value: Formatters.formatCurrency(supplier.totalPurchases),
                          icon: Icons.attach_money,
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
                      value: supplier.isActive,
                      onChanged: (value) => onStatusChange(supplier, value),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => onEdit(supplier),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    if (supplier.totalOrders == 0) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => onDelete(supplier),
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
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
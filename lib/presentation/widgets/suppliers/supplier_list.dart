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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
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
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => onEdit(supplier),
                                  color: Colors.blue[700],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _showDeleteConfirmation(context, supplier),
                                  color: Colors.red[700],
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

  void _showDeleteConfirmation(BuildContext context, SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete ${supplier.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(supplier);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final SupplierModel supplier;
  final Function(SupplierModel) onEdit;
  final Function(SupplierModel, bool) onStatusChange;
  final Function(SupplierModel) onDelete;

  const _SupplierCard({
    Key? key,
    required this.supplier,
    required this.onEdit,
    required this.onStatusChange,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(supplier.city),
        trailing: Switch(
          value: supplier.isActive,
          onChanged: (value) => onStatusChange(supplier, value),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (supplier.description != null) ...[
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(supplier.description!),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text('Phone: ${supplier.phone}'),
                if (supplier.email != null) Text('Email: ${supplier.email}'),
                const SizedBox(height: 8),
                Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text('${supplier.address}, ${supplier.city}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => onEdit(supplier),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, supplier),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
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

  void _showDeleteConfirmation(BuildContext context, SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Supplier'),
        content: Text('Are you sure you want to delete ${supplier.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(supplier);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
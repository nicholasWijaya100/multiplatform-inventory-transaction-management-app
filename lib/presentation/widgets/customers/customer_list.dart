import 'package:flutter/material.dart';
import '../../../data/models/customer_model.dart';
import '../../../utils/formatter.dart';

class CustomerList extends StatelessWidget {
  final List<CustomerModel> customers;
  final Function(CustomerModel) onEdit;
  final Function(CustomerModel, bool) onStatusChange;
  final Function(CustomerModel) onDelete;

  const CustomerList({
    Key? key,
    required this.customers,
    required this.onEdit,
    required this.onStatusChange,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: customer.isActive ? Colors.blue[900] : Colors.grey,
                child: Text(
                  customer.name[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                customer.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(customer.city),
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
                            Text(customer.phone),
                            if (customer.email != null)
                              Text(
                                customer.email!,
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
                            Text(customer.city),
                            Text(
                              customer.address,
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
                                value: customer.totalOrders.toString(),
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
                                label: 'Sales',
                                value: Formatters.formatCurrency(customer.totalPurchases),
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
                            value: customer.isActive,
                            onChanged: (value) => onStatusChange(customer, value),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => onEdit(customer),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
                          if (customer.totalOrders == 0) ...[
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _showDeleteConfirmation(context, customer),
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
                      DataColumn(label: Text('Customer')),
                      DataColumn(label: Text('Contact')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('Orders')),
                      DataColumn(label: Text('Sales')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: customers.map((customer) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: customer.isActive ? Colors.blue[900] : Colors.grey,
                                  child: Text(
                                    customer.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  customer.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(customer.phone),
                                if (customer.email != null)
                                  Text(
                                    customer.email!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(customer.city),
                                Text(
                                  customer.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
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
                                customer.totalOrders.toString(),
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              Formatters.formatCurrency(customer.totalPurchases),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          DataCell(
                            Switch(
                              value: customer.isActive,
                              onChanged: (value) => onStatusChange(customer, value),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => onEdit(customer),
                                  tooltip: 'Edit Customer',
                                ),
                                if (customer.totalOrders == 0)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _showDeleteConfirmation(context, customer),
                                    tooltip: 'Delete Customer',
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

  Future<void> _showDeleteConfirmation(
      BuildContext context,
      CustomerModel customer,
      ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Customer'),
          content: Text(
            'Are you sure you want to delete "${customer.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete(customer);
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
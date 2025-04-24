import 'package:flutter/material.dart';
import '../../../../../data/models/user_model.dart';

class UserTable extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onEdit;
  final Function(UserModel, bool) onStatusChange;

  const UserTable({
    Key? key,
    required this.users,
    required this.onEdit,
    required this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 0,
            ),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: user.isActive ? Colors.blue[900] : Colors.grey,
                child: Text(
                  user.name?[0].toUpperCase() ?? 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                user.name ?? 'N/A',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(user.email),
              trailing: Switch(
                value: user.isActive,
                onChanged: (value) => onStatusChange(user, value),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Role', user.role),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Status',
                        user.isActive ? 'Active' : 'Inactive',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => onEdit(user),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                          ),
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
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: users.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user.name ?? '-')),
                          DataCell(Text(user.email)),
                          DataCell(Text(user.role)),
                          DataCell(
                            Switch(
                              value: user.isActive,
                              onChanged: (value) => onStatusChange(user, value),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => onEdit(user),
                                  tooltip: 'Edit User',
                                ),
                                IconButton(
                                  icon: Icon(
                                    user.isActive
                                        ? Icons.block_outlined
                                        : Icons.check_circle_outline,
                                  ),
                                  onPressed: () => onStatusChange(user, !user.isActive),
                                  tooltip: user.isActive ? 'Deactivate' : 'Activate',
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value),
      ],
    );
  }
}
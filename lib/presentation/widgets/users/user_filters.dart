import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

class UserFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedRole;
  final bool showInactive;
  final void Function(String) onSearchChanged;
  final void Function(String?) onRoleChanged;
  final void Function(bool) onShowInactiveChanged;

  const UserFilters({
    Key? key,
    required this.searchController,
    required this.selectedRole,
    required this.showInactive,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.onShowInactiveChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isSmallScreen) ...[
              // Mobile Layout
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search users...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Roles'),
                  ),
                  ...UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role.name,
                      child: Text(role.name),
                    );
                  }),
                ],
                onChanged: onRoleChanged,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Show Inactive Users'),
                value: showInactive,
                onChanged: onShowInactiveChanged,
                contentPadding: EdgeInsets.zero,
              ),
            ] else ...[
              // Desktop Layout
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Roles'),
                        ),
                        ...UserRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role.name,
                            child: Text(role.name),
                          );
                        }),
                      ],
                      onChanged: onRoleChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: showInactive,
                        onChanged: (value) =>
                            onShowInactiveChanged(value ?? false),
                      ),
                      const Text('Show Inactive'),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
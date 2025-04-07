import 'package:flutter/material.dart';

class SupplierFilters extends StatelessWidget {
  final TextEditingController searchController;
  final bool showInactive;
  final void Function(String) onSearchChanged;
  final void Function(bool) onShowInactiveChanged;

  const SupplierFilters({
    Key? key,
    required this.searchController,
    required this.showInactive,
    required this.onSearchChanged,
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
                  hintText: 'Search suppliers...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Show Inactive'),
                  const Spacer(),
                  Switch(
                    value: showInactive,
                    onChanged: onShowInactiveChanged,
                  ),
                ],
              ),
            ] else ...[
              // Desktop Layout
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search suppliers...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: showInactive,
                        onChanged: (value) => onShowInactiveChanged(value ?? false),
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
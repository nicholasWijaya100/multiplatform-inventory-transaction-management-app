import 'package:flutter/material.dart';
import '../../../data/models/warehouse_model.dart';

class WarehouseFilters extends StatelessWidget {
  final TextEditingController searchController;
  final bool showInactive;
  final void Function(String) onSearchChanged;
  final void Function(bool) onShowInactiveChanged;
  final void Function(String?)? onCityFilterChanged;
  final List<String>? availableCities;
  final String? selectedCity;

  const WarehouseFilters({
    Key? key,
    required this.searchController,
    required this.showInactive,
    required this.onSearchChanged,
    required this.onShowInactiveChanged,
    this.onCityFilterChanged,
    this.availableCities,
    this.selectedCity,
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
                  hintText: 'Search warehouses...',
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
              if (availableCities != null && availableCities!.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: selectedCity,
                  decoration: InputDecoration(
                    labelText: 'Filter by City',
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
                      child: Text('All Cities'),
                    ),
                    ...availableCities!.map((city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    )),
                  ],
                  onChanged: onCityFilterChanged,
                ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Show Inactive Warehouses'),
                value: showInactive,
                onChanged: onShowInactiveChanged,
                contentPadding: EdgeInsets.zero,
              ),
            ] else ...[
              // Desktop Layout
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search warehouses...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: onSearchChanged,
                    ),
                  ),
                  if (availableCities != null && availableCities!.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCity,
                        decoration: InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Cities'),
                          ),
                          ...availableCities!.map((city) => DropdownMenuItem(
                            value: city,
                            child: Text(city),
                          )),
                        ],
                        onChanged: onCityFilterChanged,
                      ),
                    ),
                  ],
                  const SizedBox(width: 16),
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
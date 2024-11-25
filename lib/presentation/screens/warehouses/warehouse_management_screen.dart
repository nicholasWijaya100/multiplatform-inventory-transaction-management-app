import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/warehouse/warehouse_bloc.dart';
import '../../../data/models/warehouse_model.dart';
import '../../widgets/warehouses/add_warehouse_dialog.dart';
import '../../widgets/warehouses/edit_warehouse_dialog.dart';
import '../../widgets/warehouses/warehouse_filters.dart';
import '../../widgets/warehouses/warehouse_list.dart';
import '../../widgets/warehouses/warehouse_stats_cards.dart';

class WarehouseManagementScreen extends StatefulWidget {
  const WarehouseManagementScreen({Key? key}) : super(key: key);

  @override
  State<WarehouseManagementScreen> createState() => _WarehouseManagementScreenState();
}

class _WarehouseManagementScreenState extends State<WarehouseManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showInactive = false;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    context.read<WarehouseBloc>().add(LoadWarehouses());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddWarehouseDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddWarehouseDialog(),
    ).then((_) {
      // Refresh warehouses after adding
      context.read<WarehouseBloc>().add(LoadWarehouses());
    });
  }

  void _showEditWarehouseDialog(WarehouseModel warehouse) {
    showDialog(
      context: context,
      builder: (context) => EditWarehouseDialog(warehouse: warehouse),
    ).then((_) {
      // Refresh warehouses after editing
      context.read<WarehouseBloc>().add(LoadWarehouses());
    });
  }

  List<String> _getAvailableCities(List<WarehouseModel> warehouses) {
    final cities = warehouses.map((w) => w.city).toSet().toList();
    cities.sort();
    return cities;
  }

  void _handleDeleteWarehouse(WarehouseModel warehouse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Warehouse'),
        content: Text(
          'Are you sure you want to delete ${warehouse.name}? '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<WarehouseBloc>().add(DeleteWarehouse(warehouse.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Warehouse Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen)
                  ElevatedButton.icon(
                    onPressed: _showAddWarehouseDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Warehouse'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats Cards
            const WarehouseStatsCards(),
            const SizedBox(height: 24),

            // Filters
            BlocBuilder<WarehouseBloc, WarehouseState>(
              builder: (context, state) {
                if (state is WarehousesLoaded) {
                  return WarehouseFilters(
                    searchController: _searchController,
                    showInactive: _showInactive,
                    onSearchChanged: (value) {
                      context.read<WarehouseBloc>().add(SearchWarehouses(value));
                    },
                    onShowInactiveChanged: (value) {
                      setState(() => _showInactive = value);
                      context.read<WarehouseBloc>().add(ShowInactiveWarehouses(value));
                    },
                    availableCities: _getAvailableCities(state.warehouses),
                    selectedCity: _selectedCity,
                    onCityFilterChanged: (city) {
                      setState(() => _selectedCity = city);
                      // Add city filter event if needed
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),

            // Warehouse List
            Expanded(
              child: BlocConsumer<WarehouseBloc, WarehouseState>(
                listener: (context, state) {
                  if (state is WarehouseError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is WarehouseLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is WarehousesLoaded) {
                    var warehouses = state.warehouses;

                    // Apply city filter if selected
                    if (_selectedCity != null) {
                      warehouses = warehouses
                          .where((w) => w.city == _selectedCity)
                          .toList();
                    }

                    if (warehouses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warehouse_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No warehouses found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _showAddWarehouseDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Warehouse'),
                            ),
                          ],
                        ),
                      );
                    }

                    return WarehouseList(
                      warehouses: warehouses,
                      onEdit: _showEditWarehouseDialog,
                      onStatusChange: (warehouse, status) {
                        context.read<WarehouseBloc>().add(
                          UpdateWarehouseStatus(warehouse.id, status),
                        );
                      },
                      onDelete: _handleDeleteWarehouse,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isSmallScreen
          ? FloatingActionButton(
        onPressed: _showAddWarehouseDialog,
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
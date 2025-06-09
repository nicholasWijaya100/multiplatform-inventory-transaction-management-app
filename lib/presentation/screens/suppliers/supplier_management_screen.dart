import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/supplier/supplier_bloc.dart';
import '../../../data/models/supplier_model.dart';
import '../../widgets/suppliers/add_supplier_dialog.dart';
import '../../widgets/suppliers/edit_supplier_dialog.dart';
import '../../widgets/suppliers/supplier_filters.dart';
import '../../widgets/suppliers/supplier_list.dart';
import '../../widgets/suppliers/supplier_stats_card.dart';

class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({Key? key}) : super(key: key);

  @override
  State<SupplierManagementScreen> createState() => _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(LoadSuppliers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddSupplierDialog(),
    );
  }

  void _showEditSupplierDialog(SupplierModel supplier) {
    showDialog(
      context: context,
      builder: (context) => EditSupplierDialog(supplier: supplier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Supplier Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen)
                  ElevatedButton.icon(
                    onPressed: _showAddSupplierDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Supplier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
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
            const SupplierStatsCards(),
            const SizedBox(height: 24),

            // Filters
            SupplierFilters(
              searchController: _searchController,
              showInactive: _showInactive,
              onSearchChanged: (value) {
                context.read<SupplierBloc>().add(SearchSuppliers(value));
              },
              onShowInactiveChanged: (value) {
                setState(() => _showInactive = value);
                context.read<SupplierBloc>().add(ShowInactiveSuppliers(value));
              },
            ),
            const SizedBox(height: 16),

            // Supplier List
            Expanded(
              child: BlocConsumer<SupplierBloc, SupplierState>(
                listener: (context, state) {
                  if (state is SupplierError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is SupplierLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SuppliersLoaded) {
                    if (state.suppliers.isEmpty) {
                      return const Center(
                        child: Text('No suppliers found'),
                      );
                    }

                    return SupplierList(
                      suppliers: state.suppliers,
                      onEdit: _showEditSupplierDialog,
                      onStatusChange: (supplier, status) {
                        context.read<SupplierBloc>().add(
                          UpdateSupplierStatus(supplier.id, status),
                        );
                      },
                      onDelete: (supplier) {
                        context.read<SupplierBloc>().add(
                          DeleteSupplier(supplier.id),
                        );
                      },
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
        onPressed: _showAddSupplierDialog,
        backgroundColor: Colors.blue[100],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
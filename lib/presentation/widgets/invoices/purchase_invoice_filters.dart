import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/supplier/supplier_bloc.dart';
import '../../../data/models/purchase_invoice_model.dart';

class PurchaseInvoiceFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedSupplier;
  final String? selectedStatus;
  final bool showOverdue;
  final void Function(String) onSearchChanged;
  final void Function(String?) onSupplierChanged;
  final void Function(String?) onStatusChanged;
  final void Function(bool) onShowOverdueChanged;

  const PurchaseInvoiceFilters({
    Key? key,
    required this.searchController,
    required this.selectedSupplier,
    required this.selectedStatus,
    required this.showOverdue,
    required this.onSearchChanged,
    required this.onSupplierChanged,
    required this.onStatusChanged,
    required this.onShowOverdueChanged,
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
                  hintText: 'Search invoices...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: 16),
              _buildSupplierFilter(),
              const SizedBox(height: 16),
              _buildStatusFilter(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: showOverdue,
                    onChanged: (value) => onShowOverdueChanged(value ?? false),
                  ),
                  const Text('Show Overdue Only'),
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
                        hintText: 'Search invoices...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSupplierFilter()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatusFilter()),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: showOverdue,
                        onChanged: (value) => onShowOverdueChanged(value ?? false),
                      ),
                      const Text('Show Overdue Only'),
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

  Widget _buildSupplierFilter() {
    return BlocBuilder<SupplierBloc, SupplierState>(
      builder: (context, state) {
        if (state is SuppliersLoaded) {
          final activeSuppliers = state.suppliers
              .where((s) => s.isActive)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          return DropdownButtonFormField<String>(
            value: selectedSupplier,
            decoration: InputDecoration(
              labelText: 'Supplier',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Suppliers'),
              ),
              ...activeSuppliers.map((supplier) => DropdownMenuItem(
                value: supplier.id,
                child: Text(supplier.name),
              )),
            ],
            onChanged: onSupplierChanged,
          );
        }
        return const LinearProgressIndicator();
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All Statuses'),
        ),
        ...PurchaseInvoiceStatus.values.map((status) {
          final statusName = status.name[0].toUpperCase() + status.name.substring(1);
          return DropdownMenuItem(
            value: status.name,
            child: Text(statusName),
          );
        }),
      ],
      onChanged: onStatusChanged,
    );
  }
}
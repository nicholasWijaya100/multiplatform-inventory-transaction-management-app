import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/customer/customer_bloc.dart';
import '../../../data/models/invoice_model.dart';

class InvoiceFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedCustomer;
  final String? selectedStatus;
  final bool showOverdue;
  final void Function(String) onSearchChanged;
  final void Function(String?) onCustomerChanged;
  final void Function(String?) onStatusChanged;
  final void Function(bool) onShowOverdueChanged;

  const InvoiceFilters({
    Key? key,
    required this.searchController,
    required this.selectedCustomer,
    required this.selectedStatus,
    required this.showOverdue,
    required this.onSearchChanged,
    required this.onCustomerChanged,
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
              _buildCustomerFilter(),
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
                  Expanded(child: _buildCustomerFilter()),
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

  Widget _buildCustomerFilter() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomersLoaded) {
          final activeCustomers = state.customers
              .where((c) => c.isActive)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          return DropdownButtonFormField<String>(
            value: selectedCustomer,
            decoration: InputDecoration(
              labelText: 'Customer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Customers'),
              ),
              ...activeCustomers.map((customer) => DropdownMenuItem(
                value: customer.id,
                child: Text(customer.name),
              )),
            ],
            onChanged: onCustomerChanged,
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
        ...InvoiceStatus.values.map((status) {
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
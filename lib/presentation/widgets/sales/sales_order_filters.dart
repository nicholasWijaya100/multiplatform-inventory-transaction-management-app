import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/customer/customer_bloc.dart';
import '../../../data/models/sales_order_model.dart';

class SalesOrderFilters extends StatelessWidget {
  final TextEditingController searchController;
  final String? selectedCustomer;
  final String? selectedStatus;
  final void Function(String) onSearchChanged;
  final void Function(String?) onCustomerChanged;
  final void Function(String?) onStatusChanged;

  const SalesOrderFilters({
    Key? key,
    required this.searchController,
    required this.selectedCustomer,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onCustomerChanged,
    required this.onStatusChanged,
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
                  hintText: 'Search orders...',
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
            ] else ...[
              // Desktop Layout
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search orders...',
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
        ...SalesOrderStatus.values.map((status) {
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
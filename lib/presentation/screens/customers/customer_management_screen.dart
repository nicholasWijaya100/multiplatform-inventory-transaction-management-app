import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/customer/customer_bloc.dart';
import '../../../data/models/customer_model.dart';
import '../../widgets/customers/add_customer_dialog.dart';
import '../../widgets/customers/customer_filters.dart';
import '../../widgets/customers/customer_list.dart';
import '../../widgets/customers/customer_stats_cards.dart';
import '../../widgets/customers/edit_customer_dialog.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({Key? key}) : super(key: key);

  @override
  State<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCustomerDialog(),
    );
  }

  void _showEditCustomerDialog(CustomerModel customer) {
    showDialog(
      context: context,
      builder: (context) => EditCustomerDialog(customer: customer),
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen)
                  ElevatedButton.icon(
                    onPressed: _showAddCustomerDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Customer'),
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
            const CustomerStatsCards(),
            const SizedBox(height: 24),

            // Filters
            CustomerFilters(
              searchController: _searchController,
              showInactive: _showInactive,
              onSearchChanged: (value) {
                context.read<CustomerBloc>().add(SearchCustomers(value));
              },
              onShowInactiveChanged: (value) {
                setState(() => _showInactive = value);
                context.read<CustomerBloc>().add(ShowInactiveCustomers(value));
              },
            ),
            const SizedBox(height: 16),

            // Customer List
            Expanded(
              child: BlocConsumer<CustomerBloc, CustomerState>(
                listener: (context, state) {
                  if (state is CustomerError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is CustomerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CustomersLoaded) {
                    if (state.customers.isEmpty) {
                      return const Center(child: Text('No customers found'));
                    }

                    return CustomerList(
                      customers: state.customers,
                      onEdit: _showEditCustomerDialog,
                      onStatusChange: (customer, status) {
                        context.read<CustomerBloc>().add(
                          UpdateCustomerStatus(customer.id, status),
                        );
                      },
                      onDelete: (customer) {
                        context.read<CustomerBloc>().add(
                          DeleteCustomer(customer.id),
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
        onPressed: _showAddCustomerDialog,
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
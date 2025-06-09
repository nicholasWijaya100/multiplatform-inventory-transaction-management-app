import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/sales/sales_order_bloc.dart';
import '../../../data/models/sales_order_model.dart';
import '../../widgets/sales/add_sales_order_dialog.dart';
import '../../widgets/sales/sales_order_filters.dart';
import '../../widgets/sales/sales_order_list.dart';
import '../../widgets/sales/sales_order_stats_cards.dart';

class SalesOrderManagementScreen extends StatefulWidget {
  const SalesOrderManagementScreen({Key? key}) : super(key: key);

  @override
  State<SalesOrderManagementScreen> createState() => _SalesOrderManagementScreenState();
}

class _SalesOrderManagementScreenState extends State<SalesOrderManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCustomer;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<SalesOrderBloc>().add(LoadSalesOrders());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddSalesOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddSalesOrderDialog(),
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
                  'Sales Orders',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen)
                  ElevatedButton.icon(
                    onPressed: _showAddSalesOrderDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Order'),
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
            const SalesOrderStatsCards(),
            const SizedBox(height: 24),

            // Filters
            SalesOrderFilters(
              searchController: _searchController,
              selectedCustomer: _selectedCustomer,
              selectedStatus: _selectedStatus,
              onSearchChanged: (value) {
                context.read<SalesOrderBloc>().add(SearchSalesOrders(value));
              },
              onCustomerChanged: (value) {
                setState(() => _selectedCustomer = value);
                context.read<SalesOrderBloc>().add(
                  FilterSalesOrdersByCustomer(value),
                );
              },
              onStatusChanged: (value) {
                setState(() => _selectedStatus = value);
                context.read<SalesOrderBloc>().add(
                  FilterSalesOrdersByStatus(value),
                );
              },
            ),
            const SizedBox(height: 16),

            // Sales Orders List
            Expanded(
              child: BlocBuilder<SalesOrderBloc, SalesOrderState>(
                builder: (context, state) {
                  if (state is SalesOrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SalesOrderError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is SalesOrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return const Center(
                        child: Text('No sales orders found'),
                      );
                    }

                    return SalesOrderList(
                      orders: state.orders,
                      onStatusUpdate: (order, newStatus) {
                        context.read<SalesOrderBloc>().add(
                          UpdateSalesOrderStatus(order.id, newStatus),
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
        onPressed: _showAddSalesOrderDialog,
        backgroundColor: Colors.blue[100],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
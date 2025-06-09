import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/purchase/purchase_bloc.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../widgets/purchase_orders/add_purchase_order_dialog.dart';
import '../../widgets/purchase_orders/purchase_order_filters.dart';
import '../../widgets/purchase_orders/purchase_order_list.dart';
import '../../widgets/purchase_orders/purchase_order_stats_card.dart';

class PurchaseOrderManagementScreen extends StatefulWidget {
  const PurchaseOrderManagementScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseOrderManagementScreen> createState() => _PurchaseOrderManagementScreenState();
}

class _PurchaseOrderManagementScreenState extends State<PurchaseOrderManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSupplier;
  String? _selectedStatus;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    context.read<PurchaseBloc>().add(LoadPurchaseOrders());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddPurchaseOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddPurchaseOrderDialog(),
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
                  'Purchase Orders',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen)
                  ElevatedButton.icon(
                    onPressed: _showAddPurchaseOrderDialog,
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
            const PurchaseOrderStatsCards(),
            const SizedBox(height: 24),

            // Filters
            PurchaseOrderFilters(
              searchController: _searchController,
              selectedSupplier: _selectedSupplier,
              selectedStatus: _selectedStatus,
              onSearchChanged: (value) {
                context.read<PurchaseBloc>().add(SearchPurchaseOrders(value));
              },
              onSupplierChanged: (value) {
                setState(() => _selectedSupplier = value);
                context.read<PurchaseBloc>().add(
                  FilterPurchaseOrdersBySupplier(value),
                );
              },
              onStatusChanged: (value) {
                setState(() => _selectedStatus = value);
                context.read<PurchaseBloc>().add(
                  FilterPurchaseOrdersByStatus(value),
                );
              },
            ),
            const SizedBox(height: 16),

            // Purchase Orders List
            Expanded(
              child: BlocBuilder<PurchaseBloc, PurchaseState>(
                builder: (context, state) {
                  if (state is PurchaseLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PurchaseError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is PurchaseOrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return const Center(
                        child: Text('No purchase orders found'),
                      );
                    }

                    return PurchaseOrderList(
                      orders: state.orders,
                      onStatusUpdate: (order, newStatus) {
                        context.read<PurchaseBloc>().add(
                          UpdatePurchaseOrderStatus(order.id, newStatus),
                        );
                      },
                      onViewDetails: (order) {
                        // Show purchase order details dialog
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
        onPressed: _showAddPurchaseOrderDialog,
        backgroundColor: Colors.blue[100],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
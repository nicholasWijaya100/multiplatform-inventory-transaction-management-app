import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/purchase_invoice/purchase_invoice_bloc.dart';
import '../../../data/models/purchase_invoice_model.dart';
import '../../widgets/invoices/add_purchase_invoice_dialog.dart';
import '../../widgets/invoices/purchase_invoice_filters.dart';
import '../../widgets/invoices/purchase_invoice_list.dart';
import '../../widgets/invoices/purchase_invoice_stats_cards.dart';

class PurchaseInvoiceManagementScreen extends StatefulWidget {
  const PurchaseInvoiceManagementScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseInvoiceManagementScreen> createState() => _PurchaseInvoiceManagementScreenState();
}

class _PurchaseInvoiceManagementScreenState extends State<PurchaseInvoiceManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSupplier;
  String? _selectedStatus;
  bool _showOverdue = false;

  @override
  void initState() {
    super.initState();
    context.read<PurchaseInvoiceBloc>().add(LoadPurchaseInvoices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddPurchaseInvoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddPurchaseInvoiceDialog(),
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
                  'Purchase Invoices',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen)
                  ElevatedButton.icon(
                    onPressed: _showAddPurchaseInvoiceDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Invoice'),
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
            const PurchaseInvoiceStatsCards(),
            const SizedBox(height: 24),

            // Filters
            PurchaseInvoiceFilters(
              searchController: _searchController,
              selectedSupplier: _selectedSupplier,
              selectedStatus: _selectedStatus,
              showOverdue: _showOverdue,
              onSearchChanged: (value) {
                context.read<PurchaseInvoiceBloc>().add(SearchPurchaseInvoices(value));
              },
              onSupplierChanged: (value) {
                setState(() => _selectedSupplier = value);
                context.read<PurchaseInvoiceBloc>().add(
                  FilterPurchaseInvoicesBySupplier(value),
                );
              },
              onStatusChanged: (value) {
                setState(() => _selectedStatus = value);
                context.read<PurchaseInvoiceBloc>().add(
                  FilterPurchaseInvoicesByStatus(value),
                );
              },
              onShowOverdueChanged: (value) {
                setState(() => _showOverdue = value);
                context.read<PurchaseInvoiceBloc>().add(
                  ShowOverduePurchaseInvoices(value),
                );
              },
            ),
            const SizedBox(height: 16),

            // Invoices List
            Expanded(
              child: BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
                builder: (context, state) {
                  if (state is PurchaseInvoiceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is PurchaseInvoiceError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is PurchaseInvoicesLoaded) {
                    if (state.invoices.isEmpty) {
                      return const Center(
                        child: Text('No purchase invoices found'),
                      );
                    }

                    return PurchaseInvoiceList(
                      invoices: state.invoices,
                      onStatusUpdate: (invoice, newStatus) {
                        context.read<PurchaseInvoiceBloc>().add(
                          UpdatePurchaseInvoiceStatus(invoice.id, newStatus),
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
        onPressed: _showAddPurchaseInvoiceDialog,
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
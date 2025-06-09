import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/invoice/invoice_bloc.dart';
import '../../../data/models/invoice_model.dart';
import '../../widgets/invoices/add_invoice_dialog.dart';
import '../../widgets/invoices/invoice_filters.dart';
import '../../widgets/invoices/invoice_list.dart';
import '../../widgets/invoices/invoice_stats_cards.dart';

class InvoiceManagementScreen extends StatefulWidget {
  const InvoiceManagementScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceManagementScreen> createState() => _InvoiceManagementScreenState();
}

class _InvoiceManagementScreenState extends State<InvoiceManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCustomer;
  String? _selectedStatus;
  bool _showOverdue = false;

  @override
  void initState() {
    super.initState();
    context.read<InvoiceBloc>().add(LoadInvoices());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddInvoiceDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddInvoiceDialog(),
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
                  'Invoices',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen)
                  ElevatedButton.icon(
                    onPressed: _showAddInvoiceDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Invoice'),
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
            const InvoiceStatsCards(),
            const SizedBox(height: 24),

            // Filters
            InvoiceFilters(
              searchController: _searchController,
              selectedCustomer: _selectedCustomer,
              selectedStatus: _selectedStatus,
              showOverdue: _showOverdue,
              onSearchChanged: (value) {
                context.read<InvoiceBloc>().add(SearchInvoices(value));
              },
              onCustomerChanged: (value) {
                setState(() => _selectedCustomer = value);
                context.read<InvoiceBloc>().add(
                  FilterInvoicesByCustomer(value),
                );
              },
              onStatusChanged: (value) {
                setState(() => _selectedStatus = value);
                context.read<InvoiceBloc>().add(
                  FilterInvoicesByStatus(value),
                );
              },
              onShowOverdueChanged: (value) {
                setState(() => _showOverdue = value);
                context.read<InvoiceBloc>().add(
                  ShowOverdueInvoices(value),
                );
              },
            ),
            const SizedBox(height: 16),

            // Invoices List
            Expanded(
              child: BlocBuilder<InvoiceBloc, InvoiceState>(
                builder: (context, state) {
                  if (state is InvoiceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is InvoiceError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is InvoicesLoaded) {
                    if (state.invoices.isEmpty) {
                      return const Center(
                        child: Text('No invoices found'),
                      );
                    }

                    return InvoiceList(
                      invoices: state.invoices,
                      onStatusUpdate: (invoice, newStatus) {
                        context.read<InvoiceBloc>().add(
                          UpdateInvoiceStatus(invoice.id, newStatus),
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
        onPressed: _showAddInvoiceDialog,
        backgroundColor: Colors.blue[100],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
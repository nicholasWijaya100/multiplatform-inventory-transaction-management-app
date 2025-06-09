import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/customer/customer_bloc.dart';
import '../../../blocs/invoice/invoice_bloc.dart';
import '../../../blocs/sales/sales_order_bloc.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/sales_order_model.dart';
import '../../../utils/formatter.dart';

class AddInvoiceDialog extends StatefulWidget {
  const AddInvoiceDialog({Key? key}) : super(key: key);

  @override
  State<AddInvoiceDialog> createState() => _AddInvoiceDialogState();
}

class _AddInvoiceDialogState extends State<AddInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  CustomerModel? _selectedCustomer;
  SalesOrderModel? _selectedOrder;
  final List<InvoiceItem> _items = [];
  final _notesController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _taxRateController = TextEditingController(text: '10.0');
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  double _subtotal = 0.0;
  double _tax = 0.0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomers());
    context.read<SalesOrderBloc>().add(LoadSalesOrders());
  }

  @override
  void dispose() {
    _notesController.dispose();
    _paymentTermsController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  void _updateTotals() {
    final taxRate = double.tryParse(_taxRateController.text) ?? 0.0;
    setState(() {
      _subtotal = _items.fold(0.0, (sum, item) => sum + item.total);
      _tax = _subtotal * (taxRate / 100);
      _total = _subtotal + _tax;
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a customer'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedOrder == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a sales order'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one item'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final invoice = InvoiceModel(
        id: '',  // Will be set by Firestore
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        salesOrderId: _selectedOrder!.id,
        status: InvoiceStatus.draft.name,
        items: _items,
        subtotal: _subtotal,
        tax: _tax,
        total: _total,
        dueDate: _dueDate,
        notes: _notesController.text.trim(),
        paymentTerms: _paymentTermsController.text.trim(),
        isPaid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<InvoiceBloc>().add(AddInvoice(invoice));
      Navigator.pop(context);
    }
  }

  void _loadOrderItems(SalesOrderModel order) {
    setState(() {
      _items.clear();
      for (var item in order.items) {
        _items.add(
          InvoiceItem(
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            total: item.totalPrice,
          ),
        );
      }
      _updateTotals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 800,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Invoice',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Content Area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Selection
                      BlocBuilder<CustomerBloc, CustomerState>(
                        builder: (context, state) {
                          if (state is CustomersLoaded) {
                            final activeCustomers = state.customers
                                .where((c) => c.isActive)
                                .toList();

                            return DropdownButtonFormField<CustomerModel>(
                              value: _selectedCustomer,
                              decoration: InputDecoration(
                                labelText: 'Customer',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: [
                                ...activeCustomers.map((customer) {
                                  return DropdownMenuItem(
                                    value: customer,
                                    child: Text(customer.name),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCustomer = value;
                                  _selectedOrder = null;
                                  _items.clear();
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a customer';
                                }
                                return null;
                              },
                            );
                          }
                          return const LinearProgressIndicator();
                        },
                      ),
                      const SizedBox(height: 16),

                      // Order Selection
                      BlocBuilder<SalesOrderBloc, SalesOrderState>(
                        builder: (context, state) {
                          if (state is SalesOrdersLoaded) {
                            final customerOrders = _selectedCustomer != null
                                ? state.orders
                                .where((o) => o.customerId == _selectedCustomer!.id)
                                .where((o) => (o.status == SalesOrderStatus.delivered.name ||
                                o.status == SalesOrderStatus.shipped.name))
                                .where((o) => !o.isPaid) // Only show unpaid orders
                                .toList()
                                : [];

                            return DropdownButtonFormField<SalesOrderModel>(
                              isExpanded: true,
                              value: _selectedOrder,
                              decoration: InputDecoration(
                                labelText: 'Sales Order',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                                items: [
                                  ...customerOrders.map((order) {
                                    return DropdownMenuItem(
                                      value: order,
                                      child: Text(
                                        'Order #${order.id} (${Formatters.formatCurrency(order.totalAmount)})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedOrder = value;
                                  if (value != null) {
                                    _loadOrderItems(value);
                                  } else {
                                    _items.clear();
                                    _updateTotals();
                                  }
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a sales order';
                                }
                                return null;
                              },
                            );
                          }
                          return const LinearProgressIndicator();
                        },
                      ),
                      const SizedBox(height: 24),

                      // Items Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Items',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_items.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.receipt_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No items added yet. Select a sales order to load items.',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _items.length,
                                  separatorBuilder: (context, index) =>
                                  const Divider(),
                                  itemBuilder: (context, index) {
                                    final item = _items[index];
                                    return ListTile(
                                      title: Text(
                                        item.productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${item.quantity} x ${Formatters.formatCurrency(item.unitPrice)}',
                                      ),
                                      trailing: Text(
                                        Formatters.formatCurrency(item.total),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tax and Payment Options
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _paymentTermsController,
                              decoration: InputDecoration(
                                labelText: 'Payment Terms',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText: 'e.g., Net 30, Due on Receipt',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Due Date
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _dueDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Due Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Formatters.formatDate(_dueDate),
                              ),
                              const Icon(Icons.calendar_today_outlined),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Add any additional notes or payment instructions',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Summary and Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Invoice Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', Formatters.formatCurrency(_subtotal)),
                        const SizedBox(height: 8),
                        _buildSummaryRow('Tax (${_taxRateController.text}%)', Formatters.formatCurrency(_tax)),
                        const Divider(height: 16),
                        _buildSummaryRow(
                          'Total Amount',
                          Formatters.formatCurrency(_total),
                          valueStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                        ),
                        child: const Text('Create Invoice'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: valueStyle ?? const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
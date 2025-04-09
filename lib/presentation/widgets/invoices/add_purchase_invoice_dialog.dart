import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/purchase/purchase_bloc.dart';
import '../../../blocs/purchase_invoice/purchase_invoice_bloc.dart';
import '../../../blocs/supplier/supplier_bloc.dart';
import '../../../data/models/purchase_invoice_model.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../../utils/formatter.dart';

class AddPurchaseInvoiceDialog extends StatefulWidget {
  const AddPurchaseInvoiceDialog({Key? key}) : super(key: key);

  @override
  State<AddPurchaseInvoiceDialog> createState() => _AddPurchaseInvoiceDialogState();
}

class _AddPurchaseInvoiceDialogState extends State<AddPurchaseInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSupplierId;
  String? _selectedSupplierName;
  PurchaseOrderModel? _selectedOrder;
  final List<PurchaseInvoiceItem> _items = [];
  final _notesController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _taxRateController = TextEditingController(text: '10.0');
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));
  double _subtotal = 0.0;
  double _tax = 0.0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(LoadSuppliers());
    context.read<PurchaseBloc>().add(LoadPurchaseOrders());
  }

  @override
  void dispose() {
    _notesController.dispose();
    _paymentTermsController.dispose();
    _invoiceNumberController.dispose();
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
      if (_selectedSupplierId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a supplier'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_selectedOrder == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a purchase order'),
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

      final invoice = PurchaseInvoiceModel(
        id: '',  // Will be set by Firestore
        supplierId: _selectedSupplierId!,
        supplierName: _selectedSupplierName!,
        purchaseOrderId: _selectedOrder!.id,
        status: PurchaseInvoiceStatus.draft.name,
        items: _items,
        subtotal: _subtotal,
        tax: _tax,
        total: _total,
        dueDate: _dueDate,
        notes: _notesController.text.trim(),
        paymentTerms: _paymentTermsController.text.trim(),
        invoiceNumber: _invoiceNumberController.text.trim(),
        isPaid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      context.read<PurchaseInvoiceBloc>().add(AddPurchaseInvoice(invoice));
      Navigator.pop(context);
    }
  }

  void _loadOrderItems(PurchaseOrderModel order) {
    setState(() {
      _items.clear();
      for (var item in order.items) {
        _items.add(
          PurchaseInvoiceItem(
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
                    'Create Purchase Invoice',
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
                      // Supplier Selection
                      BlocBuilder<SupplierBloc, SupplierState>(
                        builder: (context, state) {
                          if (state is SuppliersLoaded) {
                            final activeSuppliers = state.suppliers
                                .where((s) => s.isActive)
                                .toList();

                            return DropdownButtonFormField<String>(
                              value: _selectedSupplierId,
                              decoration: InputDecoration(
                                labelText: 'Supplier',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: [
                                ...activeSuppliers.map((supplier) {
                                  return DropdownMenuItem(
                                    value: supplier.id,
                                    child: Text(supplier.name),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedSupplierId = value;
                                  _selectedOrder = null;
                                  _items.clear();
                                  if (value != null) {
                                    _selectedSupplierName = activeSuppliers
                                        .firstWhere((s) => s.id == value)
                                        .name;
                                  }
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a supplier';
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
                      BlocBuilder<PurchaseBloc, PurchaseState>(
                        builder: (context, state) {
                          if (state is PurchaseOrdersLoaded) {
                            final supplierOrders = _selectedSupplierId != null
                                ? state.orders
                                .where((o) => o.supplierId == _selectedSupplierId)
                                .where((o) => o.status == PurchaseOrderStatus.received.name)
                                .where((o) => !o.isPaid) // Only show unpaid orders
                                .toList()
                                : [];

                            return DropdownButtonFormField<PurchaseOrderModel>(
                              isExpanded: true,
                              value: _selectedOrder,
                              decoration: InputDecoration(
                                labelText: 'Purchase Order',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              items: [
                                ...supplierOrders.map((order) {
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
                                  return 'Please select a purchase order';
                                }
                                return null;
                              },
                            );
                          }
                          return const LinearProgressIndicator();
                        },
                      ),
                      const SizedBox(height: 24),

                      // Invoice Number
                      TextFormField(
                        controller: _invoiceNumberController,
                        decoration: InputDecoration(
                          labelText: 'Supplier\'s Invoice Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Enter the supplier\'s original invoice number',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the supplier\'s invoice number';
                          }
                          return null;
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
                                          'No items added yet. Select a purchase order to load items.',
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
                              controller: _taxRateController,
                              decoration: InputDecoration(
                                labelText: 'Tax Rate (%)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                suffixText: '%',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _updateTotals(),
                            ),
                          ),
                          const SizedBox(width: 16),
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
                          backgroundColor: Colors.blue[900],
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
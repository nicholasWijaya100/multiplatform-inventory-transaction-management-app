// lib/presentation/widgets/sales/add_sales_order_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/customer/customer_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../blocs/sales/sales_order_bloc.dart';
import '../../../data/models/sales_order_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/product_model.dart';
import '../../../utils/formatter.dart';

class AddSalesOrderDialog extends StatefulWidget {
  const AddSalesOrderDialog({Key? key}) : super(key: key);

  @override
  State<AddSalesOrderDialog> createState() => _AddSalesOrderDialogState();
}

class _AddSalesOrderDialogState extends State<AddSalesOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  CustomerModel? _selectedCustomer;
  final List<SalesOrderItem> _items = [];
  final _notesController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  DateTime? _deliveryDate;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(LoadCustomers());
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _notesController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
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

      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one item'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final order = SalesOrderModel(
        id: '',  // Will be set by Firestore
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        status: 'draft',
        items: _items,
        totalAmount: _items.fold(
          0,
              (sum, item) => sum + item.totalPrice,
        ),
        notes: _notesController.text.trim(),
        paymentTerms: _paymentTermsController.text.trim(),
        isPaid: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        deliveryDate: _deliveryDate,
      );

      context.read<SalesOrderBloc>().add(AddSalesOrder(order));
      Navigator.pop(context);
    }
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
                    'Create Sales Order',
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
                                setState(() => _selectedCustomer = value);
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
                      const SizedBox(height: 24),

                      // Items Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Items',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _addItem,
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Item'),
                                  ),
                                ],
                              ),
                              if (_items.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.shopping_cart_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No items added yet',
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
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            Formatters.formatCurrency(
                                                item.totalPrice),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            onPressed: () => _removeItem(index),
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Additional Details
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
                                hintText: 'e.g., Net 30, COD',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _deliveryDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() => _deliveryDate = date);
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Expected Delivery Date',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _deliveryDate != null
                                          ? Formatters.formatDate(_deliveryDate!)
                                          : 'Select Date',
                                    ),
                                    const Icon(Icons.calendar_today_outlined),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Add any additional notes or instructions',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer with Total and Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Total Amount
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(
                            _items.fold(0, (sum, item) => sum + item.totalPrice),
                          ),
                          style: const TextStyle(
                            fontSize: 20,
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
                        child: const Text('Create Order'),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// The AddItemDialog component for selecting products and quantities
class _AddItemDialog extends StatefulWidget {
  final Function(SalesOrderItem) onAdd;

  const _AddItemDialog({required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  ProductModel? _selectedProduct;
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _notesController = TextEditingController();
  double _total = 0;

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    setState(() {
      _total = quantity * unitPrice;
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a product'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final item = SalesOrderItem(
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        quantity: int.parse(_quantityController.text),
        unitPrice: double.parse(_unitPriceController.text),
        totalPrice: _total,
        notes: _notesController.text.trim(),
      );

      widget.onAdd(item);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Item',
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

              // Product Selection
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductsLoaded) {
                    final activeProducts = state.products
                        .where((p) => p.isActive)
                        .toList();

                    return DropdownButtonFormField<ProductModel>(
                      value: _selectedProduct,
                      decoration: InputDecoration(
                        labelText: 'Product',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: [
                        ...activeProducts.map((product) => DropdownMenuItem(
                          value: product,
                          child: Text(product.name),
                        )),
                      ],
                      onChanged: (product) {
                        setState(() {
                          _selectedProduct = product;
                          if (product != null) {
                            _unitPriceController.text = product.price.toString();
                            _updateTotal();
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a product';
                        }
                        return null;
                      },
                    );
                  }
                  return const LinearProgressIndicator();
                },
              ),
              const SizedBox(height: 16),

              // Quantity and Unit Price Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity <= 0) {
                          return 'Invalid quantity';
                        }
                        return null;
                      },
                      onChanged: (value) => _updateTotal(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitPriceController,
                      decoration: InputDecoration(
                        labelText: 'Unit Price',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                      onChanged: (value) => _updateTotal(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Total and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(_total),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // <-- handle overflow
                        ),
                      ],
                    ),
                  ),
                  Row(
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
                        child: const Text('Add Item'),
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
}
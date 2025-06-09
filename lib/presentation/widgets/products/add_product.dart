import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../blocs/warehouse/warehouse_bloc.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/warehouse_model.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({Key? key}) : super(key: key);

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategory;
  final Map<String, TextEditingController> _warehouseStockControllers = {};
  Map<String, WarehouseModel> _selectedWarehouses = {};

  @override
  void initState() {
    super.initState();
    // Load warehouses when dialog opens
    context.read<WarehouseBloc>().add(LoadWarehouses());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    for (var controller in _warehouseStockControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Calculate total stock across all warehouses
      int totalStock = 0;
      final Map<String, int> warehouseStock = {};

      // Process warehouse stock
      for (var entry in _warehouseStockControllers.entries) {
        final stockValue = int.tryParse(entry.value.text) ?? 0;
        if (stockValue > 0) {
          warehouseStock[entry.key] = stockValue;
          totalStock += stockValue;
        }
      }

      final product = ProductModel(
        id: '', // Will be set by Firestore
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        price: double.parse(_priceController.text),
        quantity: totalStock,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        warehouseStock: warehouseStock,
      );

      context.read<ProductBloc>().add(AddProduct(product));
      Navigator.pop(context);
    }
  }

  Widget _buildWarehouseStockInput(WarehouseModel warehouse) {
    // Create controller if it doesn't exist
    _warehouseStockControllers.putIfAbsent(
      warehouse.id,
          () => TextEditingController(),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouse.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      warehouse.city,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _selectedWarehouses.containsKey(warehouse.id)
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  color: _selectedWarehouses.containsKey(warehouse.id)
                      ? Colors.red
                      : Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    if (_selectedWarehouses.containsKey(warehouse.id)) {
                      _selectedWarehouses.remove(warehouse.id);
                      _warehouseStockControllers[warehouse.id]?.clear();
                    } else {
                      _selectedWarehouses[warehouse.id] = warehouse;
                    }
                  });
                },
              ),
            ],
          ),
          if (_selectedWarehouses.containsKey(warehouse.id)) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _warehouseStockControllers[warehouse.id],
              decoration: const InputDecoration(
                labelText: 'Initial Stock',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (_selectedWarehouses.containsKey(warehouse.id)) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stock quantity';
                  }
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) {
                    return 'Please enter a valid quantity';
                  }
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add New Product',
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

                // Existing product fields...
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'Enter product name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a product name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category dropdown...
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductsLoaded) {
                      return DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: state.categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() => _selectedCategory = value);
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),

                // Description field...
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Price field
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}$'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Warehouse Stock Section
                const Text(
                  'Warehouse Stock',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<WarehouseBloc, WarehouseState>(
                  builder: (context, state) {
                    if (state is WarehousesLoaded) {
                      if (state.warehouses.isEmpty) {
                        return const Text(
                          'No warehouses available. Please add a warehouse first.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        );
                      }

                      return Column(
                        children: state.warehouses
                            .where((w) => w.isActive) // Only show active warehouses
                            .map((warehouse) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildWarehouseStockInput(warehouse),
                        ))
                            .toList(),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[100],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Add Product'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
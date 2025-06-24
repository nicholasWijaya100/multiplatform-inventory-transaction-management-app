import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/warehouse/warehouse_bloc.dart';
import '../../../blocs/sales/sales_order_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../data/models/sales_order_model.dart';
import '../../../data/models/product_model.dart';

class ShipOrderDialog extends StatefulWidget {
  final SalesOrderModel order;

  const ShipOrderDialog({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<ShipOrderDialog> createState() => _ShipOrderDialogState();
}

class _ShipOrderDialogState extends State<ShipOrderDialog> {
  String? _selectedWarehouseId;
  Map<String, bool> _stockAvailability = {};
  Map<String, String> _stockMessages = {};
  bool _isCheckingStock = false;

  @override
  void initState() {
    super.initState();
    context.read<WarehouseBloc>().add(LoadWarehouses());
    context.read<ProductBloc>().add(LoadProducts());
  }

  Future<void> _checkStockAvailability(String warehouseId) async {
    setState(() {
      _isCheckingStock = true;
      _stockAvailability.clear();
      _stockMessages.clear();
    });

    final productState = context.read<ProductBloc>().state;
    if (productState is ProductsLoaded) {
      for (final orderItem in widget.order.items) {
        final product = productState.products.firstWhere(
              (p) => p.id == orderItem.productId,
          orElse: () => ProductModel(
            id: orderItem.productId,
            name: orderItem.productName,
            category: '',
            price: 0,
            quantity: 0,
            isActive: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            warehouseStock: {},
          ),
        );

        final stockInWarehouse = product.warehouseStock[warehouseId] ?? 0;
        final isAvailable = stockInWarehouse >= orderItem.quantity;

        _stockAvailability[orderItem.productId] = isAvailable;
        _stockMessages[orderItem.productId] =
        '${orderItem.productName}: ${stockInWarehouse} available / ${orderItem.quantity} required';
      }
    }

    setState(() {
      _isCheckingStock = false;
    });
  }

  bool get _canShip {
    if (_selectedWarehouseId == null || _isCheckingStock) return false;
    return _stockAvailability.values.every((available) => available == true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ship Order'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select the warehouse from which goods will be shipped:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'A delivery note will be created for this warehouse.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            BlocBuilder<WarehouseBloc, WarehouseState>(
              builder: (context, state) {
                if (state is WarehouseLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is WarehousesLoaded) {
                  final activeWarehouses = state.warehouses
                      .where((w) => w.isActive)
                      .toList();

                  if (activeWarehouses.isEmpty) {
                    return const Text('No active warehouses available');
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedWarehouseId,
                    decoration: InputDecoration(
                      labelText: 'Shipping Warehouse',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: activeWarehouses.map((warehouse) {
                      return DropdownMenuItem(
                        value: warehouse.id,
                        child: Text(warehouse.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWarehouseId = value;
                      });
                      if (value != null) {
                        _checkStockAvailability(value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a warehouse';
                      }
                      return null;
                    },
                  );
                }

                return const Text('Failed to load warehouses');
              },
            ),
            if (_selectedWarehouseId != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Stock Availability:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_isCheckingStock)
                const Center(child: CircularProgressIndicator())
              else
                ..._stockMessages.entries.map((entry) {
                  final isAvailable = _stockAvailability[entry.key] ?? false;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          isAvailable ? Icons.check_circle : Icons.error,
                          size: 16,
                          color: isAvailable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 12,
                              color: isAvailable ? Colors.green[700] : Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              if (!_canShip && !_isCheckingStock)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: const Text(
                    'Cannot ship: Insufficient stock in selected warehouse',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canShip
              ? () {
            context.read<SalesOrderBloc>().add(
              UpdateSalesOrderStatusWithWarehouse(
                widget.order.id,
                'shipped',
                _selectedWarehouseId!,
              ),
            );
            Navigator.pop(context);
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade100,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: const Text('Ship Order'),
        ),
      ],
    );
  }
}
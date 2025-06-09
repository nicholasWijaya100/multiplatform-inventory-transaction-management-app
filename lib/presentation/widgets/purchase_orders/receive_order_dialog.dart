import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/warehouse/warehouse_bloc.dart';
import '../../../blocs/purchase/purchase_bloc.dart';
import '../../../data/models/purchase_order_model.dart';

class ReceiveOrderDialog extends StatefulWidget {
  final PurchaseOrderModel order;

  const ReceiveOrderDialog({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<ReceiveOrderDialog> createState() => _ReceiveOrderDialogState();
}

class _ReceiveOrderDialogState extends State<ReceiveOrderDialog> {
  String? _selectedWarehouseId;

  @override
  void initState() {
    super.initState();
    context.read<WarehouseBloc>().add(LoadWarehouses());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Receive Order'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select the warehouse where the goods will be received:',
            style: TextStyle(fontSize: 14),
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
                    labelText: 'Receiving Warehouse',
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        BlocBuilder<WarehouseBloc, WarehouseState>(
          builder: (context, state) {
            return ElevatedButton(
              onPressed: _selectedWarehouseId == null
                  ? null
                  : () {
                context.read<PurchaseBloc>().add(
                  ReceivePurchaseOrder(
                    orderId: widget.order.id,
                    warehouseId: _selectedWarehouseId!,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
              ),
              child: const Text('Receive Order'),
            );
          },
        ),
      ],
    );
  }
}
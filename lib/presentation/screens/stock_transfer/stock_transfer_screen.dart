import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../blocs/warehouse/warehouse_bloc.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../utils/formatter.dart';

class StockTransferScreen extends StatefulWidget {
  const StockTransferScreen({Key? key}) : super(key: key);

  @override
  State<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends State<StockTransferScreen> {
  final TextEditingController _searchController = TextEditingController();
  WarehouseModel? _sourceWarehouse;
  WarehouseModel? _destinationWarehouse;
  ProductModel? _selectedProduct;
  int _transferQuantity = 0;

  @override
  void initState() {
    super.initState();
    context.read<WarehouseBloc>().add(LoadWarehouses());
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleTransfer() {
    if (_sourceWarehouse == null ||
        _destinationWarehouse == null ||
        _selectedProduct == null ||
        _transferQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentStock =
        _selectedProduct!.warehouseStock[_sourceWarehouse!.id] ?? 0;
    if (_transferQuantity > currentStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient stock in source warehouse'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update source warehouse stock
    context.read<ProductBloc>().add(
      UpdateProductStock(
        _selectedProduct!.id,
        _sourceWarehouse!.id,
        currentStock - _transferQuantity,
      ),
    );

    // Update destination warehouse stock
    final destinationStock =
        _selectedProduct!.warehouseStock[_destinationWarehouse!.id] ?? 0;
    context.read<ProductBloc>().add(
      UpdateProductStock(
        _selectedProduct!.id,
        _destinationWarehouse!.id,
        destinationStock + _transferQuantity,
      ),
    );

    // Reset form
    setState(() {
      _selectedProduct = null;
      _transferQuantity = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stock transfer completed successfully'),
        backgroundColor: Colors.green,
      ),
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
            Text(
              'Stock Transfer',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Transfer Form
            Expanded(  // Wrap in Expanded
              child: SingleChildScrollView(  // Add ScrollView
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Warehouse Selection
                        if (isSmallScreen) ...[
                          _buildWarehouseDropdowns(context),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end, // Align to bottom of row
                            children: [
                              Expanded(
                                child: _buildSourceWarehouseDropdown(context),
                              ),
                              SizedBox(
                                width: 60, // Give more space for the arrow
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end, // Align to bottom
                                  children: [
                                    const SizedBox(height: 8), // Adjust this value as needed
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: _buildDestinationWarehouseDropdown(context),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Product Selection
                        if (_sourceWarehouse != null) ...[
                          Text(
                            'Select Product',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildProductList(context),
                        ],

                        if (_selectedProduct != null) ...[
                          const SizedBox(height: 24),
                          _buildTransferQuantity(context),
                          const SizedBox(height: 24),
                          _buildTransferButton(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseDropdowns(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSourceWarehouseDropdown(context),
        const SizedBox(height: 16),
        _buildDestinationWarehouseDropdown(context),
      ],
    );
  }

  Widget _buildSourceWarehouseDropdown(BuildContext context) {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, state) {
        if (state is WarehousesLoaded) {
          final warehouses = state.warehouses.where((w) => w.isActive).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Source Warehouse',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<WarehouseModel>(
                value: _sourceWarehouse,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Select source warehouse',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                items: warehouses
                    .where((w) => w != _destinationWarehouse)
                    .map((warehouse) {
                  return DropdownMenuItem(
                    value: warehouse,
                    child: Text(
                      warehouse.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (warehouse) {
                  setState(() {
                    _sourceWarehouse = warehouse;
                    _selectedProduct = null;
                  });
                },
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDestinationWarehouseDropdown(BuildContext context) {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, state) {
        if (state is WarehousesLoaded) {
          final warehouses = state.warehouses.where((w) => w.isActive).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Destination Warehouse',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<WarehouseModel>(
                value: _destinationWarehouse,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Select destination warehouse',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                items: warehouses
                    .where((w) => w != _sourceWarehouse)
                    .map((warehouse) {
                  return DropdownMenuItem(
                    value: warehouse,
                    child: Text(
                      warehouse.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (warehouse) {
                  setState(() {
                    _destinationWarehouse = warehouse;
                  });
                },
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductList(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductsLoaded) {
          final products = state.products.where((product) {
            final hasStock =
                (product.warehouseStock[_sourceWarehouse!.id] ?? 0) > 0;
            final matchesSearch = _searchController.text.isEmpty ||
                product.name
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase());
            return hasStock && matchesSearch;
          }).toList();

          if (products.isEmpty) {
            return Container(
              height: 100,
              alignment: Alignment.center,
              child: Text(
                _searchController.text.isEmpty
                    ? 'No products in source warehouse'
                    : 'No products found',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return Card(
            elevation: 0,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: products.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final product = products[index];
                  final stockInWarehouse = product.warehouseStock[_sourceWarehouse!.id] ?? 0;
                  final warehouseStockValue = product.price * stockInWarehouse;

                  return Material(
                    color: _selectedProduct?.id == product.id
                        ? Colors.blue.withOpacity(0.1)
                        : null,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedProduct = product;
                          _transferQuantity = 0;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (product.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      product.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Unit Price
                                  Text(
                                    'Unit: ${Formatters.formatCurrency(product.price)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Total Value in this warehouse
                                  Text(
                                    Formatters.formatCurrency(warehouseStockValue),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Stock Count
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.inventory_2_outlined,
                                          size: 14,
                                          color: Colors.blue[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          stockInWarehouse.toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildTransferQuantity(BuildContext context) {
    final currentStock =
        _selectedProduct!.warehouseStock[_sourceWarehouse!.id] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transfer Quantity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _transferQuantity > 0
                  ? () {
                setState(() {
                  _transferQuantity--;
                });
              }
                  : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _transferQuantity.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _transferQuantity < currentStock
                  ? () {
                setState(() {
                  _transferQuantity++;
                });
              }
                  : null,
            ),
            const Spacer(),
            Text(
              'Available: $currentStock',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransferButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
        _transferQuantity > 0 && _destinationWarehouse != null
            ? _handleTransfer
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[900],
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),
        child: const Text('Transfer Stock'),
      ),
    );
  }
}
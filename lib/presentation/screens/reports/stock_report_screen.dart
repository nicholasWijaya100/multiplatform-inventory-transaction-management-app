import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../blocs/warehouse/warehouse_bloc.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/warehouse_model.dart';
import '../../../utils/formatter.dart';

class StockReportScreen extends StatefulWidget {
  const StockReportScreen({Key? key}) : super(key: key);

  @override
  State<StockReportScreen> createState() => _StockReportScreenState();
}

class _StockReportScreenState extends State<StockReportScreen> {
  String? _selectedWarehouse;
  String? _selectedCategory;
  bool _showLowStock = false;
  final TextEditingController _searchController = TextEditingController();
  static const int lowStockThreshold = 10;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<WarehouseBloc>().add(LoadWarehouses());
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }


  // Add helper method to get active warehouses
  List<WarehouseModel> _getActiveWarehouses(WarehousesLoaded state) {
    return state.warehouses.where((w) => w.isActive).toList();
  }

  List<ProductModel> _getFilteredProducts(List<ProductModel> products) {
    return products.where((product) {
      if (!product.isActive) return false;
      if (_showLowStock && !_isLowStock(product)) return false;
      if (_selectedCategory != null && product.category != _selectedCategory) {
        return false;
      }
      if (_searchController.text.isNotEmpty) {
        final search = _searchController.text.toLowerCase();
        return product.name.toLowerCase().contains(search) ||
            product.description?.toLowerCase().contains(search) == true;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Report',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (isSmallScreen)
              _buildMobileView()
            else
              _buildDesktopView(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopView() {
    return Expanded(
      child: Column(
        children: [
          // Stats Cards
          _buildStatsCards(),
          const SizedBox(height: 24),

          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // First row: Search and Category
                  Row(
                    children: [
                      // Search
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Category Filter
                      Expanded(
                        child: _buildCategoryFilter(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Second row: Warehouse filter and chips
                  Row(
                    children: [
                      // Warehouse Filter
                      Expanded(
                        child: _buildWarehouseFilter(),
                      ),
                      const SizedBox(width: 16),
                      // Filter Chips
                      FilterChip(
                        selected: _showLowStock,
                        onSelected: (value) => setState(() => _showLowStock = value),
                        label: const Text('Show Low Stock'),
                        avatar: Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: _showLowStock ? Colors.white : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stock Table
          Expanded(
            child: _buildStockTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileView() {
    return Expanded(
      child: Column(
        children: [
          // Stats Cards in horizontal scroll
          SizedBox(
            height: 120, // Increased height
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _buildMobileStatsCards(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filters in expandable card
          Card(
            child: ExpansionTile(
              title: const Text('Filters'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      _buildCategoryFilter(),
                      const SizedBox(height: 16),
                      _buildWarehouseFilter(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          FilterChip(
                            selected: _showLowStock,
                            onSelected: (value) => setState(() => _showLowStock = value),
                            label: const Text('Show Low Stock'),
                            avatar: Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: _showLowStock ? Colors.white : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Products List
          Expanded(
            child: _buildMobileProductsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStatsCards() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState is! ProductsLoaded) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<WarehouseBloc, WarehouseState>(
          builder: (context, warehouseState) {
            if (warehouseState is! WarehousesLoaded) {
              return const SizedBox.shrink();
            }

            final totalProducts = productState.products.length;
            final lowStockProducts = productState.products
                .where((p) => p.isActive && _isLowStock(p))
                .length;
            final outOfStockProducts = productState.products
                .where((p) => p.isActive && _getTotalStock(p) == 0)
                .length;
            final totalValue = productState.products.fold<double>(
              0,
                  (total, product) => total + (product.price * _getTotalStock(product)),
            );

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Add this
                children: [
                  _MobileStatCard(
                    title: 'Total Products',
                    value: totalProducts.toString(),
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                  ),
                  _MobileStatCard(
                    title: 'Low Stock',
                    value: lowStockProducts.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                  ),
                  _MobileStatCard(
                    title: 'Out of Stock',
                    value: outOfStockProducts.toString(),
                    icon: Icons.remove_shopping_cart,
                    color: Colors.red,
                  ),
                  _MobileStatCard(
                    title: 'Total Value',
                    value: Formatters.formatCurrency(totalValue),
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMobileProductsList() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState is! ProductsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return BlocBuilder<WarehouseBloc, WarehouseState>(
          builder: (context, warehouseState) {
            if (warehouseState is! WarehousesLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final filteredProducts = _getFilteredProducts(productState.products);
            final activeWarehouses = _getActiveWarehouses(warehouseState);

            if (filteredProducts.isEmpty) {
              return const Center(
                child: Text(
                  'No products found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return _buildMobileProductCard(product, activeWarehouses);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMobileProductCard(ProductModel product, List<WarehouseModel> warehouses) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.category),
            const SizedBox(height: 4),
            Text(
              Formatters.formatCurrency(product.price),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: _buildStatusCell(product),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                if (_selectedWarehouse != null)
                  _buildMobileStockRow(
                    'Stock',
                    product.warehouseStock[_selectedWarehouse] ?? 0,
                  )
                else
                  ...warehouses.map(
                        (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildMobileStockRow(
                        w.name,
                        product.warehouseStock[w.id] ?? 0,
                      ),
                    ),
                  ),
                const Divider(),
                const SizedBox(height: 8),
                _buildMobileInfoRow(
                  'Total Stock',
                  _getTotalStock(product).toString(),
                ),
                const SizedBox(height: 8),
                _buildMobileInfoRow(
                  'Total Value',
                  Formatters.formatCurrency(
                    product.price * _getTotalStock(product),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStockRow(String label, int stock) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        _buildStockCell(stock),
      ],
    );
  }

  Widget _buildMobileInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Update the stats cards builder to use both states:
  Widget _buildStatsCards() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState is! ProductsLoaded) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<WarehouseBloc, WarehouseState>(
          builder: (context, warehouseState) {
            if (warehouseState is! WarehousesLoaded) {
              return const SizedBox.shrink();
            }

            final totalProducts = productState.products.length;
            final lowStockProducts = productState.products
                .where((p) => p.isActive && _isLowStock(p))
                .length;
            final outOfStockProducts = productState.products
                .where((p) => p.isActive && _getTotalStock(p) == 0)
                .length;
            final totalValue = productState.products.fold<double>(
              0,
                  (total, product) => total + (product.price * _getTotalStock(product)),
            );

            return Row(
              children: [
                _StatCard(
                  title: 'Total Products',
                  value: totalProducts.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Low Stock Items',
                  value: lowStockProducts.toString(),
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Out of Stock',
                  value: outOfStockProducts.toString(),
                  icon: Icons.remove_shopping_cart,
                  color: Colors.red,
                ),
                _StatCard(
                  title: 'Total Value',
                  value: Formatters.formatCurrency(totalValue),
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWarehouseFilter() {
    return BlocBuilder<WarehouseBloc, WarehouseState>(
      builder: (context, state) {
        if (state is WarehousesLoaded) {
          final warehouses = state.warehouses.where((w) => w.isActive).toList();
          return DropdownButtonFormField<String>(
            value: _selectedWarehouse,
            decoration: InputDecoration(
              labelText: 'Warehouse',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Warehouses'),
              ),
              ...warehouses.map((w) => DropdownMenuItem(
                value: w.id,
                child: Text(
                  w.name,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
            ],
            onChanged: (value) => setState(() => _selectedWarehouse = value),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductsLoaded) {
          return SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...state.categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStockTable() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState is! ProductsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return BlocBuilder<WarehouseBloc, WarehouseState>(
          builder: (context, warehouseState) {
            if (warehouseState is! WarehousesLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final filteredProducts = _getFilteredProducts(productState.products);
            final activeWarehouses = _getActiveWarehouses(warehouseState);

            if (filteredProducts.isEmpty) {
              return const Center(
                child: Text(
                  'No products found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // Calculate minimum table width based on columns
            final double minTableWidth = _selectedWarehouse != null
                ? 1000 // Base width with single warehouse
                : 800 + (activeWarehouses.length * 100); // Base width + width per warehouse

            return Card(
              child: Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: minTableWidth,
                    ),
                    child: Scrollbar(
                      controller: _verticalScrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _verticalScrollController,
                        child: DataTable(
                          columnSpacing: 16,
                          horizontalMargin: 16,
                          headingRowHeight: 48,
                          dataRowHeight: 52,
                          columns: [
                            const DataColumn(
                              label: SizedBox(
                                width: 200,
                                child: Text('Product'),
                              ),
                            ),
                            const DataColumn(
                              label: SizedBox(
                                width: 150,
                                child: Text('Category'),
                              ),
                            ),
                            const DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text('Price'),
                              ),
                              numeric: true,
                            ),
                            if (_selectedWarehouse != null)
                              const DataColumn(
                                label: SizedBox(
                                  width: 100,
                                  child: Text('Stock'),
                                ),
                                numeric: true,
                              )
                            else
                              ...activeWarehouses.map(
                                    (w) => DataColumn(
                                  label: SizedBox(
                                    width: 100,
                                    child: Tooltip(
                                      message: '${w.name}\n${w.city}, ${w.address}',
                                      child: Text(
                                        w.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  numeric: true,
                                ),
                              ),
                            const DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text('Total Stock'),
                              ),
                              numeric: true,
                            ),
                            const DataColumn(
                              label: SizedBox(
                                width: 120,
                                child: Text('Value'),
                              ),
                              numeric: true,
                            ),
                            const DataColumn(
                              label: SizedBox(
                                width: 100,
                                child: Text('Status'),
                              ),
                            ),
                          ],
                          rows: filteredProducts.map((product) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width: 200,
                                    child: _buildProductCell(product),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      product.category,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      Formatters.formatCurrency(product.price),
                                    ),
                                  ),
                                ),
                                if (_selectedWarehouse != null)
                                  DataCell(
                                    SizedBox(
                                      width: 100,
                                      child: _buildStockCell(
                                        product.warehouseStock[_selectedWarehouse] ?? 0,
                                      ),
                                    ),
                                  )
                                else
                                  ...activeWarehouses.map(
                                        (w) => DataCell(
                                      SizedBox(
                                        width: 100,
                                        child: _buildStockCell(
                                          product.warehouseStock[w.id] ?? 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: Text(_getTotalStock(product).toString()),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      Formatters.formatCurrency(
                                        product.price * _getTotalStock(product),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: _buildStatusCell(product),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderCell(String text, {
    int flex = 1,
    String? tooltip,
  }) {
    Widget content = Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (tooltip != null) {
      content = Tooltip(
        message: tooltip,
        child: content,
      );
    }

    return content;
  }

  Widget _buildTableRow(
      ProductModel product,
      List<WarehouseModel> warehouses,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildProductCell(product)),
          Expanded(flex: 2, child: Text(product.category)),
          Expanded(
            flex: 1,
            child: Text(
              Formatters.formatCurrency(product.price),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (_selectedWarehouse != null)
            Expanded(
              flex: 1,
              child: _buildStockCell(
                product.warehouseStock[_selectedWarehouse] ?? 0,
              ),
            )
          else
            ...warehouses.map(
                  (w) => Expanded(
                flex: 1,
                child: _buildStockCell(
                  product.warehouseStock[w.id] ?? 0,
                ),
              ),
            ),
          Expanded(
            flex: 1,
            child: Text(
              _getTotalStock(product).toString(),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              Formatters.formatCurrency(
                product.price * _getTotalStock(product),
              ),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(flex: 1, child: _buildStatusCell(product)),
        ],
      ),
    );
  }

  Widget _buildProductCell(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (product.description != null)
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
    );
  }

  Widget _buildStockCell(int stock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStockColor(stock).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        stock.toString(),
        style: TextStyle(
          color: _getStockColor(stock),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusCell(ProductModel product) {
    final stock = _getTotalStock(product);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStockColor(stock).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStockStatus(stock),
        style: TextStyle(
          color: _getStockColor(stock),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helper methods remain the same
  bool _isLowStock(ProductModel product) {
    return _getTotalStock(product) < lowStockThreshold;
  }

  int _getTotalStock(ProductModel product) {
    if (_selectedWarehouse != null) {
      return product.warehouseStock[_selectedWarehouse] ?? 0;
    }
    return product.warehouseStock.values.fold(0, (sum, stock) => sum + stock);
  }

  Color _getStockColor(int stock) {
    if (stock <= 0) return Colors.red;
    if (stock < lowStockThreshold) return Colors.orange;
    return Colors.green;
  }

  String _getStockStatus(int stock) {
    if (stock <= 0) return 'Out of Stock';
    if (stock < lowStockThreshold) return 'Low Stock';
    return 'In Stock';
  }


}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
  }
}

class _MobileStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MobileStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160, // Fixed width
      child: Card(
        margin: const EdgeInsets.only(right: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Add this
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockDataSource extends DataTableSource {
  final BuildContext context;
  final List<ProductModel> products;
  final List<WarehouseModel> warehouses;
  final String? selectedWarehouse;
  final int Function(ProductModel) getTotalStock;
  final Color Function(int) getStockColor;
  final String Function(int) getStockStatus;

  _StockDataSource({
    required this.context,
    required this.products,
    required this.warehouses,
    required this.selectedWarehouse,
    required this.getTotalStock,
    required this.getStockColor,
    required this.getStockStatus,
  });

  @override
  DataRow getRow(int index) {
    final product = products[index];
    final cells = <DataCell>[
      DataCell(
        SizedBox(
          width: 200, // Match the column width
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              if (product.description != null)
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
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 120,
          child: Text(
            product.category,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      DataCell(
        SizedBox(
          width: 100,
          child: Text(Formatters.formatCurrency(product.price)),
        ),
      ),
    ];

    // Add warehouse stock cells
    if (selectedWarehouse != null) {
      cells.add(
        DataCell(
          SizedBox(
            width: 100,
            child: _buildStockBadge(
              product.warehouseStock[selectedWarehouse] ?? 0,
            ),
          ),
        ),
      );
    } else {
      cells.addAll(
        warehouses.map(
              (w) => DataCell(
            SizedBox(
              width: 100,
              child: _buildStockBadge(
                product.warehouseStock[w.id] ?? 0,
              ),
            ),
          ),
        ),
      );
    }

    // Add total stock, value and status
    final totalStock = getTotalStock(product);
    cells.addAll([
      DataCell(
        SizedBox(
          width: 100,
          child: Text(totalStock.toString()),
        ),
      ),
      DataCell(
        SizedBox(
          width: 120,
          child: Text(Formatters.formatCurrency(product.price * totalStock)),
        ),
      ),
      DataCell(
        SizedBox(
          width: 100,
          child: _buildStatusBadge(totalStock),
        ),
      ),
    ]);

    return DataRow(cells: cells);
  }

  Widget _buildStockBadge(int stock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getStockColor(stock).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        stock.toString(),
        style: TextStyle(
          color: getStockColor(stock),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(int stock) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getStockColor(stock).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        getStockStatus(stock),
        style: TextStyle(
          color: getStockColor(stock),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => products.length;

  @override
  int get selectedRowCount => 0;
}
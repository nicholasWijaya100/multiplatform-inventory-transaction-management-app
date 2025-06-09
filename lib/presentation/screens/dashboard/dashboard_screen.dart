import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/customer/customer_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../blocs/purchase/purchase_bloc.dart';
import '../../../blocs/sales/sales_order_bloc.dart';
import '../../../blocs/supplier/supplier_bloc.dart';
import '../../../blocs/warehouse/warehouse_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../utils/formatter.dart';
import '../../../utils/navigation_controller.dart';
import '../../widgets/recent_activities.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  DateTimeRange _chartDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)), // Last 30 days by default
    end: DateTime.now(),
  );

  String _selectedPeriod = 'month';

  void _loadDashboardData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    // Load data based on user role
    final user = authState.user;

    // Always load products for all roles
    context.read<ProductBloc>().add(LoadProducts());

    // Load role-specific data
    switch(user.role) {
      case 'Administrator':
        context.read<CustomerBloc>().add(LoadCustomers());
        context.read<SupplierBloc>().add(LoadSuppliers());
        context.read<SalesOrderBloc>().add(LoadSalesOrders());
        context.read<PurchaseBloc>().add(LoadPurchaseOrders());
        context.read<WarehouseBloc>().add(LoadWarehouses());
        break;
      case 'Sales':
        context.read<CustomerBloc>().add(LoadCustomers());
        context.read<SalesOrderBloc>().add(LoadSalesOrders());
        break;
      case 'Purchasing':
        context.read<SupplierBloc>().add(LoadSuppliers());
        context.read<PurchaseBloc>().add(LoadPurchaseOrders());
        break;
      case 'Warehouse':
        context.read<WarehouseBloc>().add(LoadWarehouses());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = state.user;
        final size = MediaQuery.of(context).size;
        final padding = size.width < 600 ? 16.0 : 24.0;
        final isSmallScreen = size.width < 600;

        return Container(
          color: Colors.grey[100],
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                _buildWelcomeSection(user, isSmallScreen),

                const SizedBox(height: 24),

                // Quick Stats Cards
                _buildStatCards(user, isSmallScreen),

                const SizedBox(height: 32),

                // Role-specific content sections
                _buildRoleContent(user, isSmallScreen),

                const SizedBox(height: 32),

                // Recent Activities
                //const RecentActivities(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(UserModel user, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[100],
                radius: isSmallScreen ? 24 : 32,
                child: Text(
                  user.name?[0].toUpperCase() ?? 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 20 : 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user.name ?? 'User'}!',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getWelcomeSubtitle(user),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Current date
          Text(
            'Today is ${_getCurrentDateString()}',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(UserModel user, bool isSmallScreen) {
    // Different layout based on screen size
    if (isSmallScreen) {
      return SizedBox(
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _getDashboardCards(user, isSmallScreen),
        ),
      );
    } else {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: _getDashboardCards(user, isSmallScreen),
      );
    }
  }

  Widget _buildRoleContent(UserModel user, bool isSmallScreen) {
    switch (user.role) {
      case 'Administrator':
        return _buildAdminSection(isSmallScreen);
      case 'Sales':
        return _buildSalesSection(isSmallScreen);
      case 'Warehouse':
        return _buildWarehouseSection(isSmallScreen);
      case 'Purchasing':
        return _buildPurchasingSection(isSmallScreen);
      default:
        return const SizedBox();
    }
  }

  List<Widget> _getDashboardCards(UserModel user, bool isSmallScreen) {
    final List<Widget> cards = [];
    final containerWidth = isSmallScreen ? 200.0 : 280.0;

    // Common cards for all roles - Product Stats
    cards.add(
      BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            int totalProducts = 0;
            int lowStockItems = 0;

            if (state is ProductsLoaded) {
              totalProducts = state.totalProducts;
              lowStockItems = state.lowStockProducts;
            }

            return _DashboardCard(
              title: 'Total Products',
              value: totalProducts.toString(),
              icon: Icons.inventory_2_outlined,
              color: Colors.blue,
              width: containerWidth,
              onTap: () => _navigateTo(context, '/products'),
            );
          }
      ),
    );

    print(user.role);

    // Low stock items for admin and warehouse
    if (user.role == 'Administrator' || user.role == 'Warehouse') {
      cards.add(
        BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              int lowStockItems = 0;

              if (state is ProductsLoaded) {
                lowStockItems = state.lowStockProducts;
              }

              return _DashboardCard(
                title: 'Low Stock Items',
                value: lowStockItems.toString(),
                icon: Icons.warning_amber_rounded,
                color: Colors.orange,
                width: containerWidth,
                onTap: () => _navigateTo(context, '/products'),
              );
            }
        ),
      );
    }

    // Role-specific cards
    switch (user.role) {
      case 'Administrator':
        cards.addAll([
          BlocBuilder<SalesOrderBloc, SalesOrderState>(
              builder: (context, state) {
                double totalSales = 0;

                if (state is SalesOrdersLoaded) {
                  totalSales = state.totalValue;
                }

                return _DashboardCard(
                  title: 'Total Sales',
                  value: Formatters.formatCurrency(totalSales),
                  icon: Icons.attach_money_outlined,
                  color: Colors.green,
                  width: containerWidth,
                  onTap: () => _navigateTo(context, '/sales'),
                );
              }
          ),
          BlocBuilder<PurchaseBloc, PurchaseState>(
              builder: (context, state) {
                double totalPurchases = 0;

                if (state is PurchaseOrdersLoaded) {
                  totalPurchases = state.totalValue;
                }

                return _DashboardCard(
                  title: 'Total Purchases',
                  value: Formatters.formatCurrency(totalPurchases),
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.purple,
                  width: containerWidth,
                  onTap: () => _navigateTo(context, '/purchases'),
                );
              }
          ),
        ]);
        break;

      case 'Sales':
        cards.addAll([
          BlocBuilder<SalesOrderBloc, SalesOrderState>(
              builder: (context, state) {
                double totalSales = 0;
                double pendingOrders = 0;

                if (state is SalesOrdersLoaded) {
                  totalSales = state.totalValue;
                  pendingOrders = state.pendingOrders;
                }

                return _DashboardCard(
                  title: 'Total Sales',
                  value: Formatters.formatCurrency(totalSales),
                  icon: Icons.attach_money_outlined,
                  color: Colors.green,
                  width: containerWidth,
                  onTap: () => _navigateTo(context, '/sales'),
                );
              }
          ),
          BlocBuilder<SalesOrderBloc, SalesOrderState>(
              builder: (context, state) {
                double pendingOrders = 0;

                if (state is SalesOrdersLoaded) {
                  pendingOrders = state.pendingOrders;
                }

                return _DashboardCard(
                  title: 'Pending Orders',
                  value: pendingOrders.toInt().toString(),
                  icon: Icons.shopping_cart_outlined,
                  color: Colors.orange,
                  width: containerWidth,
                  onTap: () => _navigateTo(context, '/sales'),
                );
              }
          ),
          BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                int totalCustomers = 0;

                if (state is CustomersLoaded) {
                  totalCustomers = state.totalCustomers;
                }

                return _DashboardCard(
                  title: 'Customers',
                  value: totalCustomers.toString(),
                  icon: Icons.people_outline,
                  color: Colors.blue,
                  width: containerWidth,
                  onTap: () => _navigateTo(context, '/customers'),
                );
              }
          ),
        ]);
        break;

      case 'Purchasing':
        cards.addAll([
          BlocBuilder<PurchaseBloc, PurchaseState>(
              builder: (context, state) {
                double totalPurchases = 0;

                if (state is PurchaseOrdersLoaded) {
                  totalPurchases = state.totalValue;
                }

                return _DashboardCard(
                  title: 'Total Purchases',
                  value: Formatters.formatCurrency(totalPurchases),
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.purple,
                  width: containerWidth,
                  onTap: () => _navigateTo(context, '/purchases'),
                );
              }
          ),
          BlocBuilder<PurchaseBloc, PurchaseState>(
              builder: (context, state) {
                double pendingOrders = 0;

                if (state is PurchaseOrdersLoaded) {
                  pendingOrders = state.pendingOrders;
                }

                return _DashboardCard(
                  title: 'Pending Orders',
                  value: pendingOrders.toInt().toString(),
                  icon: Icons.assignment_outlined,
                  color: Colors.orange,
                  width: containerWidth,
                  onTap: () => _navigateTo(context, '/purchases'),
                );
              }
          ),
          BlocBuilder<SupplierBloc, SupplierState>(
              builder: (context, state) {
                int totalSuppliers = 0;

                if (state is SuppliersLoaded) {
                  totalSuppliers = state.totalSuppliers;
                }

                return _DashboardCard(
                  title: 'Suppliers',
                  value: totalSuppliers.toString(),
                  icon: Icons.business_outlined,
                  color: Colors.blue,
                  width: containerWidth,
                  onTap: () => _navigateTo(context, '/suppliers'),
                );
              }
          ),
        ]);
        break;
    }

    return cards;
  }

  Widget _buildAdminSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Business Overview Section
        _buildSectionHeader('Business Overview', Icons.analytics_outlined),
        const SizedBox(height: 16),

        // Sales vs Purchases Chart
        _buildChartCard(
          title: 'Business Performance',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: _buildSalesVsPurchasesChart(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Quick Access Section
        _buildSectionHeader('Quick Access', Icons.speed_outlined),
        const SizedBox(height: 16),

        // Quick access buttons
        _buildQuickAccessGrid(isSmallScreen),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Wrap(
      spacing: 8,
      children: [
        _buildPeriodChip('Week', 'week'),
        _buildPeriodChip('Month', 'month'),
        _buildPeriodChip('Quarter', 'quarter'),
        _buildPeriodChip('Year', 'year'),
        _buildPeriodChip('Custom', 'custom'),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          // Add debug print to verify callback is triggered
          print('Selected period: $period');

          setState(() {
            _selectedPeriod = period;

            // Update the date range based on selection
            final now = DateTime.now();
            switch (period) {
              case 'week':
                _chartDateRange = DateTimeRange(
                  start: now.subtract(const Duration(days: 7)),
                  end: now,
                );
                break;
              case 'month':
                _chartDateRange = DateTimeRange(
                  start: DateTime(now.year, now.month - 1, now.day),
                  end: now,
                );
                break;
              case 'quarter':
                _chartDateRange = DateTimeRange(
                  start: DateTime(now.year, now.month - 3, now.day),
                  end: now,
                );
                break;
              case 'year':
                _chartDateRange = DateTimeRange(
                  start: DateTime(now.year - 1, now.month, now.day),
                  end: now,
                );
                break;
              case 'custom':
              // For custom, we'll show the date picker
              // But first update the state to show it's selected
                Future.delayed(Duration.zero, () => _showDateRangePicker(context));
                break;
            }

            // Print the new date range to verify it's updated
            print('New date range: ${_chartDateRange.start} to ${_chartDateRange.end}');

            // Trigger data reload
            _loadChartData();
          });
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _chartDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[800]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange != null) {
      setState(() {
        _chartDateRange = pickedRange;
        // Keep 'custom' selected
        _selectedPeriod = 'custom';
        _loadChartData();
      });
    }
  }

  void _loadChartData() {
    print('Loading data for range: ${_chartDateRange.start} to ${_chartDateRange.end}');

    // Check if your BLoCs have these events implemented
    try {
      // If you haven't implemented the period-specific events yet,
      // you can use your existing events with state variables:
      context.read<SalesOrderBloc>().add(LoadSalesOrders());
      context.read<PurchaseBloc>().add(LoadPurchaseOrders(showCompleted: true));

      // Make the date range visible on UI to confirm it's changing
      setState(() {
        // This forces a rebuild to show the updated date range
      });
    } catch (e) {
      print('Error loading chart data: $e');
    }
  }

  Widget _buildSalesVsPurchasesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date range display
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Period: ${Formatters.formatDate(_chartDateRange.start)} - ${Formatters.formatDate(_chartDateRange.end)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),

        // The chart (existing implementation)
        Expanded(
          child: BlocBuilder<SalesOrderBloc, SalesOrderState>(
            builder: (context, salesState) {
              return BlocBuilder<PurchaseBloc, PurchaseState>(
                builder: (context, purchaseState) {
                  if (salesState is SalesOrdersLoaded && purchaseState is PurchaseOrdersLoaded) {
                    // Get the data
                    final filteredSalesOrders = salesState.orders.where((order) {
                      return order.createdAt.isAfter(_chartDateRange.start) &&
                          order.createdAt.isBefore(_chartDateRange.end.add(const Duration(days: 1)));
                    }).toList();

                    final filteredPurchaseOrders = purchaseState.orders.where((order) {
                      return order.createdAt.isAfter(_chartDateRange.start) &&
                          order.createdAt.isBefore(_chartDateRange.end.add(const Duration(days: 1)));
                    }).toList();

                    // Calculate totals from filtered data
                    final salesValue = filteredSalesOrders.fold<double>(
                        0.0, (sum, order) => sum + order.totalAmount);

                    final purchaseValue = filteredPurchaseOrders.fold<double>(
                        0.0, (sum, order) => sum + order.totalAmount);

                    final profit = salesValue - purchaseValue;

                    return Padding(
                      padding: const EdgeInsets.only(top: 16, right: 16),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _getMaxValue([salesValue, purchaseValue, profit.abs()]) * 1.2,
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    // tooltipBgColor: Colors.blueGrey.shade800,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      String value = '';
                                      switch(groupIndex) {
                                        case 0:
                                          value = 'Sales: ${Formatters.formatCurrency(salesValue)}';
                                          break;
                                        case 1:
                                          value = 'Purchases: ${Formatters.formatCurrency(purchaseValue)}';
                                          break;
                                        case 2:
                                          value = 'Profit: ${Formatters.formatCurrency(profit)}';
                                          break;
                                      }
                                      return BarTooltipItem(
                                        value,
                                        const TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        String text = '';
                                        switch(value.toInt()) {
                                          case 0:
                                            text = 'Sales';
                                            break;
                                          case 1:
                                            text = 'Purchases';
                                            break;
                                          case 2:
                                            text = 'Profit';
                                            break;
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            text,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 80, // Increase the reserved size
                                      interval: _calculateInterval([salesValue, purchaseValue, profit.abs()]), // Add dynamic interval
                                      getTitlesWidget: (value, meta) {
                                        // Only show a few values to avoid crowding
                                        if (value == 0 || value % _calculateInterval([salesValue, purchaseValue, profit.abs()]) == 0) {
                                          // Shortened currency format for y-axis
                                          final formatter = NumberFormat.compact(locale: 'id_ID');
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Text(
                                              'Rp ${formatter.format(value)}',
                                              style: const TextStyle(fontSize: 10),
                                              textAlign: TextAlign.right,
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(
                                  show: true,
                                  drawHorizontalLine: true,
                                  drawVerticalLine: false,
                                ),
                                barGroups: [
                                  // Sales bar
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: salesValue,
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                        width: 40,
                                      ),
                                    ],
                                  ),
                                  // Purchases bar
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: purchaseValue,
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                        width: 40,
                                      ),
                                    ],
                                  ),
                                  // Profit bar
                                  BarChartGroupData(
                                    x: 2,
                                    barRods: [
                                      BarChartRodData(
                                        toY: profit,
                                        color: profit >= 0 ? Colors.blue : Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                        width: 40,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Legend
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem('Sales', Colors.green),
                                const SizedBox(width: 24),
                                _buildLegendItem('Purchases', Colors.red),
                                const SizedBox(width: 24),
                                _buildLegendItem('Profit', Colors.blue),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            },
          ),
        ),
      ],
    );
  }

  double _calculateInterval(List<double> values) {
    final maxValue = _getMaxValue(values);
    // Create 4-5 divisions on the y-axis
    if (maxValue <= 1000) return 200;
    if (maxValue <= 10000) return 2000;
    if (maxValue <= 100000) return 20000;
    if (maxValue <= 1000000) return 200000;
    if (maxValue <= 10000000) return 2000000;
    return maxValue / 5; // Default to 5 divisions
  }

  // Helper methods for the chart
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _getMaxValue(List<double> values) {
    return values.reduce((curr, next) => curr > next ? curr : next);
  }

  Widget _buildSalesSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sales Overview
        _buildSectionHeader('Sales Overview', Icons.point_of_sale_outlined),
        const SizedBox(height: 16),

        // Outstanding orders
        BlocBuilder<SalesOrderBloc, SalesOrderState>(
            builder: (context, state) {
              if (state is SalesOrdersLoaded) {
                final pendingOrdersCount = state.pendingOrders.toInt();
                final totalValue = state.totalValue;

                return _buildInfoCard(
                  title: 'Outstanding Orders',
                  contents: [
                    _InfoItem(
                      label: 'Pending Orders',
                      value: pendingOrdersCount.toString(),
                      icon: Icons.hourglass_empty_outlined,
                    ),
                    _InfoItem(
                      label: 'Total Order Value',
                      value: Formatters.formatCurrency(totalValue),
                      icon: Icons.attach_money_outlined,
                    ),
                  ],
                  actionText: 'View Sales Orders',
                  onAction: () => _navigateTo(context, '/sales'),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
        ),

        const SizedBox(height: 24),

        // Customer Overview
        _buildSectionHeader('Customer Overview', Icons.people_outline),
        const SizedBox(height: 16),

        // Top customers
        BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomersLoaded) {
                final activeCustomers = state.activeCustomers;
                final totalCustomers = state.totalCustomers;
                final totalSales = state.totalSales;

                return _buildInfoCard(
                  title: 'Customer Stats',
                  contents: [
                    _InfoItem(
                      label: 'Active Customers',
                      value: activeCustomers.toString(),
                      icon: Icons.people_alt_outlined,
                    ),
                    _InfoItem(
                      label: 'Total Customers',
                      value: totalCustomers.toString(),
                      icon: Icons.group_add_outlined,
                    ),
                    _InfoItem(
                      label: 'Total Sales',
                      value: Formatters.formatCurrency(totalSales),
                      icon: Icons.monetization_on_outlined,
                    ),
                  ],
                  actionText: 'Manage Customers',
                  onAction: () => _navigateTo(context, '/customers'),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
        ),
      ],
    );
  }

  Widget _buildWarehouseSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Inventory Overview
        _buildSectionHeader('Inventory Overview', Icons.inventory_2_outlined),
        const SizedBox(height: 16),

        // Stock Status
        BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductsLoaded) {
                final totalProducts = state.totalProducts;
                final lowStockProducts = state.lowStockProducts;
                final totalValue = state.totalValue;

                return _buildInfoCard(
                  title: 'Stock Status',
                  contents: [
                    _InfoItem(
                      label: 'Total Products',
                      value: totalProducts.toString(),
                      icon: Icons.category_outlined,
                    ),
                    _InfoItem(
                      label: 'Low Stock Items',
                      value: lowStockProducts.toString(),
                      icon: Icons.warning_amber_outlined,
                      valueColor: Colors.orange,
                    ),
                    // _InfoItem(
                    //   label: 'Total Stock Value',
                    //   value: Formatters.formatCurrency(totalValue),
                    //   icon: Icons.monetization_on_outlined,
                    // ),
                  ],
                  actionText: 'View Products',
                  onAction: () => _navigateTo(context, '/products'),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
        ),

        const SizedBox(height: 24),

        // Warehouse Overview
        _buildSectionHeader('Warehouse Overview', Icons.warehouse_outlined),
        const SizedBox(height: 16),

        // Warehouse stats
        BlocBuilder<WarehouseBloc, WarehouseState>(
            builder: (context, state) {
              if (state is WarehousesLoaded) {
                final activeWarehouses = state.activeWarehouses;
                final totalProducts = state.totalProducts;
                final totalValue = state.totalValue;

                return _buildInfoCard(
                  title: 'Warehouse Stats',
                  contents: [
                    _InfoItem(
                      label: 'Active Warehouses',
                      value: activeWarehouses.toString(),
                      icon: Icons.warehouse_outlined,
                    ),
                    _InfoItem(
                      label: 'Total Products',
                      value: totalProducts.toString(),
                      icon: Icons.inventory_outlined,
                    ),
                    // _InfoItem(
                    //   label: 'Total Value',
                    //   value: Formatters.formatCurrency(totalValue),
                    //   icon: Icons.monetization_on_outlined,
                    // ),
                  ],
                  actionText: 'Stock Transfer',
                  onAction: () => _navigateTo(context, '/stock-transfer'),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
        ),
      ],
    );
  }

  Widget _buildPurchasingSection(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Purchasing Overview
        _buildSectionHeader('Purchasing Overview', Icons.shopping_cart_outlined),
        const SizedBox(height: 16),

        // Purchase Orders
        BlocBuilder<PurchaseBloc, PurchaseState>(
            builder: (context, state) {
              if (state is PurchaseOrdersLoaded) {
                final totalOrders = state.totalOrders.toInt();
                final pendingOrders = state.pendingOrders.toInt();
                final totalValue = state.totalValue;

                return _buildInfoCard(
                  title: 'Purchase Orders',
                  contents: [
                    _InfoItem(
                      label: 'Total Orders',
                      value: totalOrders.toString(),
                      icon: Icons.receipt_long_outlined,
                    ),
                    _InfoItem(
                      label: 'Pending Orders',
                      value: pendingOrders.toString(),
                      icon: Icons.pending_actions_outlined,
                      valueColor: pendingOrders > 0 ? Colors.orange : null,
                    ),
                    _InfoItem(
                      label: 'Total Value',
                      value: Formatters.formatCurrency(totalValue),
                      icon: Icons.attach_money_outlined,
                    ),
                  ],
                  actionText: 'Manage Purchase Orders',
                  onAction: () => _navigateTo(context, '/purchases'),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
        ),

        const SizedBox(height: 24),

        // Supplier Overview
        _buildSectionHeader('Supplier Overview', Icons.local_shipping_outlined),
        const SizedBox(height: 16),

        // Supplier stats
        BlocBuilder<SupplierBloc, SupplierState>(
            builder: (context, state) {
              if (state is SuppliersLoaded) {
                final activeSuppliers = state.activeSuppliers;
                final totalSuppliers = state.totalSuppliers;
                final totalPurchases = state.totalPurchases;

                return _buildInfoCard(
                  title: 'Supplier Stats',
                  contents: [
                    _InfoItem(
                      label: 'Active Suppliers',
                      value: activeSuppliers.toString(),
                      icon: Icons.business_outlined,
                    ),
                    _InfoItem(
                      label: 'Total Suppliers',
                      value: totalSuppliers.toString(),
                      icon: Icons.group_outlined,
                    ),
                    _InfoItem(
                      label: 'Total Purchases',
                      value: Formatters.formatCurrency(totalPurchases),
                      icon: Icons.monetization_on_outlined,
                    ),
                  ],
                  actionText: 'Manage Suppliers',
                  onAction: () => _navigateTo(context, '/suppliers'),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue[800],
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<_InfoItem> contents,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...contents.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item.valueColor,
                    ),
                  ),
                ],
              ),
            )).toList(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onAction,
                child: Text(actionText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(bool isSmallScreen) {
    final buttonWidth = isSmallScreen ? double.infinity : 200.0;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _QuickAccessButton(
          icon: Icons.people_outline,
          label: 'Users',
          width: buttonWidth,
          onTap: () => _navigateTo(context, '/users'),
        ),
        _QuickAccessButton(
          icon: Icons.inventory_2_outlined,
          label: 'Products',
          width: buttonWidth,
          onTap: () => _navigateTo(context, '/products'),
        ),
        _QuickAccessButton(
          icon: Icons.shopping_cart_outlined,
          label: 'Sales',
          width: buttonWidth,
          onTap: () => _navigateTo(context, '/sales'),
        ),
        _QuickAccessButton(
          icon: Icons.shopping_bag_outlined,
          label: 'Purchases',
          width: buttonWidth,
          onTap: () => _navigateTo(context, '/purchases'),
        ),
        _QuickAccessButton(
          icon: Icons.bar_chart_outlined,
          label: 'Reports',
          width: buttonWidth,
          onTap: () => _navigateTo(context, '/reports/income-statement'),
        ),
      ],
    );
  }

  String _getWelcomeSubtitle(UserModel user) {
    final now = DateTime.now();
    String timeBasedGreeting;

    if (now.hour < 12) {
      timeBasedGreeting = "Good morning";
    } else if (now.hour < 17) {
      timeBasedGreeting = "Good afternoon";
    } else {
      timeBasedGreeting = "Good evening";
    }

    switch (user.role) {
      case 'Administrator':
        return '$timeBasedGreeting! Here\'s your system overview.';
      case 'Sales':
        return '$timeBasedGreeting! Check out your sales dashboard.';
      case 'Warehouse':
        return '$timeBasedGreeting! Monitor your inventory status.';
      case 'Purchasing':
        return '$timeBasedGreeting! View your purchasing dashboard.';
      default:
        return timeBasedGreeting;
    }
  }

  String _getCurrentDateString() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];

    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];

    final day = now.day;
    final month = months[now.month - 1];
    final year = now.year;
    final weekday = weekdays[now.weekday - 1];

    return '$weekday, $month $day, $year';
  }

  void _navigateTo(BuildContext context, String route) {
    Provider.of<NavigationController>(context, listen: false).navigateTo(route);
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12, bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double width;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.icon,
    required this.label,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue[800],
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });
}
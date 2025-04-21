import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/sales/sales_order_bloc.dart';
import '../../../blocs/customer/customer_bloc.dart';
import '../../../data/models/sales_order_model.dart';
import '../../../utils/formatter.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({Key? key}) : super(key: key);

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTimeRange? _dateRange;
  String? _selectedCustomer;
  String? _selectedStatus;
  bool _showPaidOnly = false;
  bool _showUnpaidOnly = false;

  @override
  void initState() {
    super.initState();
    // Set default date range to current month
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
    // Load customers and sales orders
    context.read<CustomerBloc>().add(LoadCustomers());
    _loadReport();
  }

  void _loadReport() {
    context.read<SalesOrderBloc>().add(LoadSalesOrders());
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
            Text(
              'Sales Report',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Filters Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (isSmallScreen) ...[
                      // Mobile Layout
                      _buildDateRangePicker(context),
                      const SizedBox(height: 16),
                      _buildCustomerFilter(),
                      const SizedBox(height: 16),
                      _buildStatusFilter(),
                      const SizedBox(height: 16),
                      _buildPaymentFilter(),
                    ] else ...[
                      // Desktop Layout
                      Row(
                        children: [
                          Expanded(child: _buildDateRangePicker(context)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildCustomerFilter()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatusFilter()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPaymentFilter(),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadReport,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            BlocBuilder<SalesOrderBloc, SalesOrderState>(
              builder: (context, state) {
                if (state is SalesOrdersLoaded) {
                  final filteredOrders = _getFilteredOrders(state.orders);
                  return _buildStatsCards(filteredOrders, isSmallScreen);
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 24),

            // Orders Table
            Expanded(
              child: BlocBuilder<SalesOrderBloc, SalesOrderState>(
                builder: (context, state) {
                  if (state is SalesOrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is SalesOrdersLoaded) {
                    final filteredOrders = _getFilteredOrders(state.orders);

                    if (filteredOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.assignment_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No sales orders found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return isSmallScreen
                        ? _buildMobileOrdersList(filteredOrders)
                        : _buildOrdersTable(filteredOrders);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final newRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: _dateRange,
        );
        if (newRange != null) {
          setState(() => _dateRange = newRange);
          _loadReport();
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date Range',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateRange != null
                  ? '${Formatters.formatDate(_dateRange!.start)} - '
                  '${Formatters.formatDate(_dateRange!.end)}'
                  : 'Select date range',
            ),
            const Icon(Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerFilter() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomersLoaded) {
          final activeCustomers = state.customers
              .where((c) => c.isActive)
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically

          return DropdownButtonFormField<String>(
            value: _selectedCustomer,
            decoration: InputDecoration(
              labelText: 'Customer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Customers'),
              ),
              ...activeCustomers.map((customer) => DropdownMenuItem(
                value: customer.id,
                child: Text(customer.name),
              )),
            ],
            onChanged: (value) {
              setState(() => _selectedCustomer = value);
              _loadReport();
            },
          );
        }
        return const LinearProgressIndicator();
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('All Statuses'),
        ),
        ...SalesOrderStatus.values.map((status) {
          return DropdownMenuItem(
            value: status.name,
            child: Text(status.name),
          );
        }),
      ],
      onChanged: (value) {
        setState(() => _selectedStatus = value);
        _loadReport();
      },
    );
  }

  Widget _buildPaymentFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FilterChip(
          label: const Text('Paid Orders'),
          selected: _showPaidOnly,
          onSelected: (selected) {
            setState(() {
              _showPaidOnly = selected;
              if (selected) {
                _showUnpaidOnly = false;
              }
              _loadReport();
            });
          },
          avatar: Icon(
            Icons.check_circle_outline,
            color: _showPaidOnly ? Colors.white : Colors.green,
            size: 18,
          ),
          selectedColor: Colors.green,
        ),
        const SizedBox(width: 12),
        FilterChip(
          label: const Text('Unpaid Orders'),
          selected: _showUnpaidOnly,
          onSelected: (selected) {
            setState(() {
              _showUnpaidOnly = selected;
              if (selected) {
                _showPaidOnly = false;
              }
              _loadReport();
            });
          },
          avatar: Icon(
            Icons.money_off_outlined,
            color: _showUnpaidOnly ? Colors.white : Colors.red,
            size: 18,
          ),
          selectedColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatsCards(List<SalesOrderModel> orders, bool isSmallScreen) {
    final totalOrders = orders.length;
    final totalAmount = orders.fold<double>(
      0,
          (sum, order) => sum + order.totalAmount,
    );

    // Calculate paid vs unpaid stats
    final paidOrders = orders.where((order) => order.isPaid).length;
    final paidAmount = orders
        .where((order) => order.isPaid)
        .fold<double>(0, (sum, order) => sum + order.totalAmount);
    final unpaidAmount = totalAmount - paidAmount;

    // Calculate average order value
    final avgOrderValue = orders.isNotEmpty ? totalAmount / totalOrders : 0.0;

    final cards = [
      _StatCard(
        title: 'Total Orders',
        value: totalOrders.toString(),
        icon: Icons.receipt_long_outlined,
        color: Colors.blue[700]!,
      ),
      _StatCard(
        title: 'Total Revenue',
        value: Formatters.formatCurrency(totalAmount),
        icon: Icons.attach_money,
        color: Colors.green[600]!,
      ),
      _StatCard(
        title: 'Paid Amount',
        value: Formatters.formatCurrency(paidAmount),
        icon: Icons.check_circle_outline,
        color: Colors.teal[600]!,
      ),
      _StatCard(
        title: 'Outstanding Amount',
        value: Formatters.formatCurrency(unpaidAmount),
        icon: Icons.money_off_outlined,
        color: Colors.red[600]!,
      ),
    ];

    if (isSmallScreen) {
      return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: cards.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: cards[index],
            );
          },
        ),
      );
    }

    return Row(
      children: cards.map((card) => Expanded(child: card)).toList(),
    );
  }

  Widget _buildMobileOrdersList(List<SalesOrderModel> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'SO #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildPaymentBadge(order.isPaid),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(order.customerName),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatDateTime(order.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.formatCurrency(order.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTable(List<SalesOrderModel> orders) {
    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Payment')),
            DataColumn(
              label: Text('Amount'),
              numeric: true,
            ),
          ],
          rows: orders.map((order) {
            return DataRow(
              cells: [
                DataCell(Text('#${order.id}')),
                DataCell(Text(order.customerName)),
                DataCell(Text(Formatters.formatDateTime(order.createdAt))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(_buildPaymentBadge(order.isPaid)),
                DataCell(
                  Text(
                    Formatters.formatCurrency(order.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(bool isPaid) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.check_circle_outline : Icons.money_off_outlined,
            size: 14,
            color: isPaid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            isPaid ? 'Paid' : 'Unpaid',
            style: TextStyle(
              color: isPaid ? Colors.green : Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<SalesOrderModel> _getFilteredOrders(List<SalesOrderModel> orders) {
    return orders.where((order) {
      // Date range filter
      if (_dateRange != null) {
        final orderDate = DateTime(
          order.createdAt.year,
          order.createdAt.month,
          order.createdAt.day,
        );
        if (orderDate.isBefore(_dateRange!.start) ||
            orderDate.isAfter(_dateRange!.end)) {
          return false;
        }
      }

      // Customer filter
      if (_selectedCustomer != null && order.customerId != _selectedCustomer) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && order.status != _selectedStatus) {
        return false;
      }

      // Payment filter
      if (_showPaidOnly && !order.isPaid) {
        return false;
      }

      if (_showUnpaidOnly && order.isPaid) {
        return false;
      }

      // Include all orders that passed the filters
      return true;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.grey[200]!,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
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
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../blocs/sales/sales_order_bloc.dart';
import '../../../blocs/purchase/purchase_bloc.dart';
import '../../../data/models/sales_order_model.dart';
import '../../../data/models/purchase_order_model.dart';
import '../../../utils/formatter.dart';

class IncomeStatementScreen extends StatefulWidget {
  const IncomeStatementScreen({Key? key}) : super(key: key);

  @override
  State<IncomeStatementScreen> createState() => _IncomeStatementScreenState();
}

class _IncomeStatementScreenState extends State<IncomeStatementScreen> {
  DateTimeRange? _dateRange;
  bool _isGenerating = false;
  bool _isGenerated = false;

  // Income statement data
  late double _totalRevenue;
  late double _costOfGoodsSold;
  late double _grossProfit;

  // Breakdown data
  late Map<String, double> _revenueBreakdown;
  late Map<String, double> _expenseBreakdown;

  @override
  void initState() {
    super.initState();
    // Set default date range to current month
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );

    // Initialize data structures
    _resetData();

    // Load data
    _loadData();
  }

  void _resetData() {
    _totalRevenue = 0;
    _costOfGoodsSold = 0;
    _grossProfit = 0;

    _revenueBreakdown = {};
    _expenseBreakdown = {};
  }

  void _loadData() {
    context.read<SalesOrderBloc>().add(LoadSalesOrders());
    context.read<PurchaseBloc>().add(LoadPurchaseOrders(showCompleted: true));
  }

  void _generateIncomeStatement() {
    if (_dateRange == null) return;

    setState(() {
      _isGenerating = true;
      _isGenerated = false;
      _resetData();
    });

    // Get sales data
    final salesState = context.read<SalesOrderBloc>().state;
    if (salesState is SalesOrdersLoaded) {
      _processSalesData(salesState.orders);
    }

    // Get purchase data
    final purchaseState = context.read<PurchaseBloc>().state;
    if (purchaseState is PurchaseOrdersLoaded) {
      _processPurchaseData(purchaseState.orders);
    }

    // Calculate summary values
    _calculateSummary();

    setState(() {
      _isGenerating = false;
      _isGenerated = true;
    });
  }

  void _processSalesData(List<SalesOrderModel> orders) {
    // Filter orders by date range
    final filteredOrders = orders.where((order) {
      return (order.status == 'delivered' || order.status == 'completed') &&
          _isInDateRange(order.createdAt);
    }).toList();

    // Calculate revenue
    for (final order in filteredOrders) {
      _totalRevenue += order.totalAmount;

      // Add to breakdown by customer
      final customerKey = order.customerName;
      _revenueBreakdown[customerKey] = (_revenueBreakdown[customerKey] ?? 0) + order.totalAmount;
    }
  }

  void _processPurchaseData(List<PurchaseOrderModel> orders) {
    // Filter orders by date range
    final filteredOrders = orders.where((order) {
      return (order.status == 'received' || order.status == 'completed') &&
          _isInDateRange(order.createdAt);
    }).toList();

    // Calculate COGS
    for (final order in filteredOrders) {
      _costOfGoodsSold += order.totalAmount;

      // Add to breakdown by supplier
      final supplierKey = order.supplierName;
      _expenseBreakdown[supplierKey] = (_expenseBreakdown[supplierKey] ?? 0) + order.totalAmount;
    }
  }

  void _calculateSummary() {
    _grossProfit = _totalRevenue - _costOfGoodsSold;
  }

  bool _isInDateRange(DateTime date) {
    if (_dateRange == null) return true;

    return !date.isBefore(_dateRange!.start) &&
        !date.isAfter(_dateRange!.end.add(const Duration(days: 1)));
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
            _buildHeader(isSmallScreen),
            const SizedBox(height: 16),

            // Filters Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (isSmallScreen) ...[
                      _buildDateRangePicker(context),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _generateIncomeStatement,
                          icon: const Icon(Icons.analytics_outlined),
                          label: const Text('Generate Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(child: _buildDateRangePicker(context)),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _generateIncomeStatement,
                            icon: const Icon(Icons.analytics_outlined),
                            label: const Text('Generate Report'),
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
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Income Statement
            if (_isGenerating)
              const Expanded(
                  child: Center(child: CircularProgressIndicator())
              )
            else if (_isGenerated)
              Expanded(child: _buildIncomeStatement(isSmallScreen))
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select a date range and generate the report',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSmallScreen) ...[
          const Text(
            'Income Statement',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Laporan Laba Rugi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          if (_isGenerated) ...[
            const SizedBox(height: 8),
            Text(
              'Period: ${DateFormat('d MMM yyyy').format(_dateRange!.start)} - ${DateFormat('d MMM yyyy').format(_dateRange!.end)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            // const SizedBox(height: 8),
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton.icon(
            //     onPressed: () => _showExportOptions(context),
            //     icon: const Icon(Icons.download),
            //     label: const Text('Export Report'),
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.blue[700],
            //     ),
            //   ),
            // ),
          ],
        ] else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Income Statement (Laporan Laba Rugi)',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isGenerated)
                ElevatedButton.icon(
                  onPressed: () => _showExportOptions(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                ),
            ],
          ),
          if (_isGenerated) ...[
            Text(
              'Period: ${DateFormat('d MMM yyyy').format(_dateRange!.start)} - ${DateFormat('d MMM yyyy').format(_dateRange!.end)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ],
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
            Expanded(
              child: Text(
                _dateRange != null
                    ? '${Formatters.formatDate(_dateRange!.start)} - '
                    '${Formatters.formatDate(_dateRange!.end)}'
                    : 'Select date range',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeStatement(bool isSmallScreen) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          _buildSummaryCards(isSmallScreen),
          const SizedBox(height: 16),

          // Detailed Report
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Income Statement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Revenue section
                  _buildReportSection(
                    title: 'Revenue',
                    items: {
                      'Sales Revenue': _totalRevenue,
                    },
                    total: _totalRevenue,
                    isMainSection: true,
                    isSmallScreen: isSmallScreen,
                  ),

                  const Divider(),

                  // COGS section
                  _buildReportSection(
                    title: 'Cost of Goods Sold',
                    items: {
                      'Purchases': _costOfGoodsSold,
                    },
                    total: _costOfGoodsSold,
                    isMainSection: true,
                    isCost: true,
                    isSmallScreen: isSmallScreen,
                  ),

                  const Divider(thickness: 2),

                  // Gross Profit
                  _buildReportRow(
                    'Gross Profit',
                    _grossProfit,
                    bold: true,
                    fontSize: isSmallScreen ? 16 : 18,
                    indentLevel: 0,
                    backgroundColor: Colors.blue[50],
                    isSmallScreen: isSmallScreen,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Breakdowns
          if (_revenueBreakdown.isNotEmpty) ...[
            _buildBreakdownSection(
              title: 'Revenue Breakdown by Customer',
              data: _revenueBreakdown,
              isRevenue: true,
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 16),
          ],

          if (_expenseBreakdown.isNotEmpty) ...[
            _buildBreakdownSection(
              title: 'Expense Breakdown by Supplier',
              data: _expenseBreakdown,
              isRevenue: false,
              isSmallScreen: isSmallScreen,
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCards(bool isSmallScreen) {
    final grossMargin = _totalRevenue > 0 ? (_grossProfit / _totalRevenue) * 100 : 0;

    final cards = [
      _StatCard(
        title: 'Revenue',
        value: Formatters.formatCurrency(_totalRevenue),
        icon: Icons.trending_up,
        color: Colors.blue[700]!,
      ),
      _StatCard(
        title: 'Cost of Goods Sold',
        value: Formatters.formatCurrency(_costOfGoodsSold),
        icon: Icons.trending_down,
        color: Colors.red[600]!,
      ),
      _StatCard(
        title: 'Gross Profit',
        value: Formatters.formatCurrency(_grossProfit),
        icon: Icons.account_balance,
        color: _grossProfit >= 0 ? Colors.green[600]! : Colors.red[600]!,
      ),
      _StatCard(
        title: 'Gross Margin',
        value: '${grossMargin.toStringAsFixed(2)}%',
        icon: Icons.pie_chart,
        color: Colors.purple[600]!,
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

  Widget _buildReportSection({
    required String title,
    required Map<String, double> items,
    required double total,
    required bool isSmallScreen,
    bool isMainSection = false,
    bool isCost = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReportRow(
          title,
          null,
          bold: true,
          indentLevel: isMainSection ? 0 : 1,
          isSmallScreen: isSmallScreen,
        ),
        ...items.entries.map((entry) =>
            _buildReportRow(
              entry.key,
              entry.value,
              indentLevel: isMainSection ? 1 : 2,
              isCost: isCost,
              isSmallScreen: isSmallScreen,
            ),
        ),
        _buildReportRow(
          'Total $title',
          total,
          bold: true,
          indentLevel: isMainSection ? 0 : 1,
          isCost: isCost,
          isSmallScreen: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildReportRow(
      String label,
      double? value,
      {
        bool bold = false,
        int indentLevel = 0,
        double fontSize = 14,
        Color? backgroundColor,
        bool isCost = false,
        required bool isSmallScreen,
      }
      ) {
    // For small screens, don't indent too much
    final effectiveIndent = isSmallScreen ?
    (indentLevel * 8.0) :  // Less indentation on mobile
    (indentLevel * 16.0);  // Normal indentation on desktop

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16 + effectiveIndent,
      ),
      color: backgroundColor,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: fontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (value != null)
            Expanded(
              flex: 2,
              child: Text(
                Formatters.formatCurrency(isCost && value > 0 ? -value : value),
                style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize,
                  color: value < 0 ? Colors.red : null,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection({
    required String title,
    required Map<String, double> data,
    required bool isRevenue,
    required bool isSmallScreen,
  }) {
    // Sort data by value in descending order
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Limit number of items on mobile to prevent overwhelming the screen
    final displayEntries = isSmallScreen && sortedEntries.length > 5 ?
    sortedEntries.sublist(0, 5) :
    sortedEntries;

    // Get the max value for progress bar calculations
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ...displayEntries.map((entry) =>
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              Formatters.formatCurrency(entry.value),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isRevenue ? Colors.blue[700] : Colors.red[700],
                              ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value / maxValue,
                          backgroundColor: Colors.grey[200],
                          color: isRevenue ? Colors.blue[700] : Colors.red[700],
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
            ),
            // Show "See more" text if items were limited
            if (isSmallScreen && sortedEntries.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    '+ ${sortedEntries.length - 5} more items',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    if (isSmallScreen) {
      // Use bottom sheet for mobile
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Export as PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackbar('Exporting as PDF...');
                  // Implement actual PDF export
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('Export as Excel'),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackbar('Exporting as Excel...');
                  // Implement actual Excel export
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    } else {
      // Use dialog for desktop
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Income Statement'),
          content: const Text('Choose export format:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackbar('Exporting as PDF...');
                // Implement actual PDF export
              },
              child: const Text('PDF'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showSnackbar('Exporting as Excel...');
                // Implement actual Excel export
              },
              child: const Text('Excel'),
            ),
          ],
        ),
      );
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
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
                      fontSize: isSmallScreen ? 14 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 13,
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
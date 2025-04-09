import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/purchase_invoice/purchase_invoice_bloc.dart';
import '../../../utils/formatter.dart';

class PurchaseInvoiceStatsCards extends StatelessWidget {
  const PurchaseInvoiceStatsCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      builder: (context, state) {
        if (state is! PurchaseInvoicesLoaded) {
          return const SizedBox.shrink();
        }

        final cards = [
          _StatsCard(
            title: 'Total Invoices',
            value: state.totalInvoices.toInt().toString(),
            icon: Icons.receipt_outlined,
            color: Colors.blue[700]!,
          ),
          _StatsCard(
            title: 'Pending Invoices',
            value: state.pendingInvoices.toInt().toString(),
            icon: Icons.hourglass_empty_outlined,
            color: Colors.orange[600]!,
          ),
          _StatsCard(
            title: 'Overdue Invoices',
            value: state.overdueInvoices.toInt().toString(),
            icon: Icons.warning_amber_outlined,
            color: Colors.red[600]!,
          ),
          _StatsCard(
            title: 'Total Amount',
            value: Formatters.formatCurrency(state.totalAmount),
            icon: Icons.monetization_on_outlined,
            color: Colors.green[600]!,
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
      },
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
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
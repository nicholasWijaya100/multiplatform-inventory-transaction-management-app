import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/product/product_bloc.dart';
import '../../../utils/formatter.dart';

class ProductStatsCards extends StatelessWidget {
  const ProductStatsCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductsLoaded) {
          return const SizedBox.shrink();
        }

        final cards = [
          _StatCard(
            title: 'Total Products',
            value: '${state.totalProducts}',
            icon: Icons.inventory_2_outlined,
            color: Colors.blue,
          ),
          _StatCard(
            title: 'Low Stock Items',
            value: '${state.lowStockProducts}',
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
          ),
          _StatCard(
            title: 'Categories',
            value: '${state.categories.length}',
            icon: Icons.category_outlined,
            color: Colors.green,
          ),
          _StatCard(
            title: 'Total Value',
            value: Formatters.formatCurrency(state.totalValue),
            icon: Icons.attach_money_outlined,
            color: Colors.purple,
          ),
        ];

        if (isSmallScreen) {
          return SingleChildScrollView(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: cards.map((card) => SizedBox(
                width: (MediaQuery.of(context).size.width - 64) / 2,
                child: card,
              )).toList(),
            ),
          );
        }

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: cards,
        );
      },
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

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
            ),
            child: Icon(
              icon,
              color: color,
              size: isSmallScreen ? 24 : 32,
            ),
          ),
          SizedBox(width: isSmallScreen ? 8 : 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
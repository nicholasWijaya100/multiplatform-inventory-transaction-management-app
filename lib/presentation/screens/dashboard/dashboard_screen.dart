import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/recent_activities.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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

        return Container(
          color: Colors.grey[100],
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: padding,
                    horizontal: padding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user.name}!',
                        style: TextStyle(
                          fontSize: size.width < 600 ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getWelcomeSubtitle(user),
                        style: TextStyle(
                          fontSize: size.width < 600 ? 14 : 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),


                // Quick Stats
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: _buildDashboardCards(user),
                ),

                const SizedBox(height: 32),

                // Recent Activities
                const RecentActivities(),

                // Role-specific content
                if (user.role == UserRole.administrator.name) ...[
                  const SizedBox(height: 32),
                  _buildAdminSection(),
                ],
              ],
            ),
          ),
        );
      },
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
      case 'administrator':
        return '$timeBasedGreeting! Here\'s your system overview.';
      case 'sales':
        return '$timeBasedGreeting! Here\'s your sales dashboard.';
      case 'warehouse':
        return '$timeBasedGreeting! Here\'s your inventory overview.';
      case 'purchasing':
        return '$timeBasedGreeting! Here\'s your purchasing dashboard.';
      default:
        return timeBasedGreeting;
    }
  }

  List<Widget> _buildDashboardCards(UserModel user) {
    final List<Widget> cards = [];

    // Common cards for all roles
    cards.add(
      DashboardCard(
        title: 'Total Products',
        value: '1,234',
        icon: Icons.inventory_2_outlined,
        color: Colors.blue,
        onTap: () {},
      ),
    );

    // Role-specific cards
    switch (user.role) {
      case 'administrator':
        cards.addAll([
          DashboardCard(
            title: 'Active Users',
            value: '45',
            icon: Icons.people_outline,
            color: Colors.green,
            onTap: () {},
          ),
          DashboardCard(
            title: 'Total Sales',
            value: '\$123,456',
            icon: Icons.attach_money_outlined,
            color: Colors.purple,
            onTap: () {},
          ),
          DashboardCard(
            title: 'System Health',
            value: '98%',
            icon: Icons.health_and_safety_outlined,
            color: Colors.orange,
            onTap: () {},
          ),
        ]);
        break;
      case 'sales':
        cards.addAll([
          DashboardCard(
            title: 'Today\'s Sales',
            value: '\$12,345',
            icon: Icons.point_of_sale_outlined,
            color: Colors.green,
            onTap: () {},
          ),
          DashboardCard(
            title: 'Pending Orders',
            value: '23',
            icon: Icons.shopping_cart_outlined,
            color: Colors.orange,
            onTap: () {},
          ),
        ]);
        break;
      case 'warehouse':
        cards.addAll([
          DashboardCard(
            title: 'Low Stock Items',
            value: '12',
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            onTap: () {},
          ),
          DashboardCard(
            title: 'Pending Shipments',
            value: '45',
            icon: Icons.local_shipping_outlined,
            color: Colors.purple,
            onTap: () {},
          ),
        ]);
        break;
      case 'purchasing':
        cards.addAll([
          DashboardCard(
            title: 'Purchase Orders',
            value: '34',
            icon: Icons.shopping_bag_outlined,
            color: Colors.green,
            onTap: () {},
          ),
          DashboardCard(
            title: 'Awaiting Delivery',
            value: '12',
            icon: Icons.access_time,
            color: Colors.orange,
            onTap: () {},
          ),
        ]);
        break;
    }

    return cards;
  }

  Widget _buildAdminSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Add admin-specific widgets here
          ],
        ),
      ),
    );
  }
}
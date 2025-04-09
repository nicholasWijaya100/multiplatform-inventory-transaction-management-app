import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../data/models/user_model.dart';
import '../../../utils/navigation_controller.dart';
import '../../../blocs/auth/auth_bloc.dart';

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const SizedBox();
        }

        final user = state.user;
        final navigationController = context.watch<NavigationController>();

        return Drawer(
          child: SafeArea(
            child: Column(
              children: [
                // User Header
                UserAccountsDrawerHeader(
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                  ),
                  accountName: Text(
                    user.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      user.name?[0].toUpperCase() ?? 'U',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  otherAccountsPictures: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          _getRoleIcon(user.role),
                          color: Colors.blue[900],
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                // Menu Items in Scrollable Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Dashboard - Available to all
                        _buildMenuItem(
                          context: context,
                          icon: Icons.dashboard_outlined,
                          title: 'Dashboard',
                          route: '/dashboard',
                          isSelected:
                          navigationController.currentRoute == '/dashboard',
                        ),

                        // Admin-specific items
                        if (user.role == UserRole.administrator.name) ...[
                          const _DrawerHeader('Administration'),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.people_outline,
                            title: 'User Management',
                            route: '/users',
                            isSelected:
                            navigationController.currentRoute == '/users',
                          ),
                        ],

                        // Inventory section
                        if (user.role == UserRole.administrator.name ||
                            user.role == UserRole.warehouse.name) ...[
                          const _DrawerHeader('Inventory'),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.inventory_2_outlined,
                            title: 'Products',
                            route: '/products',
                            isSelected:
                            navigationController.currentRoute == '/products',
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.category_outlined,
                            title: 'Categories',
                            route: '/categories',
                            isSelected:
                            navigationController.currentRoute == '/categories',
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.warehouse_outlined,
                            title: 'Warehouses',
                            route: '/warehouses',
                            isSelected:
                            navigationController.currentRoute == '/warehouses',
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.sync_alt_outlined,
                            title: 'Stock Transfer',
                            route: '/stock-transfer',
                            isSelected: navigationController.currentRoute ==
                                '/stock-transfer',
                          ),
                        ],

                        // Sales section
                        if (user.role == UserRole.administrator.name ||
                            user.role == UserRole.sales.name) ...[
                          const _DrawerHeader('Sales'),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.shopping_cart_outlined,
                            title: 'Sales Orders',
                            route: '/sales',
                            isSelected:
                            navigationController.currentRoute == '/sales',
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.people_outline,
                            title: 'Customers',
                            route: '/customers',
                            isSelected:
                            navigationController.currentRoute == '/customers',
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.receipt_long_outlined,
                            title: 'Invoices',
                            route: '/invoices',
                            isSelected:
                            navigationController.currentRoute == '/invoices',
                          ),
                        ],

                        // Purchasing section
                        if (user.role == UserRole.administrator.name ||
                            user.role == UserRole.purchasing.name) ...[
                          const _DrawerHeader('Purchasing'),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.shopping_bag_outlined,
                            title: 'Purchase Orders',
                            route: '/purchases',
                            isSelected:
                            navigationController.currentRoute == '/purchases',
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.local_shipping_outlined,
                            title: 'Suppliers',
                            route: '/suppliers',
                            isSelected:
                            navigationController.currentRoute == '/suppliers',
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.receipt_long_outlined,
                            title: 'Purchase Invoices',
                            route: '/purchase-invoices',
                            isSelected:
                            navigationController.currentRoute == '/purchase-invoices',
                          ),
                        ],

                        // Reports section
                        if (user.role == UserRole.administrator.name ||
                            user.role == UserRole.sales.name ||
                            user.role == UserRole.purchasing.name) ...[
                          const _DrawerHeader('Reports'),
                          if (user.role == UserRole.administrator.name ||
                              user.role == UserRole.sales.name)
                            _buildMenuItem(
                              context: context,
                              icon: Icons.bar_chart_outlined,
                              title: 'Sales Report',
                              route: '/reports/sales',
                              isSelected: navigationController.currentRoute ==
                                  '/reports/sales',
                            ),
                          if (user.role == UserRole.administrator.name ||
                              user.role == UserRole.purchasing.name)
                            _buildMenuItem(
                              context: context,
                              icon: Icons.analytics_outlined,
                              title: 'Purchase Report',
                              route: '/reports/purchases',
                              isSelected: navigationController.currentRoute ==
                                  '/reports/purchases',
                            ),
                          if (user.role == UserRole.administrator.name ||
                              user.role == UserRole.warehouse.name)
                            _buildMenuItem(
                              context: context,
                              icon: Icons.inventory_outlined,
                              title: 'Stock Report',
                              route: '/reports/stock',
                              isSelected: navigationController.currentRoute ==
                                  '/reports/stock',
                            ),
                        ],

                        const Divider(height: 16),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          route: '/settings',
                          isSelected:
                          navigationController.currentRoute == '/settings',
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          route: '/help',
                          isSelected:
                          navigationController.currentRoute == '/help',
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(
                  height: 1,
                  thickness: 1,
                ),

                // Logout section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildMenuItem(
                    context: context,
                    icon: Icons.logout,
                    title: 'Logout',
                    route: 'logout',
                    isSelected: false,
                    iconColor: Colors.red,
                    textColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required bool isSelected,
    Color? iconColor,
    Color? textColor,
  }) {
    final navigationController = context.read<NavigationController>();
    final defaultColor = isSelected ? Colors.blue[900] : Colors.grey[700];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: SizedBox(
          width: 32, // Fixed width for icon container
          child: Icon(
            icon,
            color: iconColor ?? defaultColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? defaultColor,
            fontWeight: isSelected ? FontWeight.bold : null,
            fontSize: 14,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.blue[50],
        dense: true,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        horizontalTitleGap: 8, // Fixed gap between icon and text
        onTap: () {
          if (route == 'logout') {
            Navigator.pop(context);
            context.read<AuthBloc>().add(SignOutRequested());
          } else {
            navigationController.navigateTo(route);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'administrator':
        return Icons.admin_panel_settings;
      case 'sales':
        return Icons.point_of_sale;
      case 'warehouse':
        return Icons.warehouse;
      case 'purchasing':
        return Icons.shopping_cart;
      default:
        return Icons.person;
    }
  }
}

class _DrawerHeader extends StatelessWidget {
  final String title;

  const _DrawerHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
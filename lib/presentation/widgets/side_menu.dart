import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../data/models/user_model.dart';
import '../../utils/navigation_controller.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const SizedBox();
        }

        final user = state.user;
        final navigationController = context.watch<NavigationController>();

        return Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Logo and Company Name
              _buildHeader(),

              // Menu Items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMenuItems(context, user, navigationController),
                    ],
                  ),
                ),
              ),

              // User Profile Section
              _buildUserProfile(context, user),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 32,
            color: Colors.blue[900],
          ),
          const SizedBox(width: 12),
          Text(
            'Inventory',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems(
      BuildContext context,
      UserModel user,
      NavigationController navigationController,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        // Dashboard - Available to all
        _MenuItem(
          icon: Icons.dashboard_outlined,
          title: 'Dashboard',
          isSelected: navigationController.currentRoute == '/dashboard',
          onTap: () => navigationController.navigateTo('/dashboard'),
        ),

        // Admin-only section
        if (user.role == UserRole.administrator.name) ...[
          _MenuGroup(
            title: 'Administration',
            children: [
              _MenuItem(
                icon: Icons.people_outline,
                title: 'User Management',
                isSelected: navigationController.currentRoute == '/users',
                onTap: () => navigationController.navigateTo('/users'),
              ),
            ],
          ),
        ],

        // Inventory section
        if (user.role == UserRole.administrator.name ||
            user.role == UserRole.warehouse.name) ...[
          _MenuGroup(
            title: 'Inventory',
            children: [
              _MenuItem(
                icon: Icons.inventory_2_outlined,
                title: 'Products',
                isSelected: navigationController.currentRoute == '/products',
                onTap: () => navigationController.navigateTo('/products'),
              ),
              _MenuItem(
                icon: Icons.category_outlined,
                title: 'Categories',
                isSelected: navigationController.currentRoute == '/categories',
                onTap: () => navigationController.navigateTo('/categories'),
              ),
              // Only show warehouses to administrators
              if (user.role == UserRole.administrator.name)
                _MenuItem(
                  icon: Icons.warehouse_outlined,
                  title: 'Warehouses',
                  isSelected: navigationController.currentRoute == '/warehouses',
                  onTap: () => navigationController.navigateTo('/warehouses'),
                ),
              _MenuItem(
                icon: Icons.sync_alt_outlined,
                title: 'Stock Transfer',
                isSelected: navigationController.currentRoute == '/stock-transfer',
                onTap: () => navigationController.navigateTo('/stock-transfer'),
              ),
            ],
          ),
        ],

        // Sales section
        if (user.role == UserRole.administrator.name ||
            user.role == UserRole.sales.name) ...[
          _MenuGroup(
            title: 'Sales',
            children: [
              _MenuItem(
                icon: Icons.shopping_cart_outlined,
                title: 'Sales Orders',
                isSelected: navigationController.currentRoute == '/sales',
                onTap: () => navigationController.navigateTo('/sales'),
              ),
              _MenuItem(
                icon: Icons.people_outline,
                title: 'Customers',
                isSelected: navigationController.currentRoute == '/customers',
                onTap: () => navigationController.navigateTo('/customers'),
              ),
              _MenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Invoices',
                isSelected: navigationController.currentRoute == '/invoices',
                onTap: () => navigationController.navigateTo('/invoices'),
              ),
            ],
          ),
        ],

        // Purchasing section
        if (user.role == UserRole.administrator.name ||
            user.role == UserRole.purchasing.name) ...[
          _MenuGroup(
            title: 'Purchasing',
            children: [
              _MenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'Purchase Orders',
                isSelected: navigationController.currentRoute == '/purchases',
                onTap: () => navigationController.navigateTo('/purchases'),
              ),
              _MenuItem(
                icon: Icons.local_shipping_outlined,
                title: 'Suppliers',
                isSelected: navigationController.currentRoute == '/suppliers',
                onTap: () => navigationController.navigateTo('/suppliers'),
              ),
              _MenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Purchase Invoices',
                isSelected: navigationController.currentRoute == '/purchase-invoices',
                onTap: () => navigationController.navigateTo('/purchase-invoices'),
              ),
            ],
          ),
        ],

        // Reports section
        if (user.role == UserRole.administrator.name ||
            user.role == UserRole.sales.name ||
            user.role == UserRole.purchasing.name) ...[
          _MenuGroup(
            title: 'Reports',
            children: [
              if (user.role == UserRole.administrator.name ||
                  user.role == UserRole.sales.name)
                _MenuItem(
                  icon: Icons.bar_chart_outlined,
                  title: 'Sales Report',
                  isSelected: navigationController.currentRoute == '/reports/sales',
                  onTap: () => navigationController.navigateTo('/reports/sales'),
                ),
              if (user.role == UserRole.administrator.name ||
                  user.role == UserRole.purchasing.name)
                _MenuItem(
                  icon: Icons.analytics_outlined,
                  title: 'Purchase Report',
                  isSelected:
                  navigationController.currentRoute == '/reports/purchases',
                  onTap: () =>
                      navigationController.navigateTo('/reports/purchases'),
                ),
              if (user.role == UserRole.administrator.name ||
                  user.role == UserRole.warehouse.name)
                _MenuItem(
                  icon: Icons.inventory_outlined,
                  title: 'Stock Report',
                  isSelected: navigationController.currentRoute == '/reports/stock',
                  onTap: () => navigationController.navigateTo('/reports/stock'),
                ),
              if (user.role == UserRole.administrator.name)
                _MenuItem(
                  title: 'Income Statement',
                  icon: Icons.account_balance_wallet_outlined,
                  isSelected: navigationController.currentRoute == '/reports/income-statement',
                  onTap: () => navigationController.navigateTo('/reports/income-statement'),
                ),
            ],
          ),
        ],

        _MenuGroup(
          title: 'Tools',
          children: [
            _MenuItem(
              icon: Icons.chat_outlined,
              title: 'Inventory Assistant',
              isSelected: navigationController.currentRoute == '/chatbot',
              onTap: () => navigationController.navigateTo('/chatbot'),
            ),
          ],
        ),

        // Common sections available to all users
        const Divider(height: 32),
        _MenuItem(
          icon: Icons.settings_outlined,
          title: 'Settings',
          isSelected: navigationController.currentRoute == '/settings',
          onTap: () => navigationController.navigateTo('/settings'),
        ),
        _MenuItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          isSelected: navigationController.currentRoute == '/help',
          onTap: () => navigationController.navigateTo('/help'),
        ),
      ],
    );
  }

  Widget _buildUserProfile(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue[900],
            child: Text(
              user.name?[0].toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name ?? 'User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.role,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _MenuGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          border: isSelected
              ? Border(
            left: BorderSide(
              color: Colors.blue[900]!,
              width: 4,
            ),
          )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.blue[900] : Colors.grey[700],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? Colors.blue[900] : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w500 : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.blue[900],
              ),
          ],
        ),
      ),
    );
  }
}
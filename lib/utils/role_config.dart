import 'package:flutter/material.dart';
import '../data/models/user_model.dart';

class MenuConfig {
  static List<MenuItem> getMenuItems(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return [
          MenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard_outlined,
            route: '/dashboard',
          ),
          MenuItem(
            title: 'User Management',
            icon: Icons.people_outline,
            route: '/users',
          ),
          MenuItem(
            title: 'Products',
            icon: Icons.inventory_2_outlined,
            route: '/products',
          ),
          MenuItem(
            title: 'Categories',
            icon: Icons.category_outlined,
            route: '/categories',
          ),
          MenuItem(
            title: 'Sales',
            icon: Icons.shopping_cart_outlined,
            route: '/sales',
          ),
          MenuItem(
            title: 'Purchases',
            icon: Icons.shopping_bag_outlined,
            route: '/purchases',
          ),
          MenuItem(
            title: 'Reports',
            icon: Icons.bar_chart_outlined,
            route: '/reports',
          ),
          MenuItem(
            title: 'Settings',
            icon: Icons.settings_outlined,
            route: '/settings',
          ),
        ];

      case UserRole.sales:
        return [
          MenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard_outlined,
            route: '/dashboard',
          ),
          MenuItem(
            title: 'Products',
            icon: Icons.inventory_2_outlined,
            route: '/products',
            readOnly: true,
          ),
          MenuItem(
            title: 'Sales',
            icon: Icons.shopping_cart_outlined,
            route: '/sales',
          ),
          MenuItem(
            title: 'Customers',
            icon: Icons.people_outline,
            route: '/customers',
          ),
          MenuItem(
            title: 'Sales Reports',
            icon: Icons.bar_chart_outlined,
            route: '/sales-reports',
          ),
        ];

      case UserRole.warehouse:
        return [
          MenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard_outlined,
            route: '/dashboard',
          ),
          MenuItem(
            title: 'Inventory',
            icon: Icons.inventory_2_outlined,
            route: '/inventory',
          ),
          MenuItem(
            title: 'Stock Transfer',
            icon: Icons.swap_horiz_outlined,
            route: '/stock-transfer',
          ),
          MenuItem(
            title: 'Stock Take',
            icon: Icons.fact_check_outlined,
            route: '/stock-take',
          ),
          MenuItem(
            title: 'Stock Reports',
            icon: Icons.assessment_outlined,
            route: '/stock-reports',
          ),
        ];

      case UserRole.purchasing:
        return [
          MenuItem(
            title: 'Dashboard',
            icon: Icons.dashboard_outlined,
            route: '/dashboard',
          ),
          MenuItem(
            title: 'Purchase Orders',
            icon: Icons.shopping_bag_outlined,
            route: '/purchase-orders',
          ),
          MenuItem(
            title: 'Suppliers',
            icon: Icons.business_outlined,
            route: '/suppliers',
          ),
          MenuItem(
            title: 'Products',
            icon: Icons.inventory_2_outlined,
            route: '/products',
            readOnly: true,
          ),
          MenuItem(
            title: 'Purchase Reports',
            icon: Icons.bar_chart_outlined,
            route: '/purchase-reports',
          ),
        ];
    }
  }

  static String getDashboardTitle(UserRole role) {
    switch (role) {
      case UserRole.administrator:
        return 'Admin Dashboard';
      case UserRole.sales:
        return 'Sales Dashboard';
      case UserRole.warehouse:
        return 'Warehouse Dashboard';
      case UserRole.purchasing:
        return 'Purchasing Dashboard';
    }
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final bool readOnly;

  MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.readOnly = false,
  });
}
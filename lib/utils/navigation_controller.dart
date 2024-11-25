import 'package:flutter/material.dart';
import 'package:inventory_app_revised/presentation/screens/categories/category_management_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/stock_transfer/stock_transfer_screen.dart';
import '../presentation/screens/users/user_management_screen.dart';
import '../presentation/screens/products/product_management_screen.dart';
import '../presentation/screens/warehouses/warehouse_management_screen.dart';

class NavigationController extends ChangeNotifier {
  String _currentRoute = '/dashboard';
  late Widget _currentScreen;

  NavigationController() {
    _currentScreen = const DashboardScreen();
  }

  String get currentRoute => _currentRoute;
  Widget get currentScreen => _currentScreen;

  void navigateTo(String route) {
    _currentRoute = route;
    _currentScreen = getScreenForRoute(route);
    notifyListeners();
  }

  Widget getScreenForRoute(String route) {
    switch (route) {
      case '/dashboard':
        return const DashboardScreen();
      case '/users':
        return const UserManagementScreen();
      case '/products':
        return const ProductManagementScreen();
      case '/categories':
        return const CategoryManagementScreen();
      case '/warehouses':
        return const WarehouseManagementScreen();
      case '/stock-transfer':
        return const StockTransferScreen();
      default:
        return const DashboardScreen();
    }
  }
}
import 'package:flutter/material.dart';
import 'package:inventory_app_revised/presentation/screens/categories/category_management_screen.dart';
import 'package:inventory_app_revised/presentation/screens/customers/customer_management_screen.dart';
import 'package:inventory_app_revised/presentation/screens/reports/purchase_report_screen.dart';
import 'package:inventory_app_revised/presentation/screens/sales/sales_order_management_screen.dart';
import 'package:inventory_app_revised/presentation/screens/suppliers/supplier_management_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/invoices/invoice_management_screen.dart';
import '../presentation/screens/purchase_orders/purchase_orders_screen.dart';
import '../presentation/screens/reports/stock_report_screen.dart';
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
      case '/reports/stock':
        return const StockReportScreen();
      case '/reports/purchases':
        return const PurchaseReportScreen();
      case '/suppliers':
        return const SupplierManagementScreen();
      case '/purchases':
        return const PurchaseOrderManagementScreen();
      case '/sales':
        return const SalesOrderManagementScreen();
      case '/customers':
        return const CustomerManagementScreen();
      case '/invoices':
        return const InvoiceManagementScreen();
      default:
        return const DashboardScreen();
    }
  }
}
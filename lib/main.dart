import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_app_revised/blocs/customer/customer_bloc.dart';
import 'package:inventory_app_revised/blocs/sales/sales_order_bloc.dart';
import 'package:inventory_app_revised/utils/navigation_controller.dart';
import 'package:provider/provider.dart';
import 'blocs/category/category_bloc.dart';
import 'blocs/dashboard/dashboard_bloc.dart';
import 'blocs/invoice/invoice_bloc.dart';
import 'blocs/product/product_bloc.dart';
import 'blocs/purchase/purchase_bloc.dart';
import 'blocs/supplier/supplier_bloc.dart';
import 'blocs/users/users_bloc.dart';
import 'blocs/warehouse/warehouse_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/supplier_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/warehouse_repository.dart';
import 'firebase_options.dart';
import 'utils/service_locator.dart';
import 'utils/initial_setup.dart';
import 'blocs/auth/auth_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupServiceLocator();
  await InitialSetup.checkAndCreateAdminUser();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => locator<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<UserBloc>(
          create: (context) {
            final authState = context.read<AuthBloc>().state;
            if (authState is Authenticated) {
              return locator.get<UserBloc>(param1: authState.user.id)
                ..add(LoadUsers());
            }
            throw Exception('User must be authenticated to access user management');
          },
        ),
        BlocProvider(
          create: (context) => locator<ProductBloc>(),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => locator<DashboardBloc>()..add(LoadDashboardData()),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(
            categoryRepository: locator<CategoryRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => locator<WarehouseBloc>(),
        ),
        BlocProvider(
          create: (context) => SupplierBloc(
            supplierRepository: locator<SupplierRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => locator<PurchaseBloc>(),
        ),
        BlocProvider(
          create: (context) => locator<CustomerBloc>(),
        ),
        BlocProvider(
          create: (context) => locator<SalesOrderBloc>(),
        ),
        BlocProvider(
          create: (context) => locator<InvoiceBloc>(),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (_) => NavigationController(),
        child: MaterialApp(
          title: 'Inventory Management',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (state is Authenticated) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}
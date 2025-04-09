import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_app_revised/blocs/supplier/supplier_bloc.dart';
import 'package:inventory_app_revised/data/repositories/activity_repository.dart';
import 'package:inventory_app_revised/data/repositories/sales_order_repository.dart';
import 'package:inventory_app_revised/data/repositories/supplier_repository.dart';
import '../blocs/category/category_bloc.dart';
import '../blocs/customer/customer_bloc.dart';
import '../blocs/invoice/invoice_bloc.dart';
import '../blocs/product/product_bloc.dart';
import '../blocs/purchase/purchase_bloc.dart';
import '../blocs/purchase_invoice/purchase_invoice_bloc.dart';
import '../blocs/sales/sales_order_bloc.dart';
import '../blocs/users/users_bloc.dart';
import '../blocs/warehouse/warehouse_bloc.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../data/repositories/invoice_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/purchase_invoice_repository.dart';
import '../data/repositories/purchase_repository.dart';
import '../data/repositories/user_repository.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/dashboard/dashboard_bloc.dart';
import '../data/repositories/warehouse_repository.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // Firebase Services
  locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  locator.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
        () => AuthRepository(
      firebaseAuth: locator<FirebaseAuth>(),
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerLazySingleton<UserRepository>(
        () => UserRepository(
      firebaseAuth: locator<FirebaseAuth>(),
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  // BLoCs
  locator.registerFactory<AuthBloc>(
        () => AuthBloc(
      authRepository: locator<AuthRepository>(),
    ),
  );

  // Register UserBloc factory with a function that requires currentUserId
  locator.registerFactoryParam<UserBloc, String, void>(
        (currentUserId, _) => UserBloc(
      userRepository: locator<UserRepository>(),
      currentUserId: currentUserId,
    ),
  );

  locator.registerFactory<DashboardBloc>(
        () => DashboardBloc(),
  );


  locator.registerLazySingleton<ProductRepository>(
        () => ProductRepository(
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerFactory<ProductBloc>(
        () => ProductBloc(
      productRepository: locator<ProductRepository>(),
      warehouseBloc: locator<WarehouseBloc>(),
      activityRepository: locator<ActivityRepository>(),
      currentUserId: locator<FirebaseAuth>().currentUser!.uid,
    ),
  );

  // Register CategoryRepository
  locator.registerLazySingleton<CategoryRepository>(
        () => CategoryRepository(
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  // Register CategoryBloc
  locator.registerFactory<CategoryBloc>(
        () => CategoryBloc(
      categoryRepository: locator<CategoryRepository>(),
    ),
  );

  locator.registerLazySingleton<WarehouseRepository>(
        () => WarehouseRepository(
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerFactory<WarehouseBloc>(
        () => WarehouseBloc(
      warehouseRepository: locator<WarehouseRepository>(),
    ),
  );

  locator.registerLazySingleton<ActivityRepository>(
        () => ActivityRepository(
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerFactory<SupplierBloc>(
        () => SupplierBloc(
      supplierRepository: locator<SupplierRepository>(),
    ),
  );

  locator.registerLazySingleton<SupplierRepository>(
        () => SupplierRepository(
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerLazySingleton<PurchaseRepository>(
        () => PurchaseRepository(
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerFactory<PurchaseBloc>(
        () => PurchaseBloc(
      purchaseRepository: locator<PurchaseRepository>(),
    ),
  );

  locator.registerLazySingleton<CustomerRepository>(
        () => CustomerRepository(
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerFactory<CustomerBloc>(
        () => CustomerBloc(
      customerRepository: locator<CustomerRepository>(),
    ),
  );

  locator.registerLazySingleton<SalesOrderRepository>(
        () => SalesOrderRepository(
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerFactory<SalesOrderBloc>(
        () => SalesOrderBloc(
      salesOrderRepository: locator<SalesOrderRepository>(),
    ),
  );

  locator.registerLazySingleton<InvoiceRepository>(
        () => InvoiceRepository(
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerFactory<InvoiceBloc>(
        () => InvoiceBloc(
      invoiceRepository: locator<InvoiceRepository>(),
    ),
  );

  locator.registerLazySingleton<PurchaseInvoiceRepository>(
        () => PurchaseInvoiceRepository(
      firestore: locator<FirebaseFirestore>(),
    ),
  );

  locator.registerFactory<PurchaseInvoiceBloc>(
        () => PurchaseInvoiceBloc(
      purchaseInvoiceRepository: locator<PurchaseInvoiceRepository>(),
    ),
  );
}
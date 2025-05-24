import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inventory_app_revised/blocs/sales/sales_order_bloc.dart';
import 'package:inventory_app_revised/data/models/sales_order_model.dart';
import 'package:inventory_app_revised/data/repositories/customer_repository.dart';
import 'package:inventory_app_revised/data/repositories/sales_order_repository.dart';
import 'package:inventory_app_revised/utils/service_locator.dart';
import 'package:get_it/get_it.dart';

class MockSalesOrderRepository extends Mock implements SalesOrderRepository {}
class MockCustomerRepository extends Mock implements CustomerRepository {}
class MockGetIt extends Mock implements GetIt {}

void main() {
  late MockSalesOrderRepository salesOrderRepository;
  late MockCustomerRepository customerRepository;
  late SalesOrderBloc salesOrderBloc;
  late MockGetIt mockLocator;

  // Create a mock SalesOrderItem for fallback
  final mockSalesOrderItem = SalesOrderItem(
    productId: 'product-id',
    productName: 'Product',
    quantity: 1,
    unitPrice: 10.0,
    totalPrice: 10.0,
  );

  // Register fallback values
  setUpAll(() {
    registerFallbackValue(
        SalesOrderModel(
          id: 'fallback-id',
          customerId: 'customer-id',
          customerName: 'Customer',
          status: 'draft',
          items: [mockSalesOrderItem],
          totalAmount: 10.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
    );
  });

  setUp(() {
    salesOrderRepository = MockSalesOrderRepository();
    customerRepository = MockCustomerRepository();
    mockLocator = MockGetIt();

    // Setup the locator mock
    GetIt.instance.allowReassignment = true;

    // Mock the servie locator resolution
    when(() => mockLocator.get<CustomerRepository>())
        .thenReturn(customerRepository);

    salesOrderBloc = SalesOrderBloc(
      salesOrderRepository: salesOrderRepository,
    );
  });

  tearDown(() {
    salesOrderBloc.close();
  });

  final testSalesOrder = SalesOrderModel(
    id: 'test-order-id',
    customerId: 'test-customer-id',
    customerName: 'Test Customer',
    status: 'pending',
    items: [
      SalesOrderItem(
        productId: 'test-product-id',
        productName: 'Test Product',
        quantity: 2,
        unitPrice: 19.99,
        totalPrice: 39.98,
      ),
    ],
    totalAmount: 39.98,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testSalesOrders = [testSalesOrder];

  group('SalesOrderBloc', () {
    test('initial state is SalesOrderInitial', () {
      expect(salesOrderBloc.state, equals(SalesOrderInitial()));
    });

    blocTest<SalesOrderBloc, SalesOrderState>(
      'emits [SalesOrderLoading, SalesOrdersLoaded] when LoadSalesOrders is added',
      build: () {
        when(() => salesOrderRepository.getSalesOrders(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
        )).thenAnswer((_) async => testSalesOrders);

        return salesOrderBloc;
      },
      act: (bloc) => bloc.add(LoadSalesOrders()),
      expect: () => [
        SalesOrderLoading(),
        isA<SalesOrdersLoaded>().having(
                (state) => state.orders,
            'orders',
            equals(testSalesOrders)
        ),
      ],
    );

    blocTest<SalesOrderBloc, SalesOrderState>(
      'emits [SalesOrderLoading, SalesOrdersLoaded] when FilterSalesOrdersByCustomer is added',
      build: () {
        when(() => salesOrderRepository.getSalesOrders(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
        )).thenAnswer((_) async => testSalesOrders);

        return salesOrderBloc;
      },
      act: (bloc) => bloc.add(const FilterSalesOrdersByCustomer('test-customer-id')),
      expect: () => [
        SalesOrderLoading(),
        isA<SalesOrdersLoaded>(),
      ],
    );

    blocTest<SalesOrderBloc, SalesOrderState>(
      'emits [SalesOrderLoading, SalesOrderError] when LoadSalesOrders fails',
      build: () {
        when(() => salesOrderRepository.getSalesOrders(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
        )).thenThrow(Exception('Failed to load sales orders'));

        return salesOrderBloc;
      },
      act: (bloc) => bloc.add(LoadSalesOrders()),
      expect: () => [
        SalesOrderLoading(),
        isA<SalesOrderError>(),
      ],
    );
  });
}
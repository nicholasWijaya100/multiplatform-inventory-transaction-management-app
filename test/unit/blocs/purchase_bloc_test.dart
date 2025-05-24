import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inventory_app_revised/blocs/purchase/purchase_bloc.dart';
import 'package:inventory_app_revised/data/models/purchase_order_model.dart';
import 'package:inventory_app_revised/data/repositories/purchase_repository.dart';

class MockPurchaseRepository extends Mock implements PurchaseRepository {}

void main() {
  late MockPurchaseRepository purchaseRepository;
  late PurchaseBloc purchaseBloc;

  // Create a mock PurchaseOrderItem for fallback
  final mockPurchaseOrderItem = PurchaseOrderItem(
    productId: 'product-id',
    productName: 'Product',
    quantity: 1,
    unitPrice: 10.0,
    totalPrice: 10.0,
  );

  // Register fallback values
  setUpAll(() {
    registerFallbackValue(
        PurchaseOrderModel(
          id: 'fallback-id',
          supplierId: 'supplier-id',
          supplierName: 'Supplier',
          status: 'draft',
          items: [mockPurchaseOrderItem],
          totalAmount: 10.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
    );
  });

  setUp(() {
    purchaseRepository = MockPurchaseRepository();
    purchaseBloc = PurchaseBloc(purchaseRepository: purchaseRepository);
  });

  tearDown(() {
    purchaseBloc.close();
  });

  final testPurchaseOrder = PurchaseOrderModel(
    id: 'test-order-id',
    supplierId: 'test-supplier-id',
    supplierName: 'Test Supplier',
    status: 'pending',
    items: [
      PurchaseOrderItem(
        productId: 'test-product-id',
        productName: 'Test Product',
        quantity: 5,
        unitPrice: 12.99,
        totalPrice: 64.95,
      ),
    ],
    totalAmount: 64.95,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testPurchaseOrders = [testPurchaseOrder];

  group('PurchaseBloc', () {
    test('initial state is PurchaseInitial', () {
      expect(purchaseBloc.state, equals(PurchaseInitial()));
    });

    blocTest<PurchaseBloc, PurchaseState>(
      'emits [PurchaseLoading, PurchaseOrdersLoaded] when LoadPurchaseOrders is added',
      build: () {
        when(() => purchaseRepository.getPurchaseOrders(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
        )).thenAnswer((_) async => testPurchaseOrders);

        return purchaseBloc;
      },
      act: (bloc) => bloc.add(const LoadPurchaseOrders()),
      expect: () => [
        PurchaseLoading(),
        isA<PurchaseOrdersLoaded>().having(
                (state) => state.orders,
            'orders',
            equals(testPurchaseOrders)
        ),
      ],
    );

    blocTest<PurchaseBloc, PurchaseState>(
      'emits [PurchaseLoading, PurchaseOrdersLoaded] when FilterPurchaseOrdersBySupplier is added',
      build: () {
        when(() => purchaseRepository.getPurchaseOrders(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
        )).thenAnswer((_) async => testPurchaseOrders);

        return purchaseBloc;
      },
      act: (bloc) => bloc.add(const FilterPurchaseOrdersBySupplier('test-supplier-id')),
      expect: () => [
        PurchaseLoading(),
        isA<PurchaseOrdersLoaded>(),
      ],
    );

    blocTest<PurchaseBloc, PurchaseState>(
      'emits [PurchaseLoading, PurchaseOrdersLoaded] when UpdatePurchaseOrderStatus is successful',
      build: () {
        when(() => purchaseRepository.updatePurchaseOrderStatus(any(), any()))
            .thenAnswer((_) async {});

        when(() => purchaseRepository.getPurchaseOrders(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
        )).thenAnswer((_) async => testPurchaseOrders);

        return purchaseBloc;
      },
      act: (bloc) => bloc.add(const UpdatePurchaseOrderStatus('test-order-id', 'confirmed')),
      expect: () => [
        PurchaseLoading(),
        isA<PurchaseOrdersLoaded>(),
      ],
      verify: (_) {
        verify(() => purchaseRepository.updatePurchaseOrderStatus('test-order-id', 'confirmed'))
            .called(1);
      },
    );

    blocTest<PurchaseBloc, PurchaseState>(
      'emits [PurchaseLoading, PurchaseError] when LoadPurchaseOrders fails',
      build: () {
        when(() => purchaseRepository.getPurchaseOrders(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
        )).thenThrow(Exception('Failed to load purchase orders'));

        return purchaseBloc;
      },
      act: (bloc) => bloc.add(const LoadPurchaseOrders()),
      expect: () => [
        PurchaseLoading(),
        isA<PurchaseError>(),
      ],
    );
  });
}
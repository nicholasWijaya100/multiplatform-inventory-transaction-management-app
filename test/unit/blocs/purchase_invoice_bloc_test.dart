// test/unit/blocs/purchase_invoice_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inventory_app_revised/blocs/purchase/purchase_bloc.dart';
import 'package:inventory_app_revised/blocs/purchase_invoice/purchase_invoice_bloc.dart';
import 'package:inventory_app_revised/data/models/purchase_invoice_model.dart';
import 'package:inventory_app_revised/data/repositories/purchase_invoice_repository.dart';
import 'package:inventory_app_revised/utils/service_locator.dart';

// Mocks
class MockPurchaseInvoiceRepository extends Mock implements PurchaseInvoiceRepository {}
class MockPurchaseBloc extends Mock implements PurchaseBloc {}
class MockServiceLocator extends Mock implements GetIt {}

// Fake implementations for fallback registration
class FakePurchaseInvoiceModel extends Fake implements PurchaseInvoiceModel {}
class FakeUpdatePurchaseOrderPayment extends Fake implements UpdatePurchaseOrderPayment {}
class FakePurchaseOrderStatusChanged extends Fake implements PurchaseOrderStatusChanged {}

void main() {
  late PurchaseInvoiceBloc purchaseInvoiceBloc;
  late MockPurchaseInvoiceRepository purchaseInvoiceRepository;
  late MockPurchaseBloc purchaseBloc;

  // Test data
  final testInvoice = PurchaseInvoiceModel(
    id: 'test-invoice-id',
    supplierId: 'test-supplier-id',
    supplierName: 'Test Supplier',
    purchaseOrderId: 'test-order-id',
    status: PurchaseInvoiceStatus.draft.name,
    items: [],
    subtotal: 100.0,
    tax: 10.0,
    total: 110.0,
    dueDate: DateTime.now().add(const Duration(days: 30)),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final invoicesList = [testInvoice];

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(FakePurchaseInvoiceModel());
    registerFallbackValue(FakeUpdatePurchaseOrderPayment());
    registerFallbackValue(FakePurchaseOrderStatusChanged());
  });

  setUp(() {
    purchaseInvoiceRepository = MockPurchaseInvoiceRepository();
    purchaseBloc = MockPurchaseBloc();

    // Mock the service locator
    final locator = GetIt.instance;
    locator.reset(); // Clear previous registrations
    locator.registerSingleton<PurchaseBloc>(purchaseBloc);

    purchaseInvoiceBloc = PurchaseInvoiceBloc(
      purchaseInvoiceRepository: purchaseInvoiceRepository,
    );
  });

  tearDown(() {
    purchaseInvoiceBloc.close();
  });

  group('PurchaseInvoiceBloc', () {
    test('initial state is PurchaseInvoiceInitial', () {
      expect(purchaseInvoiceBloc.state, isA<PurchaseInvoiceInitial>());
    });

    blocTest<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      'emits [PurchaseInvoiceLoading, PurchaseInvoicesLoaded] when LoadPurchaseInvoices is added',
      build: () {
        when(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return purchaseInvoiceBloc;
      },
      act: (bloc) => bloc.add(LoadPurchaseInvoices()),
      expect: () => [
        isA<PurchaseInvoiceLoading>(),
        isA<PurchaseInvoicesLoaded>(),
      ],
    );

    blocTest<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      'emits [PurchaseInvoiceLoading, PurchaseInvoicesLoaded] with filtered results when SearchPurchaseInvoices is added',
      build: () {
        when(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return purchaseInvoiceBloc;
      },
      act: (bloc) => bloc.add(const SearchPurchaseInvoices('Test')),
      expect: () => [
        isA<PurchaseInvoiceLoading>(),
        isA<PurchaseInvoicesLoaded>(),
      ],
      verify: (_) {
        verify(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: 'Test',
          supplierFilter: null,
          statusFilter: null,
          includeOverdue: false,
        )).called(1);
      },
    );

    blocTest<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      'emits [PurchaseInvoiceLoading, PurchaseInvoicesLoaded] when FilterPurchaseInvoicesBySupplier is added',
      build: () {
        when(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return purchaseInvoiceBloc;
      },
      act: (bloc) => bloc.add(const FilterPurchaseInvoicesBySupplier('test-supplier-id')),
      expect: () => [
        isA<PurchaseInvoiceLoading>(),
        isA<PurchaseInvoicesLoaded>(),
      ],
      verify: (_) {
        verify(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: null,
          supplierFilter: 'test-supplier-id',
          statusFilter: null,
          includeOverdue: false,
        )).called(1);
      },
    );

    blocTest<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      'emits [PurchaseInvoiceLoading, PurchaseInvoicesLoaded] when FilterPurchaseInvoicesByStatus is added',
      build: () {
        when(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return purchaseInvoiceBloc;
      },
      act: (bloc) => bloc.add(const FilterPurchaseInvoicesByStatus('draft')),
      expect: () => [
        isA<PurchaseInvoiceLoading>(),
        isA<PurchaseInvoicesLoaded>(),
      ],
      verify: (_) {
        verify(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: null,
          supplierFilter: null,
          statusFilter: 'draft',
          includeOverdue: false,
        )).called(1);
      },
    );

    blocTest<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      'emits [PurchaseInvoiceLoading, PurchaseInvoicesLoaded] when ShowOverduePurchaseInvoices is added',
      build: () {
        when(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return purchaseInvoiceBloc;
      },
      act: (bloc) => bloc.add(const ShowOverduePurchaseInvoices(true)),
      expect: () => [
        isA<PurchaseInvoiceLoading>(),
        isA<PurchaseInvoicesLoaded>(),
      ],
      verify: (_) {
        verify(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: null,
          supplierFilter: null,
          statusFilter: null,
          includeOverdue: true,
        )).called(1);
      },
    );

    blocTest<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      'emits [PurchaseInvoiceLoading, PurchaseInvoiceError] when LoadPurchaseInvoices fails',
      build: () {
        when(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenThrow(Exception('Failed to load invoices'));
        return purchaseInvoiceBloc;
      },
      act: (bloc) => bloc.add(LoadPurchaseInvoices()),
      expect: () => [
        isA<PurchaseInvoiceLoading>(),
        isA<PurchaseInvoiceError>(),
      ],
    );

    blocTest<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      'emits [PurchaseInvoiceLoading, PurchaseInvoicesLoaded] when AddPurchaseInvoice succeeds',
      build: () {
        when(() => purchaseInvoiceRepository.addPurchaseInvoice(any()))
            .thenAnswer((_) async => testInvoice);
        when(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return purchaseInvoiceBloc;
      },
      act: (bloc) => bloc.add(AddPurchaseInvoice(testInvoice)),
      expect: () => [
        isA<PurchaseInvoiceLoading>(),
        isA<PurchaseInvoicesLoaded>(),
      ],
      verify: (_) {
        verify(() => purchaseInvoiceRepository.addPurchaseInvoice(testInvoice)).called(1);
      },
    );

    blocTest<PurchaseInvoiceBloc, PurchaseInvoiceState>(
      'emits [PurchaseInvoiceLoading, PurchaseInvoiceError, PurchaseInvoiceLoading, PurchaseInvoicesLoaded] when AddPurchaseInvoice fails',
      build: () {
        when(() => purchaseInvoiceRepository.addPurchaseInvoice(any()))
            .thenThrow(Exception('Failed to add invoice'));
        when(() => purchaseInvoiceRepository.getPurchaseInvoices(
          searchQuery: any(named: 'searchQuery'),
          supplierFilter: any(named: 'supplierFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return purchaseInvoiceBloc;
      },
      act: (bloc) => bloc.add(AddPurchaseInvoice(testInvoice)),
      expect: () => [
        isA<PurchaseInvoiceLoading>(),
        isA<PurchaseInvoiceError>(),
        isA<PurchaseInvoiceLoading>(),
        isA<PurchaseInvoicesLoaded>(),
      ],
    );

    // blocTest<PurchaseInvoiceBloc, PurchaseInvoiceState>(
    //   'emits [PurchaseInvoiceLoading, PurchaseInvoicesLoaded] and updates purchase order when MarkPurchaseInvoiceAsPaid succeeds',
    //   build: () {
    //     when(() => purchaseInvoiceRepository.getPurchaseInvoice(any()))
    //         .thenAnswer((_) async => testInvoice);
    //     when(() => purchaseInvoiceRepository.markAsPaid(any()))
    //         .thenAnswer((_) async {});
    //     when(() => purchaseInvoiceRepository.getPurchaseInvoices(
    //       searchQuery: any(named: 'searchQuery'),
    //       supplierFilter: any(named: 'supplierFilter'),
    //       statusFilter: any(named: 'statusFilter'),
    //       includeOverdue: any(named: 'includeOverdue'),
    //     )).thenAnswer((_) async => invoicesList);
    //     when(() => purchaseBloc.add(any())).thenReturn(null);
    //     return purchaseInvoiceBloc;
    //   },
    //   act: (bloc) => bloc.add(const MarkPurchaseInvoiceAsPaid('test-invoice-id')),
    //   expect: () => [
    //     isA<PurchaseInvoiceLoading>(),
    //     isA<PurchaseInvoicesLoaded>(),
    //   ],
    //   verify: (_) {
    //     verify(() => purchaseInvoiceRepository.markAsPaid('test-invoice-id')).called(1);
    //     verify(() => purchaseBloc.add(any())).called(1);
    //   },
    // );
  });
}
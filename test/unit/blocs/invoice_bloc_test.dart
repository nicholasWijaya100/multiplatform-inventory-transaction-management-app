// test/unit/blocs/invoice_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inventory_app_revised/blocs/invoice/invoice_bloc.dart';
import 'package:inventory_app_revised/blocs/sales/sales_order_bloc.dart';
import 'package:inventory_app_revised/data/models/invoice_model.dart';
import 'package:inventory_app_revised/data/repositories/invoice_repository.dart';
import 'package:inventory_app_revised/utils/service_locator.dart';

// Mocks
class MockInvoiceRepository extends Mock implements InvoiceRepository {}
class MockSalesOrderBloc extends Mock implements SalesOrderBloc {}
class MockServiceLocator extends Mock implements GetIt {}

// Fake implementations for fallback registration
class FakeInvoiceModel extends Fake implements InvoiceModel {}
class FakeSalesOrderStatusChanged extends Fake implements SalesOrderStatusChanged {}
class FakeUpdateSalesOrderPaymentStatus extends Fake implements UpdateSalesOrderPaymentStatus {}

void main() {
  late InvoiceBloc invoiceBloc;
  late MockInvoiceRepository invoiceRepository;
  late MockSalesOrderBloc salesOrderBloc;

  // Test data
  final testInvoice = InvoiceModel(
    id: 'test-invoice-id',
    customerId: 'test-customer-id',
    customerName: 'Test Customer',
    salesOrderId: 'test-sales-order-id',
    status: InvoiceStatus.draft.name,
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
    registerFallbackValue(FakeInvoiceModel());
    registerFallbackValue(FakeSalesOrderStatusChanged());
    registerFallbackValue(FakeUpdateSalesOrderPaymentStatus());
  });

  setUp(() {
    invoiceRepository = MockInvoiceRepository();
    salesOrderBloc = MockSalesOrderBloc();

    final locator = GetIt.instance;
    locator.reset(); // Clear previous registrations
    locator.registerSingleton<SalesOrderBloc>(salesOrderBloc);

    invoiceBloc = InvoiceBloc(invoiceRepository: invoiceRepository);
  });

  tearDown(() {
    invoiceBloc.close();
  });

  group('InvoiceBloc', () {
    test('initial state is InvoiceInitial', () {
      expect(invoiceBloc.state, isA<InvoiceInitial>());
    });

    blocTest<InvoiceBloc, InvoiceState>(
      'emits [InvoiceLoading, InvoicesLoaded] when LoadInvoices is added',
      build: () {
        when(() => invoiceRepository.getInvoices(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return invoiceBloc;
      },
      act: (bloc) => bloc.add(LoadInvoices()),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoicesLoaded>(),
      ],
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'emits [InvoiceLoading, InvoicesLoaded] with filtered results when SearchInvoices is added',
      build: () {
        when(() => invoiceRepository.getInvoices(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return invoiceBloc;
      },
      act: (bloc) => bloc.add(const SearchInvoices('Test')),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoicesLoaded>(),
      ],
      verify: (_) {
        verify(() => invoiceRepository.getInvoices(
          searchQuery: 'Test',
          customerFilter: null,
          statusFilter: null,
          includeOverdue: false,
        )).called(1);
      },
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'emits [InvoiceLoading, InvoicesLoaded] when FilterInvoicesByCustomer is added',
      build: () {
        when(() => invoiceRepository.getInvoices(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return invoiceBloc;
      },
      act: (bloc) => bloc.add(const FilterInvoicesByCustomer('test-customer-id')),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoicesLoaded>(),
      ],
      verify: (_) {
        verify(() => invoiceRepository.getInvoices(
          searchQuery: null,
          customerFilter: 'test-customer-id',
          statusFilter: null,
          includeOverdue: false,
        )).called(1);
      },
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'emits [InvoiceLoading, InvoicesLoaded] when FilterInvoicesByStatus is added',
      build: () {
        when(() => invoiceRepository.getInvoices(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return invoiceBloc;
      },
      act: (bloc) => bloc.add(const FilterInvoicesByStatus('draft')),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoicesLoaded>(),
      ],
      verify: (_) {
        verify(() => invoiceRepository.getInvoices(
          searchQuery: null,
          customerFilter: null,
          statusFilter: 'draft',
          includeOverdue: false,
        )).called(1);
      },
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'emits [InvoiceLoading, InvoicesLoaded] when ShowOverdueInvoices is added',
      build: () {
        when(() => invoiceRepository.getInvoices(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return invoiceBloc;
      },
      act: (bloc) => bloc.add(const ShowOverdueInvoices(true)),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoicesLoaded>(),
      ],
      verify: (_) {
        verify(() => invoiceRepository.getInvoices(
          searchQuery: null,
          customerFilter: null,
          statusFilter: null,
          includeOverdue: true,
        )).called(1);
      },
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'emits [InvoiceLoading, InvoiceError] when LoadInvoices fails',
      build: () {
        when(() => invoiceRepository.getInvoices(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenThrow(Exception('Failed to load invoices'));
        return invoiceBloc;
      },
      act: (bloc) => bloc.add(LoadInvoices()),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoiceError>(),
      ],
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'emits [InvoiceLoading, InvoicesLoaded] when AddInvoice succeeds',
      build: () {
        when(() => invoiceRepository.addInvoice(any()))
            .thenAnswer((_) async => testInvoice);
        when(() => invoiceRepository.getInvoices(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return invoiceBloc;
      },
      act: (bloc) => bloc.add(AddInvoice(testInvoice)),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoicesLoaded>(),
      ],
      verify: (_) {
        verify(() => invoiceRepository.addInvoice(testInvoice)).called(1);
      },
    );

    blocTest<InvoiceBloc, InvoiceState>(
      'emits [InvoiceLoading, InvoiceError, InvoiceLoading, InvoicesLoaded] when AddInvoice fails',
      build: () {
        when(() => invoiceRepository.addInvoice(any()))
            .thenThrow(Exception('Failed to add invoice'));
        when(() => invoiceRepository.getInvoices(
          searchQuery: any(named: 'searchQuery'),
          customerFilter: any(named: 'customerFilter'),
          statusFilter: any(named: 'statusFilter'),
          includeOverdue: any(named: 'includeOverdue'),
        )).thenAnswer((_) async => invoicesList);
        return invoiceBloc;
      },
      act: (bloc) => bloc.add(AddInvoice(testInvoice)),
      expect: () => [
        isA<InvoiceLoading>(),
        isA<InvoiceError>(),
        isA<InvoiceLoading>(),
        isA<InvoicesLoaded>(),
      ],
    );

    // blocTest<InvoiceBloc, InvoiceState>(
    //   'emits [InvoiceLoading, InvoicesLoaded] and updates sales order when MarkInvoiceAsPaid succeeds',
    //   build: () {
    //     when(() => invoiceRepository.getInvoice(any()))
    //         .thenAnswer((_) async => testInvoice);
    //     when(() => invoiceRepository.markAsPaid(any()))
    //         .thenAnswer((_) async {});
    //     when(() => invoiceRepository.getInvoices(
    //       searchQuery: any(named: 'searchQuery'),
    //       customerFilter: any(named: 'customerFilter'),
    //       statusFilter: any(named: 'statusFilter'),
    //       includeOverdue: any(named: 'includeOverdue'),
    //     )).thenAnswer((_) async => invoicesList);
    //     when(() => salesOrderBloc.add(any())).thenReturn(null);
    //     return invoiceBloc;
    //   },
    //   act: (bloc) => bloc.add(const MarkInvoiceAsPaid('test-invoice-id')),
    //   expect: () => [
    //     isA<InvoiceLoading>(),
    //     isA<InvoicesLoaded>(),
    //   ],
    //   verify: (_) {
    //     verify(() => invoiceRepository.markAsPaid('test-invoice-id')).called(1);
    //     verify(() => salesOrderBloc.add(any())).called(1);
    //   },
    // );
  });
}
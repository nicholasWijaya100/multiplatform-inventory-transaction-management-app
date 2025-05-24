import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inventory_app_revised/blocs/supplier/supplier_bloc.dart';
import 'package:inventory_app_revised/data/models/supplier_model.dart';
import 'package:inventory_app_revised/data/repositories/supplier_repository.dart';

class MockSupplierRepository extends Mock implements SupplierRepository {}

void main() {
  late MockSupplierRepository supplierRepository;
  late SupplierBloc supplierBloc;

  // Register fallback values
  setUpAll(() {
    registerFallbackValue(
        SupplierModel(
          id: 'fallback-id',
          name: 'Fallback Supplier',
          address: 'Fallback Address',
          city: 'Fallback City',
          phone: '000-000-0000',
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
    );
  });

  setUp(() {
    supplierRepository = MockSupplierRepository();
    supplierBloc = SupplierBloc(supplierRepository: supplierRepository);
  });

  tearDown(() {
    supplierBloc.close();
  });

  final testSupplier = SupplierModel(
    id: 'test-supplier-id',
    name: 'Test Supplier',
    address: '123 Test St',
    city: 'Test City',
    phone: '123-456-7890',
    email: 'supplier@test.com',
    isActive: true,
    totalOrders: 10,
    totalPurchases: 5000.0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testSuppliers = [testSupplier];

  group('SupplierBloc', () {
    test('initial state is SupplierInitial', () {
      expect(supplierBloc.state, equals(SupplierInitial()));
    });

    blocTest<SupplierBloc, SupplierState>(
      'emits [SupplierLoading, SuppliersLoaded] when LoadSuppliers is added',
      build: () {
        when(() => supplierRepository.getSuppliers(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testSuppliers);

        return supplierBloc;
      },
      act: (bloc) => bloc.add(LoadSuppliers()),
      expect: () => [
        SupplierLoading(),
        isA<SuppliersLoaded>(),
      ],
    );

    blocTest<SupplierBloc, SupplierState>(
      'emits [SupplierLoading, SuppliersLoaded] when SearchSuppliers is added',
      build: () {
        when(() => supplierRepository.getSuppliers(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testSuppliers);

        return supplierBloc;
      },
      act: (bloc) => bloc.add(const SearchSuppliers('Test')),
      expect: () => [
        SupplierLoading(),
        isA<SuppliersLoaded>(),
      ],
    );

    blocTest<SupplierBloc, SupplierState>(
      'emits [SupplierLoading, SupplierError, SupplierLoading, SuppliersLoaded] when AddSupplier fails',
      build: () {
        when(() => supplierRepository.addSupplier(any()))
            .thenThrow(Exception('Failed to add supplier'));

        when(() => supplierRepository.getSuppliers(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testSuppliers);

        return supplierBloc;
      },
      act: (bloc) => bloc.add(AddSupplier(testSupplier)),
      expect: () => [
        SupplierLoading(),
        isA<SupplierError>(),
        SupplierLoading(),
        isA<SuppliersLoaded>(),
      ],
    );
  });
}
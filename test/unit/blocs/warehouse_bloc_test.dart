import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inventory_app_revised/blocs/warehouse/warehouse_bloc.dart';
import 'package:inventory_app_revised/data/models/warehouse_model.dart';
import 'package:inventory_app_revised/data/repositories/warehouse_repository.dart';

class MockWarehouseRepository extends Mock implements WarehouseRepository {}

void main() {
  late MockWarehouseRepository warehouseRepository;
  late WarehouseBloc warehouseBloc;

  // Register fallback values
  setUpAll(() {
    registerFallbackValue(
        WarehouseModel(
          id: 'fallback-id',
          name: 'Fallback Warehouse',
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
    warehouseRepository = MockWarehouseRepository();
    warehouseBloc = WarehouseBloc(warehouseRepository: warehouseRepository);
  });

  tearDown(() {
    warehouseBloc.close();
  });

  final testWarehouse = WarehouseModel(
    id: 'test-warehouse-id',
    name: 'Test Warehouse',
    address: '123 Test St',
    city: 'Test City',
    phone: '123-456-7890',
    email: 'warehouse@test.com',
    isActive: true,
    totalProducts: 100,
    totalValue: 10000.0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testWarehouses = [testWarehouse];

  group('WarehouseBloc', () {
    test('initial state is WarehouseInitial', () {
      expect(warehouseBloc.state, equals(WarehouseInitial()));
    });

    blocTest<WarehouseBloc, WarehouseState>(
      'emits [WarehouseLoading, WarehousesLoaded] when LoadWarehouses is added',
      build: () {
        when(() => warehouseRepository.getWarehouses(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testWarehouses);

        return warehouseBloc;
      },
      act: (bloc) => bloc.add(LoadWarehouses()),
      expect: () => [
        WarehouseLoading(),
        isA<WarehousesLoaded>().having(
                (state) => state.warehouses,
            'warehouses',
            equals(testWarehouses)
        ),
      ],
    );

    blocTest<WarehouseBloc, WarehouseState>(
      'emits [WarehouseLoading, WarehousesLoaded] when SearchWarehouses is added',
      build: () {
        when(() => warehouseRepository.getWarehouses(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testWarehouses);

        return warehouseBloc;
      },
      act: (bloc) => bloc.add(const SearchWarehouses('Test')),
      expect: () => [
        WarehouseLoading(),
        isA<WarehousesLoaded>(),
      ],
    );

    blocTest<WarehouseBloc, WarehouseState>(
      'emits [WarehouseLoading, WarehousesLoaded] when AddWarehouse is successful',
      build: () {
        when(() => warehouseRepository.addWarehouse(any()))
            .thenAnswer((_) async => testWarehouse);

        when(() => warehouseRepository.getWarehouses(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testWarehouses);

        return warehouseBloc;
      },
      act: (bloc) => bloc.add(AddWarehouse(testWarehouse)),
      expect: () => [
        WarehouseLoading(),
        isA<WarehousesLoaded>(),
      ],
      verify: (_) {
        verify(() => warehouseRepository.addWarehouse(any())).called(1);
      },
    );

    blocTest<WarehouseBloc, WarehouseState>(
      'emits [WarehouseLoading, WarehouseError] when LoadWarehouses fails',
      build: () {
        when(() => warehouseRepository.getWarehouses(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenThrow(Exception('Failed to load warehouses'));

        return warehouseBloc;
      },
      act: (bloc) => bloc.add(LoadWarehouses()),
      expect: () => [
        WarehouseLoading(),
        isA<WarehouseError>(),
      ],
    );
  });
}
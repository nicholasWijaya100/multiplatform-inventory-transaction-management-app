import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inventory_app_revised/blocs/product/product_bloc.dart';
import 'package:inventory_app_revised/blocs/warehouse/warehouse_bloc.dart';
import 'package:inventory_app_revised/data/models/product_model.dart';
import 'package:inventory_app_revised/data/repositories/activity_repository.dart';
import 'package:inventory_app_revised/data/repositories/product_repository.dart';

class MockProductRepository extends Mock implements ProductRepository {}
class MockWarehouseBloc extends Mock implements WarehouseBloc {}
class MockActivityRepository extends Mock implements ActivityRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
        ProductModel(
          id: 'fallback-id',
          name: 'Fallback Product',
          category: 'Fallback Category',
          price: 0.0,
          quantity: 0,
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
    );

    // Also register LoadWarehouses event for when we verify warehouseBloc.add()
    registerFallbackValue(LoadWarehouses());
  });

  late MockProductRepository productRepository;
  late MockWarehouseBloc warehouseBloc;
  late MockActivityRepository activityRepository;
  late ProductBloc productBloc;
  final String currentUserId = 'test-user-id';

  setUp(() {
    productRepository = MockProductRepository();
    warehouseBloc = MockWarehouseBloc();
    activityRepository = MockActivityRepository();

    productBloc = ProductBloc(
      productRepository: productRepository,
      warehouseBloc: warehouseBloc,
      activityRepository: activityRepository,
      currentUserId: currentUserId,
    );
  });

  tearDown(() {
    productBloc.close();
  });

  final testProduct = ProductModel(
    id: 'test-product-id',
    name: 'Test Product',
    category: 'Test Category',
    price: 19.99,
    quantity: 50,
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testProducts = [testProduct];

  group('ProductBloc', () {
    test('initial state is ProductInitial', () {
      expect(productBloc.state, equals(ProductInitial()));
    });

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductsLoaded] when LoadProducts is added',
      build: () {
        when(() => productRepository.getProducts(
          searchQuery: any(named: 'searchQuery'),
          categoryFilter: any(named: 'categoryFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testProducts);

        when(() => productRepository.getCategories())
            .thenAnswer((_) async => ['Test Category']);

        return productBloc;
      },
      act: (bloc) => bloc.add(LoadProducts()),
      expect: () => [
        ProductLoading(),
        isA<ProductsLoaded>(),
      ],
      verify: (_) {
        verify(() => productRepository.getProducts(
          searchQuery: null,
          categoryFilter: null,
          includeInactive: false,
        )).called(1);

        verify(() => productRepository.getCategories()).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductsLoaded] with correct data when SearchProducts is added',
      build: () {
        when(() => productRepository.getProducts(
          searchQuery: any(named: 'searchQuery'),
          categoryFilter: any(named: 'categoryFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testProducts);

        when(() => productRepository.getCategories())
            .thenAnswer((_) async => ['Test Category']);

        return productBloc;
      },
      act: (bloc) => bloc.add(const SearchProducts('Test')),
      expect: () => [
        ProductLoading(),
        isA<ProductsLoaded>(),
      ],
      verify: (_) {
        verify(() => productRepository.getProducts(
          searchQuery: 'Test',
          categoryFilter: null,
          includeInactive: false,
        )).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductsLoaded] when AddProduct is added',
      build: () {
        when(() => productRepository.addProduct(any()))
            .thenAnswer((_) async => testProduct);

        when(() => activityRepository.logActivity(
          userId: any(named: 'userId'),
          action: any(named: 'action'),
          category: any(named: 'category'),
          details: any(named: 'details'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async {});

        when(() => productRepository.getProducts(
          searchQuery: any(named: 'searchQuery'),
          categoryFilter: any(named: 'categoryFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testProducts);

        when(() => productRepository.getCategories())
            .thenAnswer((_) async => ['Test Category']);

        return productBloc;
      },
      act: (bloc) => bloc.add(AddProduct(testProduct)),
      expect: () => [
        ProductLoading(),
        isA<ProductsLoaded>(),
      ],
      verify: (_) {
        verify(() => productRepository.addProduct(testProduct)).called(1);
        verify(() => activityRepository.logActivity(
          userId: currentUserId,
          action: 'Added new product',
          category: 'inventory',
          details: any(named: 'details'),
          metadata: any(named: 'metadata'),
        )).called(1);
        verify(() => warehouseBloc.add(LoadWarehouses())).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'emits [ProductLoading, ProductError] when LoadProducts fails',
      build: () {
        when(() => productRepository.getProducts(
          searchQuery: any(named: 'searchQuery'),
          categoryFilter: any(named: 'categoryFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenThrow(Exception('Failed to load products'));

        return productBloc;
      },
      act: (bloc) => bloc.add(LoadProducts()),
      expect: () => [
        ProductLoading(),
        isA<ProductError>(),
      ],
    );
  });
}
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inventory_app_revised/blocs/category/category_bloc.dart';
import 'package:inventory_app_revised/data/models/category_model.dart';
import 'package:inventory_app_revised/data/repositories/category_repository.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockCategoryRepository categoryRepository;
  late CategoryBloc categoryBloc;

  // Register fallback values
  setUpAll(() {
    registerFallbackValue(
        CategoryModel(
          id: 'fallback-id',
          name: 'Fallback Category',
          description: 'Fallback Description',
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
    );
  });

  setUp(() {
    categoryRepository = MockCategoryRepository();
    categoryBloc = CategoryBloc(categoryRepository: categoryRepository);
  });

  tearDown(() {
    categoryBloc.close();
  });

  final testCategory = CategoryModel(
    id: 'test-category-id',
    name: 'Test Category',
    description: 'Test Description',
    isActive: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    productCount: 5,
  );

  final testCategories = [testCategory];

  group('CategoryBloc', () {
    test('initial state is CategoryInitial', () {
      expect(categoryBloc.state, equals(CategoryInitial()));
    });

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoriesLoaded] when LoadCategories is added',
      build: () {
        when(() => categoryRepository.getCategories(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testCategories);

        return categoryBloc;
      },
      act: (bloc) => bloc.add(LoadCategories()),
      expect: () => [
        CategoryLoading(),
        isA<CategoriesLoaded>().having(
                (state) => state.categories,
            'categories',
            equals(testCategories)
        ),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoriesLoaded] when SearchCategories is added',
      build: () {
        when(() => categoryRepository.getCategories(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testCategories);

        return categoryBloc;
      },
      act: (bloc) => bloc.add(const SearchCategories('Test')),
      expect: () => [
        CategoryLoading(),
        isA<CategoriesLoaded>(),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoriesLoaded] when AddCategory is successful',
      build: () {
        when(() => categoryRepository.addCategory(any()))
            .thenAnswer((_) async => testCategory);

        when(() => categoryRepository.getCategories(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testCategories);

        return categoryBloc;
      },
      act: (bloc) => bloc.add(AddCategory(testCategory)),
      expect: () => [
        CategoryLoading(),
        isA<CategoriesLoaded>(),
      ],
      verify: (_) {
        verify(() => categoryRepository.addCategory(any())).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoryError, CategoryLoading, CategoriesLoaded] when AddCategory fails',
      build: () {
        when(() => categoryRepository.addCategory(any()))
            .thenThrow(Exception('Failed to add category'));

        when(() => categoryRepository.getCategories(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testCategories);

        return categoryBloc;
      },
      act: (bloc) => bloc.add(AddCategory(testCategory)),
      expect: () => [
        CategoryLoading(),
        isA<CategoryError>(),
        CategoryLoading(),
        isA<CategoriesLoaded>(),
      ],
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoriesLoaded] when UpdateCategory is successful',
      build: () {
        when(() => categoryRepository.updateCategory(any()))
            .thenAnswer((_) async {});

        when(() => categoryRepository.getCategories(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testCategories);

        return categoryBloc;
      },
      act: (bloc) => bloc.add(UpdateCategory(testCategory)),
      expect: () => [
        CategoryLoading(),
        isA<CategoriesLoaded>(),
      ],
      verify: (_) {
        verify(() => categoryRepository.updateCategory(any())).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'emits [CategoryLoading, CategoriesLoaded] when UpdateCategoryStatus is successful',
      build: () {
        when(() => categoryRepository.updateCategoryStatus(any(), any()))
            .thenAnswer((_) async {});

        when(() => categoryRepository.getCategories(
          searchQuery: any(named: 'searchQuery'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => testCategories);

        return categoryBloc;
      },
      act: (bloc) => bloc.add(const UpdateCategoryStatus('test-category-id', false)),
      expect: () => [
        CategoryLoading(),
        isA<CategoriesLoaded>(),
      ],
      verify: (_) {
        verify(() => categoryRepository.updateCategoryStatus('test-category-id', false)).called(1);
      },
    );
  });
}
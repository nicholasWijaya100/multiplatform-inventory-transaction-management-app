import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../../lib/data/repositories/product_repository.dart';
import '../../../lib/blocs/product/product_bloc.dart';
import '../../../lib/data/models/product.dart';
import 'product_bloc_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  late ProductBloc productBloc;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    productBloc = ProductBloc(mockRepository);
  });

  tearDown(() {
    productBloc.close();
  });

  test('initial state should be ProductInitial', () {
    expect(productBloc.state, isA<ProductInitial>());
  });

  blocTest<ProductBloc, ProductState>(
    'emits [ProductLoading, ProductsLoaded] when LoadProducts is added',
    build: () {
      when(mockRepository.getProducts())
          .thenAnswer((_) async => <Product>[]);
      return productBloc;
    },
    act: (bloc) => bloc.add(LoadProducts()),
    expect: () => [
      isA<ProductLoading>(),
      isA<ProductsLoaded>(),
    ],
  );
}
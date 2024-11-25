import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../lib/data/repositories/product_repository.dart';
import '../../../lib/data/models/product.dart';
import 'product_repository_test.mocks.dart';

// Define specific mock types for Firebase
@GenerateMocks([], customMocks: [
  MockSpec<FirebaseFirestore>(as: #MockFirestore),
  MockSpec<CollectionReference<Map<String, dynamic>>>(
    as: #MockProductCollection,
  ),
  MockSpec<DocumentReference<Map<String, dynamic>>>(
    as: #MockProductDocument,
  ),
  MockSpec<DocumentSnapshot<Map<String, dynamic>>>(
    as: #MockProductSnapshot,
  ),
  MockSpec<QuerySnapshot<Map<String, dynamic>>>(
    as: #MockProductQuerySnapshot,
  ),
  MockSpec<QueryDocumentSnapshot<Map<String, dynamic>>>(
    as: #MockProductQueryDocSnapshot,
  ),
])
void main() {
  late ProductRepository productRepository;
  late MockFirestore mockFirestore;
  late MockProductCollection mockCollection;
  late MockProductDocument mockDocument;
  late MockProductQuerySnapshot mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirestore();
    mockCollection = MockProductCollection();
    mockDocument = MockProductDocument();
    mockQuerySnapshot = MockProductQuerySnapshot();
    productRepository = ProductRepository(firestore: mockFirestore);

    // Setup default responses for common calls
    when(mockFirestore.collection('products')).thenReturn(mockCollection);
  });

  group('ProductRepository', () {
    final testProduct = Product(
      id: 'test-id',
      name: 'Test Product',
      price: 99.99,
      quantity: 10,
      category: 'Test Category',
      description: 'Test Description',
    );

    test('getProducts returns list of products', () async {
      // Arrange
      final mockDocSnapshot = MockProductQueryDocSnapshot();
      final mockDocs = [mockDocSnapshot];

      when(mockCollection.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);
      when(mockDocSnapshot.data())
          .thenReturn(testProduct.toJson());
      when(mockDocSnapshot.id).thenReturn('test-id');

      // Act
      final products = await productRepository.getProducts();

      // Assert
      expect(products, isA<List<Product>>());
      expect(products.length, 1);
      expect(products.first.id, testProduct.id);
      verify(mockFirestore.collection('products')).called(1);
      verify(mockCollection.get()).called(1);
    });

    test('getProductById returns specific product', () async {
      // Arrange
      final mockDocSnapshot = MockProductSnapshot();

      when(mockCollection.doc('test-id'))
          .thenReturn(mockDocument);
      when(mockDocument.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.data())
          .thenReturn(testProduct.toJson());

      // Act
      final product = await productRepository.getProductById('test-id');

      // Assert
      expect(product, isA<Product>());
      expect(product.id, testProduct.id);
      expect(product.name, testProduct.name);
      verify(mockCollection.doc('test-id')).called(1);
    });

    test('getProductById throws exception when product not found', () async {
      // Arrange
      final mockDocSnapshot = MockProductSnapshot();

      when(mockCollection.doc('test-id'))
          .thenReturn(mockDocument);
      when(mockDocument.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false);

      // Act & Assert
      expect(
            () => productRepository.getProductById('test-id'),
        throwsA(isA<Exception>()),
      );
    });

    test('addProduct successfully adds product', () async {
      // Arrange
      when(mockCollection.add(any))
          .thenAnswer((_) async => mockDocument);
      when(mockDocument.id).thenReturn('new-test-id');

      // Act
      final result = await productRepository.addProduct(testProduct);

      // Assert
      expect(result, isA<Product>());
      expect(result.id, 'new-test-id');
      verify(mockCollection.add(any)).called(1);
    });

    test('updateProduct successfully updates product', () async {
      // Arrange
      when(mockCollection.doc(testProduct.id))
          .thenReturn(mockDocument);
      when(mockDocument.update(any))
          .thenAnswer((_) async => {});

      // Act
      await productRepository.updateProduct(testProduct);

      // Assert
      verify(mockDocument.update(any)).called(1);
    });

    test('deleteProduct successfully deletes product', () async {
      // Arrange
      when(mockCollection.doc('test-id'))
          .thenReturn(mockDocument);
      when(mockDocument.delete())
          .thenAnswer((_) async => {});

      // Act
      await productRepository.deleteProduct('test-id');

      // Assert
      verify(mockDocument.delete()).called(1);
    });

    test('getProductsStream emits list of products', () async {
      // Arrange
      final mockDocSnapshot = MockProductQueryDocSnapshot();
      final mockDocs = [mockDocSnapshot];
      final mockSnapshot = MockProductQuerySnapshot();

      when(mockCollection.snapshots())
          .thenAnswer((_) => Stream.value(mockSnapshot));
      when(mockSnapshot.docs).thenReturn(mockDocs);
      when(mockDocSnapshot.data())
          .thenReturn(testProduct.toJson());
      when(mockDocSnapshot.id).thenReturn('test-id');

      // Act & Assert
      expect(
        productRepository.getProductsStream(),
        emits(isA<List<Product>>()),
      );
    });
  });

  group('ProductRepository Integration Tests', () {
    late ProductRepository productRepository;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      productRepository = ProductRepository(firestore: fakeFirestore);
    });

    test('Integration - full CRUD operations', () async {
      // Test adding a product
      final newProduct = Product(
        id: '',
        name: 'Integration Test Product',
        price: 49.99,
        quantity: 5,
        category: 'Test',
      );

      final addedProduct = await productRepository.addProduct(newProduct);
      expect(addedProduct.id, isNotEmpty);
      expect(addedProduct.name, newProduct.name);

      // Test getting the product
      final fetchedProduct = await productRepository.getProductById(addedProduct.id);
      expect(fetchedProduct.id, addedProduct.id);
      expect(fetchedProduct.name, addedProduct.name);

      // Test updating the product
      final updatedProduct = addedProduct.copyWith(name: 'Updated Name');
      await productRepository.updateProduct(updatedProduct);

      final fetchedUpdatedProduct = await productRepository.getProductById(addedProduct.id);
      expect(fetchedUpdatedProduct.name, 'Updated Name');

      // Test deleting the product
      await productRepository.deleteProduct(addedProduct.id);

      expect(
            () => productRepository.getProductById(addedProduct.id),
        throwsA(isA<Exception>()),
      );
    });
  });
}
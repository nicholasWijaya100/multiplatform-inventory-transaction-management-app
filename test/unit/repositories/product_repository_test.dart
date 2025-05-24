import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:inventory_app_revised/data/models/product_model.dart';
import 'package:inventory_app_revised/data/repositories/product_repository.dart';

// For complex Firestore operations, use fake_cloud_firestore instead of mocks
void main() {
  late ProductRepository productRepository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    productRepository = ProductRepository(firestore: fakeFirestore);

    // Add test data to fake Firestore
    fakeFirestore.collection('products').doc('test-product-id').set({
      'name': 'Test Product',
      'category': 'Test Category',
      'price': 19.99,
      'quantity': 50,
      'isActive': true,
      'description': 'Test description',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'warehouseStock': <String, int>{'warehouse1': 20, 'warehouse2': 30}, // Explicitly typed
    });

    // Add another product for search test
    fakeFirestore.collection('products').doc('another-product-id').set({
      'name': 'Another Product',
      'category': 'Test Category',
      'price': 29.99,
      'quantity': 30,
      'isActive': true,
      'description': 'Another description',
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
      'warehouseStock': <String, int>{}, // Empty but typed map
    });

    fakeFirestore.collection('categories').doc('test-category-id').set({
      'name': 'Test Category',
      'isActive': true,
    });
  });

  group('ProductRepository', () {
    test('getProduct returns ProductModel when product exists', () async {
      final product = await productRepository.getProduct('test-product-id');

      expect(product, isNotNull);
      expect(product.id, equals('test-product-id'));
      expect(product.name, equals('Test Product'));
      expect(product.category, equals('Test Category'));
      expect(product.price, equals(19.99));
      expect(product.quantity, equals(50));
      expect(product.isActive, isTrue);
    });

    test('getProduct throws exception when product does not exist', () async {
      expect(
            () => productRepository.getProduct('non-existent-id'),
        throwsA(isA<Exception>()),
      );
    });

    test('getProducts returns list of products', () async {
      final products = await productRepository.getProducts();

      expect(products, isNotEmpty);
      expect(products.length, equals(2)); // Both products should be returned
      expect(products.any((p) => p.name == 'Test Product'), isTrue);
      expect(products.any((p) => p.name == 'Another Product'), isTrue);
    });

    test('getProducts with search query returns filtered products', () async {
      final products = await productRepository.getProducts(searchQuery: 'Another');

      expect(products, isNotEmpty);
      expect(products.length, equals(1));
      expect(products.first.name, equals('Another Product'));
    });

    test('getCategories returns list of category names', () async {
      final categories = await productRepository.getCategories();

      expect(categories, isNotEmpty);
      expect(categories.first, equals('Test Category'));
    });

    test('addProduct adds product and returns ProductModel', () async {
      final newProduct = ProductModel(
        id: '',  // Will be set by Firestore
        name: 'New Product',
        category: 'Test Category',
        price: 24.99,
        quantity: 40,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final addedProduct = await productRepository.addProduct(newProduct);

      expect(addedProduct, isNotNull);
      expect(addedProduct.id, isNotEmpty);
      expect(addedProduct.name, equals('New Product'));

      // Verify product was added to Firestore
      final docSnapshot = await fakeFirestore.collection('products').doc(addedProduct.id).get();
      expect(docSnapshot.exists, isTrue);
      expect(docSnapshot.data()!['name'], equals('New Product'));
    });

    test('updateProductStatus updates product status', () async {
      await productRepository.updateProductStatus('test-product-id', false);

      final docSnapshot = await fakeFirestore.collection('products').doc('test-product-id').get();
      expect(docSnapshot.data()!['isActive'], isFalse);
    });

    test('updateStock updates warehouse stock for product', () async {
      await productRepository.updateStock('test-product-id', 'warehouse1', 25);

      final docSnapshot = await fakeFirestore.collection('products').doc('test-product-id').get();
      final warehouseStock = docSnapshot.data()!['warehouseStock'] as Map<String, dynamic>;

      expect(warehouseStock['warehouse1'], equals(25));
    });
  });
}
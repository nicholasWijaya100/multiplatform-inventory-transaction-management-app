import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ProductModel>> getProducts({
    String? searchQuery,
    String? categoryFilter,
    bool includeInactive = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('products')
          .orderBy('name');

      if (!includeInactive) {
        query = query.where('isActive', isEqualTo: true);
      }

      if (categoryFilter != null && categoryFilter.isNotEmpty) {
        query = query.where('category', isEqualTo: categoryFilter);
      }

      final querySnapshot = await query.get();
      final products = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return products.where((product) {
          return product.name.toLowerCase().contains(searchLower) ||
              (product.description?.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      }

      return products;
    } catch (e) {
      throw Exception('Failed to fetch products: ${e.toString()}');
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList()
        ..sort(); // Sort categories alphabetically
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final docRef = await _firestore.collection('products').add({
        ...product.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final newDoc = await docRef.get();
      return ProductModel.fromJson(newDoc.data()!..['id'] = newDoc.id);
    } catch (e) {
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection('products').doc(product.id).update({
        ...product.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  Future<void> updateProductStatus(String productId, bool isActive) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product status: ${e.toString()}');
    }
  }

  Future<void> updateStock(String productId, String warehouseId, int quantity) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'warehouseStock.$warehouseId': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update stock: ${e.toString()}');
    }
  }

  Stream<List<ProductModel>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }).toList();
    });
  }
}
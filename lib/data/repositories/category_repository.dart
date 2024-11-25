import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<CategoryModel>> getCategories({
    String? searchQuery,
    bool includeInactive = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('categories')
          .orderBy('name');

      if (!includeInactive) {
        query = query.where('isActive', isEqualTo: true);
      }

      final querySnapshot = await query.get();
      final categories = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Handle timestamps if they don't exist
        if (!data.containsKey('createdAt')) {
          data['createdAt'] = Timestamp.now();
        }
        if (!data.containsKey('updatedAt')) {
          data['updatedAt'] = Timestamp.now();
        }

        return CategoryModel.fromJson(data);
      }).toList();

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return categories.where((category) {
          return category.name.toLowerCase().contains(searchLower) ||
              category.description.toLowerCase().contains(searchLower);
        }).toList();
      }

      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  Future<CategoryModel> addCategory(CategoryModel category) async {
    try {
      final docRef = await _firestore.collection('categories').add({
        'name': category.name,
        'description': category.description,
        'isActive': category.isActive,
        'productCount': category.productCount,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final newDoc = await docRef.get();
      final data = newDoc.data()!;
      data['id'] = newDoc.id;

      // Wait for server timestamp to be available
      while (data['createdAt'] == null || data['updatedAt'] == null) {
        await Future.delayed(const Duration(milliseconds: 100));
        final refreshDoc = await docRef.get();
        data['createdAt'] = refreshDoc.data()!['createdAt'];
        data['updatedAt'] = refreshDoc.data()!['updatedAt'];
      }

      return CategoryModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add category: ${e.toString()}');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore.collection('categories').doc(category.id).update({
        'name': category.name,
        'description': category.description,
        'isActive': category.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update category: ${e.toString()}');
    }
  }

  Future<void> updateCategoryStatus(String categoryId, bool isActive) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update category status: ${e.toString()}');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      // Check if category has products
      final productsQuery = await _firestore
          .collection('products')
          .where('category', isEqualTo: categoryId)
          .get();

      if (productsQuery.docs.isNotEmpty) {
        throw Exception('Cannot delete category with existing products');
      }

      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }

  Stream<List<CategoryModel>> getCategoriesStream() {
    return _firestore
        .collection('categories')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;

        // Handle timestamps if they don't exist
        if (!data.containsKey('createdAt')) {
          data['createdAt'] = Timestamp.now();
        }
        if (!data.containsKey('updatedAt')) {
          data['updatedAt'] = Timestamp.now();
        }

        return CategoryModel.fromJson(data);
      }).toList();
    });
  }
}
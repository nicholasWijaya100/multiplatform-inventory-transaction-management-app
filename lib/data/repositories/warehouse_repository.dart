import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/warehouse_model.dart';

class WarehouseRepository {
  final FirebaseFirestore _firestore;

  WarehouseRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<WarehouseModel>> getWarehouses({
    String? searchQuery,
    bool includeInactive = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('warehouses')
          .orderBy('name');

      if (!includeInactive) {
        query = query.where('isActive', isEqualTo: true);
      }

      final warehouseSnapshot = await query.get();
      final productSnapshot = await _firestore.collection('products').get();

      // Get all products to calculate warehouse totals
      final products = productSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }).toList();

      // Calculate totals for each warehouse
      return await Future.wait(warehouseSnapshot.docs.map((doc) async {
        final data = doc.data();
        data['id'] = doc.id;

        // Calculate totals for this warehouse
        int totalProducts = 0;
        double totalValue = 0;

        for (final product in products) {
          final stockInWarehouse = product.warehouseStock[doc.id] ?? 0;
          if (stockInWarehouse > 0) {
            totalProducts += stockInWarehouse;
            totalValue += stockInWarehouse * product.price;
          }
        }

        // Update the data with calculated totals
        data['totalProducts'] = totalProducts;
        data['totalValue'] = totalValue;

        // Update these values in Firestore
        await doc.reference.update({
          'totalProducts': totalProducts,
          'totalValue': totalValue,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return WarehouseModel.fromJson(data);
      }));
    } catch (e) {
      throw Exception('Failed to fetch warehouses: ${e.toString()}');
    }
  }

  Future<WarehouseModel> getWarehouse(String warehouseId) async {
    try {
      final doc = await _firestore.collection('warehouses').doc(warehouseId).get();

      if (!doc.exists) {
        throw Exception('Warehouse not found');
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      // Calculate totals for this warehouse
      final productSnapshot = await _firestore.collection('products').get();
      final products = productSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ProductModel.fromJson(data);
      }).toList();

      int totalProducts = 0;
      double totalValue = 0;

      for (final product in products) {
        final stockInWarehouse = product.warehouseStock[warehouseId] ?? 0;
        if (stockInWarehouse > 0) {
          totalProducts += stockInWarehouse;
          totalValue += stockInWarehouse * product.price;
        }
      }

      data['totalProducts'] = totalProducts;
      data['totalValue'] = totalValue;

      return WarehouseModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch warehouse: ${e.toString()}');
    }
  }

  Future<WarehouseModel> addWarehouse(WarehouseModel warehouse) async {
    try {
      final docRef = await _firestore.collection('warehouses').add({
        'name': warehouse.name,
        'address': warehouse.address,
        'city': warehouse.city,
        'phone': warehouse.phone,
        'email': warehouse.email,
        'description': warehouse.description,
        'isActive': warehouse.isActive,
        'totalProducts': warehouse.totalProducts,
        'totalValue': warehouse.totalValue,
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

      return WarehouseModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add warehouse: ${e.toString()}');
    }
  }

  Future<void> updateWarehouse(WarehouseModel warehouse) async {
    try {
      await _firestore.collection('warehouses').doc(warehouse.id).update({
        'name': warehouse.name,
        'address': warehouse.address,
        'city': warehouse.city,
        'phone': warehouse.phone,
        'email': warehouse.email,
        'description': warehouse.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update warehouse: ${e.toString()}');
    }
  }

  Future<void> updateWarehouseStatus(String warehouseId, bool isActive) async {
    try {
      await _firestore.collection('warehouses').doc(warehouseId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update warehouse status: ${e.toString()}');
    }
  }

  Future<void> deleteWarehouse(String warehouseId) async {
    try {
      // Check if warehouse has products
      final productsQuery = await _firestore
          .collection('products')
          .where('warehouseId', isEqualTo: warehouseId)
          .get();

      if (productsQuery.docs.isNotEmpty) {
        throw Exception('Cannot delete warehouse with existing products');
      }

      await _firestore.collection('warehouses').doc(warehouseId).delete();
    } catch (e) {
      throw Exception('Failed to delete warehouse: ${e.toString()}');
    }
  }

  Stream<List<WarehouseModel>> getWarehousesStream() {
    return _firestore.collection('warehouses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WarehouseModel.fromJson(data);
      }).toList();
    });
  }

  Future<void> updateWarehouseStats(String warehouseId) async {
    try {
      // Calculate total products and value
      final productsQuery = await _firestore
          .collection('products')
          .where('warehouseId', isEqualTo: warehouseId)
          .get();

      int totalProducts = 0;
      double totalValue = 0.0;

      for (var doc in productsQuery.docs) {
        final data = doc.data();
        totalProducts += (data['quantity'] as num).toInt();
        totalValue += (data['quantity'] as num).toDouble() *
            (data['price'] as num).toDouble();
      }

      await _firestore.collection('warehouses').doc(warehouseId).update({
        'totalProducts': totalProducts,
        'totalValue': totalValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update warehouse stats: ${e.toString()}');
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supplier_model.dart';

class SupplierRepository {
  final FirebaseFirestore _firestore;

  SupplierRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<SupplierModel>> getSuppliers({
    String? searchQuery,
    bool includeInactive = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('suppliers')
          .orderBy('name');

      if (!includeInactive) {
        query = query.where('isActive', isEqualTo: true);
      }

      final querySnapshot = await query.get();
      final suppliers = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SupplierModel.fromJson(data);
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return suppliers.where((supplier) {
          return supplier.name.toLowerCase().contains(searchLower) ||
              supplier.city.toLowerCase().contains(searchLower);
        }).toList();
      }

      return suppliers;
    } catch (e) {
      throw Exception('Failed to fetch suppliers: ${e.toString()}');
    }
  }

  Future<SupplierModel> addSupplier(SupplierModel supplier) async {
    try {
      final docRef = await _firestore.collection('suppliers').add({
        'name': supplier.name,
        'address': supplier.address,
        'city': supplier.city,
        'phone': supplier.phone,
        'email': supplier.email,
        'description': supplier.description,
        'isActive': supplier.isActive,
        'totalOrders': supplier.totalOrders,
        'totalPurchases': supplier.totalPurchases,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final newDoc = await docRef.get();
      final data = newDoc.data()!;
      data['id'] = newDoc.id;

      return SupplierModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add supplier: ${e.toString()}');
    }
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    try {
      await _firestore.collection('suppliers').doc(supplier.id).update({
        'name': supplier.name,
        'address': supplier.address,
        'city': supplier.city,
        'phone': supplier.phone,
        'email': supplier.email,
        'description': supplier.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update supplier: ${e.toString()}');
    }
  }

  Future<void> updateSupplierStatus(String supplierId, bool isActive) async {
    try {
      await _firestore.collection('suppliers').doc(supplierId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update supplier status: ${e.toString()}');
    }
  }

  Future<void> updateSupplierPurchaseStats(String supplierId, double amount) async {
    try {
      final supplierDoc = await _firestore.collection('suppliers').doc(supplierId).get();
      if (!supplierDoc.exists) {
        throw Exception('Supplier not found');
      }

      final currentOrders = (supplierDoc.data()?['totalOrders'] as num?)?.toInt() ?? 0;
      final currentPurchases = (supplierDoc.data()?['totalPurchases'] as num?)?.toDouble() ?? 0.0;

      await _firestore.collection('suppliers').doc(supplierId).update({
        'totalOrders': currentOrders + 1,
        'totalPurchases': currentPurchases + amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update supplier purchase stats: ${e.toString()}');
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    try {
      // Check if supplier has orders
      final ordersQuery = await _firestore
          .collection('purchase_orders')
          .where('supplierId', isEqualTo: supplierId)
          .get();

      if (ordersQuery.docs.isNotEmpty) {
        throw Exception('Cannot delete supplier with existing orders');
      }

      await _firestore.collection('suppliers').doc(supplierId).delete();
    } catch (e) {
      throw Exception('Failed to delete supplier: ${e.toString()}');
    }
  }

  Stream<List<SupplierModel>> getSuppliersStream() {
    return _firestore
        .collection('suppliers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SupplierModel.fromJson(data);
      }).toList();
    });
  }
}
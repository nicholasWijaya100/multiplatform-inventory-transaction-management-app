import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/purchase_order_model.dart';

class PurchaseRepository {
  final FirebaseFirestore _firestore;

  PurchaseRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<PurchaseOrderModel>> getPurchaseOrders({
    String? searchQuery,
    String? supplierFilter,
    String? statusFilter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('purchase_orders')
          .orderBy('createdAt', descending: true);

      if (supplierFilter != null) {
        query = query.where('supplierId', isEqualTo: supplierFilter);
      }

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }

      final querySnapshot = await query.get();
      final orders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PurchaseOrderModel.fromJson(data);
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return orders.where((order) {
          return order.supplierName.toLowerCase().contains(searchLower) ||
              order.id.toLowerCase().contains(searchLower) ||
              order.notes?.toLowerCase().contains(searchLower) == true;
        }).toList();
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch purchase orders: ${e.toString()}');
    }
  }

  Future<PurchaseOrderModel> addPurchaseOrder(PurchaseOrderModel order) async {
    try {
      final docRef = await _firestore.collection('purchase_orders').add(
        order.toFirestore(),
      );

      final newDoc = await docRef.get();
      final data = newDoc.data()!;
      data['id'] = newDoc.id;
      return PurchaseOrderModel.fromJson(data);
    } catch (e) {
      print('Error adding purchase order: $e');
      throw Exception('Failed to add purchase order: ${e.toString()}');
    }
  }

  Future<void> updatePurchaseOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('purchase_orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'received') 'receivedDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update purchase order status: ${e.toString()}');
    }
  }

  Future<void> markAsPaid(String orderId) async {
    try {
      await _firestore.collection('purchase_orders').doc(orderId).update({
        'isPaid': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark purchase order as paid: ${e.toString()}');
    }
  }

  Stream<List<PurchaseOrderModel>> getPurchaseOrdersStream() {
    return _firestore
        .collection('purchase_orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PurchaseOrderModel.fromJson(data);
      }).toList();
    });
  }
}
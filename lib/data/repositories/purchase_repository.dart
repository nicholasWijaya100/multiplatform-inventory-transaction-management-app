import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/id_generator.dart';
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
      // Generate custom purchase order ID
      final customId = IdGenerator.generatePurchaseOrderId();

      // Create a document with the custom ID
      final docRef = _firestore.collection('purchase_orders').doc(customId);

      // Set the data with the custom ID
      await docRef.set({
        ...order.toFirestore(),
        'customId': customId,  // Store the custom ID in the document as well
      });

      final newDoc = await docRef.get();
      final data = newDoc.data()!;
      data['id'] = customId;  // Use the custom ID
      return PurchaseOrderModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add purchase order: ${e.toString()}');
    }
  }

  Future<void> updatePurchaseOrderStatus(
      String orderId,
      String status,
      [String? warehouseId]
      ) async {
    try {
      final updateData = {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status == 'received') {
        updateData['receivedDate'] = FieldValue.serverTimestamp();
        if (warehouseId != null) {
          updateData['receivingWarehouseId'] = warehouseId;
        }
      }

      await _firestore.collection('purchase_orders').doc(orderId).update(updateData);
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

  Future<void> updatePurchaseOrderPaymentStatus(String orderId, bool isPaid) async {
    try {
      await _firestore.collection('purchase_orders').doc(orderId).update({
        'isPaid': isPaid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update purchase order payment status: ${e.toString()}');
    }
  }

  Future<PurchaseOrderModel> getPurchaseOrder(String orderId) async {
    try {
      final docSnapshot = await _firestore
          .collection('purchase_orders')
          .doc(orderId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Purchase order not found');
      }

      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      return PurchaseOrderModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch purchase order: ${e.toString()}');
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
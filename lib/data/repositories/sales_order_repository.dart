import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/id_generator.dart';
import '../models/sales_order_model.dart';

class SalesOrderRepository {
  final FirebaseFirestore _firestore;

  SalesOrderRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<SalesOrderModel>> getSalesOrders({
    String? searchQuery,
    String? customerFilter,
    String? statusFilter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('sales_orders')
          .orderBy('createdAt', descending: true);

      if (customerFilter != null) {
        query = query.where('customerId', isEqualTo: customerFilter);
      }

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }

      final querySnapshot = await query.get();
      final orders = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SalesOrderModel.fromJson(data);
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return orders.where((order) {
          return order.customerName.toLowerCase().contains(searchLower) ||
              order.id.toLowerCase().contains(searchLower) ||
              order.notes?.toLowerCase().contains(searchLower) == true;
        }).toList();
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch sales orders: ${e.toString()}');
    }
  }

  Future<SalesOrderModel> addSalesOrder(SalesOrderModel order) async {
    try {
      // Generate custom sales order ID
      final customId = IdGenerator.generateSalesOrderId();

      // Create a document with the custom ID
      final docRef = _firestore.collection('sales_orders').doc(customId);

      // Set the data with the custom ID
      await docRef.set({
        ...order.toFirestore(),
        'customId': customId,  // Store the custom ID in the document as well
      });

      final newDoc = await docRef.get();
      final data = newDoc.data()!;
      data['id'] = customId;  // Use the custom ID
      return SalesOrderModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add sales order: ${e.toString()}');
    }
  }

  Future<void> updateSalesOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('sales_orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'shipped') 'shippedDate': FieldValue.serverTimestamp(),
        if (status == 'delivered') 'deliveryDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update sales order status: ${e.toString()}');
    }
  }

  Future<void> updateSalesOrderPaymentStatus(String orderId, bool isPaid) async {
    try {
      await _firestore.collection('sales_orders').doc(orderId).update({
        'isPaid': isPaid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update sales order payment status: ${e.toString()}');
    }
  }

  Stream<List<SalesOrderModel>> getSalesOrdersStream() {
    return _firestore
        .collection('sales_orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SalesOrderModel.fromJson(data);
      }).toList();
    });
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore;

  CustomerRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<CustomerModel>> getCustomers({
    String? searchQuery,
    bool includeInactive = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('customers')
          .orderBy('name');

      if (!includeInactive) {
        query = query.where('isActive', isEqualTo: true);
      }

      final querySnapshot = await query.get();
      final customers = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CustomerModel.fromJson(data);
      }).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return customers.where((customer) {
          return customer.name.toLowerCase().contains(searchLower) ||
              customer.city.toLowerCase().contains(searchLower) ||
              customer.email?.toLowerCase().contains(searchLower) == true;
        }).toList();
      }

      return customers;
    } catch (e) {
      throw Exception('Failed to fetch customers: ${e.toString()}');
    }
  }

  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    try {
      final docRef = await _firestore.collection('customers').add({
        'name': customer.name,
        'address': customer.address,
        'city': customer.city,
        'phone': customer.phone,
        'email': customer.email,
        'description': customer.description,
        'isActive': customer.isActive,
        'totalOrders': customer.totalOrders,
        'totalPurchases': customer.totalPurchases,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final newDoc = await docRef.get();
      final data = newDoc.data()!;
      data['id'] = newDoc.id;

      return CustomerModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add customer: ${e.toString()}');
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _firestore.collection('customers').doc(customer.id).update({
        'name': customer.name,
        'address': customer.address,
        'city': customer.city,
        'phone': customer.phone,
        'email': customer.email,
        'description': customer.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update customer: ${e.toString()}');
    }
  }

  Future<void> updateCustomerStatus(String customerId, bool isActive) async {
    try {
      await _firestore.collection('customers').doc(customerId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update customer status: ${e.toString()}');
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      // Check if customer has orders
      final ordersQuery = await _firestore
          .collection('sales_orders')
          .where('customerId', isEqualTo: customerId)
          .get();

      if (ordersQuery.docs.isNotEmpty) {
        throw Exception('Cannot delete customer with existing orders');
      }

      await _firestore.collection('customers').doc(customerId).delete();
    } catch (e) {
      throw Exception('Failed to delete customer: ${e.toString()}');
    }
  }
}
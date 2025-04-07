import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  final FirebaseFirestore _firestore;

  InvoiceRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<InvoiceModel>> getInvoices({
    String? searchQuery,
    String? customerFilter,
    String? statusFilter,
    bool includeOverdue = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('invoices')
          .orderBy('createdAt', descending: true);

      if (customerFilter != null) {
        query = query.where('customerId', isEqualTo: customerFilter);
      }

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }

      final querySnapshot = await query.get();
      final invoices = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return InvoiceModel.fromJson(data);
      }).toList();

      // Filter overdue invoices if needed
      if (includeOverdue) {
        return invoices.where((invoice) => invoice.isOverdue).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return invoices.where((invoice) {
          return invoice.customerName.toLowerCase().contains(searchLower) ||
              invoice.id.toLowerCase().contains(searchLower);
        }).toList();
      }

      return invoices;
    } catch (e) {
      throw Exception('Failed to fetch invoices: ${e.toString()}');
    }
  }

  Future<InvoiceModel> addInvoice(InvoiceModel invoice) async {
    try {
      final docRef = await _firestore.collection('invoices').add(
        invoice.toFirestore(),
      );

      final newDoc = await docRef.get();
      final data = newDoc.data()!;
      data['id'] = newDoc.id;
      return InvoiceModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add invoice: ${e.toString()}');
    }
  }

  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    try {
      await _firestore.collection('invoices').doc(invoiceId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update invoice status: ${e.toString()}');
    }
  }

  Future<void> markAsPaid(String invoiceId) async {
    try {
      await _firestore.collection('invoices').doc(invoiceId).update({
        'isPaid': true,
        'paidDate': FieldValue.serverTimestamp(),
        'status': InvoiceStatus.paid.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark invoice as paid: ${e.toString()}');
    }
  }

  Stream<List<InvoiceModel>> getInvoicesStream() {
    return _firestore
        .collection('invoices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return InvoiceModel.fromJson(data);
      }).toList();
    });
  }
}
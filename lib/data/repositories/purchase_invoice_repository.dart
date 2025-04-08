import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/purchase_invoice_model.dart';
import '../../utils/id_generator.dart';

class PurchaseInvoiceRepository {
  final FirebaseFirestore _firestore;

  PurchaseInvoiceRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<PurchaseInvoiceModel>> getPurchaseInvoices({
    String? searchQuery,
    String? supplierFilter,
    String? statusFilter,
    bool includeOverdue = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('purchase_invoices')
          .orderBy('createdAt', descending: true);

      if (supplierFilter != null) {
        query = query.where('supplierId', isEqualTo: supplierFilter);
      }

      if (statusFilter != null) {
        query = query.where('status', isEqualTo: statusFilter);
      }

      final querySnapshot = await query.get();
      final invoices = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PurchaseInvoiceModel.fromJson(data);
      }).toList();

      // Filter overdue invoices if needed
      if (includeOverdue) {
        return invoices.where((invoice) => invoice.isOverdue).toList();
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return invoices.where((invoice) {
          return invoice.supplierName.toLowerCase().contains(searchLower) ||
              invoice.id.toLowerCase().contains(searchLower) ||
              (invoice.invoiceNumber?.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      }

      return invoices;
    } catch (e) {
      throw Exception('Failed to fetch purchase invoices: ${e.toString()}');
    }
  }

  Future<PurchaseInvoiceModel> getPurchaseInvoice(String invoiceId) async {
    try {
      final docSnapshot = await _firestore
          .collection('purchase_invoices')
          .doc(invoiceId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Purchase invoice not found');
      }

      final data = docSnapshot.data()!;
      data['id'] = docSnapshot.id;
      return PurchaseInvoiceModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch purchase invoice: ${e.toString()}');
    }
  }

  Future<PurchaseInvoiceModel> addPurchaseInvoice(PurchaseInvoiceModel invoice) async {
    try {
      // Generate custom invoice ID
      final customId = IdGenerator.generatePurchaseInvoiceId();

      // Create a document with the custom ID
      final docRef = _firestore.collection('purchase_invoices').doc(customId);

      // Set the data with the custom ID
      await docRef.set({
        ...invoice.toFirestore(),
        'customId': customId,
      });

      final newDoc = await docRef.get();
      final data = newDoc.data()!;
      data['id'] = customId;
      return PurchaseInvoiceModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to add purchase invoice: ${e.toString()}');
    }
  }

  Future<void> updatePurchaseInvoiceStatus(String invoiceId, String status) async {
    try {
      await _firestore.collection('purchase_invoices').doc(invoiceId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update purchase invoice status: ${e.toString()}');
    }
  }

  Future<void> markAsPaid(String invoiceId) async {
    try {
      await _firestore.collection('purchase_invoices').doc(invoiceId).update({
        'isPaid': true,
        'paidDate': FieldValue.serverTimestamp(),
        'status': PurchaseInvoiceStatus.paid.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark purchase invoice as paid: ${e.toString()}');
    }
  }

  Stream<List<PurchaseInvoiceModel>> getPurchaseInvoicesStream() {
    return _firestore
        .collection('purchase_invoices')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PurchaseInvoiceModel.fromJson(data);
      }).toList();
    });
  }
}
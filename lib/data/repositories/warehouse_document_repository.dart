import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/warehouse_document_model.dart';

class WarehouseDocumentRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'warehouse_documents';

  WarehouseDocumentRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  // Generate document number based on type
  Future<String> _generateDocumentNumber(WarehouseDocumentType type) async {
    final year = DateTime.now().year;
    final month = DateTime.now().month.toString().padLeft(2, '0');
    final prefix = type == WarehouseDocumentType.entryWaybill ? 'EW' : 'DN';

    // Get the count of documents for this month
    final querySnapshot = await _firestore
        .collection(_collection)
        .where('type', isEqualTo: type.name)
        .where('createdAt', isGreaterThanOrEqualTo: DateTime(year, DateTime.now().month))
        .where('createdAt', isLessThan: DateTime(year, DateTime.now().month + 1))
        .get();

    final count = querySnapshot.docs.length + 1;
    final number = count.toString().padLeft(4, '0');

    return '$prefix-$year$month-$number';
  }

  // Create a new warehouse document
  Future<WarehouseDocumentModel> createDocument(WarehouseDocumentModel document) async {
    try {
      // Generate document number
      final documentNumber = await _generateDocumentNumber(document.type);

      final updatedDocument = document.copyWith(documentNumber: documentNumber);

      final docRef = await _firestore.collection(_collection).add(
        updatedDocument.toFirestore(),
      );

      return updatedDocument.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to create warehouse document: $e');
    }
  }

  // Get all warehouse documents
  Future<List<WarehouseDocumentModel>> getDocuments({
    WarehouseDocumentType? type,
    String? warehouseId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (warehouseId != null) {
        query = query.where('warehouseId', isEqualTo: warehouseId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('createdAt', descending: true);

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => WarehouseDocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get warehouse documents: $e');
    }
  }

  // Get a single document by ID
  Future<WarehouseDocumentModel> getDocument(String documentId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(documentId).get();

      if (!doc.exists) {
        throw Exception('Document not found');
      }

      return WarehouseDocumentModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get warehouse document: $e');
    }
  }

  // Update document status
  Future<void> updateDocumentStatus(String documentId, WarehouseDocumentStatus status) async {
    try {
      final Map<String, dynamic> updates = {
        'status': status.name,
      };

      if (status == WarehouseDocumentStatus.completed) {
        updates['completedAt'] = Timestamp.now();
      }

      await _firestore.collection(_collection).doc(documentId).update(updates);
    } catch (e) {
      throw Exception('Failed to update document status: $e');
    }
  }

  // Update entire document
  Future<void> updateDocument(String documentId, WarehouseDocumentModel document) async {
    try {
      await _firestore.collection(_collection).doc(documentId).update(
        document.toFirestore(),
      );
    } catch (e) {
      throw Exception('Failed to update warehouse document: $e');
    }
  }

  // Delete document
  Future<void> deleteDocument(String documentId) async {
    try {
      await _firestore.collection(_collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete warehouse document: $e');
    }
  }

  // Get documents by related order
  Future<List<WarehouseDocumentModel>> getDocumentsByRelatedOrder(String orderId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('relatedOrderId', isEqualTo: orderId)
          .get();

      return querySnapshot.docs
          .map((doc) => WarehouseDocumentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get documents by related order: $e');
    }
  }

  // Stream of documents for real-time updates
  Stream<List<WarehouseDocumentModel>> documentsStream({
    WarehouseDocumentType? type,
    String? warehouseId,
  }) {
    Query query = _firestore.collection(_collection);

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    if (warehouseId != null) {
      query = query.where('warehouseId', isEqualTo: warehouseId);
    }

    query = query.orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => WarehouseDocumentModel.fromFirestore(doc))
          .toList();
    });
  }
}
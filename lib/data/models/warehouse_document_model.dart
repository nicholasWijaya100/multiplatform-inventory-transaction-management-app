import 'package:cloud_firestore/cloud_firestore.dart';

enum WarehouseDocumentType {
  entryWaybill,
  deliveryNote
}

enum WarehouseDocumentStatus {
  draft,
  pending,
  completed,
  cancelled
}

class WarehouseDocumentModel {
  final String id;
  final String documentNumber;
  final WarehouseDocumentType type;
  final String warehouseId;
  final String warehouseName;
  final String? relatedOrderId; // Purchase order ID for entry waybill, Sales order ID for delivery note
  final String? relatedOrderNumber;
  final List<WarehouseDocumentItem> items;
  final WarehouseDocumentStatus status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;
  final Map<String, dynamic>? metadata; // Additional info like supplier/customer details

  WarehouseDocumentModel({
    required this.id,
    required this.documentNumber,
    required this.type,
    required this.warehouseId,
    required this.warehouseName,
    this.relatedOrderId,
    this.relatedOrderNumber,
    required this.items,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.completedAt,
    this.notes,
    this.metadata,
  });

  factory WarehouseDocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WarehouseDocumentModel(
      id: doc.id,
      documentNumber: data['documentNumber'] ?? '',
      type: WarehouseDocumentType.values.firstWhere(
            (e) => e.name == data['type'],
        orElse: () => WarehouseDocumentType.entryWaybill,
      ),
      warehouseId: data['warehouseId'] ?? '',
      warehouseName: data['warehouseName'] ?? '',
      relatedOrderId: data['relatedOrderId'],
      relatedOrderNumber: data['relatedOrderNumber'],
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => WarehouseDocumentItem.fromMap(item))
          .toList() ??
          [],
      status: WarehouseDocumentStatus.values.firstWhere(
            (e) => e.name == data['status'],
        orElse: () => WarehouseDocumentStatus.draft,
      ),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      notes: data['notes'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'documentNumber': documentNumber,
      'type': type.name,
      'warehouseId': warehouseId,
      'warehouseName': warehouseName,
      'relatedOrderId': relatedOrderId,
      'relatedOrderNumber': relatedOrderNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status.name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'notes': notes,
      'metadata': metadata,
    };
  }

  WarehouseDocumentModel copyWith({
    String? id,
    String? documentNumber,
    WarehouseDocumentType? type,
    String? warehouseId,
    String? warehouseName,
    String? relatedOrderId,
    String? relatedOrderNumber,
    List<WarehouseDocumentItem>? items,
    WarehouseDocumentStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? completedAt,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return WarehouseDocumentModel(
      id: id ?? this.id,
      documentNumber: documentNumber ?? this.documentNumber,
      type: type ?? this.type,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      relatedOrderId: relatedOrderId ?? this.relatedOrderId,
      relatedOrderNumber: relatedOrderNumber ?? this.relatedOrderNumber,
      items: items ?? this.items,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }
}

class WarehouseDocumentItem {
  final String productId;
  final String productName;
  final String productSku;
  final int quantity;
  final String unit;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? notes;

  WarehouseDocumentItem({
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantity,
    required this.unit,
    this.batchNumber,
    this.expiryDate,
    this.notes,
  });

  factory WarehouseDocumentItem.fromMap(Map<String, dynamic> map) {
    return WarehouseDocumentItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productSku: map['productSku'] ?? '',
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? 'pcs',
      batchNumber: map['batchNumber'],
      expiryDate: map['expiryDate'] != null
          ? (map['expiryDate'] as Timestamp).toDate()
          : null,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'quantity': quantity,
      'unit': unit,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'notes': notes,
    };
  }

  WarehouseDocumentItem copyWith({
    String? productId,
    String? productName,
    String? productSku,
    int? quantity,
    String? unit,
    String? batchNumber,
    DateTime? expiryDate,
    String? notes,
  }) {
    return WarehouseDocumentItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_invoice_model.freezed.dart';
part 'purchase_invoice_model.g.dart';

enum PurchaseInvoiceStatus {
  draft,
  received,
  pending,
  paid,
  overdue,
  cancelled,
  disputed
}

@freezed
class PurchaseInvoiceModel with _$PurchaseInvoiceModel {
  const PurchaseInvoiceModel._(); // Base constructor for custom methods

  const factory PurchaseInvoiceModel({
    required String id,
    String? customId,
    required String supplierId,
    required String supplierName,
    required String purchaseOrderId,
    required String status,
    required List<PurchaseInvoiceItem> items,
    required double subtotal,
    required double tax,
    required double total,
    required DateTime dueDate,
    String? notes,
    String? paymentTerms,
    String? invoiceNumber, // Supplier's invoice number
    @Default(false) bool isPaid,
    DateTime? paidDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PurchaseInvoiceModel;

  factory PurchaseInvoiceModel.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoiceModel(
      id: json['id'] as String? ?? '',
      customId: json['customId'] as String?,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      purchaseOrderId: json['purchaseOrderId'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => PurchaseInvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      notes: json['notes'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
      invoiceNumber: json['invoiceNumber'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
      paidDate: json['paidDate'] != null
          ? (json['paidDate'] as Timestamp).toDate()
          : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customId': customId,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'purchaseOrderId': purchaseOrderId,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'dueDate': Timestamp.fromDate(dueDate),
      'notes': notes,
      'paymentTerms': paymentTerms,
      'invoiceNumber': invoiceNumber,
      'isPaid': isPaid,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isOverdue => !isPaid && DateTime.now().isAfter(dueDate);
}

@freezed
class PurchaseInvoiceItem with _$PurchaseInvoiceItem {
  const factory PurchaseInvoiceItem({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double total,
    String? description,
  }) = _PurchaseInvoiceItem;

  factory PurchaseInvoiceItem.fromJson(Map<String, dynamic> json) =>
      PurchaseInvoiceItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'total': total,
    'description': description,
  };
}
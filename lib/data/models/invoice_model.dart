import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invoice_model.freezed.dart';
part 'invoice_model.g.dart';

enum InvoiceStatus {
  draft,       // Just created, not yet sent to customer
  sent,        // Invoice has been sent to customer
  paid,        // Invoice has been paid
  overdue,     // Payment date has passed without payment
  disputed,    // There's an issue with the invoice that needs resolution
  refunded,    // Payment was made but then refunded (e.g. for canceled orders)
  cancelled    // Invoice is no longer valid/active
}

@freezed
class InvoiceModel with _$InvoiceModel {
  const InvoiceModel._();

  const factory InvoiceModel({
    required String id,
    String? customId,
    required String customerId,
    required String customerName,
    required String salesOrderId,
    required String status,
    required List<InvoiceItem> items,
    required double subtotal,
    required double tax,
    required double total,
    required DateTime dueDate,
    String? notes,
    String? paymentTerms,
    @Default(false) bool isPaid,
    DateTime? paidDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _InvoiceModel;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String? ?? '',
      customId: json['customId'] as String?,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      salesOrderId: json['salesOrderId'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      notes: json['notes'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
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
      'customerId': customerId,
      'customerName': customerName,
      'salesOrderId': salesOrderId,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'dueDate': Timestamp.fromDate(dueDate),
      'notes': notes,
      'paymentTerms': paymentTerms,
      'isPaid': isPaid,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isOverdue => !isPaid && DateTime.now().isAfter(dueDate);
}

@freezed
class InvoiceItem with _$InvoiceItem {
  const factory InvoiceItem({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double total,
    String? description,
  }) = _InvoiceItem;

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      InvoiceItem(
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

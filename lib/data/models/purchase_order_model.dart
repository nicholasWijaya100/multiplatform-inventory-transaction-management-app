import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase_order_model.freezed.dart';
part 'purchase_order_model.g.dart';

enum PurchaseOrderStatus {
  draft,
  pending,
  confirmed,
  received,
  completed,
  cancelled
}

@freezed
class PurchaseOrderModel with _$PurchaseOrderModel {
  const PurchaseOrderModel._(); // Base constructor for custom methods

  const factory PurchaseOrderModel({
    required String id,
    required String supplierId,
    required String supplierName,
    required String status,
    required List<PurchaseOrderItem> items,
    required double totalAmount,
    String? notes,
    String? paymentTerms,
    @Default(false) bool isPaid,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deliveryDate,
    DateTime? receivedDate,
  }) = _PurchaseOrderModel;

  // Custom fromJson factory
  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      id: json['id'] as String? ?? '',
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => PurchaseOrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      notes: json['notes'] as String?,
      paymentTerms: json['paymentTerms'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      deliveryDate: json['deliveryDate'] != null
          ? (json['deliveryDate'] as Timestamp).toDate()
          : null,
      receivedDate: json['receivedDate'] != null
          ? (json['receivedDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'notes': notes,
      'paymentTerms': paymentTerms,
      'isPaid': isPaid,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deliveryDate': deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'receivedDate': receivedDate != null ? Timestamp.fromDate(receivedDate!) : null,
    };
  }
}

@freezed
class PurchaseOrderItem with _$PurchaseOrderItem {
  const factory PurchaseOrderItem({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    String? notes,
  }) = _PurchaseOrderItem;

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) =>
      PurchaseOrderItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        notes: json['notes'] as String?,
      );
}

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
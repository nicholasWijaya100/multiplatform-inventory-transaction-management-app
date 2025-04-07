import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_order_model.freezed.dart';
part 'sales_order_model.g.dart';

enum SalesOrderStatus {
  draft,
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled
}

@freezed
class SalesOrderModel with _$SalesOrderModel {
  const SalesOrderModel._();

  const factory SalesOrderModel({
    required String id,
    required String customerId,
    required String customerName,
    required String status,
    required List<SalesOrderItem> items,
    required double totalAmount,
    String? notes,
    String? paymentTerms,
    @Default(false) bool isPaid,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deliveryDate,
    DateTime? shippedDate,
  }) = _SalesOrderModel;

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    return SalesOrderModel(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => SalesOrderItem.fromJson(item as Map<String, dynamic>))
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
      shippedDate: json['shippedDate'] != null
          ? (json['shippedDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'notes': notes,
      'paymentTerms': paymentTerms,
      'isPaid': isPaid,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deliveryDate': deliveryDate != null ? Timestamp.fromDate(deliveryDate!) : null,
      'shippedDate': shippedDate != null ? Timestamp.fromDate(shippedDate!) : null,
    };
  }
}

@freezed
class SalesOrderItem with _$SalesOrderItem {
  const factory SalesOrderItem({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    String? notes,
  }) = _SalesOrderItem;

  factory SalesOrderItem.fromJson(Map<String, dynamic> json) =>
      SalesOrderItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: json['quantity'] as int,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        notes: json['notes'] as String?,
      );
}
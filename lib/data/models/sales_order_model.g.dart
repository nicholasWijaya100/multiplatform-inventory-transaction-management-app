// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SalesOrderItemImpl _$$SalesOrderItemImplFromJson(Map<String, dynamic> json) =>
    _$SalesOrderItemImpl(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$SalesOrderItemImplToJson(
        _$SalesOrderItemImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'notes': instance.notes,
    };

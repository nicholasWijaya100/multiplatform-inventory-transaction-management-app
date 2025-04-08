// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseInvoiceItemImpl _$$PurchaseInvoiceItemImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseInvoiceItemImpl(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$PurchaseInvoiceItemImplToJson(
        _$PurchaseInvoiceItemImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'total': instance.total,
      'description': instance.description,
    };

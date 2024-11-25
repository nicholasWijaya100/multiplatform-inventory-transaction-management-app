// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'warehouse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WarehouseModelImpl _$$WarehouseModelImplFromJson(Map<String, dynamic> json) =>
    _$WarehouseModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$WarehouseModelImplToJson(
        _$WarehouseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'phone': instance.phone,
      'email': instance.email,
      'isActive': instance.isActive,
      'totalProducts': instance.totalProducts,
      'totalValue': instance.totalValue,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'description': instance.description,
    };

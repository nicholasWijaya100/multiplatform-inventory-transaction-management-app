// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CustomerModelImpl _$$CustomerModelImplFromJson(Map<String, dynamic> json) =>
    _$CustomerModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalPurchases: (json['totalPurchases'] as num?)?.toDouble() ?? 0.0,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$CustomerModelImplToJson(_$CustomerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'phone': instance.phone,
      'email': instance.email,
      'isActive': instance.isActive,
      'totalOrders': instance.totalOrders,
      'totalPurchases': instance.totalPurchases,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'description': instance.description,
    };

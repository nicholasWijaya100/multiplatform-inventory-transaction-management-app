import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'supplier_model.freezed.dart';
part 'supplier_model.g.dart';

@freezed
class SupplierModel with _$SupplierModel {
  const factory SupplierModel({
    required String id,
    required String name,
    required String address,
    required String city,
    required String phone,
    String? email,
    required bool isActive,
    @Default(0) int totalOrders,
    @Default(0.0) double totalPurchases,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
    String? description,
  }) = _SupplierModel;

  factory SupplierModel.fromJson(Map<String, dynamic> json) =>
      _$SupplierModelFromJson(json);
}

// Add this Timestamp converter
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return DateTime.now(); // Default value if timestamp is null
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
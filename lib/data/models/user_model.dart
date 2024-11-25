import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String role,
    String? name,
    @Default(true) bool isActive,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

enum UserRole {
  administrator,
  sales,
  warehouse,
  purchasing
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.administrator:
        return 'Administrator';
      case UserRole.sales:
        return 'Sales';
      case UserRole.warehouse:
        return 'Warehouse';
      case UserRole.purchasing:
        return 'Purchasing';
    }
  }
}
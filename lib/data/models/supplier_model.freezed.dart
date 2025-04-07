// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'supplier_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SupplierModel _$SupplierModelFromJson(Map<String, dynamic> json) {
  return _SupplierModel.fromJson(json);
}

/// @nodoc
mixin _$SupplierModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int get totalOrders => throw _privateConstructorUsedError;
  double get totalPurchases => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this SupplierModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SupplierModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SupplierModelCopyWith<SupplierModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SupplierModelCopyWith<$Res> {
  factory $SupplierModelCopyWith(
          SupplierModel value, $Res Function(SupplierModel) then) =
      _$SupplierModelCopyWithImpl<$Res, SupplierModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      String city,
      String phone,
      String? email,
      bool isActive,
      int totalOrders,
      double totalPurchases,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      String? description});
}

/// @nodoc
class _$SupplierModelCopyWithImpl<$Res, $Val extends SupplierModel>
    implements $SupplierModelCopyWith<$Res> {
  _$SupplierModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SupplierModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? city = null,
    Object? phone = null,
    Object? email = freezed,
    Object? isActive = null,
    Object? totalOrders = null,
    Object? totalPurchases = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalPurchases: null == totalPurchases
          ? _value.totalPurchases
          : totalPurchases // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SupplierModelImplCopyWith<$Res>
    implements $SupplierModelCopyWith<$Res> {
  factory _$$SupplierModelImplCopyWith(
          _$SupplierModelImpl value, $Res Function(_$SupplierModelImpl) then) =
      __$$SupplierModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String address,
      String city,
      String phone,
      String? email,
      bool isActive,
      int totalOrders,
      double totalPurchases,
      @TimestampConverter() DateTime createdAt,
      @TimestampConverter() DateTime updatedAt,
      String? description});
}

/// @nodoc
class __$$SupplierModelImplCopyWithImpl<$Res>
    extends _$SupplierModelCopyWithImpl<$Res, _$SupplierModelImpl>
    implements _$$SupplierModelImplCopyWith<$Res> {
  __$$SupplierModelImplCopyWithImpl(
      _$SupplierModelImpl _value, $Res Function(_$SupplierModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SupplierModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? city = null,
    Object? phone = null,
    Object? email = freezed,
    Object? isActive = null,
    Object? totalOrders = null,
    Object? totalPurchases = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? description = freezed,
  }) {
    return _then(_$SupplierModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      totalOrders: null == totalOrders
          ? _value.totalOrders
          : totalOrders // ignore: cast_nullable_to_non_nullable
              as int,
      totalPurchases: null == totalPurchases
          ? _value.totalPurchases
          : totalPurchases // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SupplierModelImpl implements _SupplierModel {
  const _$SupplierModelImpl(
      {required this.id,
      required this.name,
      required this.address,
      required this.city,
      required this.phone,
      this.email,
      required this.isActive,
      this.totalOrders = 0,
      this.totalPurchases = 0.0,
      @TimestampConverter() required this.createdAt,
      @TimestampConverter() required this.updatedAt,
      this.description});

  factory _$SupplierModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SupplierModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final String city;
  @override
  final String phone;
  @override
  final String? email;
  @override
  final bool isActive;
  @override
  @JsonKey()
  final int totalOrders;
  @override
  @JsonKey()
  final double totalPurchases;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime updatedAt;
  @override
  final String? description;

  @override
  String toString() {
    return 'SupplierModel(id: $id, name: $name, address: $address, city: $city, phone: $phone, email: $email, isActive: $isActive, totalOrders: $totalOrders, totalPurchases: $totalPurchases, createdAt: $createdAt, updatedAt: $updatedAt, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SupplierModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.totalOrders, totalOrders) ||
                other.totalOrders == totalOrders) &&
            (identical(other.totalPurchases, totalPurchases) ||
                other.totalPurchases == totalPurchases) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      address,
      city,
      phone,
      email,
      isActive,
      totalOrders,
      totalPurchases,
      createdAt,
      updatedAt,
      description);

  /// Create a copy of SupplierModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SupplierModelImplCopyWith<_$SupplierModelImpl> get copyWith =>
      __$$SupplierModelImplCopyWithImpl<_$SupplierModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SupplierModelImplToJson(
      this,
    );
  }
}

abstract class _SupplierModel implements SupplierModel {
  const factory _SupplierModel(
      {required final String id,
      required final String name,
      required final String address,
      required final String city,
      required final String phone,
      final String? email,
      required final bool isActive,
      final int totalOrders,
      final double totalPurchases,
      @TimestampConverter() required final DateTime createdAt,
      @TimestampConverter() required final DateTime updatedAt,
      final String? description}) = _$SupplierModelImpl;

  factory _SupplierModel.fromJson(Map<String, dynamic> json) =
      _$SupplierModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get address;
  @override
  String get city;
  @override
  String get phone;
  @override
  String? get email;
  @override
  bool get isActive;
  @override
  int get totalOrders;
  @override
  double get totalPurchases;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime get updatedAt;
  @override
  String? get description;

  /// Create a copy of SupplierModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SupplierModelImplCopyWith<_$SupplierModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

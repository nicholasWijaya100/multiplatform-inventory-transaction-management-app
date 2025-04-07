// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SalesOrderModel {
  String get id => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<SalesOrderItem> get items => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get paymentTerms => throw _privateConstructorUsedError;
  bool get isPaid => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deliveryDate => throw _privateConstructorUsedError;
  DateTime? get shippedDate => throw _privateConstructorUsedError;

  /// Create a copy of SalesOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesOrderModelCopyWith<SalesOrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesOrderModelCopyWith<$Res> {
  factory $SalesOrderModelCopyWith(
          SalesOrderModel value, $Res Function(SalesOrderModel) then) =
      _$SalesOrderModelCopyWithImpl<$Res, SalesOrderModel>;
  @useResult
  $Res call(
      {String id,
      String customerId,
      String customerName,
      String status,
      List<SalesOrderItem> items,
      double totalAmount,
      String? notes,
      String? paymentTerms,
      bool isPaid,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deliveryDate,
      DateTime? shippedDate});
}

/// @nodoc
class _$SalesOrderModelCopyWithImpl<$Res, $Val extends SalesOrderModel>
    implements $SalesOrderModelCopyWith<$Res> {
  _$SalesOrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? customerName = null,
    Object? status = null,
    Object? items = null,
    Object? totalAmount = null,
    Object? notes = freezed,
    Object? paymentTerms = freezed,
    Object? isPaid = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deliveryDate = freezed,
    Object? shippedDate = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SalesOrderItem>,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentTerms: freezed == paymentTerms
          ? _value.paymentTerms
          : paymentTerms // ignore: cast_nullable_to_non_nullable
              as String?,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveryDate: freezed == deliveryDate
          ? _value.deliveryDate
          : deliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      shippedDate: freezed == shippedDate
          ? _value.shippedDate
          : shippedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SalesOrderModelImplCopyWith<$Res>
    implements $SalesOrderModelCopyWith<$Res> {
  factory _$$SalesOrderModelImplCopyWith(_$SalesOrderModelImpl value,
          $Res Function(_$SalesOrderModelImpl) then) =
      __$$SalesOrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String customerId,
      String customerName,
      String status,
      List<SalesOrderItem> items,
      double totalAmount,
      String? notes,
      String? paymentTerms,
      bool isPaid,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deliveryDate,
      DateTime? shippedDate});
}

/// @nodoc
class __$$SalesOrderModelImplCopyWithImpl<$Res>
    extends _$SalesOrderModelCopyWithImpl<$Res, _$SalesOrderModelImpl>
    implements _$$SalesOrderModelImplCopyWith<$Res> {
  __$$SalesOrderModelImplCopyWithImpl(
      _$SalesOrderModelImpl _value, $Res Function(_$SalesOrderModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? customerName = null,
    Object? status = null,
    Object? items = null,
    Object? totalAmount = null,
    Object? notes = freezed,
    Object? paymentTerms = freezed,
    Object? isPaid = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deliveryDate = freezed,
    Object? shippedDate = freezed,
  }) {
    return _then(_$SalesOrderModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customerId: null == customerId
          ? _value.customerId
          : customerId // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SalesOrderItem>,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentTerms: freezed == paymentTerms
          ? _value.paymentTerms
          : paymentTerms // ignore: cast_nullable_to_non_nullable
              as String?,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deliveryDate: freezed == deliveryDate
          ? _value.deliveryDate
          : deliveryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      shippedDate: freezed == shippedDate
          ? _value.shippedDate
          : shippedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$SalesOrderModelImpl extends _SalesOrderModel {
  const _$SalesOrderModelImpl(
      {required this.id,
      required this.customerId,
      required this.customerName,
      required this.status,
      required final List<SalesOrderItem> items,
      required this.totalAmount,
      this.notes,
      this.paymentTerms,
      this.isPaid = false,
      required this.createdAt,
      required this.updatedAt,
      this.deliveryDate,
      this.shippedDate})
      : _items = items,
        super._();

  @override
  final String id;
  @override
  final String customerId;
  @override
  final String customerName;
  @override
  final String status;
  final List<SalesOrderItem> _items;
  @override
  List<SalesOrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double totalAmount;
  @override
  final String? notes;
  @override
  final String? paymentTerms;
  @override
  @JsonKey()
  final bool isPaid;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deliveryDate;
  @override
  final DateTime? shippedDate;

  @override
  String toString() {
    return 'SalesOrderModel(id: $id, customerId: $customerId, customerName: $customerName, status: $status, items: $items, totalAmount: $totalAmount, notes: $notes, paymentTerms: $paymentTerms, isPaid: $isPaid, createdAt: $createdAt, updatedAt: $updatedAt, deliveryDate: $deliveryDate, shippedDate: $shippedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesOrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.paymentTerms, paymentTerms) ||
                other.paymentTerms == paymentTerms) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deliveryDate, deliveryDate) ||
                other.deliveryDate == deliveryDate) &&
            (identical(other.shippedDate, shippedDate) ||
                other.shippedDate == shippedDate));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerId,
      customerName,
      status,
      const DeepCollectionEquality().hash(_items),
      totalAmount,
      notes,
      paymentTerms,
      isPaid,
      createdAt,
      updatedAt,
      deliveryDate,
      shippedDate);

  /// Create a copy of SalesOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesOrderModelImplCopyWith<_$SalesOrderModelImpl> get copyWith =>
      __$$SalesOrderModelImplCopyWithImpl<_$SalesOrderModelImpl>(
          this, _$identity);
}

abstract class _SalesOrderModel extends SalesOrderModel {
  const factory _SalesOrderModel(
      {required final String id,
      required final String customerId,
      required final String customerName,
      required final String status,
      required final List<SalesOrderItem> items,
      required final double totalAmount,
      final String? notes,
      final String? paymentTerms,
      final bool isPaid,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? deliveryDate,
      final DateTime? shippedDate}) = _$SalesOrderModelImpl;
  const _SalesOrderModel._() : super._();

  @override
  String get id;
  @override
  String get customerId;
  @override
  String get customerName;
  @override
  String get status;
  @override
  List<SalesOrderItem> get items;
  @override
  double get totalAmount;
  @override
  String? get notes;
  @override
  String? get paymentTerms;
  @override
  bool get isPaid;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  DateTime? get deliveryDate;
  @override
  DateTime? get shippedDate;

  /// Create a copy of SalesOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesOrderModelImplCopyWith<_$SalesOrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SalesOrderItem _$SalesOrderItemFromJson(Map<String, dynamic> json) {
  return _SalesOrderItem.fromJson(json);
}

/// @nodoc
mixin _$SalesOrderItem {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this SalesOrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SalesOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalesOrderItemCopyWith<SalesOrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalesOrderItemCopyWith<$Res> {
  factory $SalesOrderItemCopyWith(
          SalesOrderItem value, $Res Function(SalesOrderItem) then) =
      _$SalesOrderItemCopyWithImpl<$Res, SalesOrderItem>;
  @useResult
  $Res call(
      {String productId,
      String productName,
      int quantity,
      double unitPrice,
      double totalPrice,
      String? notes});
}

/// @nodoc
class _$SalesOrderItemCopyWithImpl<$Res, $Val extends SalesOrderItem>
    implements $SalesOrderItemCopyWith<$Res> {
  _$SalesOrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalesOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalPrice = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SalesOrderItemImplCopyWith<$Res>
    implements $SalesOrderItemCopyWith<$Res> {
  factory _$$SalesOrderItemImplCopyWith(_$SalesOrderItemImpl value,
          $Res Function(_$SalesOrderItemImpl) then) =
      __$$SalesOrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String productId,
      String productName,
      int quantity,
      double unitPrice,
      double totalPrice,
      String? notes});
}

/// @nodoc
class __$$SalesOrderItemImplCopyWithImpl<$Res>
    extends _$SalesOrderItemCopyWithImpl<$Res, _$SalesOrderItemImpl>
    implements _$$SalesOrderItemImplCopyWith<$Res> {
  __$$SalesOrderItemImplCopyWithImpl(
      _$SalesOrderItemImpl _value, $Res Function(_$SalesOrderItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of SalesOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? totalPrice = null,
    Object? notes = freezed,
  }) {
    return _then(_$SalesOrderItemImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as double,
      totalPrice: null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SalesOrderItemImpl implements _SalesOrderItem {
  const _$SalesOrderItemImpl(
      {required this.productId,
      required this.productName,
      required this.quantity,
      required this.unitPrice,
      required this.totalPrice,
      this.notes});

  factory _$SalesOrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$SalesOrderItemImplFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final int quantity;
  @override
  final double unitPrice;
  @override
  final double totalPrice;
  @override
  final String? notes;

  @override
  String toString() {
    return 'SalesOrderItem(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalesOrderItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, productName, quantity,
      unitPrice, totalPrice, notes);

  /// Create a copy of SalesOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalesOrderItemImplCopyWith<_$SalesOrderItemImpl> get copyWith =>
      __$$SalesOrderItemImplCopyWithImpl<_$SalesOrderItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SalesOrderItemImplToJson(
      this,
    );
  }
}

abstract class _SalesOrderItem implements SalesOrderItem {
  const factory _SalesOrderItem(
      {required final String productId,
      required final String productName,
      required final int quantity,
      required final double unitPrice,
      required final double totalPrice,
      final String? notes}) = _$SalesOrderItemImpl;

  factory _SalesOrderItem.fromJson(Map<String, dynamic> json) =
      _$SalesOrderItemImpl.fromJson;

  @override
  String get productId;
  @override
  String get productName;
  @override
  int get quantity;
  @override
  double get unitPrice;
  @override
  double get totalPrice;
  @override
  String? get notes;

  /// Create a copy of SalesOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalesOrderItemImplCopyWith<_$SalesOrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

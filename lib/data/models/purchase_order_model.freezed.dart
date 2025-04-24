// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_order_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PurchaseOrderModel {
  String get id => throw _privateConstructorUsedError;
  String get supplierId => throw _privateConstructorUsedError;
  String get supplierName => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<PurchaseOrderItem> get items => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get paymentTerms => throw _privateConstructorUsedError;
  bool get isPaid => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deliveryDate => throw _privateConstructorUsedError;
  DateTime? get receivedDate => throw _privateConstructorUsedError;
  String? get receivingWarehouseId => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseOrderModelCopyWith<PurchaseOrderModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseOrderModelCopyWith<$Res> {
  factory $PurchaseOrderModelCopyWith(
          PurchaseOrderModel value, $Res Function(PurchaseOrderModel) then) =
      _$PurchaseOrderModelCopyWithImpl<$Res, PurchaseOrderModel>;
  @useResult
  $Res call(
      {String id,
      String supplierId,
      String supplierName,
      String status,
      List<PurchaseOrderItem> items,
      double totalAmount,
      String? notes,
      String? paymentTerms,
      bool isPaid,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deliveryDate,
      DateTime? receivedDate,
      String? receivingWarehouseId});
}

/// @nodoc
class _$PurchaseOrderModelCopyWithImpl<$Res, $Val extends PurchaseOrderModel>
    implements $PurchaseOrderModelCopyWith<$Res> {
  _$PurchaseOrderModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? supplierId = null,
    Object? supplierName = null,
    Object? status = null,
    Object? items = null,
    Object? totalAmount = null,
    Object? notes = freezed,
    Object? paymentTerms = freezed,
    Object? isPaid = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deliveryDate = freezed,
    Object? receivedDate = freezed,
    Object? receivingWarehouseId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierName: null == supplierName
          ? _value.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PurchaseOrderItem>,
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
      receivedDate: freezed == receivedDate
          ? _value.receivedDate
          : receivedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      receivingWarehouseId: freezed == receivingWarehouseId
          ? _value.receivingWarehouseId
          : receivingWarehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchaseOrderModelImplCopyWith<$Res>
    implements $PurchaseOrderModelCopyWith<$Res> {
  factory _$$PurchaseOrderModelImplCopyWith(_$PurchaseOrderModelImpl value,
          $Res Function(_$PurchaseOrderModelImpl) then) =
      __$$PurchaseOrderModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String supplierId,
      String supplierName,
      String status,
      List<PurchaseOrderItem> items,
      double totalAmount,
      String? notes,
      String? paymentTerms,
      bool isPaid,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deliveryDate,
      DateTime? receivedDate,
      String? receivingWarehouseId});
}

/// @nodoc
class __$$PurchaseOrderModelImplCopyWithImpl<$Res>
    extends _$PurchaseOrderModelCopyWithImpl<$Res, _$PurchaseOrderModelImpl>
    implements _$$PurchaseOrderModelImplCopyWith<$Res> {
  __$$PurchaseOrderModelImplCopyWithImpl(_$PurchaseOrderModelImpl _value,
      $Res Function(_$PurchaseOrderModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PurchaseOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? supplierId = null,
    Object? supplierName = null,
    Object? status = null,
    Object? items = null,
    Object? totalAmount = null,
    Object? notes = freezed,
    Object? paymentTerms = freezed,
    Object? isPaid = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deliveryDate = freezed,
    Object? receivedDate = freezed,
    Object? receivingWarehouseId = freezed,
  }) {
    return _then(_$PurchaseOrderModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierName: null == supplierName
          ? _value.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PurchaseOrderItem>,
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
      receivedDate: freezed == receivedDate
          ? _value.receivedDate
          : receivedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      receivingWarehouseId: freezed == receivingWarehouseId
          ? _value.receivingWarehouseId
          : receivingWarehouseId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PurchaseOrderModelImpl extends _PurchaseOrderModel {
  const _$PurchaseOrderModelImpl(
      {required this.id,
      required this.supplierId,
      required this.supplierName,
      required this.status,
      required final List<PurchaseOrderItem> items,
      required this.totalAmount,
      this.notes,
      this.paymentTerms,
      this.isPaid = false,
      required this.createdAt,
      required this.updatedAt,
      this.deliveryDate,
      this.receivedDate,
      this.receivingWarehouseId})
      : _items = items,
        super._();

  @override
  final String id;
  @override
  final String supplierId;
  @override
  final String supplierName;
  @override
  final String status;
  final List<PurchaseOrderItem> _items;
  @override
  List<PurchaseOrderItem> get items {
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
  final DateTime? receivedDate;
  @override
  final String? receivingWarehouseId;

  @override
  String toString() {
    return 'PurchaseOrderModel(id: $id, supplierId: $supplierId, supplierName: $supplierName, status: $status, items: $items, totalAmount: $totalAmount, notes: $notes, paymentTerms: $paymentTerms, isPaid: $isPaid, createdAt: $createdAt, updatedAt: $updatedAt, deliveryDate: $deliveryDate, receivedDate: $receivedDate, receivingWarehouseId: $receivingWarehouseId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseOrderModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
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
            (identical(other.receivedDate, receivedDate) ||
                other.receivedDate == receivedDate) &&
            (identical(other.receivingWarehouseId, receivingWarehouseId) ||
                other.receivingWarehouseId == receivingWarehouseId));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      supplierId,
      supplierName,
      status,
      const DeepCollectionEquality().hash(_items),
      totalAmount,
      notes,
      paymentTerms,
      isPaid,
      createdAt,
      updatedAt,
      deliveryDate,
      receivedDate,
      receivingWarehouseId);

  /// Create a copy of PurchaseOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseOrderModelImplCopyWith<_$PurchaseOrderModelImpl> get copyWith =>
      __$$PurchaseOrderModelImplCopyWithImpl<_$PurchaseOrderModelImpl>(
          this, _$identity);
}

abstract class _PurchaseOrderModel extends PurchaseOrderModel {
  const factory _PurchaseOrderModel(
      {required final String id,
      required final String supplierId,
      required final String supplierName,
      required final String status,
      required final List<PurchaseOrderItem> items,
      required final double totalAmount,
      final String? notes,
      final String? paymentTerms,
      final bool isPaid,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final DateTime? deliveryDate,
      final DateTime? receivedDate,
      final String? receivingWarehouseId}) = _$PurchaseOrderModelImpl;
  const _PurchaseOrderModel._() : super._();

  @override
  String get id;
  @override
  String get supplierId;
  @override
  String get supplierName;
  @override
  String get status;
  @override
  List<PurchaseOrderItem> get items;
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
  DateTime? get receivedDate;
  @override
  String? get receivingWarehouseId;

  /// Create a copy of PurchaseOrderModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseOrderModelImplCopyWith<_$PurchaseOrderModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseOrderItem _$PurchaseOrderItemFromJson(Map<String, dynamic> json) {
  return _PurchaseOrderItem.fromJson(json);
}

/// @nodoc
mixin _$PurchaseOrderItem {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this PurchaseOrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseOrderItemCopyWith<PurchaseOrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseOrderItemCopyWith<$Res> {
  factory $PurchaseOrderItemCopyWith(
          PurchaseOrderItem value, $Res Function(PurchaseOrderItem) then) =
      _$PurchaseOrderItemCopyWithImpl<$Res, PurchaseOrderItem>;
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
class _$PurchaseOrderItemCopyWithImpl<$Res, $Val extends PurchaseOrderItem>
    implements $PurchaseOrderItemCopyWith<$Res> {
  _$PurchaseOrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseOrderItem
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
abstract class _$$PurchaseOrderItemImplCopyWith<$Res>
    implements $PurchaseOrderItemCopyWith<$Res> {
  factory _$$PurchaseOrderItemImplCopyWith(_$PurchaseOrderItemImpl value,
          $Res Function(_$PurchaseOrderItemImpl) then) =
      __$$PurchaseOrderItemImplCopyWithImpl<$Res>;
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
class __$$PurchaseOrderItemImplCopyWithImpl<$Res>
    extends _$PurchaseOrderItemCopyWithImpl<$Res, _$PurchaseOrderItemImpl>
    implements _$$PurchaseOrderItemImplCopyWith<$Res> {
  __$$PurchaseOrderItemImplCopyWithImpl(_$PurchaseOrderItemImpl _value,
      $Res Function(_$PurchaseOrderItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of PurchaseOrderItem
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
    return _then(_$PurchaseOrderItemImpl(
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
class _$PurchaseOrderItemImpl implements _PurchaseOrderItem {
  const _$PurchaseOrderItemImpl(
      {required this.productId,
      required this.productName,
      required this.quantity,
      required this.unitPrice,
      required this.totalPrice,
      this.notes});

  factory _$PurchaseOrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseOrderItemImplFromJson(json);

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
    return 'PurchaseOrderItem(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, totalPrice: $totalPrice, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseOrderItemImpl &&
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

  /// Create a copy of PurchaseOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseOrderItemImplCopyWith<_$PurchaseOrderItemImpl> get copyWith =>
      __$$PurchaseOrderItemImplCopyWithImpl<_$PurchaseOrderItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseOrderItemImplToJson(
      this,
    );
  }
}

abstract class _PurchaseOrderItem implements PurchaseOrderItem {
  const factory _PurchaseOrderItem(
      {required final String productId,
      required final String productName,
      required final int quantity,
      required final double unitPrice,
      required final double totalPrice,
      final String? notes}) = _$PurchaseOrderItemImpl;

  factory _PurchaseOrderItem.fromJson(Map<String, dynamic> json) =
      _$PurchaseOrderItemImpl.fromJson;

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

  /// Create a copy of PurchaseOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseOrderItemImplCopyWith<_$PurchaseOrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invoice_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$InvoiceModel {
  String get id => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get salesOrderId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<InvoiceItem> get items => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get tax => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get paymentTerms => throw _privateConstructorUsedError;
  bool get isPaid => throw _privateConstructorUsedError;
  DateTime? get paidDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of InvoiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvoiceModelCopyWith<InvoiceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceModelCopyWith<$Res> {
  factory $InvoiceModelCopyWith(
          InvoiceModel value, $Res Function(InvoiceModel) then) =
      _$InvoiceModelCopyWithImpl<$Res, InvoiceModel>;
  @useResult
  $Res call(
      {String id,
      String customerId,
      String customerName,
      String salesOrderId,
      String status,
      List<InvoiceItem> items,
      double subtotal,
      double tax,
      double total,
      DateTime dueDate,
      String? notes,
      String? paymentTerms,
      bool isPaid,
      DateTime? paidDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$InvoiceModelCopyWithImpl<$Res, $Val extends InvoiceModel>
    implements $InvoiceModelCopyWith<$Res> {
  _$InvoiceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvoiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? customerName = null,
    Object? salesOrderId = null,
    Object? status = null,
    Object? items = null,
    Object? subtotal = null,
    Object? tax = null,
    Object? total = null,
    Object? dueDate = null,
    Object? notes = freezed,
    Object? paymentTerms = freezed,
    Object? isPaid = null,
    Object? paidDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      salesOrderId: null == salesOrderId
          ? _value.salesOrderId
          : salesOrderId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      tax: null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      paidDate: freezed == paidDate
          ? _value.paidDate
          : paidDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvoiceModelImplCopyWith<$Res>
    implements $InvoiceModelCopyWith<$Res> {
  factory _$$InvoiceModelImplCopyWith(
          _$InvoiceModelImpl value, $Res Function(_$InvoiceModelImpl) then) =
      __$$InvoiceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String customerId,
      String customerName,
      String salesOrderId,
      String status,
      List<InvoiceItem> items,
      double subtotal,
      double tax,
      double total,
      DateTime dueDate,
      String? notes,
      String? paymentTerms,
      bool isPaid,
      DateTime? paidDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$InvoiceModelImplCopyWithImpl<$Res>
    extends _$InvoiceModelCopyWithImpl<$Res, _$InvoiceModelImpl>
    implements _$$InvoiceModelImplCopyWith<$Res> {
  __$$InvoiceModelImplCopyWithImpl(
      _$InvoiceModelImpl _value, $Res Function(_$InvoiceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of InvoiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customerId = null,
    Object? customerName = null,
    Object? salesOrderId = null,
    Object? status = null,
    Object? items = null,
    Object? subtotal = null,
    Object? tax = null,
    Object? total = null,
    Object? dueDate = null,
    Object? notes = freezed,
    Object? paymentTerms = freezed,
    Object? isPaid = null,
    Object? paidDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$InvoiceModelImpl(
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
      salesOrderId: null == salesOrderId
          ? _value.salesOrderId
          : salesOrderId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InvoiceItem>,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as double,
      tax: null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as double,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
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
      paidDate: freezed == paidDate
          ? _value.paidDate
          : paidDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$InvoiceModelImpl extends _InvoiceModel {
  const _$InvoiceModelImpl(
      {required this.id,
      required this.customerId,
      required this.customerName,
      required this.salesOrderId,
      required this.status,
      required final List<InvoiceItem> items,
      required this.subtotal,
      required this.tax,
      required this.total,
      required this.dueDate,
      this.notes,
      this.paymentTerms,
      this.isPaid = false,
      this.paidDate,
      required this.createdAt,
      required this.updatedAt})
      : _items = items,
        super._();

  @override
  final String id;
  @override
  final String customerId;
  @override
  final String customerName;
  @override
  final String salesOrderId;
  @override
  final String status;
  final List<InvoiceItem> _items;
  @override
  List<InvoiceItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final double subtotal;
  @override
  final double tax;
  @override
  final double total;
  @override
  final DateTime dueDate;
  @override
  final String? notes;
  @override
  final String? paymentTerms;
  @override
  @JsonKey()
  final bool isPaid;
  @override
  final DateTime? paidDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'InvoiceModel(id: $id, customerId: $customerId, customerName: $customerName, salesOrderId: $salesOrderId, status: $status, items: $items, subtotal: $subtotal, tax: $tax, total: $total, dueDate: $dueDate, notes: $notes, paymentTerms: $paymentTerms, isPaid: $isPaid, paidDate: $paidDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.salesOrderId, salesOrderId) ||
                other.salesOrderId == salesOrderId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.paymentTerms, paymentTerms) ||
                other.paymentTerms == paymentTerms) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid) &&
            (identical(other.paidDate, paidDate) ||
                other.paidDate == paidDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      customerId,
      customerName,
      salesOrderId,
      status,
      const DeepCollectionEquality().hash(_items),
      subtotal,
      tax,
      total,
      dueDate,
      notes,
      paymentTerms,
      isPaid,
      paidDate,
      createdAt,
      updatedAt);

  /// Create a copy of InvoiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceModelImplCopyWith<_$InvoiceModelImpl> get copyWith =>
      __$$InvoiceModelImplCopyWithImpl<_$InvoiceModelImpl>(this, _$identity);
}

abstract class _InvoiceModel extends InvoiceModel {
  const factory _InvoiceModel(
      {required final String id,
      required final String customerId,
      required final String customerName,
      required final String salesOrderId,
      required final String status,
      required final List<InvoiceItem> items,
      required final double subtotal,
      required final double tax,
      required final double total,
      required final DateTime dueDate,
      final String? notes,
      final String? paymentTerms,
      final bool isPaid,
      final DateTime? paidDate,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$InvoiceModelImpl;
  const _InvoiceModel._() : super._();

  @override
  String get id;
  @override
  String get customerId;
  @override
  String get customerName;
  @override
  String get salesOrderId;
  @override
  String get status;
  @override
  List<InvoiceItem> get items;
  @override
  double get subtotal;
  @override
  double get tax;
  @override
  double get total;
  @override
  DateTime get dueDate;
  @override
  String? get notes;
  @override
  String? get paymentTerms;
  @override
  bool get isPaid;
  @override
  DateTime? get paidDate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of InvoiceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvoiceModelImplCopyWith<_$InvoiceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) {
  return _InvoiceItem.fromJson(json);
}

/// @nodoc
mixin _$InvoiceItem {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this InvoiceItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvoiceItemCopyWith<InvoiceItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvoiceItemCopyWith<$Res> {
  factory $InvoiceItemCopyWith(
          InvoiceItem value, $Res Function(InvoiceItem) then) =
      _$InvoiceItemCopyWithImpl<$Res, InvoiceItem>;
  @useResult
  $Res call(
      {String productId,
      String productName,
      int quantity,
      double unitPrice,
      double total,
      String? description});
}

/// @nodoc
class _$InvoiceItemCopyWithImpl<$Res, $Val extends InvoiceItem>
    implements $InvoiceItemCopyWith<$Res> {
  _$InvoiceItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? total = null,
    Object? description = freezed,
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
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InvoiceItemImplCopyWith<$Res>
    implements $InvoiceItemCopyWith<$Res> {
  factory _$$InvoiceItemImplCopyWith(
          _$InvoiceItemImpl value, $Res Function(_$InvoiceItemImpl) then) =
      __$$InvoiceItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String productId,
      String productName,
      int quantity,
      double unitPrice,
      double total,
      String? description});
}

/// @nodoc
class __$$InvoiceItemImplCopyWithImpl<$Res>
    extends _$InvoiceItemCopyWithImpl<$Res, _$InvoiceItemImpl>
    implements _$$InvoiceItemImplCopyWith<$Res> {
  __$$InvoiceItemImplCopyWithImpl(
      _$InvoiceItemImpl _value, $Res Function(_$InvoiceItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? productName = null,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? total = null,
    Object? description = freezed,
  }) {
    return _then(_$InvoiceItemImpl(
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
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as double,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InvoiceItemImpl implements _InvoiceItem {
  const _$InvoiceItemImpl(
      {required this.productId,
      required this.productName,
      required this.quantity,
      required this.unitPrice,
      required this.total,
      this.description});

  factory _$InvoiceItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvoiceItemImplFromJson(json);

  @override
  final String productId;
  @override
  final String productName;
  @override
  final int quantity;
  @override
  final double unitPrice;
  @override
  final double total;
  @override
  final String? description;

  @override
  String toString() {
    return 'InvoiceItem(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, total: $total, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvoiceItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, productId, productName, quantity,
      unitPrice, total, description);

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvoiceItemImplCopyWith<_$InvoiceItemImpl> get copyWith =>
      __$$InvoiceItemImplCopyWithImpl<_$InvoiceItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InvoiceItemImplToJson(
      this,
    );
  }
}

abstract class _InvoiceItem implements InvoiceItem {
  const factory _InvoiceItem(
      {required final String productId,
      required final String productName,
      required final int quantity,
      required final double unitPrice,
      required final double total,
      final String? description}) = _$InvoiceItemImpl;

  factory _InvoiceItem.fromJson(Map<String, dynamic> json) =
      _$InvoiceItemImpl.fromJson;

  @override
  String get productId;
  @override
  String get productName;
  @override
  int get quantity;
  @override
  double get unitPrice;
  @override
  double get total;
  @override
  String? get description;

  /// Create a copy of InvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvoiceItemImplCopyWith<_$InvoiceItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

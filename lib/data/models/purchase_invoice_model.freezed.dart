// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_invoice_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PurchaseInvoiceModel {
  String get id => throw _privateConstructorUsedError;
  String? get customId => throw _privateConstructorUsedError;
  String get supplierId => throw _privateConstructorUsedError;
  String get supplierName => throw _privateConstructorUsedError;
  String get purchaseOrderId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<PurchaseInvoiceItem> get items => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get tax => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  DateTime get dueDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get paymentTerms => throw _privateConstructorUsedError;
  String? get invoiceNumber =>
      throw _privateConstructorUsedError; // Supplier's invoice number
  bool get isPaid => throw _privateConstructorUsedError;
  DateTime? get paidDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseInvoiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseInvoiceModelCopyWith<PurchaseInvoiceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseInvoiceModelCopyWith<$Res> {
  factory $PurchaseInvoiceModelCopyWith(PurchaseInvoiceModel value,
          $Res Function(PurchaseInvoiceModel) then) =
      _$PurchaseInvoiceModelCopyWithImpl<$Res, PurchaseInvoiceModel>;
  @useResult
  $Res call(
      {String id,
      String? customId,
      String supplierId,
      String supplierName,
      String purchaseOrderId,
      String status,
      List<PurchaseInvoiceItem> items,
      double subtotal,
      double tax,
      double total,
      DateTime dueDate,
      String? notes,
      String? paymentTerms,
      String? invoiceNumber,
      bool isPaid,
      DateTime? paidDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$PurchaseInvoiceModelCopyWithImpl<$Res,
        $Val extends PurchaseInvoiceModel>
    implements $PurchaseInvoiceModelCopyWith<$Res> {
  _$PurchaseInvoiceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseInvoiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customId = freezed,
    Object? supplierId = null,
    Object? supplierName = null,
    Object? purchaseOrderId = null,
    Object? status = null,
    Object? items = null,
    Object? subtotal = null,
    Object? tax = null,
    Object? total = null,
    Object? dueDate = null,
    Object? notes = freezed,
    Object? paymentTerms = freezed,
    Object? invoiceNumber = freezed,
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
      customId: freezed == customId
          ? _value.customId
          : customId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierName: null == supplierName
          ? _value.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String,
      purchaseOrderId: null == purchaseOrderId
          ? _value.purchaseOrderId
          : purchaseOrderId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PurchaseInvoiceItem>,
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
      invoiceNumber: freezed == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
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
abstract class _$$PurchaseInvoiceModelImplCopyWith<$Res>
    implements $PurchaseInvoiceModelCopyWith<$Res> {
  factory _$$PurchaseInvoiceModelImplCopyWith(_$PurchaseInvoiceModelImpl value,
          $Res Function(_$PurchaseInvoiceModelImpl) then) =
      __$$PurchaseInvoiceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? customId,
      String supplierId,
      String supplierName,
      String purchaseOrderId,
      String status,
      List<PurchaseInvoiceItem> items,
      double subtotal,
      double tax,
      double total,
      DateTime dueDate,
      String? notes,
      String? paymentTerms,
      String? invoiceNumber,
      bool isPaid,
      DateTime? paidDate,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$PurchaseInvoiceModelImplCopyWithImpl<$Res>
    extends _$PurchaseInvoiceModelCopyWithImpl<$Res, _$PurchaseInvoiceModelImpl>
    implements _$$PurchaseInvoiceModelImplCopyWith<$Res> {
  __$$PurchaseInvoiceModelImplCopyWithImpl(_$PurchaseInvoiceModelImpl _value,
      $Res Function(_$PurchaseInvoiceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PurchaseInvoiceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? customId = freezed,
    Object? supplierId = null,
    Object? supplierName = null,
    Object? purchaseOrderId = null,
    Object? status = null,
    Object? items = null,
    Object? subtotal = null,
    Object? tax = null,
    Object? total = null,
    Object? dueDate = null,
    Object? notes = freezed,
    Object? paymentTerms = freezed,
    Object? invoiceNumber = freezed,
    Object? isPaid = null,
    Object? paidDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PurchaseInvoiceModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      customId: freezed == customId
          ? _value.customId
          : customId // ignore: cast_nullable_to_non_nullable
              as String?,
      supplierId: null == supplierId
          ? _value.supplierId
          : supplierId // ignore: cast_nullable_to_non_nullable
              as String,
      supplierName: null == supplierName
          ? _value.supplierName
          : supplierName // ignore: cast_nullable_to_non_nullable
              as String,
      purchaseOrderId: null == purchaseOrderId
          ? _value.purchaseOrderId
          : purchaseOrderId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<PurchaseInvoiceItem>,
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
      invoiceNumber: freezed == invoiceNumber
          ? _value.invoiceNumber
          : invoiceNumber // ignore: cast_nullable_to_non_nullable
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

class _$PurchaseInvoiceModelImpl extends _PurchaseInvoiceModel {
  const _$PurchaseInvoiceModelImpl(
      {required this.id,
      this.customId,
      required this.supplierId,
      required this.supplierName,
      required this.purchaseOrderId,
      required this.status,
      required final List<PurchaseInvoiceItem> items,
      required this.subtotal,
      required this.tax,
      required this.total,
      required this.dueDate,
      this.notes,
      this.paymentTerms,
      this.invoiceNumber,
      this.isPaid = false,
      this.paidDate,
      required this.createdAt,
      required this.updatedAt})
      : _items = items,
        super._();

  @override
  final String id;
  @override
  final String? customId;
  @override
  final String supplierId;
  @override
  final String supplierName;
  @override
  final String purchaseOrderId;
  @override
  final String status;
  final List<PurchaseInvoiceItem> _items;
  @override
  List<PurchaseInvoiceItem> get items {
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
  final String? invoiceNumber;
// Supplier's invoice number
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
    return 'PurchaseInvoiceModel(id: $id, customId: $customId, supplierId: $supplierId, supplierName: $supplierName, purchaseOrderId: $purchaseOrderId, status: $status, items: $items, subtotal: $subtotal, tax: $tax, total: $total, dueDate: $dueDate, notes: $notes, paymentTerms: $paymentTerms, invoiceNumber: $invoiceNumber, isPaid: $isPaid, paidDate: $paidDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseInvoiceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.customId, customId) ||
                other.customId == customId) &&
            (identical(other.supplierId, supplierId) ||
                other.supplierId == supplierId) &&
            (identical(other.supplierName, supplierName) ||
                other.supplierName == supplierName) &&
            (identical(other.purchaseOrderId, purchaseOrderId) ||
                other.purchaseOrderId == purchaseOrderId) &&
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
            (identical(other.invoiceNumber, invoiceNumber) ||
                other.invoiceNumber == invoiceNumber) &&
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
      customId,
      supplierId,
      supplierName,
      purchaseOrderId,
      status,
      const DeepCollectionEquality().hash(_items),
      subtotal,
      tax,
      total,
      dueDate,
      notes,
      paymentTerms,
      invoiceNumber,
      isPaid,
      paidDate,
      createdAt,
      updatedAt);

  /// Create a copy of PurchaseInvoiceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseInvoiceModelImplCopyWith<_$PurchaseInvoiceModelImpl>
      get copyWith =>
          __$$PurchaseInvoiceModelImplCopyWithImpl<_$PurchaseInvoiceModelImpl>(
              this, _$identity);
}

abstract class _PurchaseInvoiceModel extends PurchaseInvoiceModel {
  const factory _PurchaseInvoiceModel(
      {required final String id,
      final String? customId,
      required final String supplierId,
      required final String supplierName,
      required final String purchaseOrderId,
      required final String status,
      required final List<PurchaseInvoiceItem> items,
      required final double subtotal,
      required final double tax,
      required final double total,
      required final DateTime dueDate,
      final String? notes,
      final String? paymentTerms,
      final String? invoiceNumber,
      final bool isPaid,
      final DateTime? paidDate,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$PurchaseInvoiceModelImpl;
  const _PurchaseInvoiceModel._() : super._();

  @override
  String get id;
  @override
  String? get customId;
  @override
  String get supplierId;
  @override
  String get supplierName;
  @override
  String get purchaseOrderId;
  @override
  String get status;
  @override
  List<PurchaseInvoiceItem> get items;
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
  String? get invoiceNumber; // Supplier's invoice number
  @override
  bool get isPaid;
  @override
  DateTime? get paidDate;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of PurchaseInvoiceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseInvoiceModelImplCopyWith<_$PurchaseInvoiceModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PurchaseInvoiceItem _$PurchaseInvoiceItemFromJson(Map<String, dynamic> json) {
  return _PurchaseInvoiceItem.fromJson(json);
}

/// @nodoc
mixin _$PurchaseInvoiceItem {
  String get productId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get total => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this PurchaseInvoiceItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PurchaseInvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PurchaseInvoiceItemCopyWith<PurchaseInvoiceItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseInvoiceItemCopyWith<$Res> {
  factory $PurchaseInvoiceItemCopyWith(
          PurchaseInvoiceItem value, $Res Function(PurchaseInvoiceItem) then) =
      _$PurchaseInvoiceItemCopyWithImpl<$Res, PurchaseInvoiceItem>;
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
class _$PurchaseInvoiceItemCopyWithImpl<$Res, $Val extends PurchaseInvoiceItem>
    implements $PurchaseInvoiceItemCopyWith<$Res> {
  _$PurchaseInvoiceItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PurchaseInvoiceItem
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
abstract class _$$PurchaseInvoiceItemImplCopyWith<$Res>
    implements $PurchaseInvoiceItemCopyWith<$Res> {
  factory _$$PurchaseInvoiceItemImplCopyWith(_$PurchaseInvoiceItemImpl value,
          $Res Function(_$PurchaseInvoiceItemImpl) then) =
      __$$PurchaseInvoiceItemImplCopyWithImpl<$Res>;
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
class __$$PurchaseInvoiceItemImplCopyWithImpl<$Res>
    extends _$PurchaseInvoiceItemCopyWithImpl<$Res, _$PurchaseInvoiceItemImpl>
    implements _$$PurchaseInvoiceItemImplCopyWith<$Res> {
  __$$PurchaseInvoiceItemImplCopyWithImpl(_$PurchaseInvoiceItemImpl _value,
      $Res Function(_$PurchaseInvoiceItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of PurchaseInvoiceItem
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
    return _then(_$PurchaseInvoiceItemImpl(
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
class _$PurchaseInvoiceItemImpl implements _PurchaseInvoiceItem {
  const _$PurchaseInvoiceItemImpl(
      {required this.productId,
      required this.productName,
      required this.quantity,
      required this.unitPrice,
      required this.total,
      this.description});

  factory _$PurchaseInvoiceItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseInvoiceItemImplFromJson(json);

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
    return 'PurchaseInvoiceItem(productId: $productId, productName: $productName, quantity: $quantity, unitPrice: $unitPrice, total: $total, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseInvoiceItemImpl &&
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

  /// Create a copy of PurchaseInvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseInvoiceItemImplCopyWith<_$PurchaseInvoiceItemImpl> get copyWith =>
      __$$PurchaseInvoiceItemImplCopyWithImpl<_$PurchaseInvoiceItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseInvoiceItemImplToJson(
      this,
    );
  }
}

abstract class _PurchaseInvoiceItem implements PurchaseInvoiceItem {
  const factory _PurchaseInvoiceItem(
      {required final String productId,
      required final String productName,
      required final int quantity,
      required final double unitPrice,
      required final double total,
      final String? description}) = _$PurchaseInvoiceItemImpl;

  factory _PurchaseInvoiceItem.fromJson(Map<String, dynamic> json) =
      _$PurchaseInvoiceItemImpl.fromJson;

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

  /// Create a copy of PurchaseInvoiceItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PurchaseInvoiceItemImplCopyWith<_$PurchaseInvoiceItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

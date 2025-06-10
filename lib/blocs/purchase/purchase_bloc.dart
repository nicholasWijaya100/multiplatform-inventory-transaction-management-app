import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/purchase_order_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/warehouse_document_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/purchase_repository.dart';
import '../../data/repositories/warehouse_document_repository.dart';
import '../../data/repositories/warehouse_repository.dart';
import '../../utils/service_locator.dart';
import '../auth/auth_bloc.dart';
import '../product/product_bloc.dart';
import '../purchase_invoice/purchase_invoice_bloc.dart';

// Events
abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

class LoadPurchaseOrders extends PurchaseEvent {
  final bool showCompleted;

  const LoadPurchaseOrders({
    this.showCompleted = false,
  });

  @override
  List<Object?> get props => [showCompleted];
}

class LoadPurchaseOrdersForPeriod extends PurchaseEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadPurchaseOrdersForPeriod({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class ReceivePurchaseOrder extends PurchaseEvent {
  final String orderId;
  final String warehouseId;

  const ReceivePurchaseOrder({
    required this.orderId,
    required this.warehouseId,
  });

  @override
  List<Object?> get props => [orderId, warehouseId];
}

class SearchPurchaseOrders extends PurchaseEvent {
  final String query;

  const SearchPurchaseOrders(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterPurchaseOrdersBySupplier extends PurchaseEvent {
  final String? supplierId;

  const FilterPurchaseOrdersBySupplier(this.supplierId);

  @override
  List<Object?> get props => [supplierId];
}

class FilterPurchaseOrdersByStatus extends PurchaseEvent {
  final String? status;

  const FilterPurchaseOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class ShowCompletedPurchaseOrders extends PurchaseEvent {
  final bool show;

  const ShowCompletedPurchaseOrders(this.show);

  @override
  List<Object?> get props => [show];
}

class AddPurchaseOrder extends PurchaseEvent {
  final PurchaseOrderModel order;

  const AddPurchaseOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdatePurchaseOrderStatus extends PurchaseEvent {
  final String orderId;
  final String status;

  const UpdatePurchaseOrderStatus(this.orderId, this.status);

  @override
  List<Object?> get props => [orderId, status];
}

class UpdatePurchaseOrderPaymentStatus extends PurchaseEvent {
  final String orderId;
  final bool isPaid;

  const UpdatePurchaseOrderPaymentStatus(this.orderId, this.isPaid);

  @override
  List<Object?> get props => [orderId, isPaid];
}

// States
abstract class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object?> get props => [];
}

class PurchaseInitial extends PurchaseState {}

class PurchaseLoading extends PurchaseState {}

class PurchaseOrdersLoaded extends PurchaseState {
  final List<PurchaseOrderModel> orders;
  final String? searchQuery;
  final String? supplierFilter;
  final String? statusFilter;
  final bool showCompleted;
  final double totalOrders;
  final double pendingOrders;
  final double totalValue;

  const PurchaseOrdersLoaded({
    required this.orders,
    this.searchQuery,
    this.supplierFilter,
    this.statusFilter,
    this.showCompleted = false,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalValue,
  });

  @override
  List<Object?> get props => [
    orders,
    searchQuery,
    supplierFilter,
    statusFilter,
    showCompleted,
    totalOrders,
    pendingOrders,
    totalValue,
  ];
}

class PurchaseError extends PurchaseState {
  final String message;

  const PurchaseError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdatePurchaseOrderStatusWithWarehouse extends PurchaseEvent {
  final String orderId;
  final String status;
  final String warehouseId;

  const UpdatePurchaseOrderStatusWithWarehouse(this.orderId, this.status, this.warehouseId);

  @override
  List<Object?> get props => [orderId, status, warehouseId];
}

// BLoC
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final PurchaseRepository _purchaseRepository;
  String? _currentSearchQuery;
  String? _currentSupplierFilter;
  String? _currentStatusFilter;
  bool _showCompleted = false;

  PurchaseBloc({
    required PurchaseRepository purchaseRepository,
  })  : _purchaseRepository = purchaseRepository,
        super(PurchaseInitial()) {
    on<LoadPurchaseOrders>(_onLoadPurchaseOrders);
    on<SearchPurchaseOrders>(_onSearchPurchaseOrders);
    on<FilterPurchaseOrdersBySupplier>(_onFilterPurchaseOrdersBySupplier);
    on<FilterPurchaseOrdersByStatus>(_onFilterPurchaseOrdersByStatus);
    //on<ShowCompletedPurchaseOrders>(_onShowCompletedPurchaseOrders);
    on<AddPurchaseOrder>(_onAddPurchaseOrder);
    on<UpdatePurchaseOrderStatus>(_onUpdatePurchaseOrderStatus);
    on<UpdatePurchaseOrderPaymentStatus>(_onUpdatePurchaseOrderPaymentStatus);
    on<ReceivePurchaseOrder>(_onReceivePurchaseOrder);
    on<UpdatePurchaseOrderStatusWithWarehouse>(_onUpdatePurchaseOrderStatusWithWarehouse);
  }

  Future<void> _onReceivePurchaseOrder(
      ReceivePurchaseOrder event,
      Emitter<PurchaseState> emit,
      ) async {
    emit(PurchaseLoading());
    try {
      // 1. Get the purchase order to access items
      final order = await _purchaseRepository.getPurchaseOrder(event.orderId);

      // 2. Get warehouse information
      final warehouseRepository = locator<WarehouseRepository>();
      final warehouses = await warehouseRepository.getWarehouses();
      final warehouse = warehouses.firstWhere(
            (w) => w.id == event.warehouseId,
        orElse: () => throw Exception('Warehouse not found'),
      );

      // 3. Create entry waybill document
      final warehouseDocumentRepository = locator<WarehouseDocumentRepository>();
      final authBloc = locator<AuthBloc>();
      final authState = authBloc.state;

      late final currentUser;

      if (authState is Authenticated) {
        currentUser = authState.user;
      } else {
        // fall back to repo (could still be null-check here)
        currentUser = await locator<AuthRepository>().getCurrentUser();
      }

      // Convert purchase order items to warehouse document items
      final documentItems = order.items.map((orderItem) async {
        // Get product details
        final productRepository = locator<ProductRepository>();
        final product = await productRepository.getProduct(orderItem.productId);

        return WarehouseDocumentItem(
          productId: orderItem.productId,
          productName: orderItem.productName,
          productSku: product.sku ?? orderItem.productId,
          quantity: orderItem.quantity,
          unit: 'pcs', // Default unit since PurchaseOrderItem doesn't have unit field
          batchNumber: null, // Can be added later if needed
          expiryDate: null, // Can be added later if needed
          notes: orderItem.notes,
        );
      }).toList();

      // Wait for all items to be converted
      final resolvedItems = await Future.wait(documentItems);

      // Create the entry waybill
      final entryWaybill = WarehouseDocumentModel(
        id: '', // Will be set by Firestore
        documentNumber: '', // Will be generated by repository
        type: WarehouseDocumentType.entryWaybill,
        warehouseId: event.warehouseId,
        warehouseName: warehouse.name,
        relatedOrderId: order.id,
        relatedOrderNumber: order.id,
        items: resolvedItems,
        status: WarehouseDocumentStatus.pending,
        createdBy: currentUser.id,
        createdAt: DateTime.now(),
        completedAt: null,
        notes: 'Auto-generated from Purchase Order #${order.id}',
        metadata: {
          'supplierId': order.supplierId,
          'supplierName': order.supplierName,
          'purchaseOrderTotal': order.totalAmount,
        },
      );

      await warehouseDocumentRepository.createDocument(entryWaybill);

      // 4. Update purchase order status to received
      await _purchaseRepository.updatePurchaseOrderStatus(
        event.orderId,
        PurchaseOrderStatus.received.name,
        event.warehouseId,
      );

      // Note: Stock update will be done when the entry waybill is marked as completed
      // This gives warehouse staff the chance to verify the received items

      add(LoadPurchaseOrders());
    } catch (e) {
      emit(PurchaseError(e.toString()));
      add(LoadPurchaseOrders());
    }
  }

  Future<void> _onLoadPurchaseOrders(
      LoadPurchaseOrders event,
      Emitter<PurchaseState> emit,
      ) async {
    emit(PurchaseLoading());
    try {
      final orders = await _purchaseRepository.getPurchaseOrders(
        searchQuery: _currentSearchQuery,
        supplierFilter: _currentSupplierFilter,
        statusFilter: _currentStatusFilter,
      );

      final totalOrders = orders.length.toDouble();
      final pendingOrders = orders
          .where((order) => order.status == PurchaseOrderStatus.pending.name)
          .length
          .toDouble();
      final totalValue = orders.fold<double>(
        0,
            (sum, order) => sum + order.totalAmount,
      );

      emit(PurchaseOrdersLoaded(
        orders: orders,
        searchQuery: _currentSearchQuery,
        supplierFilter: _currentSupplierFilter,
        statusFilter: _currentStatusFilter,
        showCompleted: _showCompleted,
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        totalValue: totalValue,
      ));
    } catch (e) {
      emit(PurchaseError(e.toString()));
    }
  }

  Future<void> _onUpdatePurchaseOrderPaymentStatus(
      UpdatePurchaseOrderPaymentStatus event,
      Emitter<PurchaseState> emit,
      ) async {
    emit(PurchaseLoading());
    try {
      await _purchaseRepository.updatePurchaseOrderPaymentStatus(
        event.orderId,
        event.isPaid,
      );
      add(LoadPurchaseOrders());
    } catch (e) {
      emit(PurchaseError(e.toString()));
      add(LoadPurchaseOrders());
    }
  }

  void _onSearchPurchaseOrders(
      SearchPurchaseOrders event,
      Emitter<PurchaseState> emit,
      ) {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadPurchaseOrders());
  }

  void _onFilterPurchaseOrdersBySupplier(
      FilterPurchaseOrdersBySupplier event,
      Emitter<PurchaseState> emit,
      ) {
    _currentSupplierFilter = event.supplierId;
    add(LoadPurchaseOrders());
  }

  void _onFilterPurchaseOrdersByStatus(
      FilterPurchaseOrdersByStatus event,
      Emitter<PurchaseState> emit,
      ) {
    _currentStatusFilter = event.status;
    add(LoadPurchaseOrders());
  }

  /*
  void _onShowCompletedPurchaseOrders(
      ShowCompletedPurchaseOrders event,
      Emitter<PurchaseState> emit,
      ) {
    _showCompleted = event.show;
    add(LoadPurchaseOrders());
  }
   */

  Future<void> _onAddPurchaseOrder(
      AddPurchaseOrder event,
      Emitter<PurchaseState> emit,
      ) async {
    emit(PurchaseLoading());
    try {
      await _purchaseRepository.addPurchaseOrder(event.order);
      add(LoadPurchaseOrders());
    } catch (e) {
      emit(PurchaseError(e.toString()));
      add(LoadPurchaseOrders());
    }
  }

  Future<void> _onUpdatePurchaseOrderStatus(
      UpdatePurchaseOrderStatus event,
      Emitter<PurchaseState> emit,
      ) async {
    emit(PurchaseLoading());
    try {
      // If changing to confirmed status, create entry waybill
      if (event.status == 'confirmed') {
        // Get the purchase order details
        final order = await _purchaseRepository.getPurchaseOrder(event.orderId);

        // Get warehouse information - you might need to show a dialog to select warehouse
        // For now, let's assume there's a default warehouse or it's passed with the event
        final warehouseRepository = locator<WarehouseRepository>();
        final warehouses = await warehouseRepository.getWarehouses();
        final defaultWarehouse = warehouses.firstWhere(
              (w) => w.isActive,
          orElse: () => throw Exception('No active warehouse found'),
        );

        // Create entry waybill document
        final warehouseDocumentRepository = locator<WarehouseDocumentRepository>();
        final authBloc = locator<AuthBloc>();
        final authState = authBloc.state;

        late final currentUser;

        if (authState is Authenticated) {
          currentUser = authState.user;
        } else {
          // fall back to repo (could still be null-check here)
          currentUser = await locator<AuthRepository>().getCurrentUser();
        }

        // Convert purchase order items to warehouse document items
        final documentItems = order.items.map((orderItem) async {
          final productRepository = locator<ProductRepository>();
          final product = await productRepository.getProduct(orderItem.productId);

          return WarehouseDocumentItem(
            productId: orderItem.productId,
            productName: orderItem.productName,
            productSku: product.sku ?? orderItem.productId,
            quantity: orderItem.quantity,
            unit: 'pcs', // Default unit
            batchNumber: null,
            expiryDate: null,
            notes: orderItem.notes,
          );
        }).toList();

        final resolvedItems = await Future.wait(documentItems);

        final entryWaybill = WarehouseDocumentModel(
          id: '', // Will be set by Firestore
          documentNumber: '', // Will be generated by repository
          type: WarehouseDocumentType.entryWaybill,
          warehouseId: defaultWarehouse.id,
          warehouseName: defaultWarehouse.name,
          relatedOrderId: order.id,
          relatedOrderNumber: order.id,
          items: resolvedItems,
          status: WarehouseDocumentStatus.pending,
          createdBy: currentUser.id,
          createdAt: DateTime.now(),
          completedAt: null,
          notes: 'Auto-generated from Purchase Order #${order.id}',
          metadata: {
            'supplierId': order.supplierId,
            'supplierName': order.supplierName,
            'purchaseOrderTotal': order.totalAmount,
          },
        );

        await warehouseDocumentRepository.createDocument(entryWaybill);
      }

      // Update purchase order status
      await _purchaseRepository.updatePurchaseOrderStatus(
        event.orderId,
        event.status,
      );

      // Notify the purchase invoice bloc about the status change
      if (event.status == 'cancelled') {
        try {
          final purchaseInvoiceBloc = locator<PurchaseInvoiceBloc>();
          purchaseInvoiceBloc.add(PurchaseOrderStatusChanged(event.orderId, event.status));
        } catch (e) {
          print('Error notifying purchase invoice bloc: $e');
        }
      }

      add(LoadPurchaseOrders());
    } catch (e) {
      emit(PurchaseError(e.toString()));
      add(LoadPurchaseOrders());
    }
  }

  Future<void> _onUpdatePurchaseOrderStatusWithWarehouse(
      UpdatePurchaseOrderStatusWithWarehouse event,
      Emitter<PurchaseState> emit,
      ) async {
    emit(PurchaseLoading());
    try {
      // If changing to confirmed status, create entry waybill with selected warehouse
      if (event.status == 'confirmed') {
        // Get the purchase order details
        final order = await _purchaseRepository.getPurchaseOrder(event.orderId);

        // Get warehouse information
        final warehouseRepository = locator<WarehouseRepository>();
        final warehouse = await warehouseRepository.getWarehouse(event.warehouseId);

        // Create entry waybill document
        final warehouseDocumentRepository = locator<WarehouseDocumentRepository>();
        final authBloc = locator<AuthBloc>();
        final authState = authBloc.state;

        late final currentUser;

        if (authState is Authenticated) {
          currentUser = authState.user;
        } else {
          // fall back to repo (could still be null-check here)
          currentUser = await locator<AuthRepository>().getCurrentUser();
        }

        // Convert purchase order items to warehouse document items
        final documentItems = order.items.map((orderItem) async {
          final productRepository = locator<ProductRepository>();
          final product = await productRepository.getProduct(orderItem.productId);

          return WarehouseDocumentItem(
            productId: orderItem.productId,
            productName: orderItem.productName,
            productSku: product.sku ?? orderItem.productId,
            quantity: orderItem.quantity,
            unit: 'pcs',
            batchNumber: null,
            expiryDate: null,
            notes: orderItem.notes,
          );
        }).toList();

        final resolvedItems = await Future.wait(documentItems);

        final entryWaybill = WarehouseDocumentModel(
          id: '',
          documentNumber: '',
          type: WarehouseDocumentType.entryWaybill,
          warehouseId: event.warehouseId,
          warehouseName: warehouse.name,
          relatedOrderId: order.id,
          relatedOrderNumber: order.id,
          items: resolvedItems,
          status: WarehouseDocumentStatus.pending,
          createdBy: currentUser.id,
          createdAt: DateTime.now(),
          completedAt: null,
          notes: 'Auto-generated from Purchase Order #${order.id}',
          metadata: {
            'supplierId': order.supplierId,
            'supplierName': order.supplierName,
            'purchaseOrderTotal': order.totalAmount,
          },
        );

        await warehouseDocumentRepository.createDocument(entryWaybill);
      }

      // Update purchase order status
      await _purchaseRepository.updatePurchaseOrderStatus(
        event.orderId,
        event.status,
      );

      add(LoadPurchaseOrders());
    } catch (e) {
      emit(PurchaseError(e.toString()));
      add(LoadPurchaseOrders());
    }
  }

  // Helper methods for status management
  List<String> getNextPossibleStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'draft':
        return ['pending', 'cancelled'];
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['cancelled']; // Can only be cancelled now, received happens automatically
      case 'received':
        return ['completed']; // Can only be completed once received
      case 'completed':
        return [];
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }

// The getStatusLabel and getStatusColor methods remain the same
  String getStatusLabel(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'received':
        return 'Received';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'received':
        return Colors.green;
      case 'completed':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/sales_order_model.dart';
import '../../data/models/warehouse_document_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/sales_order_repository.dart';
import '../../data/repositories/warehouse_document_repository.dart';
import '../../data/repositories/warehouse_repository.dart';
import '../../utils/service_locator.dart';
import '../auth/auth_bloc.dart';
import '../invoice/invoice_bloc.dart';

// Events
abstract class SalesOrderEvent extends Equatable {
  const SalesOrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesOrders extends SalesOrderEvent {}

class SearchSalesOrders extends SalesOrderEvent {
  final String query;

  const SearchSalesOrders(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateSalesOrderStatusWithWarehouse extends SalesOrderEvent {
  final String orderId;
  final String status;
  final String warehouseId;

  const UpdateSalesOrderStatusWithWarehouse(this.orderId, this.status, this.warehouseId);

  @override
  List<Object?> get props => [orderId, status, warehouseId];
}

class FilterSalesOrdersByCustomer extends SalesOrderEvent {
  final String? customerId;

  const FilterSalesOrdersByCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class LoadSalesOrdersForPeriod extends SalesOrderEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadSalesOrdersForPeriod({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class FilterSalesOrdersByStatus extends SalesOrderEvent {
  final String? status;

  const FilterSalesOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class AddSalesOrder extends SalesOrderEvent {
  final SalesOrderModel order;

  const AddSalesOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdateSalesOrderStatus extends SalesOrderEvent {
  final String orderId;
  final String status;

  const UpdateSalesOrderStatus(this.orderId, this.status);

  @override
  List<Object?> get props => [orderId, status];
}

class UpdateSalesOrderPaymentStatus extends SalesOrderEvent {
  final String orderId;
  final bool isPaid;

  const UpdateSalesOrderPaymentStatus(this.orderId, this.isPaid);

  @override
  List<Object?> get props => [orderId, isPaid];
}

// States
abstract class SalesOrderState extends Equatable {
  const SalesOrderState();

  @override
  List<Object?> get props => [];
}

class SalesOrderInitial extends SalesOrderState {}

class SalesOrderLoading extends SalesOrderState {}

class SalesOrdersLoaded extends SalesOrderState {
  final List<SalesOrderModel> orders;
  final String? searchQuery;
  final String? customerFilter;
  final String? statusFilter;
  final double totalOrders;
  final double pendingOrders;
  final double totalValue;

  const SalesOrdersLoaded({
    required this.orders,
    this.searchQuery,
    this.customerFilter,
    this.statusFilter,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalValue,
  });

  @override
  List<Object?> get props => [
    orders,
    searchQuery,
    customerFilter,
    statusFilter,
    totalOrders,
    pendingOrders,
    totalValue,
  ];
}

class SalesOrderError extends SalesOrderState {
  final String message;

  const SalesOrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class SalesOrderBloc extends Bloc<SalesOrderEvent, SalesOrderState> {
  final SalesOrderRepository _salesOrderRepository;
  String? _currentSearchQuery;
  String? _currentCustomerFilter;
  String? _currentStatusFilter;

  SalesOrderBloc({
    required SalesOrderRepository salesOrderRepository,
  })  : _salesOrderRepository = salesOrderRepository,
        super(SalesOrderInitial()) {
    on<LoadSalesOrders>(_onLoadSalesOrders);
    on<SearchSalesOrders>(_onSearchSalesOrders);
    on<FilterSalesOrdersByCustomer>(_onFilterSalesOrdersByCustomer);
    on<FilterSalesOrdersByStatus>(_onFilterSalesOrdersByStatus);
    on<AddSalesOrder>(_onAddSalesOrder);
    on<UpdateSalesOrderStatus>(_onUpdateSalesOrderStatus);
    on<UpdateSalesOrderPaymentStatus>(_onUpdateSalesOrderPaymentStatus);
    on<UpdateSalesOrderStatusWithWarehouse>(_onUpdateSalesOrderStatusWithWarehouse);
  }

  Future<void> _onLoadSalesOrders(
      LoadSalesOrders event,
      Emitter<SalesOrderState> emit,
      ) async {
    emit(SalesOrderLoading());
    try {
      final orders = await _salesOrderRepository.getSalesOrders(
        searchQuery: _currentSearchQuery,
        customerFilter: _currentCustomerFilter,
        statusFilter: _currentStatusFilter,
      );

      final totalOrders = orders.length.toDouble();
      final pendingOrders = orders
          .where((order) => order.status == SalesOrderStatus.pending.name)
          .length
          .toDouble();

      // Update this to only count delivered orders
      final totalValue = orders
          .where((order) => order.status == SalesOrderStatus.delivered.name)
          .fold<double>(
        0,
            (sum, order) => sum + order.totalAmount,
      );

      emit(SalesOrdersLoaded(
        orders: orders,
        searchQuery: _currentSearchQuery,
        customerFilter: _currentCustomerFilter,
        statusFilter: _currentStatusFilter,
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        totalValue: totalValue,
      ));
    } catch (e) {
      emit(SalesOrderError(e.toString()));
    }
  }

  void _onSearchSalesOrders(
      SearchSalesOrders event,
      Emitter<SalesOrderState> emit,
      ) {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadSalesOrders());
  }

  void _onFilterSalesOrdersByCustomer(
      FilterSalesOrdersByCustomer event,
      Emitter<SalesOrderState> emit,
      ) {
    _currentCustomerFilter = event.customerId;
    add(LoadSalesOrders());
  }

  void _onFilterSalesOrdersByStatus(
      FilterSalesOrdersByStatus event,
      Emitter<SalesOrderState> emit,
      ) {
    _currentStatusFilter = event.status;
    add(LoadSalesOrders());
  }

  Future<void> _onAddSalesOrder(
      AddSalesOrder event,
      Emitter<SalesOrderState> emit,
      ) async {
    emit(SalesOrderLoading());
    try {
      final order = await _salesOrderRepository.addSalesOrder(event.order);

      // Update customer purchase stats
      // final customerRepository = locator<CustomerRepository>();
      // await customerRepository.updateCustomerPurchaseStats(
      //   order.customerId,
      //   order.totalAmount,
      // );

      add(LoadSalesOrders());
    } catch (e) {
      emit(SalesOrderError(e.toString()));
      add(LoadSalesOrders());
    }
  }

  Future<void> _onUpdateSalesOrderStatus(
      UpdateSalesOrderStatus event,
      Emitter<SalesOrderState> emit,
      ) async {
    emit(SalesOrderLoading());
    try {
      // Get the order details first
      final order = await _salesOrderRepository.getSalesOrder(event.orderId);

      // If changing to delivered status, update customer purchase stats
      if (event.status == 'delivered') {
        final customerRepository = locator<CustomerRepository>();
        await customerRepository.updateCustomerPurchaseStats(
          order.customerId,
          order.totalAmount,
        );
      }

      // If changing to shipped status, create delivery note
      if (event.status == 'shipped') {
        // Get the sales order details
        final order = await _salesOrderRepository.getSalesOrder(event.orderId);

        // Get warehouse information - you might need to show a dialog to select warehouse
        // For now, let's assume there's a default warehouse or it's passed with the event
        final warehouseRepository = locator<WarehouseRepository>();
        final warehouses = await warehouseRepository.getWarehouses();
        final defaultWarehouse = warehouses.firstWhere(
              (w) => w.isActive,
          orElse: () => throw Exception('No active warehouse found'),
        );

        // Create delivery note document
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

        // Convert sales order items to warehouse document items
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

        final deliveryNote = WarehouseDocumentModel(
          id: '', // Will be set by Firestore
          documentNumber: '', // Will be generated by repository
          type: WarehouseDocumentType.deliveryNote,
          warehouseId: defaultWarehouse.id,
          warehouseName: defaultWarehouse.name,
          relatedOrderId: order.id,
          relatedOrderNumber: order.id,
          items: resolvedItems,
          status: WarehouseDocumentStatus.pending,
          createdBy: currentUser.id,
          createdAt: DateTime.now(),
          completedAt: null,
          notes: 'Auto-generated from Sales Order #${order.id}',
          metadata: {
            'customerId': order.customerId,
            'customerName': order.customerName,
            'salesOrderTotal': order.totalAmount,
          },
        );

        await warehouseDocumentRepository.createDocument(deliveryNote);
      }

      await _salesOrderRepository.updateSalesOrderStatus(
        event.orderId,
        event.status,
      );

      // Notify the invoice bloc about the status change
      if (event.status == 'cancelled') {
        try {
          final invoiceBloc = locator<InvoiceBloc>();
          invoiceBloc.add(SalesOrderStatusChanged(event.orderId, event.status));
        } catch (e) {
          // Log error but don't change sales order state
          print('Error notifying invoice bloc: $e');
        }
      }

      add(LoadSalesOrders());
    } catch (e) {
      emit(SalesOrderError(e.toString()));
      add(LoadSalesOrders());
    }
  }

  Future<void> _onUpdateSalesOrderStatusWithWarehouse(
      UpdateSalesOrderStatusWithWarehouse event,
      Emitter<SalesOrderState> emit,
      ) async {
    emit(SalesOrderLoading());
    try {
      // If changing to shipped status, create delivery note with selected warehouse
      if (event.status == 'shipped') {
        // Get the sales order details
        final order = await _salesOrderRepository.getSalesOrder(event.orderId);

        // Get warehouse information
        final warehouseRepository = locator<WarehouseRepository>();
        final warehouse = await warehouseRepository.getWarehouse(event.warehouseId);

        // Create delivery note document
        final warehouseDocumentRepository = locator<WarehouseDocumentRepository>();
        final authBloc = locator<AuthBloc>();
        final authState = authBloc.state;

        late final currentUser;

        if (authState is Authenticated) {
          currentUser = authState.user;
        } else {
          currentUser = await locator<AuthRepository>().getCurrentUser();
        }

        // Convert sales order items to warehouse document items
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

        final deliveryNote = WarehouseDocumentModel(
          id: '',
          documentNumber: '',
          type: WarehouseDocumentType.deliveryNote,
          warehouseId: event.warehouseId,
          warehouseName: warehouse.name,
          relatedOrderId: order.id,
          relatedOrderNumber: order.id,
          items: resolvedItems,
          status: WarehouseDocumentStatus.pending,
          createdBy: currentUser.id,
          createdAt: DateTime.now(),
          completedAt: null,
          notes: 'Auto-generated from Sales Order #${order.id}',
          metadata: {
            'customerId': order.customerId,
            'customerName': order.customerName,
            'salesOrderTotal': order.totalAmount,
          },
        );

        await warehouseDocumentRepository.createDocument(deliveryNote);
      }

      // Update sales order status
      await _salesOrderRepository.updateSalesOrderStatus(
        event.orderId,
        event.status,
      );

      add(LoadSalesOrders());
    } catch (e) {
      emit(SalesOrderError(e.toString()));
      add(LoadSalesOrders());
    }
  }

  Future<void> _onUpdateSalesOrderPaymentStatus(
      UpdateSalesOrderPaymentStatus event,
      Emitter<SalesOrderState> emit,
      ) async {
    emit(SalesOrderLoading());
    try {
      await _salesOrderRepository.updateSalesOrderPaymentStatus(
        event.orderId,
        event.isPaid,
      );
      add(LoadSalesOrders());
    } catch (e) {
      emit(SalesOrderError(e.toString()));
      add(LoadSalesOrders());
    }
  }

  List<String> getNextPossibleStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'draft':
        return ['pending', 'cancelled'];
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['shipped', 'cancelled'];
      case 'shipped':
        return []; // Remove all manual transitions - only warehouse documents can change this
      case 'delivered':
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }
}
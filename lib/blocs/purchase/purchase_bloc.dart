import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/purchase_order_model.dart';
import '../../data/repositories/purchase_repository.dart';

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

  List<String> getNextPossibleStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'draft':
        return ['pending', 'cancelled'];
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['received', 'cancelled'];
      case 'received':
        return ['completed', 'cancelled'];
      case 'completed':
        return [];
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }
}
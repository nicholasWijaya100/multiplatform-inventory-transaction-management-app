import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/warehouse_model.dart';
import '../../data/repositories/warehouse_repository.dart';

// Events
abstract class WarehouseEvent extends Equatable {
  const WarehouseEvent();

  @override
  List<Object?> get props => [];
}

class LoadWarehouses extends WarehouseEvent {}

class SearchWarehouses extends WarehouseEvent {
  final String query;

  const SearchWarehouses(this.query);

  @override
  List<Object?> get props => [query];
}

class ShowInactiveWarehouses extends WarehouseEvent {
  final bool show;

  const ShowInactiveWarehouses(this.show);

  @override
  List<Object?> get props => [show];
}

class AddWarehouse extends WarehouseEvent {
  final WarehouseModel warehouse;

  const AddWarehouse(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

class UpdateWarehouse extends WarehouseEvent {
  final WarehouseModel warehouse;

  const UpdateWarehouse(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

class UpdateWarehouseStatus extends WarehouseEvent {
  final String warehouseId;
  final bool isActive;

  const UpdateWarehouseStatus(this.warehouseId, this.isActive);

  @override
  List<Object?> get props => [warehouseId, isActive];
}

class DeleteWarehouse extends WarehouseEvent {
  final String warehouseId;

  const DeleteWarehouse(this.warehouseId);

  @override
  List<Object?> get props => [warehouseId];
}

// States
abstract class WarehouseState extends Equatable {
  const WarehouseState();

  @override
  List<Object?> get props => [];
}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoading extends WarehouseState {}

class WarehousesLoaded extends WarehouseState {
  final List<WarehouseModel> warehouses;
  final String? searchQuery;
  final bool showInactive;
  final int totalWarehouses;
  final int activeWarehouses;
  final double totalValue;
  final int totalProducts;

  const WarehousesLoaded({
    required this.warehouses,
    this.searchQuery,
    this.showInactive = false,
    required this.totalWarehouses,
    required this.activeWarehouses,
    required this.totalValue,
    required this.totalProducts,
  });

  @override
  List<Object?> get props => [
    warehouses,
    searchQuery,
    showInactive,
    totalWarehouses,
    activeWarehouses,
    totalValue,
    totalProducts,
  ];
}

class WarehouseError extends WarehouseState {
  final String message;

  const WarehouseError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class WarehouseBloc extends Bloc<WarehouseEvent, WarehouseState> {
  final WarehouseRepository _warehouseRepository;
  String? _currentSearchQuery;
  bool _showInactive = false;

  WarehouseBloc({
    required WarehouseRepository warehouseRepository,
  })  : _warehouseRepository = warehouseRepository,
        super(WarehouseInitial()) {
    on<LoadWarehouses>(_onLoadWarehouses);
    on<SearchWarehouses>(_onSearchWarehouses);
    on<ShowInactiveWarehouses>(_onShowInactiveWarehouses);
    on<AddWarehouse>(_onAddWarehouse);
    on<UpdateWarehouse>(_onUpdateWarehouse);
    on<UpdateWarehouseStatus>(_onUpdateWarehouseStatus);
    on<DeleteWarehouse>(_onDeleteWarehouse);
  }

  Future<void> _onLoadWarehouses(
      LoadWarehouses event,
      Emitter<WarehouseState> emit,
      ) async {
    emit(WarehouseLoading());
    try {
      final warehouses = await _warehouseRepository.getWarehouses(
        searchQuery: _currentSearchQuery,
        includeInactive: _showInactive,
      );

      final activeWarehouses = warehouses.where((w) => w.isActive).length;
      final totalProducts = warehouses.fold<int>(
        0,
            (sum, warehouse) => sum + warehouse.totalProducts,
      );
      final totalValue = warehouses.fold<double>(
        0,
            (sum, warehouse) => sum + warehouse.totalValue,
      );

      emit(WarehousesLoaded(
        warehouses: warehouses,
        searchQuery: _currentSearchQuery,
        showInactive: _showInactive,
        totalWarehouses: warehouses.length,
        activeWarehouses: activeWarehouses,
        totalProducts: totalProducts,
        totalValue: totalValue,
      ));
    } catch (e) {
      emit(WarehouseError(e.toString()));
    }
  }

  Future<void> _onSearchWarehouses(
      SearchWarehouses event,
      Emitter<WarehouseState> emit,
      ) async {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadWarehouses());
  }

  Future<void> _onShowInactiveWarehouses(
      ShowInactiveWarehouses event,
      Emitter<WarehouseState> emit,
      ) async {
    _showInactive = event.show;
    add(LoadWarehouses());
  }

  Future<void> _onAddWarehouse(
      AddWarehouse event,
      Emitter<WarehouseState> emit,
      ) async {
    emit(WarehouseLoading());
    try {
      await _warehouseRepository.addWarehouse(event.warehouse);
      add(LoadWarehouses());
    } catch (e) {
      emit(WarehouseError(e.toString()));
      add(LoadWarehouses());
    }
  }

  Future<void> _onUpdateWarehouse(
      UpdateWarehouse event,
      Emitter<WarehouseState> emit,
      ) async {
    emit(WarehouseLoading());
    try {
      await _warehouseRepository.updateWarehouse(event.warehouse);
      add(LoadWarehouses());
    } catch (e) {
      emit(WarehouseError(e.toString()));
      add(LoadWarehouses());
    }
  }

  Future<void> _onUpdateWarehouseStatus(
      UpdateWarehouseStatus event,
      Emitter<WarehouseState> emit,
      ) async {
    emit(WarehouseLoading());
    try {
      await _warehouseRepository.updateWarehouseStatus(
        event.warehouseId,
        event.isActive,
      );
      add(LoadWarehouses()); // This will recalculate totals
    } catch (e) {
      emit(WarehouseError(e.toString()));
      add(LoadWarehouses());
    }
  }

  Future<void> _onDeleteWarehouse(
      DeleteWarehouse event,
      Emitter<WarehouseState> emit,
      ) async {
    emit(WarehouseLoading());
    try {
      await _warehouseRepository.deleteWarehouse(event.warehouseId);
      add(LoadWarehouses());
    } catch (e) {
      emit(WarehouseError(e.toString()));
      add(LoadWarehouses());
    }
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/supplier_model.dart';
import '../../data/repositories/supplier_repository.dart';

// Events
abstract class SupplierEvent extends Equatable {
  const SupplierEvent();

  @override
  List<Object?> get props => [];
}

class LoadSuppliers extends SupplierEvent {}

class SearchSuppliers extends SupplierEvent {
  final String query;

  const SearchSuppliers(this.query);

  @override
  List<Object?> get props => [query];
}

class ShowInactiveSuppliers extends SupplierEvent {
  final bool show;

  const ShowInactiveSuppliers(this.show);

  @override
  List<Object?> get props => [show];
}

class AddSupplier extends SupplierEvent {
  final SupplierModel supplier;

  const AddSupplier(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class UpdateSupplier extends SupplierEvent {
  final SupplierModel supplier;

  const UpdateSupplier(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class UpdateSupplierStatus extends SupplierEvent {
  final String supplierId;
  final bool isActive;

  const UpdateSupplierStatus(this.supplierId, this.isActive);

  @override
  List<Object?> get props => [supplierId, isActive];
}

class DeleteSupplier extends SupplierEvent {
  final String supplierId;

  const DeleteSupplier(this.supplierId);

  @override
  List<Object?> get props => [supplierId];
}

// States
abstract class SupplierState extends Equatable {
  const SupplierState();

  @override
  List<Object?> get props => [];
}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SuppliersLoaded extends SupplierState {
  final List<SupplierModel> suppliers;
  final String? searchQuery;
  final bool showInactive;
  final int totalSuppliers;
  final int activeSuppliers;
  final double totalPurchases;

  const SuppliersLoaded({
    required this.suppliers,
    this.searchQuery,
    this.showInactive = false,
    required this.totalSuppliers,
    required this.activeSuppliers,
    required this.totalPurchases,
  });

  @override
  List<Object?> get props => [
    suppliers,
    searchQuery,
    showInactive,
    totalSuppliers,
    activeSuppliers,
    totalPurchases,
  ];
}

class SupplierError extends SupplierState {
  final String message;

  const SupplierError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierRepository _supplierRepository;
  String? _currentSearchQuery;
  bool _showInactive = false;

  SupplierBloc({
    required SupplierRepository supplierRepository,
  })  : _supplierRepository = supplierRepository,
        super(SupplierInitial()) {
    on<LoadSuppliers>(_onLoadSuppliers);
    on<SearchSuppliers>(_onSearchSuppliers);
    on<ShowInactiveSuppliers>(_onShowInactiveSuppliers);
    on<AddSupplier>(_onAddSupplier);
    on<UpdateSupplier>(_onUpdateSupplier);
    on<UpdateSupplierStatus>(_onUpdateSupplierStatus);
    on<DeleteSupplier>(_onDeleteSupplier);
  }

  Future<void> _onLoadSuppliers(
      LoadSuppliers event,
      Emitter<SupplierState> emit,
      ) async {
    emit(SupplierLoading());
    try {
      final suppliers = await _supplierRepository.getSuppliers(
        searchQuery: _currentSearchQuery,
        includeInactive: _showInactive,
      );

      final activeSuppliers = suppliers.where((s) => s.isActive).length;
      final totalPurchases = suppliers.fold<double>(
        0,
            (sum, supplier) => sum + supplier.totalPurchases,
      );

      emit(SuppliersLoaded(
        suppliers: suppliers,
        searchQuery: _currentSearchQuery,
        showInactive: _showInactive,
        totalSuppliers: suppliers.length,
        activeSuppliers: activeSuppliers,
        totalPurchases: totalPurchases,
      ));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onSearchSuppliers(
      SearchSuppliers event,
      Emitter<SupplierState> emit,
      ) async {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadSuppliers());
  }

  Future<void> _onShowInactiveSuppliers(
      ShowInactiveSuppliers event,
      Emitter<SupplierState> emit,
      ) async {
    _showInactive = event.show;
    add(LoadSuppliers());
  }

  Future<void> _onAddSupplier(
      AddSupplier event,
      Emitter<SupplierState> emit,
      ) async {
    emit(SupplierLoading());
    try {
      await _supplierRepository.addSupplier(event.supplier);
      add(LoadSuppliers());
    } catch (e) {
      emit(SupplierError(e.toString()));
      add(LoadSuppliers());
    }
  }

  Future<void> _onUpdateSupplier(
      UpdateSupplier event,
      Emitter<SupplierState> emit,
      ) async {
    emit(SupplierLoading());
    try {
      await _supplierRepository.updateSupplier(event.supplier);
      add(LoadSuppliers());
    } catch (e) {
      emit(SupplierError(e.toString()));
      add(LoadSuppliers());
    }
  }

  Future<void> _onUpdateSupplierStatus(
      UpdateSupplierStatus event,
      Emitter<SupplierState> emit,
      ) async {
    emit(SupplierLoading());
    try {
      await _supplierRepository.updateSupplierStatus(
        event.supplierId,
        event.isActive,
      );
      add(LoadSuppliers());
    } catch (e) {
      emit(SupplierError(e.toString()));
      add(LoadSuppliers());
    }
  }

  Future<void> _onDeleteSupplier(
      DeleteSupplier event,
      Emitter<SupplierState> emit,
      ) async {
    emit(SupplierLoading());
    try {
      await _supplierRepository.deleteSupplier(event.supplierId);
      add(LoadSuppliers());
    } catch (e) {
      emit(SupplierError(e.toString()));
      add(LoadSuppliers());
    }
  }
}
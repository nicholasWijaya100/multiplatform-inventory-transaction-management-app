import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

// Events
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {}

class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

class ShowInactiveCustomers extends CustomerEvent {
  final bool show;

  const ShowInactiveCustomers(this.show);

  @override
  List<Object?> get props => [show];
}

class AddCustomer extends CustomerEvent {
  final CustomerModel customer;

  const AddCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class UpdateCustomer extends CustomerEvent {
  final CustomerModel customer;

  const UpdateCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class UpdateCustomerStatus extends CustomerEvent {
  final String customerId;
  final bool isActive;

  const UpdateCustomerStatus(this.customerId, this.isActive);

  @override
  List<Object?> get props => [customerId, isActive];
}

class DeleteCustomer extends CustomerEvent {
  final String customerId;

  const DeleteCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

// States
abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomersLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final String? searchQuery;
  final bool showInactive;
  final int totalCustomers;
  final int activeCustomers;
  final double totalSales;

  const CustomersLoaded({
    required this.customers,
    this.searchQuery,
    this.showInactive = false,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.totalSales,
  });

  @override
  List<Object?> get props => [
    customers,
    searchQuery,
    showInactive,
    totalCustomers,
    activeCustomers,
    totalSales,
  ];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _customerRepository;
  String? _currentSearchQuery;
  bool _showInactive = false;

  CustomerBloc({
    required CustomerRepository customerRepository,
  })  : _customerRepository = customerRepository,
        super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<SearchCustomers>(_onSearchCustomers);
    on<ShowInactiveCustomers>(_onShowInactiveCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<UpdateCustomerStatus>(_onUpdateCustomerStatus);
    on<DeleteCustomer>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
      LoadCustomers event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());
    try {
      final customers = await _customerRepository.getCustomers(
        searchQuery: _currentSearchQuery,
        includeInactive: _showInactive,
      );

      final activeCustomers = customers.where((c) => c.isActive).length;
      final totalSales = customers.fold<double>(
        0,
            (sum, customer) => sum + customer.totalPurchases,
      );

      emit(CustomersLoaded(
        customers: customers,
        searchQuery: _currentSearchQuery,
        showInactive: _showInactive,
        totalCustomers: customers.length,
        activeCustomers: activeCustomers,
        totalSales: totalSales,
      ));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onSearchCustomers(
      SearchCustomers event,
      Emitter<CustomerState> emit,
      ) async {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadCustomers());
  }

  Future<void> _onShowInactiveCustomers(
      ShowInactiveCustomers event,
      Emitter<CustomerState> emit,
      ) async {
    _showInactive = event.show;
    add(LoadCustomers());
  }

  Future<void> _onAddCustomer(
      AddCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());
    try {
      await _customerRepository.addCustomer(event.customer);
      add(LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
      add(LoadCustomers());
    }
  }

  Future<void> _onUpdateCustomer(
      UpdateCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());
    try {
      await _customerRepository.updateCustomer(event.customer);
      add(LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
      add(LoadCustomers());
    }
  }

  Future<void> _onUpdateCustomerStatus(
      UpdateCustomerStatus event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());
    try {
      await _customerRepository.updateCustomerStatus(
        event.customerId,
        event.isActive,
      );
      add(LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
      add(LoadCustomers());
    }
  }

  Future<void> _onDeleteCustomer(
      DeleteCustomer event,
      Emitter<CustomerState> emit,
      ) async {
    emit(CustomerLoading());
    try {
      await _customerRepository.deleteCustomer(event.customerId);
      add(LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
      add(LoadCustomers());
    }
  }
}
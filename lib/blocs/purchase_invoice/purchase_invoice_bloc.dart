import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/purchase_invoice_model.dart';
import '../../data/repositories/purchase_invoice_repository.dart';
import '../purchase/purchase_bloc.dart';
import '../../utils/service_locator.dart';

// Events
abstract class PurchaseInvoiceEvent extends Equatable {
  const PurchaseInvoiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadPurchaseInvoices extends PurchaseInvoiceEvent {}

class SearchPurchaseInvoices extends PurchaseInvoiceEvent {
  final String query;

  const SearchPurchaseInvoices(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterPurchaseInvoicesBySupplier extends PurchaseInvoiceEvent {
  final String? supplierId;

  const FilterPurchaseInvoicesBySupplier(this.supplierId);

  @override
  List<Object?> get props => [supplierId];
}

class FilterPurchaseInvoicesByStatus extends PurchaseInvoiceEvent {
  final String? status;

  const FilterPurchaseInvoicesByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class ShowOverduePurchaseInvoices extends PurchaseInvoiceEvent {
  final bool show;

  const ShowOverduePurchaseInvoices(this.show);

  @override
  List<Object?> get props => [show];
}

class AddPurchaseInvoice extends PurchaseInvoiceEvent {
  final PurchaseInvoiceModel invoice;

  const AddPurchaseInvoice(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class UpdatePurchaseInvoiceStatus extends PurchaseInvoiceEvent {
  final String invoiceId;
  final String status;

  const UpdatePurchaseInvoiceStatus(this.invoiceId, this.status);

  @override
  List<Object?> get props => [invoiceId, status];
}

class MarkPurchaseInvoiceAsPaid extends PurchaseInvoiceEvent {
  final String invoiceId;

  const MarkPurchaseInvoiceAsPaid(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class UpdatePurchaseOrderPayment extends PurchaseInvoiceEvent {
  final String purchaseOrderId;
  final bool isPaid;

  const UpdatePurchaseOrderPayment(this.purchaseOrderId, this.isPaid);

  @override
  List<Object?> get props => [purchaseOrderId, isPaid];
}

// States
abstract class PurchaseInvoiceState extends Equatable {
  const PurchaseInvoiceState();

  @override
  List<Object?> get props => [];
}

class PurchaseInvoiceInitial extends PurchaseInvoiceState {}

class PurchaseInvoiceLoading extends PurchaseInvoiceState {}

class PurchaseInvoicesLoaded extends PurchaseInvoiceState {
  final List<PurchaseInvoiceModel> invoices;
  final String? searchQuery;
  final String? supplierFilter;
  final String? statusFilter;
  final bool showOverdue;
  final double totalInvoices;
  final double pendingInvoices;
  final double overdueInvoices;
  final double totalAmount;
  final double paidAmount;

  const PurchaseInvoicesLoaded({
    required this.invoices,
    this.searchQuery,
    this.supplierFilter,
    this.statusFilter,
    this.showOverdue = false,
    required this.totalInvoices,
    required this.pendingInvoices,
    required this.overdueInvoices,
    required this.totalAmount,
    required this.paidAmount,
  });

  @override
  List<Object?> get props => [
    invoices,
    searchQuery,
    supplierFilter,
    statusFilter,
    showOverdue,
    totalInvoices,
    pendingInvoices,
    overdueInvoices,
    totalAmount,
    paidAmount,
  ];
}

class PurchaseInvoiceError extends PurchaseInvoiceState {
  final String message;

  const PurchaseInvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PurchaseInvoiceBloc
    extends Bloc<PurchaseInvoiceEvent, PurchaseInvoiceState> {
  final PurchaseInvoiceRepository _purchaseInvoiceRepository;
  String? _currentSearchQuery;
  String? _currentSupplierFilter;
  String? _currentStatusFilter;
  bool _showOverdue = false;

  PurchaseInvoiceBloc({
    required PurchaseInvoiceRepository purchaseInvoiceRepository,
  })  : _purchaseInvoiceRepository = purchaseInvoiceRepository,
        super(PurchaseInvoiceInitial()) {
    on<LoadPurchaseInvoices>(_onLoadPurchaseInvoices);
    on<SearchPurchaseInvoices>(_onSearchPurchaseInvoices);
    on<FilterPurchaseInvoicesBySupplier>(_onFilterPurchaseInvoicesBySupplier);
    on<FilterPurchaseInvoicesByStatus>(_onFilterPurchaseInvoicesByStatus);
    on<ShowOverduePurchaseInvoices>(_onShowOverduePurchaseInvoices);
    on<AddPurchaseInvoice>(_onAddPurchaseInvoice);
    on<UpdatePurchaseInvoiceStatus>(_onUpdatePurchaseInvoiceStatus);
    on<MarkPurchaseInvoiceAsPaid>(_onMarkPurchaseInvoiceAsPaid);
    on<UpdatePurchaseOrderPayment>(_onUpdatePurchaseOrderPayment);
  }

  Future<void> _onLoadPurchaseInvoices(
      LoadPurchaseInvoices event,
      Emitter<PurchaseInvoiceState> emit,
      ) async {
    emit(PurchaseInvoiceLoading());
    try {
      final invoices = await _purchaseInvoiceRepository.getPurchaseInvoices(
        searchQuery: _currentSearchQuery,
        supplierFilter: _currentSupplierFilter,
        statusFilter: _currentStatusFilter,
        includeOverdue: _showOverdue,
      );

      final totalInvoices = invoices.length.toDouble();
      final pendingInvoices = invoices
          .where((invoice) => invoice.status == PurchaseInvoiceStatus.pending.name)
          .length
          .toDouble();
      final overdueInvoices = invoices
          .where((invoice) => invoice.isOverdue)
          .length
          .toDouble();
      final totalAmount = invoices.fold<double>(
        0,
            (sum, invoice) => sum + invoice.total,
      );
      final paidAmount = invoices
          .where((invoice) => invoice.isPaid)
          .fold<double>(
        0,
            (sum, invoice) => sum + invoice.total,
      );

      emit(PurchaseInvoicesLoaded(
        invoices: invoices,
        searchQuery: _currentSearchQuery,
        supplierFilter: _currentSupplierFilter,
        statusFilter: _currentStatusFilter,
        showOverdue: _showOverdue,
        totalInvoices: totalInvoices,
        pendingInvoices: pendingInvoices,
        overdueInvoices: overdueInvoices,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
      ));
    } catch (e) {
      emit(PurchaseInvoiceError(e.toString()));
    }
  }

  void _onSearchPurchaseInvoices(
      SearchPurchaseInvoices event,
      Emitter<PurchaseInvoiceState> emit,
      ) {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadPurchaseInvoices());
  }

  void _onFilterPurchaseInvoicesBySupplier(
      FilterPurchaseInvoicesBySupplier event,
      Emitter<PurchaseInvoiceState> emit,
      ) {
    _currentSupplierFilter = event.supplierId;
    add(LoadPurchaseInvoices());
  }

  void _onFilterPurchaseInvoicesByStatus(
      FilterPurchaseInvoicesByStatus event,
      Emitter<PurchaseInvoiceState> emit,
      ) {
    _currentStatusFilter = event.status;
    add(LoadPurchaseInvoices());
  }

  void _onShowOverduePurchaseInvoices(
      ShowOverduePurchaseInvoices event,
      Emitter<PurchaseInvoiceState> emit,
      ) {
    _showOverdue = event.show;
    add(LoadPurchaseInvoices());
  }

  Future<void> _onAddPurchaseInvoice(
      AddPurchaseInvoice event,
      Emitter<PurchaseInvoiceState> emit,
      ) async {
    emit(PurchaseInvoiceLoading());
    try {
      await _purchaseInvoiceRepository.addPurchaseInvoice(event.invoice);
      add(LoadPurchaseInvoices());
    } catch (e) {
      emit(PurchaseInvoiceError(e.toString()));
      add(LoadPurchaseInvoices());
    }
  }

  Future<void> _onUpdatePurchaseInvoiceStatus(
      UpdatePurchaseInvoiceStatus event,
      Emitter<PurchaseInvoiceState> emit,
      ) async {
    emit(PurchaseInvoiceLoading());
    try {
      await _purchaseInvoiceRepository.updatePurchaseInvoiceStatus(
        event.invoiceId,
        event.status,
      );
      add(LoadPurchaseInvoices());
    } catch (e) {
      emit(PurchaseInvoiceError(e.toString()));
      add(LoadPurchaseInvoices());
    }
  }

  Future<void> _onMarkPurchaseInvoiceAsPaid(
      MarkPurchaseInvoiceAsPaid event,
      Emitter<PurchaseInvoiceState> emit,
      ) async {
    emit(PurchaseInvoiceLoading());
    try {
      // Get the invoice first to get the purchaseOrderId
      final invoice = await _purchaseInvoiceRepository.getPurchaseInvoice(event.invoiceId);

      // Mark invoice as paid
      await _purchaseInvoiceRepository.markAsPaid(event.invoiceId);

      // Also update the purchase order payment status
      if (invoice.purchaseOrderId.isNotEmpty) {
        add(UpdatePurchaseOrderPayment(invoice.purchaseOrderId, true));
      }

      add(LoadPurchaseInvoices());
    } catch (e) {
      emit(PurchaseInvoiceError(e.toString()));
      add(LoadPurchaseInvoices());
    }
  }

  Future<void> _onUpdatePurchaseOrderPayment(
      UpdatePurchaseOrderPayment event,
      Emitter<PurchaseInvoiceState> emit,
      ) async {
    try {
      // Get an instance of PurchaseBloc
      final purchaseBloc = locator<PurchaseBloc>();

      // Add event to update payment status
      purchaseBloc.add(UpdatePurchaseOrderPaymentStatus(
          event.purchaseOrderId,
          event.isPaid
      ));
    } catch (e) {
      // Log error but don't change invoice state
      print('Error updating purchase order payment: $e');
    }
  }

  // Helper methods for status
  List<String> getNextPossibleStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'draft':
        return ['received', 'cancelled'];
      case 'received':
        return ['pending', 'cancelled', 'disputed'];
      case 'pending':
        return ['paid', 'overdue', 'disputed', 'cancelled'];
      case 'overdue':
        return ['paid', 'disputed', 'cancelled'];
      case 'disputed':
        return ['pending', 'paid', 'cancelled'];
      case 'paid':
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }
}
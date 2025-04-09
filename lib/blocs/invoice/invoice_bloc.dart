// lib/blocs/invoice/invoice_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/invoice_model.dart';
import '../../data/repositories/invoice_repository.dart';
import '../../utils/service_locator.dart';
import '../sales/sales_order_bloc.dart';

// Events
abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvoices extends InvoiceEvent {}

class SearchInvoices extends InvoiceEvent {
  final String query;

  const SearchInvoices(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterInvoicesByCustomer extends InvoiceEvent {
  final String? customerId;

  const FilterInvoicesByCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class FilterInvoicesByStatus extends InvoiceEvent {
  final String? status;

  const FilterInvoicesByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class ShowOverdueInvoices extends InvoiceEvent {
  final bool show;

  const ShowOverdueInvoices(this.show);

  @override
  List<Object?> get props => [show];
}

class AddInvoice extends InvoiceEvent {
  final InvoiceModel invoice;

  const AddInvoice(this.invoice);

  @override
  List<Object?> get props => [invoice];
}

class UpdateInvoiceStatus extends InvoiceEvent {
  final String invoiceId;
  final String status;

  const UpdateInvoiceStatus(this.invoiceId, this.status);

  @override
  List<Object?> get props => [invoiceId, status];
}

class MarkInvoiceAsPaid extends InvoiceEvent {
  final String invoiceId;

  const MarkInvoiceAsPaid(this.invoiceId);

  @override
  List<Object?> get props => [invoiceId];
}

class UpdateSalesOrderPayment extends InvoiceEvent {
  final String salesOrderId;
  final bool isPaid;

  const UpdateSalesOrderPayment(this.salesOrderId, this.isPaid);

  @override
  List<Object?> get props => [salesOrderId, isPaid];
}

class SalesOrderStatusChanged extends InvoiceEvent {
  final String salesOrderId;
  final String newStatus;

  const SalesOrderStatusChanged(this.salesOrderId, this.newStatus);

  @override
  List<Object?> get props => [salesOrderId, newStatus];
}

// States
abstract class InvoiceState extends Equatable {
  const InvoiceState();

  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoicesLoaded extends InvoiceState {
  final List<InvoiceModel> invoices;
  final String? searchQuery;
  final String? customerFilter;
  final String? statusFilter;
  final bool showOverdue;
  final double totalInvoices;
  final double pendingInvoices;
  final double overdueInvoices;
  final double totalAmount;
  final double paidAmount;

  const InvoicesLoaded({
    required this.invoices,
    this.searchQuery,
    this.customerFilter,
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
    customerFilter,
    statusFilter,
    showOverdue,
    totalInvoices,
    pendingInvoices,
    overdueInvoices,
    totalAmount,
    paidAmount,
  ];
}

class InvoiceError extends InvoiceState {
  final String message;

  const InvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository _invoiceRepository;
  String? _currentSearchQuery;
  String? _currentCustomerFilter;
  String? _currentStatusFilter;
  bool _showOverdue = false;

  InvoiceBloc({
    required InvoiceRepository invoiceRepository,
  })  : _invoiceRepository = invoiceRepository,
        super(InvoiceInitial()) {
    on<LoadInvoices>(_onLoadInvoices);
    on<SearchInvoices>(_onSearchInvoices);
    on<FilterInvoicesByCustomer>(_onFilterInvoicesByCustomer);
    on<FilterInvoicesByStatus>(_onFilterInvoicesByStatus);
    on<ShowOverdueInvoices>(_onShowOverdueInvoices);
    on<AddInvoice>(_onAddInvoice);
    on<UpdateInvoiceStatus>(_onUpdateInvoiceStatus);
    on<MarkInvoiceAsPaid>(_onMarkInvoiceAsPaid);
    on<UpdateSalesOrderPayment>(_onUpdateSalesOrderPayment);
    on<SalesOrderStatusChanged>(_onSalesOrderStatusChanged);
  }

  Future<void> _onLoadInvoices(
      LoadInvoices event,
      Emitter<InvoiceState> emit,
      ) async {
    emit(InvoiceLoading());
    try {
      final invoices = await _invoiceRepository.getInvoices(
        searchQuery: _currentSearchQuery,
        customerFilter: _currentCustomerFilter,
        statusFilter: _currentStatusFilter,
        includeOverdue: _showOverdue,
      );

      final totalInvoices = invoices.length.toDouble();
      final pendingInvoices = invoices
          .where((invoice) => invoice.status == InvoiceStatus.sent.name)
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

      emit(InvoicesLoaded(
        invoices: invoices,
        searchQuery: _currentSearchQuery,
        customerFilter: _currentCustomerFilter,
        statusFilter: _currentStatusFilter,
        showOverdue: _showOverdue,
        totalInvoices: totalInvoices,
        pendingInvoices: pendingInvoices,
        overdueInvoices: overdueInvoices,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
      ));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  void _onSearchInvoices(
      SearchInvoices event,
      Emitter<InvoiceState> emit,
      ) {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadInvoices());
  }

  void _onFilterInvoicesByCustomer(
      FilterInvoicesByCustomer event,
      Emitter<InvoiceState> emit,
      ) {
    _currentCustomerFilter = event.customerId;
    add(LoadInvoices());
  }

  void _onFilterInvoicesByStatus(
      FilterInvoicesByStatus event,
      Emitter<InvoiceState> emit,
      ) {
    _currentStatusFilter = event.status;
    add(LoadInvoices());
  }

  void _onShowOverdueInvoices(
      ShowOverdueInvoices event,
      Emitter<InvoiceState> emit,
      ) {
    _showOverdue = event.show;
    add(LoadInvoices());
  }

  Future<void> _onAddInvoice(
      AddInvoice event,
      Emitter<InvoiceState> emit,
      ) async {
    emit(InvoiceLoading());
    try {
      await _invoiceRepository.addInvoice(event.invoice);
      add(LoadInvoices());
    } catch (e) {
      emit(InvoiceError(e.toString()));
      add(LoadInvoices());
    }
  }

  Future<void> _onUpdateInvoiceStatus(
      UpdateInvoiceStatus event,
      Emitter<InvoiceState> emit,
      ) async {
    emit(InvoiceLoading());
    try {
      // If the new status is 'paid', set the paid date as well
      if (event.status == InvoiceStatus.paid.name) {
        await _invoiceRepository.markAsPaid(event.invoiceId);

        // If there's a sales order, update its payment status
        final invoice = await _invoiceRepository.getInvoice(event.invoiceId);
        if (invoice.salesOrderId.isNotEmpty) {
          add(UpdateSalesOrderPayment(invoice.salesOrderId, true));
        }
      } else {
        // Handle regular status update
        await _invoiceRepository.updateInvoiceStatus(
          event.invoiceId,
          event.status,
        );
      }

      add(LoadInvoices());
    } catch (e) {
      emit(InvoiceError(e.toString()));
      add(LoadInvoices());
    }
  }

  Future<void> _onMarkInvoiceAsPaid(
      MarkInvoiceAsPaid event,
      Emitter<InvoiceState> emit,
      ) async {
    emit(InvoiceLoading());
    try {
      // Get the invoice first to get the salesOrderId
      final invoice = await _invoiceRepository.getInvoice(event.invoiceId);

      // Mark invoice as paid
      await _invoiceRepository.markAsPaid(event.invoiceId);

      // Also update the sales order payment status
      if (invoice.salesOrderId.isNotEmpty) {
        add(UpdateSalesOrderPayment(invoice.salesOrderId, true));
      }

      add(LoadInvoices());
    } catch (e) {
      emit(InvoiceError(e.toString()));
      add(LoadInvoices());
    }
  }

  Future<void> _onUpdateSalesOrderPayment(
      UpdateSalesOrderPayment event,
      Emitter<InvoiceState> emit,
      ) async {
    try {
      // Get an instance of SalesOrderBloc
      final salesOrderBloc = locator<SalesOrderBloc>();

      // Add event to update payment status
      salesOrderBloc.add(UpdateSalesOrderPaymentStatus(
          event.salesOrderId,
          event.isPaid
      ));
    } catch (e) {
      // Log error but don't change invoice state
      print('Error updating sales order payment: $e');
    }
  }

  Future<void> _onSalesOrderStatusChanged(
      SalesOrderStatusChanged event,
      Emitter<InvoiceState> emit,
      ) async {
    try {
      // Get all invoices for this sales order
      final invoices = await _invoiceRepository.getInvoicesBySalesOrder(event.salesOrderId);

      if (event.newStatus == 'cancelled') {
        for (var invoice in invoices) {
          if (invoice.isPaid) {
            // Mark paid invoices as refunded
            await _invoiceRepository.updateInvoiceStatus(
                invoice.id,
                InvoiceStatus.refunded.name
            );
          } else {
            // Mark unpaid invoices as cancelled
            await _invoiceRepository.updateInvoiceStatus(
                invoice.id,
                InvoiceStatus.cancelled.name
            );
          }
        }
      }

      // Reload invoices
      add(LoadInvoices());
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  // Helper methods for status
  List<String> getNextPossibleStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'draft':
        return ['sent', 'cancelled'];
      case 'sent':
        return ['paid', 'overdue', 'disputed', 'cancelled'];
      case 'overdue':
        return ['paid', 'disputed', 'cancelled'];
      case 'disputed':
        return ['sent', 'paid', 'cancelled'];
      case 'paid':
        return ['refunded']; // Only paid invoices can be refunded
      case 'refunded':
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }
}
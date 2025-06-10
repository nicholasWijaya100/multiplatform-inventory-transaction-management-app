import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/warehouse_document_model.dart';
import '../../data/repositories/warehouse_document_repository.dart';
import '../../utils/service_locator.dart';
import '../product/product_bloc.dart';
import '../purchase/purchase_bloc.dart';
import '../sales/sales_order_bloc.dart';

// Events
abstract class WarehouseDocumentEvent extends Equatable {
  const WarehouseDocumentEvent();

  @override
  List<Object?> get props => [];
}

class LoadWarehouseDocuments extends WarehouseDocumentEvent {
  final WarehouseDocumentType? type;
  final String? warehouseId;
  final String? status;

  const LoadWarehouseDocuments({
    this.type,
    this.warehouseId,
    this.status,
  });

  @override
  List<Object?> get props => [type, warehouseId, status];
}

class CreateWarehouseDocument extends WarehouseDocumentEvent {
  final WarehouseDocumentModel document;

  const CreateWarehouseDocument(this.document);

  @override
  List<Object?> get props => [document];
}

class UpdateWarehouseDocumentStatus extends WarehouseDocumentEvent {
  final String documentId;
  final WarehouseDocumentStatus status;

  const UpdateWarehouseDocumentStatus(this.documentId, this.status);

  @override
  List<Object?> get props => [documentId, status];
}

class UpdateWarehouseDocument extends WarehouseDocumentEvent {
  final String documentId;
  final WarehouseDocumentModel document;

  const UpdateWarehouseDocument(this.documentId, this.document);

  @override
  List<Object?> get props => [documentId, document];
}

class DeleteWarehouseDocument extends WarehouseDocumentEvent {
  final String documentId;

  const DeleteWarehouseDocument(this.documentId);

  @override
  List<Object?> get props => [documentId];
}

class FilterWarehouseDocumentsByType extends WarehouseDocumentEvent {
  final WarehouseDocumentType? type;

  const FilterWarehouseDocumentsByType(this.type);

  @override
  List<Object?> get props => [type];
}

class FilterWarehouseDocumentsByWarehouse extends WarehouseDocumentEvent {
  final String? warehouseId;

  const FilterWarehouseDocumentsByWarehouse(this.warehouseId);

  @override
  List<Object?> get props => [warehouseId];
}

class SearchWarehouseDocuments extends WarehouseDocumentEvent {
  final String query;

  const SearchWarehouseDocuments(this.query);

  @override
  List<Object?> get props => [query];
}

// States
abstract class WarehouseDocumentState extends Equatable {
  const WarehouseDocumentState();

  @override
  List<Object?> get props => [];
}

class WarehouseDocumentInitial extends WarehouseDocumentState {}

class WarehouseDocumentLoading extends WarehouseDocumentState {}

class WarehouseDocumentsLoaded extends WarehouseDocumentState {
  final List<WarehouseDocumentModel> documents;
  final WarehouseDocumentType? typeFilter;
  final String? warehouseFilter;
  final String? searchQuery;
  final int entryWaybillCount;
  final int deliveryNoteCount;
  final int pendingCount;

  const WarehouseDocumentsLoaded({
    required this.documents,
    this.typeFilter,
    this.warehouseFilter,
    this.searchQuery,
    required this.entryWaybillCount,
    required this.deliveryNoteCount,
    required this.pendingCount,
  });

  @override
  List<Object?> get props => [
    documents,
    typeFilter,
    warehouseFilter,
    searchQuery,
    entryWaybillCount,
    deliveryNoteCount,
    pendingCount,
  ];
}

class WarehouseDocumentError extends WarehouseDocumentState {
  final String message;

  const WarehouseDocumentError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class WarehouseDocumentBloc extends Bloc<WarehouseDocumentEvent, WarehouseDocumentState> {
  final WarehouseDocumentRepository _repository;

  WarehouseDocumentType? _currentTypeFilter;
  String? _currentWarehouseFilter;
  String? _currentSearchQuery;

  WarehouseDocumentBloc({
    required WarehouseDocumentRepository repository,
  })  : _repository = repository,
        super(WarehouseDocumentInitial()) {
    on<LoadWarehouseDocuments>(_onLoadWarehouseDocuments);
    on<CreateWarehouseDocument>(_onCreateWarehouseDocument);
    on<UpdateWarehouseDocumentStatus>(_onUpdateWarehouseDocumentStatus);
    on<UpdateWarehouseDocument>(_onUpdateWarehouseDocument);
    on<DeleteWarehouseDocument>(_onDeleteWarehouseDocument);
    on<FilterWarehouseDocumentsByType>(_onFilterWarehouseDocumentsByType);
    on<FilterWarehouseDocumentsByWarehouse>(_onFilterWarehouseDocumentsByWarehouse);
    on<SearchWarehouseDocuments>(_onSearchWarehouseDocuments);
  }

  Future<void> _onLoadWarehouseDocuments(
      LoadWarehouseDocuments event,
      Emitter<WarehouseDocumentState> emit,
      ) async {
    emit(WarehouseDocumentLoading());
    try {
      final documents = await _repository.getDocuments(
        type: event.type ?? _currentTypeFilter,
        warehouseId: event.warehouseId ?? _currentWarehouseFilter,
        status: event.status,
      );

      // Apply search filter if present
      List<WarehouseDocumentModel> filteredDocuments = documents;
      if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
        final query = _currentSearchQuery!.toLowerCase();
        filteredDocuments = documents.where((doc) {
          return doc.documentNumber.toLowerCase().contains(query) ||
              doc.warehouseName.toLowerCase().contains(query) ||
              (doc.relatedOrderNumber?.toLowerCase().contains(query) ?? false) ||
              doc.items.any((item) => item.productName.toLowerCase().contains(query));
        }).toList();
      }

      // Calculate counts
      final allDocuments = await _repository.getDocuments();
      final entryWaybillCount = allDocuments
          .where((doc) => doc.type == WarehouseDocumentType.entryWaybill)
          .length;
      final deliveryNoteCount = allDocuments
          .where((doc) => doc.type == WarehouseDocumentType.deliveryNote)
          .length;
      final pendingCount = allDocuments
          .where((doc) => doc.status == WarehouseDocumentStatus.pending)
          .length;

      emit(WarehouseDocumentsLoaded(
        documents: filteredDocuments,
        typeFilter: _currentTypeFilter,
        warehouseFilter: _currentWarehouseFilter,
        searchQuery: _currentSearchQuery,
        entryWaybillCount: entryWaybillCount,
        deliveryNoteCount: deliveryNoteCount,
        pendingCount: pendingCount,
      ));
    } catch (e) {
      emit(WarehouseDocumentError(e.toString()));
    }
  }

  Future<void> _onCreateWarehouseDocument(
      CreateWarehouseDocument event,
      Emitter<WarehouseDocumentState> emit,
      ) async {
    emit(WarehouseDocumentLoading());
    try {
      await _repository.createDocument(event.document);
      add(LoadWarehouseDocuments());
    } catch (e) {
      emit(WarehouseDocumentError(e.toString()));
      add(LoadWarehouseDocuments());
    }
  }

  Future<void> _onUpdateWarehouseDocumentStatus(
      UpdateWarehouseDocumentStatus event,
      Emitter<WarehouseDocumentState> emit,
      ) async {
    emit(WarehouseDocumentLoading());
    try {
      // Get the document first to check its type and related order
      final document = await _repository.getDocument(event.documentId);

      // If marking as completed, update stock accordingly
      if (event.status == WarehouseDocumentStatus.completed) {
        // Get product bloc instance
        final productBloc = locator<ProductBloc>();

        // Update stock based on document type
        for (final item in document.items) {
          if (document.type == WarehouseDocumentType.entryWaybill) {
            // Add stock for entry waybill (receiving goods)
            productBloc.add(AdjustProductStock(
              item.productId,
              document.warehouseId,
              item.quantity, // Positive quantity to add
            ));
          } else if (document.type == WarehouseDocumentType.deliveryNote) {
            // Reduce stock for delivery note (shipping goods)
            productBloc.add(AdjustProductStock(
              item.productId,
              document.warehouseId,
              -item.quantity, // Negative quantity to reduce
            ));
          }
        }

        // ====== AUTOMATIC STATUS UPDATES ======

        // If it's an entry waybill, update the related purchase order to 'received'
        if (document.type == WarehouseDocumentType.entryWaybill && document.relatedOrderId != null) {
          final purchaseBloc = locator<PurchaseBloc>();
          purchaseBloc.add(UpdatePurchaseOrderStatus(
            document.relatedOrderId!,
            'received',
          ));
        }

        // If it's a delivery note, update the related sales order to 'delivered'
        if (document.type == WarehouseDocumentType.deliveryNote && document.relatedOrderId != null) {
          final salesOrderBloc = locator<SalesOrderBloc>();
          salesOrderBloc.add(UpdateSalesOrderStatus(
            document.relatedOrderId!,
            'delivered',
          ));
        }
      }

      // If marking as cancelled, handle related order cancellation
      if (event.status == WarehouseDocumentStatus.cancelled) {
        if (document.type == WarehouseDocumentType.entryWaybill && document.relatedOrderId != null) {
          // Cancel the related purchase order
          final purchaseBloc = locator<PurchaseBloc>();
          purchaseBloc.add(UpdatePurchaseOrderStatus(
            document.relatedOrderId!,
            'cancelled',
          ));
        }

        // Add this new logic for sales orders
        if (document.type == WarehouseDocumentType.deliveryNote && document.relatedOrderId != null) {
          // Cancel the related sales order
          final salesOrderBloc = locator<SalesOrderBloc>();
          salesOrderBloc.add(UpdateSalesOrderStatus(
            document.relatedOrderId!,
            'cancelled',
          ));
        }
      }

      // Update the document status in the database
      await _repository.updateDocumentStatus(event.documentId, event.status);

      // Reload documents to reflect changes
      add(LoadWarehouseDocuments());
    } catch (e) {
      emit(WarehouseDocumentError(e.toString()));
      add(LoadWarehouseDocuments());
    }
  }

  Future<void> _onUpdateWarehouseDocument(
      UpdateWarehouseDocument event,
      Emitter<WarehouseDocumentState> emit,
      ) async {
    emit(WarehouseDocumentLoading());
    try {
      await _repository.updateDocument(event.documentId, event.document);
      add(LoadWarehouseDocuments());
    } catch (e) {
      emit(WarehouseDocumentError(e.toString()));
      add(LoadWarehouseDocuments());
    }
  }

  Future<void> _onDeleteWarehouseDocument(
      DeleteWarehouseDocument event,
      Emitter<WarehouseDocumentState> emit,
      ) async {
    emit(WarehouseDocumentLoading());
    try {
      await _repository.deleteDocument(event.documentId);
      add(LoadWarehouseDocuments());
    } catch (e) {
      emit(WarehouseDocumentError(e.toString()));
      add(LoadWarehouseDocuments());
    }
  }

  void _onFilterWarehouseDocumentsByType(
      FilterWarehouseDocumentsByType event,
      Emitter<WarehouseDocumentState> emit,
      ) {
    _currentTypeFilter = event.type;
    add(LoadWarehouseDocuments());
  }

  void _onFilterWarehouseDocumentsByWarehouse(
      FilterWarehouseDocumentsByWarehouse event,
      Emitter<WarehouseDocumentState> emit,
      ) {
    _currentWarehouseFilter = event.warehouseId;
    add(LoadWarehouseDocuments());
  }

  void _onSearchWarehouseDocuments(
      SearchWarehouseDocuments event,
      Emitter<WarehouseDocumentState> emit,
      ) {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadWarehouseDocuments());
  }
}
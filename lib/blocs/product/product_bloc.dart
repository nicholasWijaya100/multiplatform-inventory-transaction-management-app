import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../warehouse/warehouse_bloc.dart';

// Events
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterProductsByCategory extends ProductEvent {
  final String? category;

  const FilterProductsByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class ShowInactiveProducts extends ProductEvent {
  final bool show;

  const ShowInactiveProducts(this.show);

  @override
  List<Object?> get props => [show];
}

class AddProduct extends ProductEvent {
  final ProductModel product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final ProductModel product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProductStatus extends ProductEvent {
  final String productId;
  final bool isActive;

  const UpdateProductStatus(this.productId, this.isActive);

  @override
  List<Object?> get props => [productId, isActive];
}

class UpdateProductStock extends ProductEvent {
  final String productId;
  final String warehouseId;
  final int quantity;

  const UpdateProductStock(this.productId, this.warehouseId, this.quantity);

  @override
  List<Object?> get props => [productId, warehouseId, quantity];
}

class TransferStock extends ProductEvent {
  final String productId;
  final String sourceWarehouseId;
  final String destinationWarehouseId;
  final int quantity;

  const TransferStock({
    required this.productId,
    required this.sourceWarehouseId,
    required this.destinationWarehouseId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
    productId,
    sourceWarehouseId,
    destinationWarehouseId,
    quantity,
  ];
}

// States
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductModel> products;
  final String? searchQuery;
  final String? categoryFilter;
  final bool showInactive;
  final List<String> categories;
  final Map<String, int> productsByCategory;
  final int totalProducts;
  final int lowStockProducts;
  final double totalValue;

  const ProductsLoaded({
    required this.products,
    this.searchQuery,
    this.categoryFilter,
    this.showInactive = false,
    required this.categories,
    required this.productsByCategory,
    required this.totalProducts,
    required this.lowStockProducts,
    required this.totalValue,
  });

  @override
  List<Object?> get props => [
    products,
    searchQuery,
    categoryFilter,
    showInactive,
    categories,
    productsByCategory,
    totalProducts,
    lowStockProducts,
    totalValue,
  ];

  ProductsLoaded copyWith({
    List<ProductModel>? products,
    String? searchQuery,
    String? categoryFilter,
    bool? showInactive,
    List<String>? categories,
    Map<String, int>? productsByCategory,
    int? totalProducts,
    int? lowStockProducts,
    double? totalValue,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      showInactive: showInactive ?? this.showInactive,
      categories: categories ?? this.categories,
      productsByCategory: productsByCategory ?? this.productsByCategory,
      totalProducts: totalProducts ?? this.totalProducts,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      totalValue: totalValue ?? this.totalValue,
    );
  }
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;
  final WarehouseBloc _warehouseBloc;
  String? _currentSearchQuery;
  String? _currentCategoryFilter;
  bool _showInactive = false;
  static const int lowStockThreshold = 10;

  ProductBloc({
    required ProductRepository productRepository,
    required WarehouseBloc warehouseBloc,
  })  : _productRepository = productRepository,
        _warehouseBloc = warehouseBloc,
        super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProductsByCategory>(_onFilterProductsByCategory);
    on<ShowInactiveProducts>(_onShowInactiveProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<UpdateProductStatus>(_onUpdateProductStatus);
    on<UpdateProductStock>(_onUpdateProductStock);
    on<TransferStock>(_onTransferStock);
  }

  Future<void> _onLoadProducts(
      LoadProducts event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductLoading());
    try {
      final products = await _productRepository.getProducts(
        searchQuery: _currentSearchQuery,
        categoryFilter: _currentCategoryFilter,
        includeInactive: _showInactive,
      );

      final categories = await _productRepository.getCategories();

      // Calculate statistics
      final productsByCategory = <String, int>{};
      var lowStockProducts = 0;
      var totalValue = 0.0;

      for (final product in products) {
        productsByCategory[product.category] =
            (productsByCategory[product.category] ?? 0) + 1;

        if (product.quantity < lowStockThreshold && product.isActive) {
          lowStockProducts++;
        }

        totalValue += product.price * product.quantity;
      }

      emit(ProductsLoaded(
        products: products,
        searchQuery: _currentSearchQuery,
        categoryFilter: _currentCategoryFilter,
        showInactive: _showInactive,
        categories: categories,
        productsByCategory: productsByCategory,
        totalProducts: products.length,
        lowStockProducts: lowStockProducts,
        totalValue: totalValue,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
      SearchProducts event,
      Emitter<ProductState> emit,
      ) async {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadProducts());
  }

  Future<void> _onFilterProductsByCategory(
      FilterProductsByCategory event,
      Emitter<ProductState> emit,
      ) async {
    _currentCategoryFilter = event.category;
    add(LoadProducts());
  }

  Future<void> _onShowInactiveProducts(
      ShowInactiveProducts event,
      Emitter<ProductState> emit,
      ) async {
    _showInactive = event.show;
    add(LoadProducts());
  }

  Future<void> _onAddProduct(
      AddProduct event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductLoading());
    try {
      await _productRepository.addProduct(event.product);
      add(LoadProducts());
    } catch (e) {
      emit(ProductError(e.toString()));
      add(LoadProducts());
    }
  }

  Future<void> _onUpdateProduct(
      UpdateProduct event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductLoading());
    try {
      await _productRepository.updateProduct(event.product);
      add(LoadProducts());
    } catch (e) {
      emit(ProductError(e.toString()));
      add(LoadProducts());
    }
  }

  Future<void> _onUpdateProductStatus(
      UpdateProductStatus event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductLoading());
    try {
      await _productRepository.updateProductStatus(
        event.productId,
        event.isActive,
      );
      add(LoadProducts());
    } catch (e) {
      emit(ProductError(e.toString()));
      add(LoadProducts());
    }
  }

  Future<void> _onUpdateProductStock(
      UpdateProductStock event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductLoading());
    try {
      await _productRepository.updateStock(
        event.productId,
        event.warehouseId,
        event.quantity,
      );

      // Update warehouse totals
      _warehouseBloc.add(LoadWarehouses());

      add(LoadProducts());
    } catch (e) {
      emit(ProductError(e.toString()));
      add(LoadProducts());
    }
  }

  Future<void> _onTransferStock(
      TransferStock event,
      Emitter<ProductState> emit,
      ) async {
    emit(ProductLoading());
    try {
      final product = (state as ProductsLoaded)
          .products
          .firstWhere((p) => p.id == event.productId);

      final sourceStock = product.warehouseStock[event.sourceWarehouseId] ?? 0;
      if (sourceStock < event.quantity) {
        emit(ProductError('Insufficient stock in source warehouse'));
        add(LoadProducts());
        return;
      }

      // Update source warehouse stock
      await _productRepository.updateStock(
        event.productId,
        event.sourceWarehouseId,
        sourceStock - event.quantity,
      );

      // Update destination warehouse stock
      final destinationStock =
          product.warehouseStock[event.destinationWarehouseId] ?? 0;
      await _productRepository.updateStock(
        event.productId,
        event.destinationWarehouseId,
        destinationStock + event.quantity,
      );

      // Refresh warehouses
      _warehouseBloc.add(LoadWarehouses());

      add(LoadProducts());
    } catch (e) {
      emit(ProductError(e.toString()));
      add(LoadProducts());
    }
  }

  // Helper methods
  bool isLowStock(ProductModel product) {
    return product.quantity < lowStockThreshold && product.isActive;
  }

  String getStockStatus(ProductModel product) {
    if (!product.isActive) return 'Inactive';
    if (product.quantity <= 0) return 'Out of Stock';
    if (product.quantity < lowStockThreshold) return 'Low Stock';
    return 'In Stock';
  }

  Color getStockStatusColor(ProductModel product) {
    if (!product.isActive) return Colors.grey;
    if (product.quantity <= 0) return Colors.red;
    if (product.quantity < lowStockThreshold) return Colors.orange;
    return Colors.green;
  }
}
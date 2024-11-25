import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

// Events
abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

class SearchCategories extends CategoryEvent {
  final String query;

  const SearchCategories(this.query);

  @override
  List<Object?> get props => [query];
}

class ShowInactiveCategories extends CategoryEvent {
  final bool show;

  const ShowInactiveCategories(this.show);

  @override
  List<Object?> get props => [show];
}

class AddCategory extends CategoryEvent {
  final CategoryModel category;

  const AddCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategory extends CategoryEvent {
  final CategoryModel category;

  const UpdateCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategoryStatus extends CategoryEvent {
  final String categoryId;
  final bool isActive;

  const UpdateCategoryStatus(this.categoryId, this.isActive);

  @override
  List<Object?> get props => [categoryId, isActive];
}

class DeleteCategory extends CategoryEvent {
  final String categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

// States
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoriesLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final String? searchQuery;
  final bool showInactive;
  final int totalCategories;
  final int activeCategories;
  final int totalProducts;

  const CategoriesLoaded({
    required this.categories,
    this.searchQuery,
    this.showInactive = false,
    required this.totalCategories,
    required this.activeCategories,
    required this.totalProducts,
  });

  @override
  List<Object?> get props => [
    categories,
    searchQuery,
    showInactive,
    totalCategories,
    activeCategories,
    totalProducts,
  ];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;
  String? _currentSearchQuery;
  bool _showInactive = false;

  CategoryBloc({
    required CategoryRepository categoryRepository,
  })  : _categoryRepository = categoryRepository,
        super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<SearchCategories>(_onSearchCategories);
    on<ShowInactiveCategories>(_onShowInactiveCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<UpdateCategoryStatus>(_onUpdateCategoryStatus);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
      LoadCategories event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryLoading());
    try {
      final categories = await _categoryRepository.getCategories(
        searchQuery: _currentSearchQuery,
        includeInactive: _showInactive,
      );

      final totalProducts = categories.fold<int>(
        0,
            (sum, category) => sum + category.productCount,
      );

      emit(CategoriesLoaded(
        categories: categories,
        searchQuery: _currentSearchQuery,
        showInactive: _showInactive,
        totalCategories: categories.length,
        activeCategories: categories.where((c) => c.isActive).length,
        totalProducts: totalProducts,
      ));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onSearchCategories(
      SearchCategories event,
      Emitter<CategoryState> emit,
      ) async {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadCategories());
  }

  Future<void> _onShowInactiveCategories(
      ShowInactiveCategories event,
      Emitter<CategoryState> emit,
      ) async {
    _showInactive = event.show;
    add(LoadCategories());
  }

  Future<void> _onAddCategory(
      AddCategory event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryLoading());
    try {
      await _categoryRepository.addCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
      add(LoadCategories());
    }
  }

  Future<void> _onUpdateCategory(
      UpdateCategory event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryLoading());
    try {
      await _categoryRepository.updateCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
      add(LoadCategories());
    }
  }

  Future<void> _onUpdateCategoryStatus(
      UpdateCategoryStatus event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryLoading());
    try {
      await _categoryRepository.updateCategoryStatus(
        event.categoryId,
        event.isActive,
      );
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
      add(LoadCategories());
    }
  }

  Future<void> _onDeleteCategory(
      DeleteCategory event,
      Emitter<CategoryState> emit,
      ) async {
    emit(CategoryLoading());
    try {
      await _categoryRepository.deleteCategory(event.categoryId);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError(e.toString()));
      add(LoadCategories());
    }
  }
}
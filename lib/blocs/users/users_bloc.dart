import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

// Events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsers extends UserEvent {}

class SearchUsers extends UserEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterUsersByRole extends UserEvent {
  final String? role;

  const FilterUsersByRole(this.role);

  @override
  List<Object?> get props => [role];
}

class ShowInactiveUsers extends UserEvent {
  final bool show;

  const ShowInactiveUsers(this.show);

  @override
  List<Object?> get props => [show];
}

class AddUser extends UserEvent {
  final String email;
  final String password;
  final String name;
  final String role;

  const AddUser({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

class UpdateUser extends UserEvent {
  final UserModel user;
  final String? newPassword;

  const UpdateUser({
    required this.user,
    this.newPassword,
  });

  @override
  List<Object?> get props => [user, newPassword];
}

class UpdateUserStatus extends UserEvent {
  final String userId;
  final bool isActive;

  const UpdateUserStatus(this.userId, this.isActive);

  @override
  List<Object?> get props => [userId, isActive];
}

class DeleteUser extends UserEvent {
  final String userId;

  const DeleteUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

// States
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UsersLoaded extends UserState {
  final List<UserModel> users;
  final String? searchQuery;
  final String? roleFilter;
  final bool showInactive;
  final int totalUsers;
  final int activeUsers;
  final Map<String, int> usersByRole;

  const UsersLoaded({
    required this.users,
    this.searchQuery,
    this.roleFilter,
    this.showInactive = false,
    required this.totalUsers,
    required this.activeUsers,
    required this.usersByRole,
  });

  @override
  List<Object?> get props => [
    users,
    searchQuery,
    roleFilter,
    showInactive,
    totalUsers,
    activeUsers,
    usersByRole,
  ];

  UsersLoaded copyWith({
    List<UserModel>? users,
    String? searchQuery,
    String? roleFilter,
    bool? showInactive,
    int? totalUsers,
    int? activeUsers,
    Map<String, int>? usersByRole,
  }) {
    return UsersLoaded(
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
      showInactive: showInactive ?? this.showInactive,
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      usersByRole: usersByRole ?? this.usersByRole,
    );
  }
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;
  final String currentUserId;
  String? _currentSearchQuery;
  String? _currentRoleFilter;
  bool _showInactive = false;

  UserBloc({
    required UserRepository userRepository,
    required this.currentUserId,
  })  : _userRepository = userRepository,
        super(UserInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<SearchUsers>(_onSearchUsers);
    on<FilterUsersByRole>(_onFilterUsersByRole);
    on<ShowInactiveUsers>(_onShowInactiveUsers);
    on<AddUser>(_onAddUser);
    on<UpdateUser>(_onUpdateUser);
    on<UpdateUserStatus>(_onUpdateUserStatus);
    on<DeleteUser>(_onDeleteUser);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final users = await _userRepository.getUsers(
        searchQuery: _currentSearchQuery,
        roleFilter: _currentRoleFilter,
        includeInactive: _showInactive,
      );

      final totalUsers = users.length;
      final activeUsers = users.where((user) => user.isActive).length;

      // Count users by role
      final usersByRole = <String, int>{};
      for (final user in users) {
        usersByRole[user.role] = (usersByRole[user.role] ?? 0) + 1;
      }

      emit(UsersLoaded(
        users: users,
        searchQuery: _currentSearchQuery,
        roleFilter: _currentRoleFilter,
        showInactive: _showInactive,
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        usersByRole: usersByRole,
      ));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<UserState> emit) async {
    _currentSearchQuery = event.query.isEmpty ? null : event.query;
    add(LoadUsers());
  }

  Future<void> _onFilterUsersByRole(
      FilterUsersByRole event, Emitter<UserState> emit) async {
    _currentRoleFilter = event.role;
    add(LoadUsers());
  }

  Future<void> _onShowInactiveUsers(
      ShowInactiveUsers event, Emitter<UserState> emit) async {
    _showInactive = event.show;
    add(LoadUsers());
  }

  Future<void> _onAddUser(AddUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userRepository.createUser(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
        currentUserId: currentUserId,
      );
      add(LoadUsers());
    } catch (e) {
      emit(UserError(e.toString()));
      add(LoadUsers());
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      // Update user information
      await _userRepository.updateUser(
        user: event.user,
        currentUserId: currentUserId,
      );

      // Update password if provided
      if (event.newPassword != null && event.newPassword!.isNotEmpty) {
        await _userRepository.updateUserPassword(
          event.user.id,
          event.newPassword!,
        );
      }

      add(LoadUsers());
    } catch (e) {
      emit(UserError(e.toString()));
      add(LoadUsers());
    }
  }

  Future<void> _onUpdateUserStatus(
      UpdateUserStatus event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      await _userRepository.updateUserStatus(event.userId, event.isActive);
      add(LoadUsers());
    } catch (e) {
      emit(UserError(e.toString()));
      add(LoadUsers());
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      // Instead of deleting, we deactivate the user
      await _userRepository.updateUserStatus(event.userId, false);
      add(LoadUsers());
    } catch (e) {
      emit(UserError(e.toString()));
      add(LoadUsers());
    }
  }

  // Helper methods
  bool isCurrentUser(String userId) => userId == currentUserId;

  bool canEditUser(UserModel user) {
    return !isCurrentUser(user.id) || user.role != UserRole.administrator.name;
  }
}
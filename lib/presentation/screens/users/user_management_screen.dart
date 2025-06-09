import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/users/users_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../widgets/users/add_user_dialog.dart';
import '../../widgets/users/edit_user_dialog.dart';
import '../../widgets/users/user_table.dart';
import '../../widgets/users/user_filters.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(LoadUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }

  void _showEditUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return EditUserDialog(
              user: user,
              currentUser: state.user,
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isSmallScreen)
                  ElevatedButton.icon(
                    onPressed: _showAddUserDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Filters
            UserFilters(
              searchController: _searchController,
              selectedRole: _selectedRole,
              showInactive: _showInactive,
              onSearchChanged: (value) {
                context.read<UserBloc>().add(SearchUsers(value));
              },
              onRoleChanged: (role) {
                setState(() => _selectedRole = role);
                context.read<UserBloc>().add(FilterUsersByRole(role));
              },
              onShowInactiveChanged: (value) {
                setState(() => _showInactive = value);
                context.read<UserBloc>().add(ShowInactiveUsers(value));
              },
            ),
            const SizedBox(height: 16),

            // User List
            Expanded(
              child: BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is UserError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is UsersLoaded) {
                    if (state.users.isEmpty) {
                      return const Center(
                        child: Text('No users found'),
                      );
                    }

                    return UserTable(
                      users: state.users,
                      onEdit: _showEditUserDialog,
                      onStatusChange: (user, isActive) {
                        context.read<UserBloc>().add(
                          UpdateUserStatus(user.id, isActive),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
      // FAB for mobile
      floatingActionButton: isSmallScreen
          ? FloatingActionButton(
        onPressed: _showAddUserDialog,
        backgroundColor: Colors.blue[100],
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
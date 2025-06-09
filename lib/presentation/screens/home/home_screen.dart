import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../utils/navigation_controller.dart';
import '../../widgets/common/mobile_drawer.dart';
import '../../widgets/common/responsive_layout.dart';
import '../../widgets/side_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationController>(
      builder: (context, navigator, _) => Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(context, navigator),
        drawer: MediaQuery.of(context).size.width < 600
            ? const MobileDrawer()
            : null,
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (MediaQuery.of(context).size.width >= 600) const SideMenu(),
              Expanded(
                child: Container(
                  height: double.infinity,
                  color: Colors.grey[100],
                  child: navigator.currentScreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, NavigationController navigator) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 24, // Add proper spacing
      leading: MediaQuery.of(context).size.width < 600
          ? IconButton(
        icon: const Icon(
          Icons.menu,
          color: Colors.black87,
        ),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      )
          : null,
      leadingWidth: MediaQuery.of(context).size.width < 600 ? 56 : 0, // Adjust leading width
      title: Text(
        _getScreenTitle(navigator.currentRoute),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24), // Add proper spacing
          child: _buildAppBarActions(context),
        ),
      ],
    );
  }

  Widget _buildAppBarActions(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const SizedBox();
        }

        final user = state.user;

        return Row(
          children: [
            // Notifications
            // Stack(
            //   children: [
            //     IconButton(
            //       icon: const Icon(
            //         Icons.notifications_outlined,
            //         color: Colors.black87,
            //       ),
            //       onPressed: () {
            //         // TODO: Implement notifications
            //       },
            //     ),
            //     Positioned(
            //       right: 8,
            //       top: 8,
            //       child: Container(
            //         padding: const EdgeInsets.all(4),
            //         decoration: const BoxDecoration(
            //           color: Colors.red,
            //           shape: BoxShape.circle,
            //         ),
            //         child: const Text(
            //           '3',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 10,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(width: 8),

            // User Profile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 48),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue[100],
                      radius: 16,
                      child: Text(
                        user.name?[0].toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (MediaQuery.of(context).size.width >= 800) ...[
                      const SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'User',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.role,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text('Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'logout',
                    child: const ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () {
                      context.read<AuthBloc>().add(SignOutRequested());
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getScreenTitle(String route) {
    switch (route) {
      case '/dashboard':
        return 'Dashboard';
      case '/users':
        return 'User Management';
      case '/products':
        return 'Products';
      case '/categories':
        return 'Categories';
      case '/warehouses':
        return 'Warehouse Management';
      case '/stock-transfer':
        return 'Stock Transfer';
      case '/reports/sales':
        return 'Sales Reports';
      case '/reports/purchases':
        return 'Purchase Reports';
      case '/reports/stock':
        return 'Stock Reports';
      case '/suppliers':
        return 'Suppliers';
      case '/customers':
        return 'Customers';
      case '/sales':
        return 'Sales Orders';
      case '/purchases':
        return 'Purchase Orders';
      case '/settings':
        return 'Settings';
      case '/help':
        return 'Help & Support';
      default:
        return 'Dashboard';
    }
  }
}
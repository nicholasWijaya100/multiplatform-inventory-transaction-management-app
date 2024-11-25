import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/activity_item.dart';

// Events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

// States
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalProducts;
  final int lowStockItems;
  final int pendingOrders;
  final double totalSales;
  final List<ActivityItem> recentActivities;

  const DashboardLoaded({
    required this.totalProducts,
    required this.lowStockItems,
    required this.pendingOrders,
    required this.totalSales,
    required this.recentActivities,
  });

  @override
  List<Object?> get props => [
    totalProducts,
    lowStockItems,
    pendingOrders,
    totalSales,
    recentActivities,
  ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
      LoadDashboardData event,
      Emitter<DashboardState> emit,
      ) async {
    emit(DashboardLoading());
    try {
      // TODO: Replace with actual data fetching
      final activities = [
        ActivityItem(
          id: '1',
          title: 'Stock Updated',
          subtitle: 'Product #1234 stock updated',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          type: ActivityType.stock,
        ),
        ActivityItem(
          id: '2',
          title: 'New Order',
          subtitle: 'New order #5678 received',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          type: ActivityType.order,
        ),
        ActivityItem(
          id: '3',
          title: 'User Activity',
          subtitle: 'User John Doe updated their profile',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          type: ActivityType.user,
        ),
        ActivityItem(
          id: '4',
          title: 'Delivery Status',
          subtitle: 'Order #9012 delivered successfully',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          type: ActivityType.delivery,
        ),
      ];

      emit(DashboardLoaded(
        totalProducts: 1234,
        lowStockItems: 12,
        pendingOrders: 56,
        totalSales: 12345.0,
        recentActivities: activities,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
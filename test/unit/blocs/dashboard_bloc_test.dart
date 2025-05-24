// test/unit/blocs/dashboard_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app_revised/blocs/dashboard/dashboard_bloc.dart';
import 'package:inventory_app_revised/data/models/activity_item.dart';

void main() {
  late DashboardBloc dashboardBloc;

  setUp(() {
    dashboardBloc = DashboardBloc();
  });

  tearDown(() {
    dashboardBloc.close();
  });

  group('DashboardBloc', () {
    test('initial state is DashboardInitial', () {
      expect(dashboardBloc.state, isA<DashboardInitial>());
    });

    blocTest<DashboardBloc, DashboardState>(
      'emits [DashboardLoading, DashboardLoaded] when LoadDashboardData is added',
      build: () => dashboardBloc,
      act: (bloc) => bloc.add(LoadDashboardData()),
      expect: () => [
        isA<DashboardLoading>(),
        isA<DashboardLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as DashboardLoaded;
        expect(state.totalProducts, isA<int>());
        expect(state.lowStockItems, isA<int>());
        expect(state.pendingOrders, isA<int>());
        expect(state.totalSales, isA<double>());
        expect(state.recentActivities, isA<List<ActivityItem>>());
        expect(state.recentActivities, isNotEmpty);
      },
    );
  });
}
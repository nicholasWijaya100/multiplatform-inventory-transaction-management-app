// test/unit/blocs/users_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inventory_app_revised/blocs/users/users_bloc.dart';
import 'package:inventory_app_revised/data/models/user_model.dart';
import 'package:inventory_app_revised/data/repositories/user_repository.dart';

// Mocks
class MockUserRepository extends Mock implements UserRepository {}

// Fake implementations for fallback registration
class FakeUserModel extends Fake implements UserModel {}

void main() {
  late UserBloc userBloc;
  late MockUserRepository userRepository;
  const String currentUserId = 'current-user-id';

  // Test data
  final testAdmin = UserModel(
    id: 'admin-id',
    email: 'admin@example.com',
    role: UserRole.administrator.name,
    name: 'Admin User',
    isActive: true,
  );

  final testStaff = UserModel(
    id: 'staff-id',
    email: 'staff@example.com',
    role: UserRole.sales.name,
    name: 'Staff User',
    isActive: true,
  );

  final usersList = [testAdmin, testStaff];

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    userRepository = MockUserRepository();
    userBloc = UserBloc(
      userRepository: userRepository,
      currentUserId: currentUserId,
    );
  });

  tearDown(() {
    userBloc.close();
  });

  group('UserBloc', () {
    test('initial state is UserInitial', () {
      expect(userBloc.state, isA<UserInitial>());
    });

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UsersLoaded] when LoadUsers is added',
      build: () {
        when(() => userRepository.getUsers(
          searchQuery: any(named: 'searchQuery'),
          roleFilter: any(named: 'roleFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => usersList);
        return userBloc;
      },
      act: (bloc) => bloc.add(LoadUsers()),
      expect: () => [
        isA<UserLoading>(),
        isA<UsersLoaded>(),
      ],
      verify: (_) {
        verify(() => userRepository.getUsers(
          searchQuery: null,
          roleFilter: null,
          includeInactive: false,
        )).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UsersLoaded] with filtered results when SearchUsers is added',
      build: () {
        when(() => userRepository.getUsers(
          searchQuery: any(named: 'searchQuery'),
          roleFilter: any(named: 'roleFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => usersList);
        return userBloc;
      },
      act: (bloc) => bloc.add(const SearchUsers('admin')),
      expect: () => [
        isA<UserLoading>(),
        isA<UsersLoaded>(),
      ],
      verify: (_) {
        verify(() => userRepository.getUsers(
          searchQuery: 'admin',
          roleFilter: null,
          includeInactive: false,
        )).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UsersLoaded] when FilterUsersByRole is added',
      build: () {
        when(() => userRepository.getUsers(
          searchQuery: any(named: 'searchQuery'),
          roleFilter: any(named: 'roleFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => usersList);
        return userBloc;
      },
      act: (bloc) => bloc.add(const FilterUsersByRole('administrator')),
      expect: () => [
        isA<UserLoading>(),
        isA<UsersLoaded>(),
      ],
      verify: (_) {
        verify(() => userRepository.getUsers(
          searchQuery: null,
          roleFilter: 'administrator',
          includeInactive: false,
        )).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UsersLoaded] when ShowInactiveUsers is added',
      build: () {
        when(() => userRepository.getUsers(
          searchQuery: any(named: 'searchQuery'),
          roleFilter: any(named: 'roleFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => usersList);
        return userBloc;
      },
      act: (bloc) => bloc.add(const ShowInactiveUsers(true)),
      expect: () => [
        isA<UserLoading>(),
        isA<UsersLoaded>(),
      ],
      verify: (_) {
        verify(() => userRepository.getUsers(
          searchQuery: null,
          roleFilter: null,
          includeInactive: true,
        )).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UsersLoaded] when AddUser succeeds',
      build: () {
        when(() => userRepository.createUser(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
          role: any(named: 'role'),
          currentUserId: any(named: 'currentUserId'),
        )).thenAnswer((_) async => testStaff);
        when(() => userRepository.getUsers(
          searchQuery: any(named: 'searchQuery'),
          roleFilter: any(named: 'roleFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => usersList);
        return userBloc;
      },
      act: (bloc) => bloc.add(const AddUser(
        email: 'new@example.com',
        password: 'password123',
        name: 'New User',
        role: 'sales',
      )),
      expect: () => [
        isA<UserLoading>(),
        isA<UsersLoaded>(),
      ],
      verify: (_) {
        verify(() => userRepository.createUser(
          email: 'new@example.com',
          password: 'password123',
          name: 'New User',
          role: 'sales',
          currentUserId: currentUserId,
        )).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError, UserLoading, UsersLoaded] when AddUser fails',
      build: () {
        when(() => userRepository.createUser(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
          role: any(named: 'role'),
          currentUserId: any(named: 'currentUserId'),
        )).thenThrow(Exception('Failed to create user'));
        when(() => userRepository.getUsers(
          searchQuery: any(named: 'searchQuery'),
          roleFilter: any(named: 'roleFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => usersList);
        return userBloc;
      },
      act: (bloc) => bloc.add(const AddUser(
        email: 'invalid@example.com',
        password: 'password',
        name: 'Invalid User',
        role: 'administrator',
      )),
      expect: () => [
        isA<UserLoading>(),
        isA<UserError>(),
        isA<UserLoading>(),
        isA<UsersLoaded>(),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UsersLoaded] when UpdateUser succeeds',
      build: () {
        when(() => userRepository.updateUser(
          user: any(named: 'user'),
          currentUserId: any(named: 'currentUserId'),
        )).thenAnswer((_) async {});
        when(() => userRepository.getUsers(
          searchQuery: any(named: 'searchQuery'),
          roleFilter: any(named: 'roleFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => usersList);
        return userBloc;
      },
      act: (bloc) => bloc.add(UpdateUser(user: testStaff)),
      expect: () => [
        isA<UserLoading>(),
        isA<UsersLoaded>(),
      ],
      verify: (_) {
        verify(() => userRepository.updateUser(
          user: testStaff,
          currentUserId: currentUserId,
        )).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UsersLoaded] when UpdateUserStatus succeeds',
      build: () {
        when(() => userRepository.updateUserStatus(any(), any()))
            .thenAnswer((_) async {});
        when(() => userRepository.getUsers(
          searchQuery: any(named: 'searchQuery'),
          roleFilter: any(named: 'roleFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => usersList);
        return userBloc;
      },
      act: (bloc) => bloc.add(const UpdateUserStatus('staff-id', false)),
      expect: () => [
        isA<UserLoading>(),
        isA<UsersLoaded>(),
      ],
      verify: (_) {
        verify(() => userRepository.updateUserStatus('staff-id', false)).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emits [UserLoading, UserError, UserLoading, UsersLoaded] when UpdateUserStatus fails',
      build: () {
        when(() => userRepository.updateUserStatus(any(), any()))
            .thenThrow(Exception('Failed to update user status'));
        when(() => userRepository.getUsers(
          searchQuery: any(named: 'searchQuery'),
          roleFilter: any(named: 'roleFilter'),
          includeInactive: any(named: 'includeInactive'),
        )).thenAnswer((_) async => usersList);
        return userBloc;
      },
      act: (bloc) => bloc.add(const UpdateUserStatus('admin-id', false)),
      expect: () => [
        isA<UserLoading>(),
        isA<UserError>(),
        isA<UserLoading>(),
        isA<UsersLoaded>(),
      ],
    );
  });
}
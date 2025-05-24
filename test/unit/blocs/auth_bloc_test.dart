import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:inventory_app_revised/blocs/auth/auth_bloc.dart';
import 'package:inventory_app_revised/data/models/user_model.dart';
import 'package:inventory_app_revised/data/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository authRepository;
  late AuthBloc authBloc;
  late UserModel mockUser;

  setUp(() {
    authRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: authRepository);
    mockUser = const UserModel(
      id: 'test-id',
      email: 'test@example.com',
      role: 'administrator',
      name: 'Test User',
      isActive: true,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when AuthCheckRequested succeeds',
      build: () {
        when(() => authRepository.getCurrentUser())
            .thenAnswer((_) async => mockUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        AuthLoading(),
        Authenticated(mockUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when AuthCheckRequested fails',
      build: () {
        when(() => authRepository.getCurrentUser())
            .thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when SignInRequested succeeds',
      build: () {
        when(() => authRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => mockUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInRequested('test@example.com', 'password')),
      expect: () => [
        AuthLoading(),
        Authenticated(mockUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, Unauthenticated] when SignInRequested fails',
      build: () {
        when(() => authRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignInRequested('test@example.com', 'wrong-password')),
      expect: () => [
        AuthLoading(),
        isA<AuthError>(),
        Unauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when SignOutRequested succeeds',
      build: () {
        when(() => authRepository.signOut()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(SignOutRequested()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });
}
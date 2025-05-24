import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:inventory_app_revised/data/models/user_model.dart';
import 'package:inventory_app_revised/data/repositories/auth_repository.dart';

// Define mocks using Mocktail
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

// For fallback registration
class FakeUserCredential extends Fake implements UserCredential {}

void main() {
  late AuthRepository authRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  setUpAll(() {
    // Register fallback values for complex types using our fake implementation
    registerFallbackValue(FakeUserCredential());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    authRepository = AuthRepository(
      firebaseAuth: mockFirebaseAuth,
      firestore: fakeFirestore,
    );

    // Setup mock user
    when(() => mockUser.uid).thenReturn('test-uid');
    when(() => mockUserCredential.user).thenReturn(mockUser);

    // For current user tests
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

    // For signIn test
    when(() => mockFirebaseAuth.signInWithEmailAndPassword(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => mockUserCredential);

    // For signOut test
    when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

    // Setup Firestore document for user - make sure all the expected fields are there
    fakeFirestore.collection('users').doc('test-uid').set({
      'email': 'test@example.com',
      'role': 'administrator',
      'name': 'Test User',
      'isActive': true,
      // Add any other fields that your UserModel.fromJson expects
    });
  });

  group('AuthRepository', () {
    test('getCurrentUser returns UserModel when user is authenticated', () async {
      final user = await authRepository.getCurrentUser();

      expect(user, isNotNull);
      expect(user?.id, equals('test-uid'));
      expect(user?.email, equals('test@example.com'));
      expect(user?.role, equals('administrator'));
      expect(user?.isActive, isTrue);
    });

    test('getCurrentUser returns null when user is not authenticated', () async {
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      final user = await authRepository.getCurrentUser();

      expect(user, isNull);
    });

    test('signIn returns UserModel when credentials are valid', () async {
      final mockUserCredential = MockUserCredential();
      when(() => mockUserCredential.user).thenReturn(mockUser);

      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockUserCredential);

      final user = await authRepository.signIn(
        email: 'test@example.com',
        password: 'password',
      );

      expect(user, isNotNull);
      expect(user.id, equals('test-uid'));
      expect(user.email, equals('test@example.com'));
    });

    test('signIn throws exception when credentials are invalid', () async {
      // Mock the specific Firebase exception that would be thrown
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      expect(
            () => authRepository.signIn(
          email: 'test@example.com',
          password: 'wrong-password',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('signOut calls Firebase signOut', () async {
      // Important fix: setup the mock correctly for void async method
      when(() => mockFirebaseAuth.signOut())
          .thenAnswer((_) async {}); // Use thenAnswer for async methods

      await authRepository.signOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../lib/data/repositories/auth_repository.dart';
import '../../../lib/data/models/user_model.dart';
import 'auth_repository_test.mocks.dart';

// Generate mocks with proper type arguments
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  UserCredential,
  User,
  DocumentReference,
  CollectionReference,
  DocumentSnapshot,
  Query,
])
void main() {
  late AuthRepository authRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockDocumentReference = MockDocumentReference();
    mockCollectionReference = MockCollectionReference();
    mockDocumentSnapshot = MockDocumentSnapshot();

    authRepository = AuthRepository(
      firebaseAuth: mockFirebaseAuth,
      firestore: mockFirestore,
    );
  });

  group('AuthRepository', () {
    const testEmail = 'admin@admin.com';
    const testPassword = 'admin123';
    const testUserId = 'NQm9v46NRHSl6I9oPWIxYFgBLeV2';

    final testUserData = {
      'id': testUserId,
      'email': testEmail,
      'role': 'Administrator',
      'name': 'Administrator',
      'isActive': true,
    };

    test('signIn - successful', () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      // Mock Firestore collection chain
      when(mockFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(testUserId))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data())
          .thenReturn(testUserData);

      // Act
      final result = await authRepository.signIn(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, isA<UserModel>());
      expect(result.email, testEmail);
      expect(result.role, 'administrator');

      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).called(1);
      verify(mockFirestore.collection('users')).called(1);
      verify(mockCollectionReference.doc(testUserId)).called(1);
      verify(mockDocumentReference.get()).called(1);
    });

    test('signIn - throws exception when user not found', () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenThrow(
        FirebaseAuthException(code: 'user-not-found'),
      );

      // Act & Assert
      expect(
            () => authRepository.signIn(
          email: testEmail,
          password: testPassword,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('signIn - throws exception when document does not exist', () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      )).thenAnswer((_) async => mockUserCredential);

      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      when(mockFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(testUserId))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      // Act & Assert
      expect(
            () => authRepository.signIn(
          email: testEmail,
          password: testPassword,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('signOut - successful', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act
      await authRepository.signOut();

      // Assert
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('getCurrentUser - returns null when no user is signed in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await authRepository.getCurrentUser();

      // Assert
      expect(result, isNull);
    });

    test('getCurrentUser - returns user when signed in', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);

      when(mockFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(testUserId))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data())
          .thenReturn(testUserData);

      // Act
      final result = await authRepository.getCurrentUser();

      // Assert
      expect(result, isA<UserModel>());
      expect(result!.email, testEmail);
      expect(result.role, 'administrator');
    });
  });
}
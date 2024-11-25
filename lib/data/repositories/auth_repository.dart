import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _firebaseAuth.signOut();
        return null;
      }

      final userData = UserModel.fromJson(doc.data()!..['id'] = doc.id);

      // Check if user is active
      if (!userData.isActive) {
        await _firebaseAuth.signOut();
        throw Exception('Your account has been deactivated. Please contact administrator.');
      }

      return userData;
    } catch (e) {
      await _firebaseAuth.signOut();
      throw _handleError(e);
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Sign out any existing user first
      await _firebaseAuth.signOut();

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Login failed');
      }

      final doc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        await _firebaseAuth.signOut();
        throw Exception('User data not found');
      }

      final userData = UserModel.fromJson(doc.data()!..['id'] = doc.id);

      // Check if user is active
      if (!userData.isActive) {
        await _firebaseAuth.signOut();
        throw Exception('Your account has been deactivated. Please contact administrator.');
      }

      return userData;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Wrong password');
      case 'user-disabled':
        return Exception('This account has been disabled');
      case 'invalid-email':
        return Exception('Invalid email address');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }

  Exception _handleError(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    }
    if (error is Exception) {
      return error;
    }
    return Exception(error.toString());
  }
}
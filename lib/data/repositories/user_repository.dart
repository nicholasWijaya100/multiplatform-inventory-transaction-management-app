import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Get users with filtering options
  Future<List<UserModel>> getUsers({
    String? searchQuery,
    String? roleFilter,
    bool includeInactive = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('users');

      // Apply role filter if specified
      if (roleFilter != null && roleFilter != 'All') {
        query = query.where('role', isEqualTo: roleFilter);
      }

      // Apply active status filter if not including inactive users
      if (!includeInactive) {
        query = query.where('isActive', isEqualTo: true);
      }

      final querySnapshot = await query.get();
      final users = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();

      // Apply search filter if specified
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchLower = searchQuery.toLowerCase();
        return users.where((user) {
          return user.email.toLowerCase().contains(searchLower) ||
              (user.name?.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      }

      return users;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Create new user
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required String role,
    required String currentUserId,  // Add this parameter
  }) async {
    try {
      // Check if trying to create an administrator
      if (role == UserRole.administrator.name) {
        throw Exception('Creating new administrator accounts is not allowed');
      }

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user authentication');
      }

      // Create user document in Firestore
      final userData = UserModel(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        role: role,
        isActive: true,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData.toJson());

      // Log activity
      await logUserActivity(
        currentUserId,
        'Created new user: $email with role: $role',
      );

      return userData;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateUser({
    required UserModel user,
    required String currentUserId,  // Add this parameter
  }) async {
    try {
      // Get the current user's data
      final currentUserDoc = await _firestore.collection('users').doc(currentUserId).get();
      if (!currentUserDoc.exists) {
        throw Exception('Current user not found');
      }
      final currentUserData = UserModel.fromJson(currentUserDoc.data()!..['id'] = currentUserDoc.id);

      // Get the target user's original data
      final userDoc = await _firestore.collection('users').doc(user.id).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      final originalUserData = UserModel.fromJson(userDoc.data()!..['id'] = userDoc.id);

      // Check role change restrictions
      if (user.id == currentUserId && user.role != originalUserData.role) {
        throw Exception('You cannot change your own role');
      }

      // Check if trying to change someone to administrator
      if (user.role == UserRole.administrator.name &&
          originalUserData.role != UserRole.administrator.name) {
        throw Exception('Creating new administrator accounts is not allowed');
      }

      // Update user document
      await _firestore.collection('users').doc(user.id).update(user.toJson());

      // Log activity if role was changed
      if (user.role != originalUserData.role) {
        await logUserActivity(
          currentUserId,
          'Changed user ${user.email} role from ${originalUserData.role} to ${user.role}',
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update user password
  Future<void> updateUserPassword(String userId, String newPassword) async {
    try {
      // Get current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // Only allow administrators or the user themselves to change password
      final adminDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final isAdmin = adminDoc.data()?['role'] == UserRole.administrator.name;

      if (!isAdmin && currentUser.uid != userId) {
        throw Exception('Unauthorized to change password');
      }

      // Update password
      if (currentUser.uid == userId) {
        await currentUser.updatePassword(newPassword);
      } else {
        // For admin changing other user's password, we'll need to use a cloud function
        // For now, we'll just update the user's document with a flag
        await _firestore.collection('users').doc(userId).update({
          'passwordResetRequired': true,
          'temporaryPassword': newPassword,
        });
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Update user active status (soft delete/disable)
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      // Check if user exists
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = UserModel.fromJson(userDoc.data()!..['id'] = userDoc.id);

      // Don't allow deactivating the last active administrator
      if (!isActive && userData.role == UserRole.administrator.name) {
        final adminQuery = await _firestore
            .collection('users')
            .where('role', isEqualTo: UserRole.administrator.name)
            .where('isActive', isEqualTo: true)
            .get();

        if (adminQuery.docs.length <= 1) {
          throw Exception(
              'Cannot deactivate the last active administrator account');
        }
      }

      // Update user status
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'lastModified': FieldValue.serverTimestamp(),
        'lastModifiedBy': _auth.currentUser?.uid ?? 'system',
        if (!isActive) 'deactivatedAt': FieldValue.serverTimestamp(),
        if (!isActive) 'deactivatedBy': _auth.currentUser?.uid ?? 'system',
        if (isActive) 'reactivatedAt': FieldValue.serverTimestamp(),
        if (isActive) 'reactivatedBy': _auth.currentUser?.uid ?? 'system',
      });

      // Log the action
      await logUserActivity(
        _auth.currentUser?.uid ?? 'system',
        isActive ? 'Reactivated user' : 'Deactivated user',
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handling
  Exception _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('Email is already in use');
      case 'invalid-email':
        return Exception('Invalid email address');
      case 'operation-not-allowed':
        return Exception('Operation not allowed');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'user-disabled':
        return Exception('User has been disabled');
      case 'user-not-found':
        return Exception('User not found');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'requires-recent-login':
        return Exception('Please log in again to perform this action');
      default:
        return Exception(e.message ?? 'An authentication error occurred');
    }
  }

  Exception _handleError(dynamic error) {
    if (error is FirebaseAuthException) {
      return _handleAuthError(error);
    }
    if (error is FirebaseException) {
      return Exception(error.message ?? 'A database error occurred');
    }
    if (error is Exception) {
      return error;
    }
    return Exception(error.toString());
  }

  // Activity Logging
  Future<void> logUserActivity(String userId, String activity) async {
    try {
      await _firestore.collection('user_activity_logs').add({
        'userId': userId,
        'activity': activity,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Log errors but don't throw them to prevent disrupting main operations
      print('Failed to log user activity: $e');
    }
  }

  // Role Management Methods
  List<String> getAvailableRoles() {
    return UserRole.values.map((role) => role.name).toList();
  }

  bool isAdministrator(UserModel user) {
    return user.role == UserRole.administrator.name;
  }

  // Permission Check Methods
  bool canManageUsers(UserModel currentUser) {
    return isAdministrator(currentUser);
  }

  bool canEditUser(UserModel currentUser, UserModel targetUser) {
    if (!isAdministrator(currentUser)) return false;
    return true;
  }
}
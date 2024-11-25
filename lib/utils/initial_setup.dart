import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_model.dart';

class InitialSetup {
  static Future<void> checkAndCreateAdminUser() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      // Check if admin user exists
      final adminQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: 'admin@admin.com')
          .get();

      if (adminQuery.docs.isEmpty) {
        // Create admin user in Firebase Auth
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: 'admin@admin.com',
          password: 'admin123',
        );

        // Create admin user in Firestore
        final adminUser = UserModel(
          id: userCredential.user!.uid,
          email: 'admin@admin.com',
          role: UserRole.administrator.name,
          name: 'Administrator',
          isActive: true,
        );

        await firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(adminUser.toJson());
      }
    } catch (e) {
      print('Error creating admin user: $e');
    }
  }
}
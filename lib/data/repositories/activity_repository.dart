import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ActivityRepository {
  final FirebaseFirestore _firestore;

  ActivityRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> logActivity({
    required String userId,
    required String action,
    required String category,
    String? details,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('activity_logs').add({
        'userId': userId,
        'action': action,
        'category': category,
        'details': details,
        'metadata': metadata,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to log activity: $e');
      // We don't throw here to prevent disrupting main operations
    }
  }
}
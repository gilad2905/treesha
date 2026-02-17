import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore =
          firestore ??
          FirebaseFirestore.instanceFor(
            app: Firebase.app(),
            databaseId: 'treesha',
          );

  Future<void> blockUser(String currentUserId, String blockedUserId) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .doc(blockedUserId)
          .set({
            'blockedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw Exception('Failed to block user: $e');
    }
  }

  Future<void> unblockUser(String currentUserId, String blockedUserId) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .doc(blockedUserId)
          .delete();
    } catch (e) {
      throw Exception('Failed to unblock user: $e');
    }
  }

  Future<List<String>> getBlockedUsers(String currentUserId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked_users')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error fetching blocked users: $e');
      return [];
    }
  }
}

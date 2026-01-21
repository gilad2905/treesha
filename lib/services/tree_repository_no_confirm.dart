import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// TreeRepository that uses Firebase SDK with the custom "treesha" database
class TreeRepositoryNoConfirm {
  // Use the named "treesha" database instead of the default database
  FirebaseFirestore get _firestore =>
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'treesha');

  /// Add a tree using Firebase SDK
  Future<String> addTree({
    required String userId,
    required String name,
    required String fruitType,
    required Position position,
    String? imageUrl,
    Map<String, dynamic>? initialPost, // Optional initial post data
  }) async {
    debugPrint('[TreeRepo-SDK] =====================================');
    debugPrint('[TreeRepo-SDK] ADDING TREE VIA SDK');
    debugPrint('[TreeRepo-SDK] =====================================');

    try {
      // Create tree document
      final treeData = {
        'userId': userId,
        'name': name,
        'fruitType': fruitType,
        'position': GeoPoint(position.latitude, position.longitude),
        'imageUrl': imageUrl ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'upvotes': [],
        'downvotes': [],
      };

      debugPrint('[TreeRepo-SDK] Creating tree document...');
      final docRef = await _firestore.collection('trees').add(treeData);
      final docId = docRef.id;
      debugPrint('[TreeRepo-SDK] Tree created with ID: $docId');

      // If initial post data is provided, add it as a subcollection
      if (initialPost != null) {
        final imageUrls = initialPost['imageUrls'] as List? ?? [];
        final comment = initialPost['comment'] as String? ?? '';

        if (imageUrls.isNotEmpty || comment.isNotEmpty) {
          try {
            debugPrint('[TreeRepo-SDK] Adding initial post...');
            await addPostToTree(docId, initialPost);
            debugPrint('[TreeRepo-SDK] ✅ Initial post added successfully!');
          } catch (e) {
            debugPrint('[TreeRepo-SDK] ⚠️  Failed to add initial post: $e');
            // Don't fail the entire operation if post fails
          }
        }
      }

      debugPrint('[TreeRepo-SDK] ✅ SUCCESS!');
      debugPrint('[TreeRepo-SDK] =====================================');
      return docId;
    } catch (e, stack) {
      debugPrint('[TreeRepo-SDK] ❌ Exception: $e');
      debugPrint('[TreeRepo-SDK] Stack: $stack');
      debugPrint('[TreeRepo-SDK] =====================================');
      rethrow;
    }
  }

  /// Get all trees from the treesha database
  Future<List<Map<String, dynamic>>> getAllTrees() async {
    debugPrint('[TreeRepo-SDK] Fetching all trees...');

    try {
      final snapshot = await _firestore.collection('trees').get();

      debugPrint('[TreeRepo-SDK] ✅ Fetched ${snapshot.docs.length} trees');

      // Convert to simplified format
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final position = data['position'] as GeoPoint;

        // Debug: Check if lastVerifiedAt exists
        if (data['lastVerifiedAt'] != null) {
          debugPrint('[TreeRepo-SDK] Tree ${doc.id} has lastVerifiedAt: ${data['lastVerifiedAt']}');
        }

        return {
          'id': doc.id,
          'userId': data['userId'] as String? ?? '',
          'name': data['name'] as String? ?? '',
          'fruitType': data['fruitType'] as String? ?? '',
          'latitude': position.latitude,
          'longitude': position.longitude,
          'imageUrl': data['imageUrl'] as String? ?? '',
          'createdAt':
              (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ??
              '',
          'lastVerifiedAt': (data['lastVerifiedAt'] as Timestamp?)
              ?.toDate()
              .toIso8601String(),
          'upvotes': List<String>.from(data['upvotes'] ?? []),
          'downvotes': List<String>.from(data['downvotes'] ?? []),
        };
      }).toList();
    } catch (e, stack) {
      debugPrint('[TreeRepo-SDK] ❌ Error fetching trees: $e');
      debugPrint('[TreeRepo-SDK] Stack: $stack');
      return [];
    }
  }

  /// Verify a tree exists
  Future<bool> verifyTreeExists(String docId) async {
    try {
      final doc = await _firestore.collection('trees').doc(docId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('[TreeRepo-SDK] Verification failed: $e');
      return false;
    }
  }

  /// Upvote a tree using Firebase SDK
  Future<void> upvoteTree(String treeId, String userId) async {
    debugPrint('[TreeRepo-SDK] Upvoting tree $treeId for user $userId');

    try {
      final treeRef = _firestore.collection('trees').doc(treeId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(treeRef);

        if (!snapshot.exists) {
          throw Exception('Tree not found');
        }

        final data = snapshot.data()!;
        List<String> upvotes = List<String>.from(data['upvotes'] ?? []);
        List<String> downvotes = List<String>.from(data['downvotes'] ?? []);

        bool isAddingUpvote = !upvotes.contains(userId);

        if (upvotes.contains(userId)) {
          upvotes.remove(userId);
        } else {
          upvotes.add(userId);
          downvotes.remove(userId);
        }

        final updateData = <String, dynamic>{
          'upvotes': upvotes,
          'downvotes': downvotes,
        };

        // Update lastVerifiedAt when adding an upvote
        if (isAddingUpvote) {
          updateData['lastVerifiedAt'] = FieldValue.serverTimestamp();
        }

        transaction.update(treeRef, updateData);
      });

      debugPrint('[TreeRepo-SDK] ✅ Upvote successful');
    } catch (e, stack) {
      debugPrint('[TreeRepo-SDK] ❌ Upvote failed: $e');
      debugPrint('[TreeRepo-SDK] Stack: $stack');
      rethrow;
    }
  }

  /// Downvote a tree using Firebase SDK
  Future<void> downvoteTree(String treeId, String userId) async {
    debugPrint('[TreeRepo-SDK] Downvoting tree $treeId for user $userId');

    try {
      final treeRef = _firestore.collection('trees').doc(treeId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(treeRef);

        if (!snapshot.exists) {
          throw Exception('Tree not found');
        }

        final data = snapshot.data()!;
        List<String> upvotes = List<String>.from(data['upvotes'] ?? []);
        List<String> downvotes = List<String>.from(data['downvotes'] ?? []);

        if (downvotes.contains(userId)) {
          downvotes.remove(userId);
        } else {
          downvotes.add(userId);
          upvotes.remove(userId);
        }

        transaction.update(treeRef, {
          'upvotes': upvotes,
          'downvotes': downvotes,
        });
      });

      debugPrint('[TreeRepo-SDK] ✅ Downvote successful');
    } catch (e, stack) {
      debugPrint('[TreeRepo-SDK] ❌ Downvote failed: $e');
      debugPrint('[TreeRepo-SDK] Stack: $stack');
      rethrow;
    }
  }

  /// Get all posts for a tree
  Future<List<Map<String, dynamic>>> getTreePosts(String treeId) async {
    debugPrint('[TreeRepo-SDK] Fetching posts for tree $treeId...');

    try {
      final snapshot = await _firestore
          .collection('trees')
          .doc(treeId)
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      debugPrint('[TreeRepo-SDK] ✅ Fetched ${snapshot.docs.length} posts');

      // Convert to simplified format
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'userId': data['userId'] as String? ?? '',
          'userName': data['userName'] as String? ?? 'Anonymous',
          'imageUrls': List<String>.from(data['imageUrls'] ?? []),
          'comment': data['comment'] as String? ?? '',
          'createdAt':
              (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ??
              '',
        };
      }).toList();
    } catch (e, stack) {
      debugPrint('[TreeRepo-SDK] ❌ Error fetching posts: $e');
      debugPrint('[TreeRepo-SDK] Stack: $stack');
      return [];
    }
  }

  /// Add a new post to an existing tree
  Future<void> addPostToTree(
    String treeId,
    Map<String, dynamic> postData,
  ) async {
    debugPrint('[TreeRepo-SDK] Adding post to tree $treeId...');

    try {
      final postRef = _firestore
          .collection('trees')
          .doc(treeId)
          .collection('posts')
          .doc();

      await postRef.set({
        'userId': postData['userId'],
        'userName': postData['userName'],
        'imageUrls': postData['imageUrls'],
        'comment': postData['comment'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[TreeRepo-SDK] ✅ Post added successfully!');
    } catch (e, stack) {
      debugPrint('[TreeRepo-SDK] ❌ Add post failed: $e');
      debugPrint('[TreeRepo-SDK] Stack: $stack');
      rethrow;
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:treez/constants.dart';
import 'package:treez/models/tree_model.dart';
import 'package:treez/services/firestore_config.dart';

/// Repository for tree operations
/// Handles all Firestore interactions for trees
class TreeRepository {
  final FirebaseFirestore _firestore;

  TreeRepository({FirebaseFirestore? firestore})
    : _firestore =
          firestore ??
          FirebaseFirestore.instanceFor(
            app: Firebase.app(),
            databaseId: 'treesha',
          );

  /// Add a new tree to Firestore
  ///
  /// Uses a different approach: Creates document with explicit ID first,
  /// then writes data. This sometimes bypasses WebSocket connection issues.
  /// [userRole] should be 'admin' or 'user'. Admins' trees are auto-approved.
  Future<String> addTree({
    required String userId,
    String? userName,
    required String name,
    required String fruitType,
    required Position position,
    String? imageUrl,
    required String userRole,
  }) async {
    print('[TreeRepository] =====================================');
    print('[TreeRepository] ADD TREE - NEW APPROACH');
    print('[TreeRepository] =====================================');
    print('[TreeRepository]   User: $userId ($userName)');
    print('[TreeRepository]   Name: $name');
    print('[TreeRepository]   Type: $fruitType');
    print(
      '[TreeRepository]   Position: ${position.latitude}, ${position.longitude}',
    );

    // Check configuration
    if (!FirestoreConfig.isConfigured) {
      throw Exception(
        'Firestore not configured. Call FirestoreConfig.configure() first.',
      );
    }

    // Validate inputs
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (name.isEmpty) throw ArgumentError('name cannot be empty');
    if (fruitType.isEmpty) throw ArgumentError('fruitType cannot be empty');

    // Create document data
    final now = DateTime.now();
    final data = {
      'userId': userId,
      'userName': userName ?? '',
      'name': name,
      'fruitType': fruitType,
      'position': GeoPoint(position.latitude, position.longitude),
      'imageUrl': imageUrl ?? '',
      'createdAt': Timestamp.fromDate(now),
      'upvotes': <String>[],
      'downvotes': <String>[],
      'status':
          userRole == AppConstants.statusApproved || userRole == 'admin'
              ? AppConstants.statusApproved
              : AppConstants.statusPending,
    };

    print('[TreeRepository] Document data prepared');

    try {
      // APPROACH 1: Try doc() + set() instead of add()
      // This creates a document with explicit ID, which sometimes works better
      print('[TreeRepository] Approach: Using doc().set() instead of add()');

      final docRef = _firestore.collection('trees').doc(); // Auto-generate ID
      final docId = docRef.id;
      print('[TreeRepository] Generated document ID: $docId');

      print('[TreeRepository] Attempting to write document...');
      await docRef
          .set(data)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException(
                'Write operation timed out after 10 seconds',
              );
            },
          );

      print('[TreeRepository] ✅ SUCCESS! Tree added with ID: $docId');
      print('[TreeRepository] =====================================');
      return docId;
    } on FirebaseException catch (e) {
      print('[TreeRepository] ❌ FirebaseException: ${e.code}');
      print('[TreeRepository]    Message: ${e.message}');
      print('[TreeRepository]    Plugin: ${e.plugin}');
      print('[TreeRepository] =====================================');

      throw TreeRepositoryException(
        'Failed to add tree: ${e.message}',
        code: e.code,
        originalException: e,
      );
    } on TimeoutException catch (e) {
      print('[TreeRepository] ❌ TIMEOUT after 10 seconds');
      print('[TreeRepository]    This suggests WebSocket connection issues');
      print('[TreeRepository] =====================================');

      throw TreeRepositoryException(
        'Failed to add tree: operation timed out',
        code: 'timeout',
        originalException: e,
      );
    } catch (e, stack) {
      print('[TreeRepository] ❌ Unexpected error: $e');
      print('[TreeRepository] Stack: $stack');
      print('[TreeRepository] =====================================');

      throw TreeRepositoryException(
        'Failed to add tree: $e',
        code: 'unknown',
        originalException: e,
      );
    }
  }

  /// Upvote a tree
  ///
  /// Adds userId to upvotes, removes from downvotes.
  /// If upvotes >= threshold, updates status to approved.
  /// If isAdmin is true, updates status to approved immediately.
  Future<void> upvoteTree(String treeId, String userId, {bool isAdmin = false}) async {
    final treeRef = _firestore.collection('trees').doc(treeId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(treeRef);

        if (!snapshot.exists) {
          throw TreeRepositoryException(
            'Tree not found',
            code: 'not-found',
          );
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
          updateData['lastVerifiedAt'] = Timestamp.now();
        }

        // Check 2: Auto-approval logic
        final String currentStatus =
            data['status'] ?? AppConstants.statusPending;

        if (currentStatus == AppConstants.statusPending) {
          if (isAdmin || upvotes.length >= AppConstants.requiredTreeUpvotes) {
            updateData['status'] = AppConstants.statusApproved;
          }
        } else if (currentStatus == AppConstants.statusApproved) {
          // If admin removes upvote, check if we should revoke approval
          if (!isAddingUpvote &&
              isAdmin &&
              upvotes.length < AppConstants.requiredTreeUpvotes) {
            updateData['status'] = AppConstants.statusPending;
          }
        }

        transaction.update(treeRef, updateData);
      });
    } on TreeRepositoryException {
      rethrow;
    } on FirebaseException catch (e) {
      throw TreeRepositoryException(
        'Failed to upvote tree: ${e.message}',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw TreeRepositoryException(
        'Failed to upvote tree: $e',
        code: 'unknown',
        originalException: e,
      );
    }
  }

  /// Downvote a tree
  ///
  /// Adds userId to downvotes, removes from upvotes.
  Future<void> downvoteTree(String treeId, String userId, {bool isAdmin = false}) async {
    final treeRef = _firestore.collection('trees').doc(treeId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(treeRef);

        if (!snapshot.exists) {
          throw TreeRepositoryException(
            'Tree not found',
            code: 'not-found',
          );
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

        final updateData = <String, dynamic>{
          'upvotes': upvotes,
          'downvotes': downvotes,
        };

        // Revocation logic: If admin downvotes, check if we should revoke approval
        final String currentStatus =
            data['status'] ?? AppConstants.statusPending;

        if (currentStatus == AppConstants.statusApproved &&
            isAdmin &&
            upvotes.length < AppConstants.requiredTreeUpvotes) {
          updateData['status'] = AppConstants.statusPending;
        }

        transaction.update(treeRef, updateData);
      });
    } on TreeRepositoryException {
      rethrow;
    } on FirebaseException catch (e) {
      throw TreeRepositoryException(
        'Failed to downvote tree: ${e.message}',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw TreeRepositoryException(
        'Failed to downvote tree: $e',
        code: 'unknown',
        originalException: e,
      );
    }
  }

  /// Report a tree
  Future<void> reportTree(String treeId, String userId) async {
    final treeRef = _firestore.collection('trees').doc(treeId);

    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(treeRef);
        if (!snapshot.exists) {
          throw TreeRepositoryException('Tree not found', code: 'not-found');
        }

        final data = snapshot.data()!;
        List<String> reported = List<String>.from(data['reported'] ?? []);

        if (!reported.contains(userId)) {
          reported.add(userId);
          transaction.update(treeRef, {'reported': reported});
        }
      });
    } on FirebaseException catch (e) {
      throw TreeRepositoryException('Failed to report tree: ${e.message}',
          code: e.code, originalException: e);
    } catch (e) {
      throw TreeRepositoryException('Failed to report tree: $e',
          code: 'unknown', originalException: e);
    }
  }

  /// Delete a tree and all its posts
  Future<void> deleteTree(String treeId) async {
    print('[TreeRepository] Deleting tree $treeId...');
    try {
      // Delete all posts in the subcollection first
      final postsSnapshot = await _firestore
          .collection('trees')
          .doc(treeId)
          .collection('posts')
          .get();
      
      final batch = _firestore.batch();
      for (var doc in postsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the tree document
      batch.delete(_firestore.collection('trees').doc(treeId));
      
      await batch.commit();
      print('[TreeRepository] ✅ Tree and posts deleted successfully');
    } catch (e) {
      print('[TreeRepository] ❌ Delete tree failed: $e');
      throw TreeRepositoryException('Failed to delete tree: $e', code: 'unknown');
    }
  }

  /// Delete a post from a tree
  Future<void> deletePost(String treeId, String postId) async {
    print('[TreeRepository] Deleting post $postId from tree $treeId...');
    try {
      await _firestore
          .collection('trees')
          .doc(treeId)
          .collection('posts')
          .doc(postId)
          .delete();
      print('[TreeRepository] ✅ Post deleted successfully');
    } catch (e) {
      print('[TreeRepository] ❌ Delete post failed: $e');
      throw TreeRepositoryException('Failed to delete post: $e', code: 'unknown');
    }
  }

  /// Get all trees
  Stream<List<Tree>> getTrees() {
    return _firestore.collection('trees').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Tree.fromFirestore(doc)).toList();
    });
  }

  /// Get all posts for a tree
  Future<List<Map<String, dynamic>>> getTreePosts(String treeId) async {
    print('[TreeRepository] Fetching posts for tree $treeId...');

    try {
      final snapshot = await _firestore
          .collection('trees')
          .doc(treeId)
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      print('[TreeRepository] ✅ Fetched ${snapshot.docs.length} posts');

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
      print('[TreeRepository] ❌ Error fetching posts: $e');
      print('[TreeRepository] Stack: $stack');
      return [];
    }
  }

  /// Add a new post to an existing tree
  Future<void> addPostToTree(
    String treeId,
    Map<String, dynamic> postData,
  ) async {
    print('[TreeRepository] Adding post to tree $treeId...');

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

      print('[TreeRepository] ✅ Post added successfully!');
    } catch (e, stack) {
      print('[TreeRepository] ❌ Add post failed: $e');
      print('[TreeRepository] Stack: $stack');
      rethrow;
    }
  }

  /// Test write operation
  Future<bool> testWrite() async {
    print('[TreeRepository] Testing write operation...');
    try {
      final testDoc = await _firestore
          .collection('trees')
          .add({'test': true, 'timestamp': Timestamp.now()})
          .timeout(const Duration(seconds: 10));

      print('[TreeRepository] ✅ Test write successful! ID: ${testDoc.id}');

      // Clean up
      await testDoc.delete();
      print('[TreeRepository] Test document deleted');

      return true;
    } catch (e) {
      print('[TreeRepository] ❌ Test write failed: $e');
      return false;
    }
  }
}

/// Custom exception for tree repository operations
class TreeRepositoryException implements Exception {
  final String message;
  final String code;
  final dynamic originalException;

  TreeRepositoryException(
    this.message, {
    required this.code,
    this.originalException,
  });

  @override
  String toString() => 'TreeRepositoryException($code): $message';
}

/// Timeout exception
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

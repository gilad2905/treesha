import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:treesha/models/tree_model.dart';
import 'package:treesha/services/firestore_config.dart';

/// Repository for tree operations
/// Handles all Firestore interactions for trees
class TreeRepository {
  final FirebaseFirestore _firestore;

  TreeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Add a new tree to Firestore
  ///
  /// Uses a different approach: Creates document with explicit ID first,
  /// then writes data. This sometimes bypasses WebSocket connection issues.
  Future<String> addTree({
    required String userId,
    required String name,
    required String fruitType,
    required Position position,
    String? imageUrl,
  }) async {
    print('[TreeRepository] =====================================');
    print('[TreeRepository] ADD TREE - NEW APPROACH');
    print('[TreeRepository] =====================================');
    print('[TreeRepository]   User: $userId');
    print('[TreeRepository]   Name: $name');
    print('[TreeRepository]   Type: $fruitType');
    print('[TreeRepository]   Position: ${position.latitude}, ${position.longitude}');

    // Validate inputs
    if (userId.isEmpty) throw ArgumentError('userId cannot be empty');
    if (name.isEmpty) throw ArgumentError('name cannot be empty');
    if (fruitType.isEmpty) throw ArgumentError('fruitType cannot be empty');

    // Create document data
    final now = DateTime.now();
    final data = {
      'userId': userId,
      'name': name,
      'fruitType': fruitType,
      'position': GeoPoint(position.latitude, position.longitude),
      'imageUrl': imageUrl ?? '',
      'createdAt': Timestamp.fromDate(now),
      'upvotes': <String>[],
      'downvotes': <String>[],
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
      await docRef.set(data).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Write operation timed out after 10 seconds');
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

  /// Get all trees
  Stream<List<Tree>> getTrees() {
    return _firestore.collection('trees').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Tree.fromFirestore(doc)).toList();
    });
  }

  /// Test write operation
  Future<bool> testWrite() async {
    print('[TreeRepository] Testing write operation...');
    try {
      final testDoc = await _firestore
          .collection('trees')
          .add({
            'test': true,
            'timestamp': Timestamp.now(),
          })
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

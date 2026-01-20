import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


class FirebaseService {
  // Use the named "treesha" database instead of the default database
  FirebaseFirestore get _firestore => FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'treesha',
  );
  FirebaseStorage get _storage => FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  /// Test Firestore connection by attempting a simple read
  Future<void> testFirestoreConnection() async {
    print('[FirebaseService] Testing Firestore connection...');
    try {
      final testDoc = await _firestore.collection('trees').limit(1).get().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw FirebaseException(
            plugin: "firebase_firestore",
            code: "timeout",
            message: "Firestore connection test timed out",
          );
        },
      );
      print('[FirebaseService] Firestore connection test SUCCESS. Found ${testDoc.docs.length} documents');
    } catch (e) {
      print('[FirebaseService] Firestore connection test FAILED: $e');
      rethrow;
    }
  }

  Future<bool> addTree({ // Changed return type to Future<bool>
    required String userId, // User ID of the tree creator
    required String name,
    required String fruitType,
    required Position position,
    XFile? image,
  }) async {
    debugPrint('[FirebaseService] Starting addTree - userId: $userId, name: $name, fruitType: $fruitType');
    debugPrint('[FirebaseService] Position: lat=${position.latitude}, lng=${position.longitude}');

    try {
      String? imageUrl;
      if (image != null) {
        debugPrint('[FirebaseService] Image provided, starting upload: ${image.name}');
        final uploadStart = DateTime.now();

        try {
          imageUrl = await _uploadImage(image).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('[FirebaseService] ERROR: Image upload timed out after 30 seconds');
              throw FirebaseException(
                plugin: "firebase_storage",
                code: "timeout",
                message: "Image upload timed out after 30 seconds",
              );
            },
          );

          final uploadDuration = DateTime.now().difference(uploadStart);
          debugPrint('[FirebaseService] Image upload completed in ${uploadDuration.inSeconds}s, URL: $imageUrl');
        } catch (e) {
          debugPrint('[FirebaseService] ERROR: Image upload failed: $e');
          // Re-throw to fail the entire operation
          rethrow;
        }
      } else {
        debugPrint('[FirebaseService] No image provided, proceeding without image');
      }

      // Create timestamp explicitly
      final now = DateTime.now();
      final timestamp = Timestamp.fromDate(now);

      final payload = {
        'userId': userId, // Store who created the tree
        'name': name,
        'fruitType': fruitType,
        'position': GeoPoint(position.latitude, position.longitude),
        'imageUrl': imageUrl ?? '',
        'createdAt': timestamp, // Use explicit timestamp
        'upvotes': [],
        'downvotes': [],
      };

      debugPrint('[FirebaseService] Using explicit timestamp: $timestamp');

      debugPrint('[FirebaseService] Payload prepared, adding to Firestore: $payload');
      final firestoreStart = DateTime.now();

      // Check Firestore settings
      debugPrint('[FirebaseService] Firestore settings: persistenceEnabled=${_firestore.settings.persistenceEnabled}');

      debugPrint('[FirebaseService] ======================================');
      debugPrint('[FirebaseService] DEBUGGING FIRESTORE ADD OPERATION');
      debugPrint('[FirebaseService] ======================================');
      debugPrint('[FirebaseService] Step 1: Checking Firestore instance...');
      debugPrint('[FirebaseService]   Instance: ${_firestore.runtimeType}');
      debugPrint('[FirebaseService]   App: ${_firestore.app.name}');
      debugPrint('[FirebaseService]   Settings: ${_firestore.settings}');

      debugPrint('[FirebaseService] Step 2: Getting collection reference...');
      final collectionRef = _firestore.collection('trees');
      debugPrint('[FirebaseService]   Collection path: ${collectionRef.path}');
      debugPrint('[FirebaseService]   Collection ID: ${collectionRef.id}');

      debugPrint('[FirebaseService] Step 3: Testing with MINIMAL payload first...');
      debugPrint('[FirebaseService]   NOTE: If this hangs, check Firebase Console:');
      debugPrint('[FirebaseService]   Authentication > Settings > Authorized domains');
      debugPrint('[FirebaseService]   Make sure "localhost" is listed!');

      try {
        debugPrint('[FirebaseService]   Testing: Adding {"test": "hello"}...');

        // Add with a 10 second timeout for the test
        final testDoc = await collectionRef.add({
          'test': 'hello',
          'timestamp': DateTime.now().toString()
        }).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('[FirebaseService]   ⏱️ MINIMAL TEST TIMED OUT after 10s');
            debugPrint('[FirebaseService]   ');
            debugPrint('[FirebaseService]   🚨 CRITICAL: Firestore writes are hanging!');
            debugPrint('[FirebaseService]   This is almost certainly because:');
            debugPrint('[FirebaseService]   1. "localhost" is NOT in Firebase Authorized Domains');
            debugPrint('[FirebaseService]   2. Or WebSocket connections are blocked');
            debugPrint('[FirebaseService]   ');
            debugPrint('[FirebaseService]   ✅ FIX: Go to Firebase Console:');
            debugPrint('[FirebaseService]   https://console.firebase.google.com/project/applied-primacy-294221/authentication/settings');
            debugPrint('[FirebaseService]   Add "localhost" to Authorized domains');
            throw Exception('Firestore write timed out - check authorized domains');
          },
        );

        debugPrint('[FirebaseService]   ✅ MINIMAL TEST SUCCESS! ID: ${testDoc.id}');
        debugPrint('[FirebaseService]   This proves Firestore writes work!');

        // Delete the test document
        await testDoc.delete();
        debugPrint('[FirebaseService]   Test document deleted');
      } catch (e) {
        debugPrint('[FirebaseService]   ❌ MINIMAL TEST FAILED: $e');
        rethrow;
      }

      debugPrint('[FirebaseService] Step 4: Starting REAL add operation...');
      debugPrint('[FirebaseService]   Payload size: ${payload.toString().length} chars');
      debugPrint('[FirebaseService]   Calling add()...');

      DocumentReference? docRef;
      bool operationStarted = false;

      try {
        // Mark that we're starting
        operationStarted = true;
        debugPrint('[FirebaseService] Step 5: Awaiting add() response...');

        // Try the add operation
        docRef = await collectionRef.add(payload);

        debugPrint('[FirebaseService] ✅ SUCCESS! Add operation completed');
        debugPrint('[FirebaseService]   Document ID: ${docRef.id}');
      } on FirebaseException catch (e) {
        debugPrint('[FirebaseService] ========================================');
        debugPrint('[FirebaseService] ❌ ERROR: FirebaseException during add');
        debugPrint('[FirebaseService] Code: ${e.code}');
        debugPrint('[FirebaseService] Message: ${e.message}');
        debugPrint('[FirebaseService] Plugin: ${e.plugin}');
        debugPrint('[FirebaseService] ========================================');

        if (e.code == 'permission-denied') {
          debugPrint('[FirebaseService] PERMISSION DENIED');
          debugPrint('[FirebaseService] Your rules expire 2026-02-18, so this should work!');
          debugPrint('[FirebaseService] Try updating rules in Firebase Console');
        } else if (e.code == 'unavailable') {
          debugPrint('[FirebaseService] UNAVAILABLE - Cannot reach Firebase');
        } else if (e.code == 'unauthenticated') {
          debugPrint('[FirebaseService] UNAUTHENTICATED - User not logged in');
        }
        rethrow;
      } catch (e, stackTrace) {
        debugPrint('[FirebaseService] ========================================');
        debugPrint('[FirebaseService] ❌ UNEXPECTED ERROR: ${e.runtimeType}');
        debugPrint('[FirebaseService] Error: $e');
        debugPrint('[FirebaseService] Stack: $stackTrace');
        debugPrint('[FirebaseService] ========================================');
        rethrow;
      }

      debugPrint('[FirebaseService] Document added with ID: ${docRef.id}');

      final firestoreDuration = DateTime.now().difference(firestoreStart);
      debugPrint('[FirebaseService] SUCCESS: Tree added to Firestore in ${firestoreDuration.inSeconds}s');
      return true; // Tree added successfully
    } on FirebaseException catch (e) {
      debugPrint('[FirebaseService] ERROR: FirebaseException - plugin: ${e.plugin}, code: ${e.code}, message: ${e.message}');
      throw e; // Re-throw Firebase exceptions
    } catch (e, stackTrace) {
      // Catch any other unexpected errors and wrap them in a FirebaseException
      debugPrint('[FirebaseService] ERROR: Unexpected error while adding tree: $e');
      debugPrint('[FirebaseService] Stack trace: $stackTrace');
      throw FirebaseException(
        plugin: "firebase_firestore",
        code: "unknown",
        message: "An unexpected error occurred while adding tree: $e",
      );
    }
  }

  Stream<QuerySnapshot> getTrees({int minVerificationScore = -100}) {
    return _firestore
        .collection('trees')
        .where('verificationScore', isGreaterThanOrEqualTo: minVerificationScore)
        .snapshots();
  }

  Future<void> upvoteTree(String treeId, String userId) async {
    final treeRef = _firestore.collection('trees').doc(treeId);
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(treeRef);

        if (!snapshot.exists) {
          throw Exception("Tree document with ID $treeId not found.");
        }
        final data = snapshot.data();
        if (data == null) {
          throw Exception("Tree data is null for ID $treeId.");
        }
        List<String> upvotes = [];
        List<String> downvotes = [];
        try {
          if (data['upvotes'] is List) {
            upvotes = List<String>.from(data['upvotes'].whereType<String>());
          }
        } catch (e) {
          // Error casting upvotes for tree $treeId: $e
        }
        try {
          if (data['downvotes'] is List) {
            downvotes = List<String>.from(data['downvotes'].whereType<String>());
          }
        } catch (e) {
          // Error casting downvotes for tree $treeId: $e
        }

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
    } on FirebaseException catch (e) {
      rethrow; // Use rethrow
    } catch (error) { // ignore: unused_catch_clause
      throw FirebaseException(
        plugin: "firebase_firestore",
        code: "unknown",
        message: "An unexpected error occurred during upvote: $error",
      );
    }
  }

  Future<void> downvoteTree(String treeId, String userId) async {
    final treeRef = _firestore.collection('trees').doc(treeId);
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(treeRef);

        if (!snapshot.exists) {
          throw Exception("Tree document with ID $treeId not found.");
        }
        final List<String> upvotes = List<String>.from(snapshot.data()!['upvotes'] ?? []);
        final List<String> downvotes = List<String>.from(snapshot.data()!['downvotes'] ?? []);

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
    } on FirebaseException catch (e) {
      rethrow; // Use rethrow
    } catch (error) { // ignore: unused_catch_clause
      throw FirebaseException(
        plugin: "firebase_firestore",
        code: "unknown",
        message: "An unexpected error occurred during downvote: $error",
      );
    }
  }

  /// Public method to upload image to Firebase Storage
  Future<String> uploadImage(XFile image) async {
    final url = await _uploadImage(image);
    if (url == null) {
      throw Exception('Image upload returned null URL');
    }
    return url;
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      print('[FirebaseService] _uploadImage: Reading image bytes...');
      final bytes = await image.readAsBytes();
      print('[FirebaseService] _uploadImage: Image size: ${bytes.length} bytes');

      final fileName = 'trees/${DateTime.now().toIso8601String()}_${image.name}';
      final ref = _storage.ref().child(fileName);
      print('[FirebaseService] _uploadImage: Storage ref created: $fileName');

      final metadata = SettableMetadata(contentType: image.mimeType);
      print('[FirebaseService] _uploadImage: Starting upload with contentType: ${image.mimeType}');

      final uploadTask = await ref.putData(bytes, metadata);
      print('[FirebaseService] _uploadImage: Upload complete, getting download URL...');

      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('[FirebaseService] _uploadImage: Download URL obtained: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      print('[FirebaseService] ERROR: _uploadImage failed: $e');
      print('[FirebaseService] Stack trace: $stackTrace');
      rethrow; // Re-throw instead of returning null
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<XFile?> pickImage() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      return await _imagePicker.pickImage(source: ImageSource.camera);
    } else {
      return null;
    }
  }
}

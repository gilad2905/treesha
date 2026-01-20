import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Comprehensive diagnostic to understand Firebase SDK behavior
class FirestoreDiagnostic {
  static Future<void> runFullDiagnostic() async {
    print('[Diagnostic] =====================================');
    print('[Diagnostic] FIRESTORE SDK DIAGNOSTIC');
    print('[Diagnostic] =====================================');

    // 1. Check Firebase initialization
    await _checkFirebaseInit();

    // 2. Check Firestore settings
    await _checkFirestoreSettings();

    // 3. Test simple read operation
    await _testSimpleRead();

    // 4. Test simple write operation
    await _testSimpleWrite();

    // 5. Test write with explicit timeout
    await _testWriteWithTimeout();

    // 6. Test batch write
    await _testBatchWrite();

    print('[Diagnostic] =====================================');
    print('[Diagnostic] DIAGNOSTIC COMPLETE');
    print('[Diagnostic] =====================================');
  }

  static Future<void> _checkFirebaseInit() async {
    print('[Diagnostic] --- Step 1: Firebase Initialization ---');
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;
      print('[Diagnostic] ✅ Firebase Auth initialized');
      print('[Diagnostic] User: ${user?.uid ?? "not logged in"}');
      print('[Diagnostic] User email: ${user?.email ?? "none"}');
    } catch (e) {
      print('[Diagnostic] ❌ Firebase Auth error: $e');
    }
  }

  static Future<void> _checkFirestoreSettings() async {
    print('[Diagnostic] --- Step 2: Firestore Settings ---');
    try {
      final firestore = FirebaseFirestore.instance;
      final settings = firestore.settings;

      print('[Diagnostic] Current settings:');
      print(
        '[Diagnostic]   - persistenceEnabled: ${settings.persistenceEnabled}',
      );
      print('[Diagnostic]   - sslEnabled: ${settings.sslEnabled}');
      print('[Diagnostic]   - cacheSizeBytes: ${settings.cacheSizeBytes}');
      print('[Diagnostic]   - host: ${settings.host}');
      print(
        '[Diagnostic]   - webExperimentalForceLongPolling: ${settings.webExperimentalForceLongPolling}',
      );
      print(
        '[Diagnostic]   - webExperimentalAutoDetectLongPolling: ${settings.webExperimentalAutoDetectLongPolling}',
      );

      // Try to apply new settings
      print('[Diagnostic] Attempting to apply new settings...');
      firestore.settings = const Settings(
        persistenceEnabled: false,
        webExperimentalForceLongPolling: true,
      );

      // Check if they applied
      await Future.delayed(const Duration(milliseconds: 100));
      final newSettings = firestore.settings;
      print('[Diagnostic] After applying:');
      print(
        '[Diagnostic]   - webExperimentalForceLongPolling: ${newSettings.webExperimentalForceLongPolling}',
      );

      if (newSettings.webExperimentalForceLongPolling == true) {
        print('[Diagnostic] ✅ Settings applied successfully');
      } else {
        print('[Diagnostic] ⚠️  Settings NOT applied (this is the problem!)');
      }
    } catch (e) {
      print('[Diagnostic] ❌ Settings error: $e');
    }
  }

  static Future<void> _testSimpleRead() async {
    print('[Diagnostic] --- Step 3: Simple Read Test ---');
    try {
      print('[Diagnostic] Reading from "trees" collection...');
      final start = DateTime.now();

      final snapshot = await FirebaseFirestore.instance
          .collection('trees')
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Read timed out after 5 seconds');
            },
          );

      final duration = DateTime.now().difference(start);
      print('[Diagnostic] ✅ Read succeeded in ${duration.inMilliseconds}ms');
      print('[Diagnostic] Found ${snapshot.docs.length} documents');
    } catch (e) {
      print('[Diagnostic] ❌ Read failed: $e');
    }
  }

  static Future<void> _testSimpleWrite() async {
    print('[Diagnostic] --- Step 4: Simple Write Test ---');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('[Diagnostic] ⚠️  User not logged in, skipping write test');
      return;
    }

    try {
      print('[Diagnostic] Writing test document to "trees" collection...');
      final start = DateTime.now();
      final testDocId =
          'diagnostic_test_${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance
          .collection('trees')
          .doc(testDocId)
          .set({
            'test': true,
            'userId': user.uid,
            'timestamp': FieldValue.serverTimestamp(),
            'diagnostic': true,
          })
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw Exception('Write timed out after 5 seconds');
            },
          );

      final duration = DateTime.now().difference(start);
      print('[Diagnostic] ✅ Write succeeded in ${duration.inMilliseconds}ms');

      // Clean up
      print('[Diagnostic] Cleaning up test document...');
      await FirebaseFirestore.instance
          .collection('trees')
          .doc(testDocId)
          .delete();
      print('[Diagnostic] ✅ Test document deleted');
    } catch (e, stack) {
      print('[Diagnostic] ❌ Write failed: $e');
      print('[Diagnostic] Stack: $stack');
    }
  }

  static Future<void> _testWriteWithTimeout() async {
    print('[Diagnostic] --- Step 5: Write with Extended Timeout ---');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('[Diagnostic] ⚠️  User not logged in, skipping');
      return;
    }

    try {
      print('[Diagnostic] Writing with 30s timeout...');
      final start = DateTime.now();
      final testDocId =
          'diagnostic_timeout_${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance
          .collection('trees')
          .doc(testDocId)
          .set({
            'test': true,
            'userId': user.uid,
            'timestamp': FieldValue.serverTimestamp(),
          })
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Write timed out after 30 seconds');
            },
          );

      final duration = DateTime.now().difference(start);
      print('[Diagnostic] ✅ Write succeeded in ${duration.inMilliseconds}ms');

      // Clean up
      await FirebaseFirestore.instance
          .collection('trees')
          .doc(testDocId)
          .delete();
    } catch (e) {
      print('[Diagnostic] ❌ Write with extended timeout failed: $e');
    }
  }

  static Future<void> _testBatchWrite() async {
    print('[Diagnostic] --- Step 6: Batch Write Test ---');

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('[Diagnostic] ⚠️  User not logged in, skipping');
      return;
    }

    try {
      print('[Diagnostic] Creating batch write...');
      final start = DateTime.now();
      final batch = FirebaseFirestore.instance.batch();
      final testDocId =
          'diagnostic_batch_${DateTime.now().millisecondsSinceEpoch}';

      final docRef = FirebaseFirestore.instance
          .collection('trees')
          .doc(testDocId);
      batch.set(docRef, {
        'test': true,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'batchTest': true,
      });

      await batch.commit().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('Batch commit timed out after 5 seconds');
        },
      );

      final duration = DateTime.now().difference(start);
      print(
        '[Diagnostic] ✅ Batch write succeeded in ${duration.inMilliseconds}ms',
      );

      // Clean up
      await docRef.delete();
    } catch (e) {
      print('[Diagnostic] ❌ Batch write failed: $e');
    }
  }
}

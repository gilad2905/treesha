import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Centralized Firestore configuration
/// This MUST be called before any Firestore operations
class FirestoreConfig {
  static bool _isConfigured = false;
  static Settings? _appliedSettings;

  /// Configure Firestore with optimal settings for web
  static Future<void> configure() async {
    if (_isConfigured) {
      print('[FirestoreConfig] Already configured, skipping');
      return;
    }

    print('[FirestoreConfig] Starting configuration...');
    print('[FirestoreConfig] NOTE: Using database "treesha" (not default)');

    // Verify Firebase is initialized
    try {
      final app = Firebase.app();
      print('[FirestoreConfig] Firebase app: ${app.name}');
      print('[FirestoreConfig] Project: ${app.options.projectId}');
    } catch (e) {
      throw Exception('Firebase not initialized! Call Firebase.initializeApp() first');
    }

    // Note: The Flutter SDK doesn't support custom database names easily
    // We're using the REST API which explicitly targets the "treesha" database
    print('[FirestoreConfig] Using database: treesha (via REST API)');

    // Apply Firestore settings
    try {
      final settings = const Settings(
        persistenceEnabled: false,
        webExperimentalForceLongPolling: true,
      );

      print('[FirestoreConfig] Applying settings...');
      FirebaseFirestore.instance.settings = settings;

      // Verify settings were applied
      await Future.delayed(const Duration(milliseconds: 100));
      final applied = FirebaseFirestore.instance.settings;
      _appliedSettings = applied;

      print('[FirestoreConfig] Settings applied:');
      print('[FirestoreConfig]   - persistenceEnabled: ${applied.persistenceEnabled}');
      print('[FirestoreConfig]   - webExperimentalForceLongPolling: ${applied.webExperimentalForceLongPolling}');

      _isConfigured = true;
      print('[FirestoreConfig] ✅ Configuration complete');
    } catch (e, stack) {
      print('[FirestoreConfig] ❌ Configuration failed: $e');
      print('[FirestoreConfig] Stack: $stack');
      throw Exception('Failed to configure Firestore: $e');
    }
  }

  /// Check if Firestore is properly configured
  static bool get isConfigured => _isConfigured;

  /// Get applied settings
  static Settings? get appliedSettings => _appliedSettings;

  /// Verify Firestore connectivity
  static Future<bool> testConnection() async {
    if (!_isConfigured) {
      throw Exception('Firestore not configured! Call configure() first');
    }

    print('[FirestoreConfig] Testing Firestore connectivity...');
    try {
      // Try to read from a collection (doesn't need to exist)
      final result = await FirebaseFirestore.instance
          .collection('_connection_test')
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Connection test timed out'),
          );

      print('[FirestoreConfig] ✅ Connection test passed (${result.docs.length} docs)');
      return true;
    } catch (e) {
      print('[FirestoreConfig] ❌ Connection test failed: $e');
      return false;
    }
  }

  /// Reset configuration (for testing)
  static void reset() {
    _isConfigured = false;
    _appliedSettings = null;
  }
}

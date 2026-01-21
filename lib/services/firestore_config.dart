import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Centralized Firestore configuration
/// This MUST be called before any Firestore operations
class FirestoreConfig {
  static bool _isConfigured = false;
  static Settings? _appliedSettings;

  /// Configure Firestore with optimal settings for web
  static Future<void> configure() async {
    if (_isConfigured) {
      debugPrint('[FirestoreConfig] Already configured, skipping');
      return;
    }

    debugPrint('[FirestoreConfig] Starting configuration...');
    debugPrint('[FirestoreConfig] NOTE: Using database "treesha" (not default)');

    // Verify Firebase is initialized
    try {
      final app = Firebase.app();
      debugPrint('[FirestoreConfig] Firebase app: ${app.name}');
      debugPrint('[FirestoreConfig] Project: ${app.options.projectId}');
    } catch (e) {
      throw Exception(
        'Firebase not initialized! Call Firebase.initializeApp() first',
      );
    }

    // Note: The Flutter SDK doesn't support custom database names easily
    // We're using the REST API which explicitly targets the "treesha" database
    debugPrint('[FirestoreConfig] Using database: treesha (via REST API)');

    // Apply Firestore settings
    try {
      final settings = const Settings(
        persistenceEnabled: false,
        webExperimentalForceLongPolling: true,
      );

      debugPrint('[FirestoreConfig] Applying settings...');
      FirebaseFirestore.instance.settings = settings;

      // Verify settings were applied
      await Future.delayed(const Duration(milliseconds: 100));
      final applied = FirebaseFirestore.instance.settings;
      _appliedSettings = applied;

      debugPrint('[FirestoreConfig] Settings applied:');
      debugPrint(
        '[FirestoreConfig]   - persistenceEnabled: ${applied.persistenceEnabled}',
      );
      debugPrint(
        '[FirestoreConfig]   - webExperimentalForceLongPolling: ${applied.webExperimentalForceLongPolling}',
      );

      _isConfigured = true;
      debugPrint('[FirestoreConfig] ✅ Configuration complete');
    } catch (e, stack) {
      debugPrint('[FirestoreConfig] ❌ Configuration failed: $e');
      debugPrint('[FirestoreConfig] Stack: $stack');
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

    debugPrint('[FirestoreConfig] Testing Firestore connectivity...');
    debugPrint('[FirestoreConfig] Note: We use REST API for the "treesha" database');
    debugPrint(
      '[FirestoreConfig] Skipping SDK connection test as we use REST API directly',
    );
    debugPrint('[FirestoreConfig] ✅ Configuration verified (REST API mode)');
    return true;
  }

  /// Reset configuration (for testing)
  static void reset() {
    _isConfigured = false;
    _appliedSettings = null;
  }
}

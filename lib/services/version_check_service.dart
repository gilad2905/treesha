import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Service to check if app version meets minimum requirements
class VersionCheckService {
  // Use the named "treesha" database
  FirebaseFirestore get _firestore =>
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'treesha');

  /// Check if current app version meets minimum requirements
  /// Returns null if version is OK, or a map with update info if update needed
  Future<Map<String, dynamic>?> checkVersion() async {
    try {
      debugPrint('[VersionCheck] Checking app version...');

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      debugPrint('[VersionCheck] Current version: $currentVersion ($currentBuildNumber)');

      // Get minimum required version from Firestore
      final configDoc = await _firestore
          .collection('app_config')
          .doc('version')
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Version check timed out');
            },
          );

      if (!configDoc.exists) {
        debugPrint('[VersionCheck] No version config found - allowing access');
        return null; // No config = allow access
      }

      final data = configDoc.data()!;

      // Get platform-specific minimum version
      final platform = defaultTargetPlatform == TargetPlatform.android
          ? 'android'
          : defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'web';

      final minVersion = data['minVersion_$platform'] as String?;
      final minBuildNumber = data['minBuildNumber_$platform'] as int?;
      final updateMessage = data['updateMessage'] as String?;
      final forceUpdate = data['forceUpdate'] as bool? ?? true;

      if (minVersion == null && minBuildNumber == null) {
        debugPrint('[VersionCheck] No minimum version set for $platform');
        return null; // No minimum version set
      }

      debugPrint('[VersionCheck] Minimum version: $minVersion ($minBuildNumber)');

      // Compare versions
      bool needsUpdate = false;

      if (minBuildNumber != null && currentBuildNumber < minBuildNumber) {
        needsUpdate = true;
        debugPrint('[VersionCheck] Build number too old: $currentBuildNumber < $minBuildNumber');
      } else if (minVersion != null) {
        final comparison = _compareVersions(currentVersion, minVersion);
        if (comparison < 0) {
          needsUpdate = true;
          debugPrint('[VersionCheck] Version too old: $currentVersion < $minVersion');
        }
      }

      if (needsUpdate) {
        debugPrint('[VersionCheck] ⚠️  Update required!');
        return {
          'needsUpdate': true,
          'forceUpdate': forceUpdate,
          'currentVersion': currentVersion,
          'minVersion': minVersion ?? 'Unknown',
          'message': updateMessage ??
              'A new version of Treesha is available. Please update to continue.',
        };
      }

      debugPrint('[VersionCheck] ✅ Version OK');
      return null;
    } catch (e, stack) {
      debugPrint('[VersionCheck] ❌ Error checking version: $e');
      debugPrint('[VersionCheck] Stack: $stack');
      // On error, allow access (fail-open to prevent lockout)
      return null;
    }
  }

  /// Compare two semantic version strings
  /// Returns: -1 if v1 < v2, 0 if equal, 1 if v1 > v2
  int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad to same length
    while (parts1.length < 3) {
      parts1.add(0);
    }
    while (parts2.length < 3) {
      parts2.add(0);
    }

    // Compare major.minor.patch
    for (int i = 0; i < 3; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }

    return 0; // Equal
  }
}

# New Tree Addition Implementation

## Overview

Complete rewrite of the tree addition logic with proper configuration management, error handling, and unit tests.

## Architecture

### 1. FirestoreConfig (`lib/services/firestore_config.dart`)

**Purpose**: Centralized Firestore configuration management

**Key Features**:
- Ensures settings are applied before any Firestore operations
- Verifies configuration was successful
- Tests connectivity
- Tracks configuration state

**Usage**:
```dart
// In main.dart
await FirestoreConfig.configure();

// Check if configured
if (FirestoreConfig.isConfigured) {
  // Safe to use Firestore
}

// Test connectivity
bool connected = await FirestoreConfig.testConnection();
```

### 2. TreeRepository (`lib/services/tree_repository.dart`)

**Purpose**: Clean separation of data access logic

**Key Features**:
- Simple, focused API
- Proper error handling with custom exceptions
- Validation of all inputs
- Detailed logging
- Timeout handling (15 seconds)

**Usage**:
```dart
final repository = TreeRepository();

try {
  final docId = await repository.addTree(
    userId: 'user123',
    name: 'Apple Tree',
    fruitType: 'Apple',
    position: position,
    imageUrl: 'https://...',
  );
  print('Tree added: $docId');
} on TreeRepositoryException catch (e) {
  print('Failed: ${e.code} - ${e.message}');
}
```

### 3. Updated main.dart

**Initialization Flow**:
```
1. Firebase.initializeApp()
2. FirestoreConfig.configure()  ← Settings applied here
3. FirestoreConfig.testConnection()  ← Verify it works
4. runApp()
5. TreeRepository created in initState()  ← Safe to use
```

## Configuration Verification

### Startup Logs

You should see:
```
[Main] ========================================
[Main] Treesha App Starting
[Main] ========================================
[Main] Step 1: Initializing Firebase...
[Main] ✅ Firebase initialized
[Main]    Project: applied-primacy-294221
[Main] Step 2: Configuring Firestore...
[FirestoreConfig] Starting configuration...
[FirestoreConfig] Firebase app: [DEFAULT]
[FirestoreConfig] Project: applied-primacy-294221
[FirestoreConfig] Applying settings...
[FirestoreConfig] Settings applied:
[FirestoreConfig]   - persistenceEnabled: false
[FirestoreConfig]   - webExperimentalForceLongPolling: true ← MUST BE true!
[FirestoreConfig] ✅ Configuration complete
[Main] ✅ Firestore configured
[Main] Step 3: Testing Firestore connectivity...
[FirestoreConfig] Testing Firestore connectivity...
[FirestoreConfig] ✅ Connection test passed
[Main] ✅ Firestore connectivity verified
[Main] ========================================
[Main] Initialization Complete
[Main] ========================================
```

**⚠️ CRITICAL**: If `webExperimentalForceLongPolling` is `null`, settings didn't apply!

### Adding a Tree

Expected logs:
```
[Main] ========================================
[Main] ADD TREE REQUEST
[Main] ========================================
[Main] Adding tree to repository...
[TreeRepository] Adding tree...
[TreeRepository]   User: jnlgswGpHYXSjlCn5UUd6WoYsBn1
[TreeRepository]   Name: Apple Tree
[TreeRepository]   Type: Apple
[TreeRepository]   Position: 32.0, 34.0
[TreeRepository] Document data prepared: userId, name, fruitType, position, imageUrl, createdAt, upvotes, downvotes
[TreeRepository] ✅ Tree added successfully! ID: abc123xyz
[Main] ✅ Tree added successfully! ID: abc123xyz
[Main] ========================================
[Main] ADD TREE COMPLETE
[Main] ========================================
```

## Error Handling

### TreeRepositoryException

Custom exception with error codes:

```dart
try {
  await repository.addTree(...);
} on TreeRepositoryException catch (e) {
  switch (e.code) {
    case 'permission-denied':
      // Security rules blocking
      break;
    case 'timeout':
      // Operation took too long
      break;
    case 'unavailable':
      // Network issues
      break;
    default:
      // Unknown error
      break;
  }
}
```

### Common Error Codes

- `permission-denied`: Firestore security rules blocking write
- `timeout`: Operation exceeded 15 seconds
- `unavailable`: Cannot reach Firebase servers
- `unauthenticated`: User not logged in
- `unknown`: Unexpected error

## Unit Tests

Run tests:
```bash
flutter test test/services/tree_repository_test.dart
```

Tests cover:
- ✅ Validation of all required fields
- ✅ Empty string rejection
- ✅ Exception types and messages
- ✅ Configuration requirements

## Dependencies

Add to `pubspec.yaml` (for tests):
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  fake_cloud_firestore: ^3.0.3
```

Then run:
```bash
flutter pub get
```

## Troubleshooting

### Settings Not Applying

**Symptom**: `webExperimentalForceLongPolling: null` in logs

**Causes**:
1. Firestore instance accessed before settings applied
2. Flutter web version doesn't support the setting
3. Settings object created incorrectly

**Solution**:
- Ensure no code accesses `FirebaseFirestore.instance` before `FirestoreConfig.configure()`
- Check that all service constructors use `late` initialization
- Verify services are created in `initState()`, not as class fields

### Connection Test Fails

**Symptom**: `Connection test failed` or times out

**Causes**:
1. Network issues
2. Firestore database doesn't exist
3. localhost not authorized

**Solution**:
1. Check internet connection
2. Verify Firestore database exists in Firebase Console
3. Add `localhost` to Firebase Authentication > Settings > Authorized domains

### Writes Time Out

**Symptom**: `TreeRepositoryException(timeout)`

**Causes**:
1. WebSocket connections blocked
2. Long polling not enabled
3. Network/firewall blocking Firebase

**Solution**:
1. Verify `webExperimentalForceLongPolling: true` in startup logs
2. Try different network (disable VPN)
3. Clear browser cache/storage
4. Try incognito mode

## Migration from Old Code

### Old Code:
```dart
final success = await _firebaseService.addTree(
  userId: userId,
  name: name,
  fruitType: fruitType,
  position: position,
  image: image,
);
```

### New Code:
```dart
final docId = await _treeRepository.addTree(
  userId: userId,
  name: name,
  fruitType: fruitType,
  position: position,
  imageUrl: imageUrl,
);
```

**Key Differences**:
- Returns document ID (String) instead of boolean
- Takes `imageUrl` (String?) instead of `image` (XFile?)
- Image upload handled separately
- Throws exceptions instead of returning false

## Next Steps

1. ✅ Run the app and verify startup logs
2. ✅ Check that `webExperimentalForceLongPolling: true`
3. ✅ Test connection passes
4. ✅ Try adding a tree
5. ✅ Verify tree appears in Firebase Console
6. ⬜ Add image upload functionality
7. ⬜ Add more unit tests
8. ⬜ Add integration tests

## Benefits

✅ **Clean Architecture**: Separation of concerns
✅ **Testable**: Dependency injection, mockable
✅ **Reliable**: Proper error handling
✅ **Debuggable**: Comprehensive logging
✅ **Maintainable**: Clear, focused code
✅ **Type-Safe**: Strong typing, no dynamic types

# Quick Start - New Tree Implementation

## Step 1: Get Dependencies

```bash
cd /Users/gilad/projects/treesha_base/treesha
flutter pub get
```

## Step 2: Run Tests (Optional but Recommended)

```bash
flutter test test/services/tree_repository_test.dart
```

You should see:
```
✓ TreeRepository addTree throws if Firestore not configured
✓ TreeRepository addTree throws ArgumentError if userId is empty
✓ TreeRepository addTree throws ArgumentError if name is empty
✓ TreeRepository addTree throws ArgumentError if fruitType is empty
✓ TreeRepositoryException toString returns formatted message
✓ TimeoutException toString returns formatted message
```

## Step 3: Run the App

```bash
flutter run -d chrome --web-hostname localhost --web-port 53491
```

## Step 4: Watch Startup Logs

**CRITICAL**: Look for these logs on startup:

```
[Main] ========================================
[Main] Treesha App Starting
[Main] ========================================
[Main] Step 1: Initializing Firebase...
[Main] ✅ Firebase initialized
[Main] Step 2: Configuring Firestore...
[FirestoreConfig] Settings applied:
[FirestoreConfig]   - persistenceEnabled: false
[FirestoreConfig]   - webExperimentalForceLongPolling: true  ← MUST BE true!
[Main] Step 3: Testing Firestore connectivity...
[Main] ✅ Firestore connectivity verified
```

### ✅ Success Indicators:
- `webExperimentalForceLongPolling: true`
- `Firestore connectivity verified`

### ❌ Failure Indicators:
- `webExperimentalForceLongPolling: null`
- `Connection test failed`
- `FATAL ERROR during initialization`

## Step 5: Try Adding a Tree

1. Sign in with Google
2. Click the green "+" button
3. Fill out the form:
   - Tree Name: "Test Tree"
   - Fruit Type: Pick any fruit (e.g., "Apple")
4. Click "Add"

## Step 6: Verify Success

### In Console:
```
[Main] ========================================
[Main] ADD TREE REQUEST
[Main] ========================================
[Main] Adding tree to repository...
[TreeRepository] Adding tree...
[TreeRepository] ✅ Tree added successfully! ID: abc123xyz
[Main] ✅ Tree added successfully! ID: abc123xyz
[Main] ========================================
[Main] ADD TREE COMPLETE
[Main] ========================================
```

### In App:
- Green snackbar: "🌳 Tree added successfully!"
- Tree marker appears on map

### In Firebase Console:
1. Go to: https://console.firebase.google.com/project/applied-primacy-294221/firestore
2. Click on "trees" collection
3. You should see your new tree document!

## Troubleshooting

### Issue: `webExperimentalForceLongPolling: null`

**Problem**: Settings not applying

**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome --web-hostname localhost --web-port 53491
```

### Issue: "Firestore not configured"

**Problem**: TreeRepository used before configuration

**Solution**: This shouldn't happen with new code. If it does:
1. Check that `FirestoreConfig.configure()` is called in `main()`
2. Check that TreeRepository is created in `initState()`, not as a class field

### Issue: "Connection test failed"

**Problem**: Can't reach Firestore

**Solutions**:
1. Check internet connection
2. Verify Firestore database exists in Firebase Console
3. Add `localhost` to authorized domains (should already be done)
4. Try different network (disable VPN)
5. Clear browser cache: DevTools → Application → Clear site data

### Issue: "TreeRepositoryException(timeout)"

**Problem**: Write operation taking too long

**Solutions**:
1. Verify `webExperimentalForceLongPolling: true` in logs
2. Clear browser IndexedDB: DevTools → Application → IndexedDB → Delete
3. Try incognito mode
4. Try different browser

### Issue: Still having problems?

Check browser's JavaScript console:
1. Open DevTools (F12)
2. Go to Console tab (not Network)
3. Look for RED errors
4. Share those errors

## What Changed

### Before (Old Code):
- Settings applied inconsistently
- No validation
- No configuration verification
- Complex service with mixed responsibilities
- Hard to test
- Unclear error messages

### After (New Code):
- ✅ Settings guaranteed to apply before use
- ✅ All inputs validated
- ✅ Configuration verified on startup
- ✅ Clean separation: Config, Repository, UI
- ✅ Unit tested
- ✅ Clear error codes and messages

## Key Files

- `lib/services/firestore_config.dart` - Configuration management
- `lib/services/tree_repository.dart` - Data access layer
- `lib/main.dart` - Updated initialization and UI
- `test/services/tree_repository_test.dart` - Unit tests
- `NEW_TREE_IMPLEMENTATION.md` - Detailed documentation

## Success Criteria

✅ App starts without errors
✅ `webExperimentalForceLongPolling: true` in logs
✅ Connection test passes
✅ Can add a tree (< 5 seconds)
✅ Tree appears in Firebase Console
✅ Green success message shows

If ALL of these work, the implementation is successful!

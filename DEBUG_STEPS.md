# Debug Steps - Find the Root Cause

## What We Know:
- ✅ Firebase is initialized (network requests are happening)
- ✅ Firestore database exists
- ✅ Security rules allow writes until 2026-02-18
- ❌ The `.add()` operation hangs forever with NO error

## This suggests one of these issues:

### 1. **JavaScript Error in Browser Console**
   - The Flutter/Firebase SDK might be hitting a JS error
   - Go to DevTools → **Console** tab (not Network)
   - Look for RED error messages
   - Especially look for errors mentioning:
     - "Firestore"
     - "Firebase"
     - "IndexedDB"
     - "Promise"

### 2. **Firestore Using Wrong Database**
   - You might have multiple databases
   - Go to: https://console.firebase.google.com/project/applied-primacy-294221/firestore/databases
   - Check if there are multiple databases listed
   - Is the default one "(default)" or named something else?

### 3. **Browser IndexedDB Issues**
   - Firestore uses IndexedDB for caching
   - Even with persistence disabled, it might still try to access it
   - Try: DevTools → Application tab → Storage → Clear site data
   - Or test in **Incognito/Private window**

### 4. **CORS or Network Policy**
   - Some networks/firewalls block WebSocket connections
   - The hanging might be a failed WebSocket upgrade
   - In Network tab, filter by "WS" (WebSocket)
   - See if any WebSocket connections are failing

## Immediate Action Items:

### A. Check Console Tab (Most Important!)
1. Open DevTools
2. Click **Console** tab (not Network!)
3. Clear console
4. Try adding a tree
5. **Screenshot ANY red errors**

### B. Try Incognito Mode
1. Open app in Incognito/Private window
2. Sign in again
3. Try adding a tree
4. Does it work? If yes → browser cache/storage issue

### C. Check for Multiple Databases
1. Go to Firebase Console → Firestore
2. Click on the database dropdown (top of page)
3. Are there multiple databases?
4. Which one is marked as "(default)"?

### D. Check Application Storage
1. DevTools → Application tab
2. Look at:
   - IndexedDB → firebaseLocalStorageDb
   - Local Storage → Your domain
3. Try clearing all storage and reload

## Expected Console Output:

When you try to add a tree now, you should see:

```
[FirebaseService] ======================================
[FirebaseService] DEBUGGING FIRESTORE ADD OPERATION
[FirebaseService] ======================================
[FirebaseService] Step 1: Checking Firestore instance...
[FirebaseService]   Instance: FirebaseFirestore
[FirebaseService]   App: [DEFAULT]
[FirebaseService]   Settings: {...}
[FirebaseService] Step 2: Getting collection reference...
[FirebaseService]   Collection path: trees
[FirebaseService]   Collection ID: trees
[FirebaseService] Step 3: Starting add operation...
[FirebaseService]   Payload size: XXX chars
[FirebaseService]   Calling add()...
[FirebaseService] Step 4: Awaiting add() response...
```

If you see "Step 4" but nothing after, the operation is hanging.

## Nuclear Option - Simplify Everything:

If nothing above works, let's try the SIMPLEST possible write:

Instead of your complex payload, try adding just:
```dart
await _firestore.collection('trees').add({'test': 'hello'});
```

This will tell us if it's a problem with:
- The payload structure
- The GeoPoint
- The Timestamp
- Or Firestore itself

---

## What to Share:

Please share:
1. ✅ Full console output (including the Step 1-4 logs)
2. ✅ **Browser Console tab** - any RED errors?
3. ✅ Result of trying Incognito mode
4. ✅ Screenshot of Firebase Console showing database name

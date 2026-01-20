# Troubleshooting: Firestore Timeout Issues

## Current Status
Your Firebase rules expire on **2026-02-18**, so they should be allowing writes. The timeout suggests a different issue.

## Changes Made to Help Debug

### 1. **Disabled Offline Persistence** (`main.dart:44-51`)
   - Web platforms sometimes have issues with offline persistence
   - This forces all operations to go directly to the server
   - Look for log: `[Main] Firestore persistence disabled for better web compatibility`

### 2. **Using Server Timestamps** (`firebase_service.dart:80`)
   - Changed from `Timestamp.now()` to `FieldValue.serverTimestamp()`
   - Eliminates client-server time sync issues

### 3. **Enhanced Error Logging** (throughout codebase)
   - Detailed diagnostics for every step
   - Specific error codes and suggested fixes

## Diagnostic Steps

### Step 1: Check Browser Console
1. Open browser DevTools (F12 or Cmd+Option+I)
2. Go to **Console** tab
3. Try adding a tree
4. Look for errors that start with `[FirebaseService]`
5. **IMPORTANT**: Also check the **Network** tab:
   - Filter by "firestore" or "googleapis"
   - Look for red/failed requests
   - Check the status code and error message

### Step 2: Verify Firestore Database Exists
1. Go to [Firebase Console](https://console.firebase.google.com/project/applied-primacy-294221/firestore)
2. Click on **Firestore Database** in left sidebar
3. **If you see "Create database"**: You haven't created a Firestore database yet!
   - Click "Create database"
   - Choose a location (us-central1 recommended)
   - Start in **production mode** (we'll update rules after)
4. **If database exists**: Check the "trees" collection to see if any documents are appearing

### Step 3: Check Network Connectivity
The timeout might be a network issue:

```bash
# Test if you can reach Firebase services
curl -I https://firestore.googleapis.com

# Check if your firewall/VPN is blocking Firebase
ping firestore.googleapis.com
```

### Step 4: Verify Authentication
Even though you're signed in, double-check:
1. Look for log: `[Main] Starting tree addition...`
2. It should show your userId: `jnlgswGpHYXSjlCn5UUd6WoYsBn1`
3. If userId is missing or "null", authentication failed

### Step 5: Check Firestore Indexes
Some queries require indexes:
1. Go to Firebase Console > Firestore > Indexes
2. Check if there are any "needs index" errors

## Common Causes & Solutions

### Cause 1: Firestore Database Not Created
**Symptom**: Timeout with no error in browser console Network tab

**Solution**:
```
1. Go to Firebase Console
2. Create Firestore database (if it doesn't exist)
3. Choose location and mode
```

### Cause 2: Network/Firewall Blocking Firebase
**Symptom**: Network tab shows "Failed to load" or "ERR_CONNECTION_REFUSED"

**Solution**:
```
- Disable VPN
- Check corporate firewall settings
- Try a different network
- Check browser extensions blocking requests
```

### Cause 3: Browser Cache Issues
**Symptom**: Worked before, now timing out

**Solution**:
```
1. Hard refresh (Cmd+Shift+R or Ctrl+Shift+R)
2. Clear browser cache
3. Try incognito/private mode
```

### Cause 4: Firebase Service Outage
**Symptom**: Sudden timeout after working fine

**Solution**:
```
- Check Firebase Status: https://status.firebase.google.com
- Check project quotas in Firebase Console
```

### Cause 5: Incorrect Project Configuration
**Symptom**: All Firebase operations timeout

**Solution**:
```
1. Verify project ID in firebase_options.dart matches console: applied-primacy-294221
2. Check API keys are not restricted
3. Verify domain is whitelisted in Firebase Console > Authentication > Settings
```

## What to Look For in Logs

### SUCCESS Pattern:
```
[FirebaseService] Starting addTree - userId: jnlgswGpHYXSjlCn5UUd6WoYsBn1...
[FirebaseService] Payload prepared, adding to Firestore: {...}
[FirebaseService] Firestore add operation started, waiting for response...
[FirebaseService] Document added with ID: abc123xyz
[FirebaseService] SUCCESS: Tree added to Firestore in 2s
```

### TIMEOUT Pattern (what you're seeing):
```
[FirebaseService] Starting addTree - userId: jnlgswGpHYXSjlCn5UUd6WoYsBn1...
[FirebaseService] Payload prepared, adding to Firestore: {...}
[FirebaseService] Firestore add operation started, waiting for response...
[... 30 seconds of silence ...]
[FirebaseService] ERROR: Firestore add operation TIMED OUT after 30 seconds
```

### PERMISSION DENIED Pattern (different issue):
```
[FirebaseService] Starting addTree - userId: jnlgswGpHYXSjlCn5UUd6WoYsBn1...
[FirebaseService] ERROR: FirebaseException during add
[FirebaseService] Code: permission-denied
```

## Next Steps

1. **Run the app again** and note the logs
2. **Check Browser DevTools Network tab** for failed requests
3. **Verify Firestore database exists** in Firebase Console
4. **Share the results**:
   - Full console logs
   - Network tab screenshot
   - Confirmation that database exists

## If Still Stuck

Try this minimal test to isolate the issue:

1. Go to Firebase Console > Firestore > Data
2. Click "+ Start collection"
3. Collection ID: `test`
4. Add a document manually
5. If manual add works, issue is in the app
6. If manual add fails, issue is with Firebase setup

## Additional Debugging

Enable verbose Firebase logging by adding to your `index.html` (if web):
```html
<script>
  firebase.firestore.setLogLevel('debug');
</script>
```

Or check the browser console for Firebase debug logs.

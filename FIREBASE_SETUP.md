# Firebase Setup Instructions

## Problem: Timeout when adding trees

The timeout you're experiencing is caused by **Firestore Security Rules** blocking write operations.

### Root Cause
Your current Firestore security rules are likely set to:
- **Test mode** (which expired after 30 days), OR
- **Locked mode** (which blocks all writes)

### Solution: Deploy Updated Security Rules

#### Option 1: Firebase Console (Easiest)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **applied-primacy-294221**
3. Navigate to: **Firestore Database** → **Rules** tab
4. Replace the existing rules with the contents of `firestore.rules` file
5. Click **Publish**

#### Option 2: Firebase CLI
```bash
# Make sure you're in the project directory
cd /Users/gilad/projects/treesha_base/treesha

# Login to Firebase (if not already logged in)
firebase login

# Initialize Firebase (if not already done)
firebase init firestore

# Deploy the rules
firebase deploy --only firestore:rules
```

### What the New Rules Do

The `firestore.rules` file allows:

✅ **READ**: Anyone can read trees (even unauthenticated users can view the map)
✅ **CREATE**: Only authenticated users can add trees, and they must include their userId
✅ **UPDATE**: Only authenticated users can update (for voting)
✅ **DELETE**: Only the tree creator can delete their own tree

### Security Features
- Users can only create trees with their own `userId` (prevents impersonation)
- All required fields are validated (`userId`, `name`, `fruitType`, `position`, etc.)
- Voting lists (`upvotes`, `downvotes`) must be arrays

### Testing After Deployment
1. Deploy the rules using one of the methods above
2. Wait 30 seconds for rules to propagate
3. Try adding a tree in your app
4. Check the console logs - you should see:
   ```
   [FirebaseService] Document added with ID: <some-id>
   [FirebaseService] SUCCESS: Tree added to Firestore in <X>s
   ```

### Current Security Rules (Likely Issue)
Your current rules probably look like this:
```
// BAD - Blocks all writes
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

Or this (if expired):
```
// BAD - Test mode (expired after 30 days)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2024, 12, 20);
    }
  }
}
```

### Verification
After deploying, you can verify the rules are active:
1. Go to Firebase Console → Firestore → Rules tab
2. You should see the new rules with authentication checks
3. The "Last modified" timestamp should be recent

---

## Additional Notes

### If timeout persists after deploying rules:
1. Check browser console for network errors
2. Verify Firebase project ID matches: `applied-primacy-294221`
3. Try clearing browser cache and reloading
4. Check Firebase Console → Firestore → Data to see if any trees were created

### Common Errors:
- **`permission-denied`**: Rules are still blocking - verify deployment
- **`timeout`**: Network issue or rules not yet propagated
- **`unauthenticated`**: User not signed in (should be caught by the app)

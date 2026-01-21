# Version Control Setup

This app includes a minimum version check feature to handle breaking changes gracefully.

## How It Works

1. On app startup, the app checks Firestore for minimum version requirements
2. If the installed version is below the minimum, a dialog is shown
3. Users can either update immediately or skip (configurable)
4. The dialog can be blocking (force update) or dismissible (soft update)

## Firestore Configuration

### Step 1: Create the version config document

In Firebase Console, go to your "treesha" database and create:

**Collection**: `app_config`
**Document ID**: `version`

**Fields**:
```javascript
{
  // Android minimum version (semantic version)
  "minVersion_android": "1.0.0",

  // Android minimum build number (optional, more reliable)
  "minBuildNumber_android": 1,

  // iOS minimum version (semantic version)
  "minVersion_ios": "1.0.0",

  // iOS minimum build number (optional)
  "minBuildNumber_ios": 1,

  // Web minimum version (optional)
  "minVersion_web": "1.0.0",

  // Whether to force the update (true = blocking, false = dismissible)
  "forceUpdate": true,

  // Custom message to show users
  "updateMessage": "A new version of Treesha is available with important bug fixes. Please update to continue."
}
```

### Step 2: Deploy Firestore Rules

The security rules already include support for `app_config`:

```javascript
// App configuration (version requirements, etc.)
match /app_config/{configId} {
  // Anyone can read config (needed for version checking)
  allow read: if true;

  // Only admins can write config (manage in Firebase Console)
  allow write: if false;
}
```

Deploy the rules:
```bash
firebase deploy --only firestore:rules
```

⚠️ **Note**: Firebase CLI doesn't support deploying rules to named databases ("treesha"). You'll need to copy the rules manually in Firebase Console:
1. Go to Firebase Console → Firestore Database
2. Select the "treesha" database
3. Go to "Rules" tab
4. Paste the rules from `firestore.rules`

## Usage Examples

### Example 1: Force Update for Breaking Change
When you release v2.0.0 with breaking changes:

```javascript
{
  "minVersion_android": "2.0.0",
  "minBuildNumber_android": 10,
  "forceUpdate": true,
  "updateMessage": "This update includes important changes. Please update to continue using Treesha."
}
```

### Example 2: Soft Update for New Features
Encourage users to update but don't force:

```javascript
{
  "minVersion_android": "1.5.0",
  "minBuildNumber_android": 7,
  "forceUpdate": false,
  "updateMessage": "A new version with exciting features is available! Update now to try them out."
}
```

### Example 3: Remove Version Check
To disable version checking, just delete the document or set very low versions:

```javascript
{
  "minVersion_android": "1.0.0",
  "minBuildNumber_android": 1,
  "forceUpdate": false
}
```

## App Version Management

Update version in `pubspec.yaml`:

```yaml
version: 1.0.0+1
#        ^     ^
#        |     |
#        |     +-- Build number (minBuildNumber_android)
#        +-------- Version string (minVersion_android)
```

**Best Practice**: Increment build number (+1) with every release, even if version stays the same.

## Store URLs

Update the store URLs in `lib/main.dart` after publishing:

```dart
// Android Play Store
'https://play.google.com/store/apps/details?id=com.example.treesha'

// iOS App Store
'https://apps.apple.com/app/treesha/id123456789'
```

## Testing

To test the version check feature:

1. **Test Force Update**:
   - Set `minBuildNumber_android` to 999 in Firestore
   - Set `forceUpdate: true`
   - Launch app
   - Should see blocking dialog

2. **Test Soft Update**:
   - Set `minBuildNumber_android` to 999 in Firestore
   - Set `forceUpdate: false`
   - Launch app
   - Should see dismissible dialog

3. **Test No Update Needed**:
   - Set `minBuildNumber_android` to 1 in Firestore
   - Launch app
   - Should proceed normally

## Error Handling

The version check is **fail-open**:
- If Firestore is unreachable → App continues normally
- If document doesn't exist → App continues normally
- If data is malformed → App continues normally

This prevents users from being locked out due to network issues or configuration errors.

## Platform Support

- ✅ Android - Fully supported
- ✅ iOS - Fully supported
- ✅ Web - Supported (but optional)
- ❌ Desktop - Not implemented (version checking disabled)

## Security

- ✅ Version config is read-only for clients
- ✅ Only Firebase Console can modify the config
- ✅ No authentication required to read version info
- ✅ Version comparison happens client-side (no sensitive logic)

## Monitoring

Monitor version adoption in Firebase Analytics:
- Track app version distribution
- Monitor update dialog dismissals
- See how many users are on old versions

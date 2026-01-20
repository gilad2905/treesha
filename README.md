# Treesha 🌳

A Flutter app for tracking fruit trees around the world. View, add, and verify fruit trees with location-based mapping.

## Features

- 🗺️ **Interactive Map**: View fruit trees on Google Maps
- 🌳 **Add Trees**: Document trees with name, fruit type, location, and photos
- 👍👎 **Verification System**: Upvote/downvote trees to verify their existence
- 🔐 **Authentication**: Google Sign-In required for adding/voting
- 📊 **Filter by Score**: Filter trees by verification score
- 📸 **Image Upload**: Upload tree photos to Firebase Storage

## Tech Stack

- **Frontend**: Flutter/Dart
- **Authentication**: Firebase Auth (Google Sign-In)
- **Database**: Cloud Firestore (custom database: "treesha")
- **Storage**: Firebase Storage
- **Maps**: Google Maps Flutter

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase account
- Google Maps API key

### Running the App

```bash
cd ~/projects/treesha_base/treesha
flutter run --web-hostname localhost --web-port 53491
```

## Firebase Configuration

This app uses a **custom Firestore database named "treesha"** (not the default database).

### Security Rules Deployment

⚠️ **Important**: Due to a [known bug in Firebase CLI](https://github.com/firebase/firebase-tools/issues/8809), security rules cannot be automatically deployed to named databases via CLI.

**To deploy security rules:**

1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Firestore Database
4. Select the **"treesha"** database from the dropdown
5. Click the **"Rules"** tab
6. Copy the contents of `firestore.rules` and paste them
7. Click **"Publish"**

The rules file is maintained in `firestore.rules` for version control, but must be manually deployed to the "treesha" database.

## Security

### Is the API Key Safe in the Repo?

**Yes!** Firebase API keys for web apps are designed to be public. Security is enforced by:

- ✅ Firestore Security Rules (authentication required)
- ✅ Firebase Authentication (Google Sign-In)
- ✅ Authorized domains (only your domain + localhost)

See: [Firebase API Keys Best Practices](https://firebase.google.com/docs/projects/api-keys)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

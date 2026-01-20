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

### Unit Tests
```bash
cd /Users/gilad/projects/treesha_base/treesha
flutter pub get
```

## Step 2: Run Tests (Optional but Recommended)

```bash
flutter test test/services/tree_repository_test.dart
```

### Running the App

```bash
cd ~/projects/treesha_base/treesha
flutter run -d chrome --web-hostname localhost --web-port 53491
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


### Future features:

Based on your app concept, here are features that would be valuable:

  High Priority Features

  1. Tree Photos Gallery
    - Multiple photos per tree
    - Photo verification (separate upvotes for photos)
    - Community can add photos to existing trees
  2. Seasonal Information
    - When fruit is ripe (month range)
    - Current season indicator
    - Notifications when trees near you are in season
  3. Tree Status Updates
    - "Still here" / "Removed" reports
    - Last verified date
    - Health status (healthy, diseased, dead)
  4. Search & Filters
    - Search by fruit type
    - Filter by distance
    - Filter by season
    - "Show only verified trees" (score > X)
  5. User Contributions
    - Track trees added per user
    - User reputation score
    - Badges (10 trees added, 100 votes, etc.)

  Medium Priority

  6. Directions
    - "Navigate to this tree" button
    - Opens Google Maps with directions
  7. Tree Details
    - Notes/description field
    - Accessibility info (public/private property)
    - Harvesting tips
  8. Notifications
    - Trees near you are in season
    - Someone added a tree nearby
    - Your tree got verified
  9. Offline Support
    - Cache nearby trees
    - Work offline, sync later
  10. Social Features
    - Follow other users
    - Share trees with friends
    - Comments on trees

  Advanced Features

  11. Gamification
    - Leaderboards
    - Achievements
    - Challenges ("Find 10 different fruit types")
  12. Tree Clusters
    - Group nearby trees (orchards, parks)
    - Show cluster count on map
  13. API/Export
    - Export tree data (CSV, GeoJSON)
    - Public API for researchers
  14. Machine Learning
    - Auto-identify fruit from photo
    - Suggest fruit type based on description

  ---
  My Top 3 Recommendations

  If you want to add features next, I'd suggest:

  1. 🔍 Search by fruit type - Very useful, easy to implement
  2. 📅 Seasonal info - Core to the use case (when to harvest)
  3. 📸 Multiple photos - Builds trust, engages community


can we translate this app to hebrew?
  (don't just replace english to hebrew, have it ready to be multilaguage, according to user selection)
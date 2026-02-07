// Script to initialize version config in Firestore
// Run with: node scripts/init_version_config.js

const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('../path/to/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://applied-primacy-294221.firebaseio.com"
});

// Get Firestore instance for "treez" database
const db = admin.firestore();
db.settings({ databaseId: 'treez' });

async function initVersionConfig() {
  try {
    const versionConfig = {
      minVersion_android: "1.0.0",
      minBuildNumber_android: 1,
      minVersion_ios: "1.0.0",
      minBuildNumber_ios: 1,
      forceUpdate: false,
      updateMessage: "A new version of Treez is available. Please update to get the latest features and improvements."
    };

    await db.collection('app_config').doc('version').set(versionConfig);

    console.log('✅ Version config initialized successfully!');
    console.log('Config:', versionConfig);

    process.exit(0);
  } catch (error) {
    console.error('❌ Error initializing version config:', error);
    process.exit(1);
  }
}

initVersionConfig();

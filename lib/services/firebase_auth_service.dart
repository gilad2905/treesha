import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: kIsWeb
        ? '859938357630-9adn9ql6cn1toefs0ilqdm7ell3d3l1s.apps.googleusercontent.com'
        : null,
  );

  Stream<User?> get user => _firebaseAuth.authStateChanges();

  /// Ensure user exists in Firestore users collection with default role
  Future<void> ensureUserInFirestore(User user) async {
    // Use the specific 'treesha' database
    final firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(),
      databaseId: 'treesha',
    );
    final userDoc = firestore.collection('users').doc(user.uid);
    final doc = await userDoc.get();
    if (!doc.exists) {
      await userDoc.set({
        'roles': ['user'],
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await ensureUserInFirestore(user);
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Fetch user roles from Firestore
  Future<List<String>> getUserRoles(String uid) async {
    try {
      final firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'treesha',
      );
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['roles'] is List) {
          return List<String>.from(data['roles']);
        }
      }
    } catch (e) {
      debugPrint('[FirebaseAuthService] Error fetching roles: $e');
    }
    return ['user']; // Default role
  }
}

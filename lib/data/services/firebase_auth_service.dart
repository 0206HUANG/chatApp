import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart' as app_user;

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn =
      kIsWeb
          ? GoogleSignIn(
            clientId: '86982231047-iosapp.apps.googleusercontent.com',
          )
          : GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the Google sign-in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create new credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Convert Firebase User to app User model
  app_user.User? convertToAppUser(User? firebaseUser) {
    if (firebaseUser == null) return null;

    return app_user.User(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      avatar: firebaseUser.photoURL,
      isOnline: true,
      lastSeen: DateTime.now(),
    );
  }
}

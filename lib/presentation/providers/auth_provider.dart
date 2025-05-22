import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../data/models/user_model.dart';
import '../../data/services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;
  User? _currentUser;
  String? _error;

  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider() {
    // Listen to Firebase authentication state changes
    _authService.authStateChanges.listen((firebase_auth.User? firebaseUser) {
      _currentUser = _authService.convertToAppUser(firebaseUser);
      notifyListeners();
    });
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      _error = null;
      return true;
    } catch (e) {
      _error = _getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _error = null;
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final firebase_auth.User? firebaseUser = _authService.currentUser;

      if (firebaseUser != null) {
        if (data.containsKey('name')) {
          await firebaseUser.updateDisplayName(data['name']);
        }
        if (data.containsKey('photoURL')) {
          await firebaseUser.updatePhotoURL(data['photoURL']);
        }

        // Update local user data
        _currentUser = _authService.convertToAppUser(firebaseUser);
      }
    } catch (e) {
      _error = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic exception) {
    if (exception is firebase_auth.FirebaseAuthException) {
      switch (exception.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'invalid-email':
          return 'Invalid email format';
        case 'user-disabled':
          return 'This user has been disabled';
        case 'email-already-in-use':
          return 'This email is already registered';
        case 'weak-password':
          return 'Password is too weak';
        case 'operation-not-allowed':
          return 'This operation is not allowed';
        case 'popup-closed-by-user':
          return 'Sign-in popup was closed before completing the process';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials';
        default:
          return 'Authentication failed: ${exception.message}';
      }
    }
    return exception.toString();
  }
}

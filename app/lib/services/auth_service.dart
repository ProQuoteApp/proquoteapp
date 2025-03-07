import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../models/user_profile.dart';
import '../models/user.dart' as app_user;

/// Exception thrown during the authentication process
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, [this.code]);

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

/// Service that handles all authentication-related functionality
class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  /// Constructor that allows dependency injection for testing
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream of auth state changes
  Stream<AuthUser?> get authStateChanges => _firebaseAuth.authStateChanges().map(
        (firebase_auth.User? user) =>
            user != null ? AuthUser.fromFirebaseUser(user) : null,
      );

  /// Get the current authenticated user
  AuthUser? get currentUser => _firebaseAuth.currentUser != null
      ? AuthUser.fromFirebaseUser(_firebaseAuth.currentUser!)
      : null;

  /// Sign up with email and password
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required UserType userType,
    String? displayName,
  }) async {
    try {
      // Create the user in Firebase Authentication
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('User creation failed');
      }

      // Update the user's display name if provided
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      // Create a user profile in Firestore
      await _createUserProfile(
        uid: user.uid,
        email: email,
        displayName: displayName,
        userType: userType,
      );

      // Send email verification
      await user.sendEmailVerification();

      return AuthUser.fromFirebaseUser(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Sign in failed');
      }

      return AuthUser.fromFirebaseUser(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Create a user profile in Firestore
  Future<void> _createUserProfile({
    required String uid,
    required String email,
    String? displayName,
    required UserType userType,
  }) async {
    try {
      final userProfile = UserProfile(
        uid: uid,
        displayName: displayName,
        email: email,
        userType: userType,
        isProfileComplete: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(userProfile.toFirestore());
    } catch (e) {
      throw AuthException('Failed to create user profile: ${e.toString()}');
    }
  }

  /// Handle Firebase Auth exceptions and convert them to AuthException
  AuthException _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AuthException('The email address is already in use', e.code);
      case 'invalid-email':
        return AuthException('The email address is invalid', e.code);
      case 'operation-not-allowed':
        return AuthException('Email/password accounts are not enabled', e.code);
      case 'weak-password':
        return AuthException('The password is too weak', e.code);
      case 'user-disabled':
        return AuthException('This user has been disabled', e.code);
      case 'user-not-found':
        return AuthException('No user found with this email', e.code);
      case 'wrong-password':
        return AuthException('Incorrect password', e.code);
      case 'invalid-credential':
        return AuthException('The credentials are invalid', e.code);
      case 'account-exists-with-different-credential':
        return AuthException(
            'An account already exists with the same email address', e.code);
      default:
        return AuthException('Authentication error: ${e.message}', e.code);
    }
  }
} 
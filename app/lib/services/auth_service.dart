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
  final GoogleSignIn? _googleSignIn;

  /// Constructor that allows dependency injection for testing
  AuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        // Skip Google Sign-In initialization on web until properly configured
        _googleSignIn = kIsWeb ? null : (googleSignIn ?? GoogleSignIn());

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

  /// Sign in with Google
  Future<AuthUser> signInWithGoogle() async {
    try {
      firebase_auth.UserCredential userCredential;
      
      if (kIsWeb) {
        // Web platform - use simple popup flow
        final googleProvider = firebase_auth.GoogleAuthProvider();
        userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      } else {
        // Mobile platforms
        final googleSignIn = GoogleSignIn();
        
        // Trigger the authentication flow
        final googleUser = await googleSignIn.signIn();
        
        // User canceled the sign-in flow
        if (googleUser == null) {
          throw AuthException('Google Sign-In was canceled by user');
        }
        
        // Get authentication details
        final googleAuth = await googleUser.authentication;
        
        // Create credential
        final credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        // Sign in with Firebase
        userCredential = await _firebaseAuth.signInWithCredential(credential);
      }
      
      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Google Sign-In failed: No user returned');
      }

      // Check if user profile exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // Create profile for new user
        await _createUserProfile(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          userType: UserType.seeker, // Default for Google Sign-In
          photoURL: user.photoURL,
        );
      }

      return AuthUser.fromFirebaseUser(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Google Sign-In failed: ${e.toString()}');
    }
  }

  /// Start phone number verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(AuthUser) verificationCompleted,
    required Function(String) verificationFailed,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          final userCredential = await _firebaseAuth.signInWithCredential(credential);
          final user = userCredential.user;
          if (user != null) {
            verificationCompleted(AuthUser.fromFirebaseUser(user));
          }
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          verificationFailed(_handleFirebaseAuthException(e).message);
        },
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      throw AuthException('Phone verification failed: ${e.toString()}');
    }
  }

  /// Sign in with phone verification code
  Future<AuthUser> signInWithPhoneVerificationCode({
    required String verificationId,
    required String smsCode,
    required UserType userType,
    String? displayName,
  }) async {
    try {
      // Create the credential
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign in with the credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Phone sign-in failed');
      }

      // Check if the user already has a profile in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        // Create a user profile if it doesn't exist
        await _createUserProfile(
          uid: user.uid,
          email: user.email ?? '', // Handle nullable email
          displayName: displayName ?? user.displayName,
          userType: userType,
          phoneNumber: user.phoneNumber,
        );
      }

      return AuthUser.fromFirebaseUser(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Phone sign-in failed: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
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
    String? phoneNumber,
    String? photoURL,
  }) async {
    try {
      final userProfile = UserProfile(
        uid: uid,
        displayName: displayName,
        email: email,
        phoneNumber: phoneNumber,
        photoURL: photoURL,
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
      case 'invalid-verification-code':
        return AuthException('The verification code is invalid', e.code);
      case 'invalid-verification-id':
        return AuthException('The verification ID is invalid', e.code);
      default:
        return AuthException('Authentication error: ${e.message}', e.code);
    }
  }
} 
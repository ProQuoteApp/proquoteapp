import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// A model class that wraps the Firebase User object
/// This allows us to decouple our app from Firebase and makes testing easier
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? lastSignInTime;
  final List<String> providerIds;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.emailVerified,
    this.phoneNumber,
    this.createdAt,
    this.lastSignInTime,
    required this.providerIds,
  });

  /// Factory constructor to create an AuthUser from a Firebase User
  factory AuthUser.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      emailVerified: firebaseUser.emailVerified,
      phoneNumber: firebaseUser.phoneNumber,
      createdAt: firebaseUser.metadata.creationTime,
      lastSignInTime: firebaseUser.metadata.lastSignInTime,
      providerIds: firebaseUser.providerData
          .map((userInfo) => userInfo.providerId)
          .toList(),
    );
  }

  /// Check if the user is anonymous
  bool get isAnonymous => email == null && phoneNumber == null;

  /// Check if the user has verified their email
  bool get isEmailVerified => emailVerified;

  /// Check if the user signed in with a specific provider
  bool hasProvider(String providerId) => providerIds.contains(providerId);

  /// Check if the user has a Google provider
  bool get hasGoogleProvider => hasProvider('google.com');

  /// Check if the user has a phone provider
  bool get hasPhoneProvider => hasProvider('phone');

  /// Check if the user has an email provider
  bool get hasEmailProvider => hasProvider('password');

  /// Check if the user has an Apple provider
  bool get hasAppleProvider => hasProvider('apple.com');

  /// Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'emailVerified': emailVerified,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'lastSignInTime': lastSignInTime?.millisecondsSinceEpoch,
      'providerIds': providerIds,
    };
  }
} 
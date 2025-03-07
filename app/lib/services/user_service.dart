import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/auth_user.dart';
import '../models/user.dart' as app_user;

/// Service for user-related operations
class UserService {
  final FirebaseFirestore _firestore;
  
  // Cache for user profiles to minimize Firestore reads
  final Map<String, UserProfile> _profileCache = {};

  /// Constructor that allows dependency injection for testing
  UserService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get a user profile by ID
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      // Check cache first
      if (_profileCache.containsKey(uid)) {
        print('Using cached profile for uid: $uid');
        return _profileCache[uid];
      }
      
      print('Fetching user profile for uid: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      print('Document exists: ${doc.exists}');
      
      if (doc.exists) {
        print('Document data found, creating UserProfile');
        final profile = UserProfile.fromFirestore(doc);
        // Cache the profile
        _profileCache[uid] = profile;
        return profile;
      }
      
      // Return null if profile doesn't exist
      // We'll only create a profile when explicitly requested
      print('No profile found for uid: $uid');
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      // Don't throw, just log the error and return null
      return null;
    }
  }
  
  /// Create a default user profile
  Future<UserProfile?> createDefaultUserProfile(AuthUser authUser) async {
    try {
      print('Creating default user profile for uid: ${authUser.uid}');
      final defaultProfile = UserProfile(
        uid: authUser.uid,
        displayName: authUser.displayName,
        email: authUser.email,
        phoneNumber: authUser.phoneNumber,
        photoURL: authUser.photoURL,
        userType: UserType.seeker,
        isProfileComplete: false,
        createdAt: authUser.createdAt ?? DateTime.now(),
      );
      
      try {
        // Try to save to Firestore, but don't fail if offline or permission issues
        await _firestore.collection('users').doc(authUser.uid).set(defaultProfile.toFirestore());
        print('Default profile saved to Firestore');
      } catch (e) {
        print('Failed to save profile to Firestore: $e');
        if (e is FirebaseException && e.code == 'permission-denied') {
          print('Permission denied. Check Firestore security rules.');
        }
        // Continue anyway - we'll use the local profile
      }
      
      // Cache the profile regardless of whether Firestore save succeeded
      _profileCache[authUser.uid] = defaultProfile;
      
      return defaultProfile;
    } catch (e) {
      print('Error creating default user profile: $e');
      return null;
    }
  }

  /// Get a combined user object with auth and profile data
  Future<app_user.User?> getUser(AuthUser authUser) async {
    try {
      print('Getting user data for: ${authUser.uid}, name: ${authUser.displayName}');
      
      // Try to get profile from Firestore
      UserProfile? profile;
      try {
        profile = await getUserProfile(authUser.uid);
      } catch (e) {
        print('Error fetching profile, continuing with auth data only: $e');
        // Continue with null profile
      }
      
      // Create a User object regardless of whether we have a profile
      final user = app_user.User.fromAuthAndProfile(authUser, profile);
      print('Created User object with name: ${user.name}');
      return user;
    } catch (e) {
      print('Error getting user: $e');
      
      // Create a fallback user with just auth data if there's an error
      print('Creating fallback user with just auth data');
      return app_user.User.fromAuthAndProfile(authUser, null);
    }
  }

  /// Update a user profile
  Future<void> updateUserProfile(String uid, UserProfile profile) async {
    try {
      print('Updating user profile for uid: $uid');
      
      // Update cache first
      _profileCache[uid] = profile;
      
      // Then try to update Firestore
      try {
        await _firestore.collection('users').doc(uid).update(profile.toFirestore());
        print('User profile updated successfully in Firestore');
      } catch (e) {
        print('Failed to update profile in Firestore: $e');
        if (e is FirebaseException && e.code == 'permission-denied') {
          print('Permission denied. Check Firestore security rules.');
        }
        // Continue anyway - we'll use the cached profile
      }
    } catch (e) {
      print('Error updating user profile: $e');
      // Don't throw, just log the error
    }
  }
  
  /// Clear the profile cache
  void clearCache() {
    _profileCache.clear();
  }
} 
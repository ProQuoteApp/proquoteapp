import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/auth_user.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';

/// Provider that manages user state
class UserProvider extends ChangeNotifier {
  final UserService _userService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _profileCreationInProgress = false;
  bool _firestoreAvailable = true;

  /// Constructor
  UserProvider({
    UserService? userService,
  }) : _userService = userService ?? UserService();

  /// Current user
  User? get currentUser => _currentUser;

  /// Whether data is being loaded
  bool get isLoading => _isLoading;

  /// Error message if any
  String? get error => _error;
  
  /// Whether profile creation is in progress
  bool get profileCreationInProgress => _profileCreationInProgress;
  
  /// Whether Firestore is available
  bool get firestoreAvailable => _firestoreAvailable;

  /// Load user data from auth user
  Future<void> loadUser(AuthUser authUser) async {
    print('UserProvider: Loading user data for ${authUser.uid}');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _userService.getUser(authUser);
      
      if (user != null) {
        print('UserProvider: User data loaded successfully: ${user.name}');
        _currentUser = user;
        
        // Even if we don't have a Firestore profile, we can still use the auth data
        if (user.isProfileComplete == false) {
          print('UserProvider: User profile is not complete, using auth data only');
        }
      } else {
        print('UserProvider: User data is null');
        _error = 'Failed to load user data: User data is null';
      }
    } catch (e) {
      print('UserProvider: Error loading user: $e');
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
      print('UserProvider: User loading complete. User: ${_currentUser?.name}, Error: $_error');
    }
  }
  
  /// Create a default profile for the user if one doesn't exist
  Future<void> createUserProfileIfNeeded(AuthUser authUser) async {
    if (_profileCreationInProgress) return;
    
    print('UserProvider: Checking if profile needs to be created for ${authUser.uid}');
    _profileCreationInProgress = true;
    _error = null;
    notifyListeners();
    
    try {
      // Check if profile exists
      final profile = await _userService.getUserProfile(authUser.uid);
      
      if (profile == null) {
        print('UserProvider: No profile exists, creating default profile');
        final newProfile = await _userService.createDefaultUserProfile(authUser);
        
        if (newProfile != null) {
          // Reload user data with the new profile
          await loadUser(authUser);
        } else {
          // If we couldn't create a profile in Firestore, create a local-only user
          print('UserProvider: Could not create profile in Firestore, using auth data only');
          _currentUser = User.fromAuthAndProfile(authUser, null);
          _error = 'Could not save profile to Firestore. Using local data only.';
          _firestoreAvailable = false;
        }
      } else {
        print('UserProvider: Profile already exists, no need to create');
      }
    } catch (e) {
      print('UserProvider: Error creating profile: $e');
      _handleError(e);
      
      // Even if we couldn't create a profile, we can still use the auth data
      _currentUser = User.fromAuthAndProfile(authUser, null);
    } finally {
      _profileCreationInProgress = false;
      notifyListeners();
    }
  }

  /// Update user data
  void updateUser(User user) {
    print('UserProvider: Updating user data: ${user.name}');
    _currentUser = user;
    notifyListeners();
  }

  /// Clear user data
  void clearUser() {
    print('UserProvider: Clearing user data');
    _currentUser = null;
    _userService.clearCache();
    notifyListeners();
  }

  /// Reset error
  void resetError() {
    print('UserProvider: Resetting error');
    _error = null;
    notifyListeners();
  }
  
  /// Update user profile
  Future<void> updateUserProfile(AuthUser authUser, UserProfile updatedProfile) async {
    print('UserProvider: Updating user profile for ${authUser.uid}');
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Update the profile in Firestore
      await _userService.updateUserProfile(authUser.uid, updatedProfile);
      
      // Reload the user data
      await loadUser(authUser);
      
      print('UserProvider: User profile updated successfully');
    } catch (e) {
      print('UserProvider: Error updating user profile: $e');
      _handleError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle errors and set appropriate error messages
  void _handleError(dynamic e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          _error = 'Permission denied. Please check Firestore security rules.';
          _firestoreAvailable = false;
          break;
        case 'unavailable':
          _error = 'Firestore is currently unavailable. Using local data only.';
          _firestoreAvailable = false;
          break;
        case 'not-found':
          _error = 'Requested document not found.';
          break;
        default:
          _error = 'Firebase error: ${e.message}';
      }
    } else {
      _error = 'Error: $e';
    }
  }
} 
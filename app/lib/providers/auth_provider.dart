import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/auth_user.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

/// Provider that manages authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  /// Constructor
  AuthProvider({AuthService? authService}) 
      : _authService = authService ?? AuthService() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  /// Current authenticated user
  AuthUser? get currentUser => _currentUser;

  /// Whether authentication is in progress
  bool get isLoading => _isLoading;

  /// Error message if authentication failed
  String? get error => _error;

  /// Whether the user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required UserType userType,
    String? displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        userType: userType,
        displayName: displayName,
      );
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signOut();
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/auth_user.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../utils/mock_data.dart';

/// Provider that manages authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService? _authService;
  
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _useMockAuth = false;
  
  // Phone verification state
  String? _verificationId;
  int? _resendToken;
  bool _isPhoneVerificationInProgress = false;

  /// Constructor
  AuthProvider({AuthService? authService}) 
      : _authService = authService {
    _initializeAuth();
  }

  void _initializeAuth() {
    try {
      // Try to initialize the auth service
      final authService = _authService ?? AuthService();
      
      // Listen to auth state changes
      authService.authStateChanges.listen((user) {
        _currentUser = user;
        notifyListeners();
      });
    } catch (e) {
      print('Error initializing auth service: $e');
      // Fall back to mock authentication for testing
      _useMockAuth = true;
      // Set a mock user for testing
      if (kDebugMode) {
        _currentUser = MockData.mockAuthUser;
      }
    }
  }

  /// Current authenticated user
  AuthUser? get currentUser => _currentUser;

  /// Whether authentication is in progress
  bool get isLoading => _isLoading;

  /// Error message if authentication failed
  String? get error => _error;

  /// Whether the user is authenticated
  bool get isAuthenticated => _currentUser != null || _useMockAuth;
  
  /// Whether phone verification is in progress
  bool get isPhoneVerificationInProgress => _isPhoneVerificationInProgress;
  
  /// Verification ID for phone authentication
  String? get verificationId => _verificationId;

  /// Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required UserType userType,
    String? displayName,
  }) async {
    if (_useMockAuth) {
      // Mock implementation for testing
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = MockData.mockAuthUser;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService!.signUpWithEmailAndPassword(
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
    if (_useMockAuth) {
      // Mock implementation for testing
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = MockData.mockAuthUser;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService!.signInWithEmailAndPassword(
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
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    if (_useMockAuth) {
      // Mock implementation for testing
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = MockData.mockAuthUser;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService!.signInWithGoogle();
    } on AuthException catch (e) {
      // Handle specific auth exceptions
      if (e.message.contains('canceled by user')) {
        // User canceled - don't show as error
        _error = null;
      } else {
        _error = e.message;
        print('Google Sign-In error: ${e.message}');
      }
    } catch (e) {
      _error = 'Google Sign-In failed. Please try again.';
      print('Google Sign-In unexpected error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Start phone number verification
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    if (_useMockAuth) {
      // Mock implementation for testing
      await Future.delayed(const Duration(seconds: 1));
      _verificationId = 'mock-verification-id';
      _isPhoneVerificationInProgress = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _isPhoneVerificationInProgress = true;
    notifyListeners();

    try {
      await _authService!.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isLoading = false;
          notifyListeners();
        },
        verificationCompleted: (AuthUser user) {
          _currentUser = user;
          _isLoading = false;
          _isPhoneVerificationInProgress = false;
          notifyListeners();
        },
        verificationFailed: (String errorMessage) {
          _error = errorMessage;
          _isLoading = false;
          _isPhoneVerificationInProgress = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Failed to verify phone number: ${e.toString()}';
      _isLoading = false;
      _isPhoneVerificationInProgress = false;
      notifyListeners();
    }
  }
  
  /// Sign in with phone verification code
  Future<void> signInWithPhoneVerificationCode({
    required String smsCode,
    required UserType userType,
    String? displayName,
  }) async {
    if (_useMockAuth) {
      // Mock implementation for testing
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = MockData.mockAuthUser;
      _isPhoneVerificationInProgress = false;
      notifyListeners();
      return;
    }

    if (_verificationId == null) {
      _error = 'Verification ID is missing. Please restart phone verification.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService!.signInWithPhoneVerificationCode(
        verificationId: _verificationId!,
        smsCode: smsCode,
        userType: userType,
        displayName: displayName,
      );
      _isPhoneVerificationInProgress = false;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to verify code: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Cancel phone verification
  void cancelPhoneVerification() {
    _isPhoneVerificationInProgress = false;
    _verificationId = null;
    _resendToken = null;
    notifyListeners();
  }

  /// Sign out
  Future<void> signOut() async {
    if (_useMockAuth) {
      // Mock implementation for testing
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService!.signOut();
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
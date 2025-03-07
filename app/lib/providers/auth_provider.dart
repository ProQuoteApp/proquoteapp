import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

/// Provider that manages authentication state
class AuthProvider extends ChangeNotifier {
  AuthService? _authService;
  StreamSubscription<AuthUser?>? _authSubscription;
  
  AuthUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  
  // Phone verification state
  String? _verificationId;
  // The resendToken can be used to resend the verification code without
  // triggering the reCAPTCHA flow again on Android devices
  int? _resendToken;
  bool _isPhoneVerificationInProgress = false;

  /// Constructor
  AuthProvider({AuthService? authService}) {
    _authService = authService;
    initialize();
  }

  /// Initialize the provider
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Initialize auth service if not provided
      _authService ??= AuthService();
      
      // Listen for auth state changes
      _authSubscription = _authService!.authStateChanges.listen((user) {
        _currentUser = user;
        notifyListeners();
      });
      
      // Check if there's a current user
      _currentUser = _authService!.currentUser;
      
      _initialized = true;
    } catch (e) {
      _error = 'Failed to initialize authentication: $e';
      print('Auth Provider initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Current authenticated user
  AuthUser? get currentUser => _currentUser;

  /// Whether authentication is in progress
  bool get isLoading => _isLoading;

  /// Current error message
  String? get error => _error;

  /// Whether the user is authenticated
  bool get isAuthenticated => _currentUser != null;
  
  /// Whether phone verification is in progress
  bool get isPhoneVerificationInProgress => _isPhoneVerificationInProgress;
  
  /// Verification ID for phone authentication
  String? get verificationId => _verificationId;
  
  /// Resend token for phone verification
  int? get resendToken => _resendToken;

  /// Sign up with email and password
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required UserType userType,
    String? displayName,
  }) async {
    if (_authService == null) {
      _error = 'Authentication service not initialized';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService!.signUpWithEmailAndPassword(
        email: email,
        password: password,
        userType: userType,
        displayName: displayName,
      );
      _currentUser = user;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
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
    if (_authService == null) {
      _error = 'Authentication service not initialized';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = user;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'An unexpected error occurred: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    if (_isLoading) return;
    
    if (_authService == null) {
      _error = 'Authentication service not initialized';
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      print('Provider: Starting Google Sign-In');
      
      final user = await _authService!.signInWithGoogle();
      
      _currentUser = user;
      _error = null;
      print('Provider: Google Sign-In successful: ${user.uid}');
      
    } on AuthException catch (e) {
      print('Provider: Google Sign-In error: ${e.message}');
      _error = e.message;
      
      if (e.code == 'popup-closed-by-user') {
        _error = 'Sign-in was canceled. Please try again.';
      } else if (e.code == 'popup-blocked') {
        _error = 'Sign-in popup was blocked. Please allow popups for this site.';
      }
    } catch (e) {
      print('Provider: Unexpected Google Sign-In error: $e');
      _error = 'An unexpected error occurred. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Start phone number verification
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    if (_authService == null) {
      _error = 'Authentication service not initialized';
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
    if (_authService == null) {
      _error = 'Authentication service not initialized';
      notifyListeners();
      return;
    }

    if (_verificationId == null) {
      _error = 'Verification ID not available';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService!.signInWithPhoneVerificationCode(
        verificationId: _verificationId!,
        smsCode: smsCode,
        userType: userType,
        displayName: displayName,
      );
      
      _currentUser = user;
      _isPhoneVerificationInProgress = false;
      _verificationId = null;
      _resendToken = null;
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to sign in with verification code: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (_authService == null) {
      _error = 'Authentication service not initialized';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService!.signOut();
      _currentUser = null;
    } catch (e) {
      _error = 'Failed to sign out: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Dispose of resources
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
} 
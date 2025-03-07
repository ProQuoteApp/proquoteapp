import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';
import '../utils/platform_helper.dart';
import '../widgets/error_display.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  
  late TabController _tabController;
  bool _isPhoneAuth = false;
  bool _obscurePassword = true;
  UserType _userType = UserType.seeker;
  bool _isVerificationSent = false;
  
  // Store a reference to the auth provider
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store a reference to the auth provider
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    
    // Reset phone verification state if needed
    if (_authProvider.isPhoneVerificationInProgress) {
      // We can't cancel the verification, but we can reset the UI state
      _resetPhoneVerification();
    }
    
    super.dispose();
  }
  
  // Reset phone verification state
  void _resetPhoneVerification() {
    setState(() {
      _isVerificationSent = false;
      _smsCodeController.clear();
    });
  }

  void _togglePhoneAuth() {
    if (_authProvider.isPhoneVerificationInProgress) {
      _resetPhoneVerification();
    }
    
    setState(() {
      _isPhoneAuth = !_isPhoneAuth;
      _isVerificationSent = false;
      if (_isPhoneAuth) {
        _phoneController.clear();
        _smsCodeController.clear();
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_tabController.index == 1) { // Sign Up
        await _authProvider.signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          userType: _userType,
          displayName: _nameController.text.trim(),
        );
      } else { // Sign In
        await _authProvider.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    }
  }

  void _handleGoogleSignIn() async {
    // Clear any previous snackbars
    ScaffoldMessenger.of(context).clearSnackBars();
    
    // Show a snackbar to indicate the sign-in process has started
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting Google Sign-In...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    await _authProvider.signInWithGoogle();
    
    // Check if the widget is still mounted before showing success/error messages
    if (!mounted) return;
    
    if (_authProvider.error != null) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else if (_authProvider.currentUser != null) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign-In successful!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }
    
    await _authProvider.verifyPhoneNumber(_phoneController.text.trim());
    
    // Set verification sent flag if successful
    if (_authProvider.verificationId != null) {
      setState(() {
        _isVerificationSent = true;
      });
    }
  }

  Future<void> _verifyPhoneCode() async {
    if (_smsCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
      return;
    }
    
    await _authProvider.signInWithPhoneVerificationCode(
      smsCode: _smsCodeController.text.trim(),
      userType: _userType,
      displayName: _tabController.index == 1 ? _nameController.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to handle responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;
    final isMediumScreen = screenWidth > 600 && screenWidth <= 900;
    
    // Calculate content width based on screen size
    final contentWidth = isLargeScreen 
        ? 900.0 
        : isMediumScreen 
            ? screenWidth * 0.9 
            : screenWidth;
    
    // Listen to auth provider for state changes
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;
    final error = authProvider.error;
    
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Logo and Title
                Column(
                  children: [
                    const SizedBox(height: AppConstants.sectionSpacing),
                    Icon(
                      Icons.handyman_rounded,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: AppConstants.itemSpacing),
                    Text(
                      'ProQuote',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppConstants.textSpacing),
                    Text(
                      'Connect with service providers',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: AppConstants.sectionSpacing),
                  ],
                ),
                
                // Error Message
                if (error != null)
                  ErrorDisplay(
                    message: error,
                    type: ErrorType.error,
                    isDismissible: true,
                    onDismiss: () {
                      authProvider.clearError();
                    },
                    actionButton: error.contains('network') ? 
                      TextButton(
                        onPressed: () {
                          // Retry the last operation
                          if (_isPhoneAuth && authProvider.isPhoneVerificationInProgress) {
                            _verifyPhoneCode();
                          } else if (_isPhoneAuth) {
                            _verifyPhoneNumber();
                          } else {
                            _submitForm();
                          }
                        },
                        child: const Text('Retry'),
                      ) : null,
                  ),
                
                // Tab Bar for Sign In / Sign Up
                if (!_isPhoneAuth || !_authProvider.isPhoneVerificationInProgress)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).primaryColor,
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[700],
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      tabs: const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Sign In'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Sign Up'),
                        ),
                      ],
                      onTap: (_) {
                        // Force rebuild to update form validation
                        setState(() {});
                      },
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      if (_isPhoneAuth)
                        Text(
                          _authProvider.isPhoneVerificationInProgress && _authProvider.verificationId != null ? 'Verify Phone' : 'Phone Authentication',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      
                      if (_isPhoneAuth)
                        const SizedBox(height: 16),
                      
                      // Name Field (Sign Up only)
                      if (_tabController.index == 1 && !_isPhoneAuth)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full Name',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Enter your full name',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (_tabController.index == 1 && (value == null || value.isEmpty)) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      
                      // Email & Password Fields
                      if (!_isPhoneAuth) ...[
                        Text(
                          'Email',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'Password',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: _tabController.index == 0 
                                ? 'Enter your password' 
                                : 'Create a password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                    ? Icons.visibility_outlined 
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (_tabController.index == 1 && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        
                        if (_tabController.index == 0) // Sign In
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Forgot password functionality
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                      ]
                      // Phone Authentication
                      else if (!(_authProvider.isPhoneVerificationInProgress && _authProvider.verificationId != null)) ...[
                        Text(
                          'Phone Number',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: '+27 82 123 4567',
                            prefixIcon: const Icon(Icons.phone_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            return null;
                          },
                        ),
                        if (_isVerificationSent) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Verification code sent! Please check your phone.',
                                    style: TextStyle(color: Colors.green.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ]
                      // Verification Code
                      else ...[
                        Text(
                          'Verification Code',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _smsCodeController,
                          decoration: InputDecoration(
                            hintText: '123456',
                            prefixIcon: const Icon(Icons.sms_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the verification code';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            // Resend code
                            _verifyPhoneNumber();
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Resend Code'),
                        ),
                      ],
                      
                      // User Type Selection (Sign Up only)
                      if (_tabController.index == 1 && !_isPhoneAuth) ...[
                        const SizedBox(height: 24),
                        Text(
                          'I am a:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<UserType>(
                                title: const Text('Customer'),
                                value: UserType.seeker,
                                groupValue: _userType,
                                onChanged: (value) {
                                  setState(() {
                                    _userType = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<UserType>(
                                title: const Text('Provider'),
                                value: UserType.provider,
                                groupValue: _userType,
                                onChanged: (value) {
                                  setState(() {
                                    _userType = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : (_isPhoneAuth
                                  ? ( _authProvider.isPhoneVerificationInProgress && _authProvider.verificationId != null ? _verifyPhoneCode : _verifyPhoneNumber)
                                  : _submitForm),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isPhoneAuth
                                      ? ( _authProvider.isPhoneVerificationInProgress && _authProvider.verificationId != null ? 'Verify Code' : 'Send Verification Code')
                                      : (_tabController.index == 0 ? 'Sign In' : 'Sign Up'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // OR Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey[400],
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Social Sign In Buttons
                      Row(
                        children: [
                          // Google Button - Only show if supported on this platform
                          if (PlatformHelper.isFeatureSupported('supportsGoogleSignIn'))
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading ? null : _handleGoogleSignIn,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 18,
                                      width: 18,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'G',
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Google'),
                                  ],
                                ),
                              ),
                            ),
                          if (PlatformHelper.isFeatureSupported('supportsGoogleSignIn') && 
                              PlatformHelper.isFeatureSupported('supportsPhoneAuth'))
                            const SizedBox(width: 16),
                          // Phone Button - Only show if supported on this platform
                          if (PlatformHelper.isFeatureSupported('supportsPhoneAuth'))
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isLoading ? null : _togglePhoneAuth,
                                icon: const Icon(Icons.phone, size: 20),
                                label: Text(_isPhoneAuth ? 'Email' : 'Phone'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          // Apple Button - Only show on iOS
                          if (PlatformHelper.isFeatureSupported('supportsAppleSignIn'))
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: isLoading ? null : () {
                                  // TODO: Implement Apple Sign In
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Apple Sign In not implemented yet'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.apple, size: 20),
                                label: const Text('Apple'),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.grey.shade300),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isSignUp = false;
  UserType _userType = UserType.seeker;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (_isSignUp) {
        await authProvider.signUpWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          userType: _userType,
          displayName: _nameController.text.trim(),
        );
      } else {
        await authProvider.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Create Account' : 'Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (authProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  color: Colors.red.shade100,
                  child: Text(
                    authProvider.error!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              
              if (_isSignUp)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isSignUp && (value == null || value.isEmpty)) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              
              if (_isSignUp) const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
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
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (_isSignUp && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              
              if (_isSignUp) ...[
                const SizedBox(height: 16),
                
                const Text('I am a:'),
                
                RadioListTile<UserType>(
                  title: const Text('Service Seeker (Customer)'),
                  value: UserType.seeker,
                  groupValue: _userType,
                  onChanged: (value) {
                    setState(() {
                      _userType = value!;
                    });
                  },
                ),
                
                RadioListTile<UserType>(
                  title: const Text('Service Provider (Professional)'),
                  value: UserType.provider,
                  groupValue: _userType,
                  onChanged: (value) {
                    setState(() {
                      _userType = value!;
                    });
                  },
                ),
              ],
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _submitForm,
                child: authProvider.isLoading
                    ? const CircularProgressIndicator()
                    : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
              ),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: _toggleMode,
                child: Text(_isSignUp
                    ? 'Already have an account? Sign In'
                    : 'Don\'t have an account? Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
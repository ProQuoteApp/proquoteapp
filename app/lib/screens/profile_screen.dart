import 'package:flutter/material.dart';
import 'package:proquote/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proquote/providers/auth_provider.dart';
import 'package:proquote/providers/user_provider.dart';
import 'package:proquote/providers/theme_provider.dart';
import 'package:proquote/models/user_profile.dart';
import 'package:proquote/utils/constants.dart';
import 'package:proquote/widgets/user_avatar.dart';
import 'package:proquote/widgets/error_display.dart';
import 'package:proquote/widgets/address_autocomplete.dart';
import 'package:proquote/widgets/app_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final authUser = authProvider.currentUser;
    final isLoading = userProvider.isLoading;
    final error = userProvider.error;
    final firestoreAvailable = userProvider.firestoreAvailable;
    
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

    return Scaffold(
      appBar: AppHeader(
        title: 'Profile',
        centerTitle: isLargeScreen,
        additionalActions: [
          // Add a button to clear image cache
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Clear image cache',
            onPressed: () {
              // Clear the image cache
              UserAvatar.clearAllImageCache();
              
              // Show a snackbar to confirm
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Image cache cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
              
              // Refresh the user data
              if (authUser != null) {
                userProvider.loadUser(authUser);
              }
            },
          ),
          if (user != null && firestoreAvailable)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(user: user),
                  ),
                ).then((_) {
                  // Refresh user data when returning from edit screen
                  if (authUser != null) {
                    userProvider.loadUser(authUser);
                  }
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : (user == null && authUser == null)
                  ? const Center(child: Text('No user data available'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Show error message if there is one
                          if (error != null)
                            ErrorDisplay(
                              message: error,
                              type: ErrorType.warning,
                              isDismissible: true,
                              onDismiss: () {
                                userProvider.resetError();
                              },
                            ),
                            
                          const SizedBox(height: AppConstants.sectionSpacing),
                          Center(
                            child: UserAvatar(
                              user: user,
                              authUser: authUser,
                            ),
                          ),
                          const SizedBox(height: AppConstants.itemSpacing),
                          Text(
                            _getName(user, authUser),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppConstants.textSpacing),
                          Text(
                            _getEmail(user, authUser),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          
                          // Show profile creation button if no Firestore profile exists
                          if (user == null && authUser != null && firestoreAvailable) ...[
                            const SizedBox(height: AppConstants.sectionSpacing),
                            ElevatedButton.icon(
                              onPressed: () {
                                userProvider.createUserProfileIfNeeded(authUser);
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text('Create Profile'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.itemSpacing),
                            const Text(
                              'Create a profile to save your preferences and job history',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          
                          // Show Firestore unavailable message
                          if (!firestoreAvailable) ...[
                            const SizedBox(height: AppConstants.sectionSpacing),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.info, color: Colors.blue.shade800),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Using local data only',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppConstants.textSpacing),
                                  Text(
                                    'Your profile data is not being saved to the cloud. '
                                    'This may be due to Firestore security rules or connectivity issues.',
                                    style: TextStyle(color: Colors.blue.shade800),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          if (user != null || !firestoreAvailable) ...[
                            const SizedBox(height: AppConstants.sectionSpacing),
                            _buildInfoSection(context, 'Account Information'),
                            _buildInfoTile(
                              context,
                              'Phone Number',
                              user?.phoneNumber ?? authUser?.phoneNumber ?? 'Not provided',
                              Icons.phone,
                            ),
                            _buildInfoTile(
                              context,
                              'Location',
                              user?.address ?? 'Not provided',
                              Icons.location_on,
                            ),
                            _buildInfoTile(
                              context,
                              'Member Since',
                              _getFormattedDate(user?.createdAt ?? authUser?.createdAt ?? DateTime.now()),
                              Icons.calendar_today,
                            ),
                            const SizedBox(height: AppConstants.sectionSpacing),
                            _buildInfoSection(context, 'Preferences'),
                            SwitchListTile(
                              title: const Text('Notifications'),
                              subtitle: const Text('Receive push notifications'),
                              value: true, // This would come from user preferences
                              onChanged: firestoreAvailable ? (value) {
                                // TODO: Implement notification toggle
                              } : null,
                            ),
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, _) {
                                return SwitchListTile(
                                  title: const Text('Dark Mode'),
                                  subtitle: const Text('Use dark theme'),
                                  value: themeProvider.isDarkMode,
                                  onChanged: (value) {
                                    themeProvider.setThemeMode(
                                      value ? ThemeMode.dark : ThemeMode.light
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                          
                          const SizedBox(height: AppConstants.sectionSpacing),
                          _buildInfoSection(context, 'Support'),
                          _buildInfoTile(
                            context,
                            'Help Center',
                            '',
                            Icons.help,
                            showTrailing: true,
                          ),
                          _buildInfoTile(
                            context,
                            'Terms of Service',
                            '',
                            Icons.description,
                            showTrailing: true,
                          ),
                          _buildInfoTile(
                            context,
                            'Privacy Policy',
                            '',
                            Icons.privacy_tip,
                            showTrailing: true,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  String _getName(User? user, dynamic authUser) {
    return user?.name ?? authUser?.displayName ?? 'No Name';
  }
  
  String _getEmail(User? user, dynamic authUser) {
    return user?.email ?? authUser?.email ?? 'No Email';
  }
  
  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildInfoSection(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    bool showTrailing = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: showTrailing ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: showTrailing ? () {} : null,
    );
  }
}

/// Screen for editing user profile
class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _addressController = TextEditingController(text: widget.user.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      // Show a snackbar with validation error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authUser = authProvider.currentUser;

      if (authUser == null) {
        setState(() {
          _error = 'User not authenticated. Please sign in again.';
          _isLoading = false;
        });
        return;
      }

      // Create a new UserProfile with updated values
      final updatedUser = widget.user;
      
      // Create a UserProfile object with the updated values
      final updatedProfile = UserProfile(
        uid: authUser.uid,
        displayName: _nameController.text.trim(),
        email: updatedUser.email,
        phoneNumber: _phoneController.text.trim(),
        photoURL: updatedUser.profileImageUrl,
        address: _addressController.text.trim(),
        userType: updatedUser.isServiceProvider ? UserType.provider : UserType.seeker,
        isProfileComplete: true,
        createdAt: updatedUser.createdAt,
        lastUpdatedAt: DateTime.now(),
      );
      
      // Update the profile using the service
      await Provider.of<UserProvider>(context, listen: false)
          .updateUserProfile(authUser, updatedProfile);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Handle specific error types
      String errorMessage = 'Error updating profile';
      
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. You may not have access to update this profile.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('not-found')) {
        errorMessage = 'Profile not found. Please try creating a new profile.';
      } else {
        errorMessage = 'Error updating profile: $e';
      }
      
      setState(() {
        _error = errorMessage;
      });
      
      // Also show a snackbar for immediate feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
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
    
    return Scaffold(
      appBar: AppHeader(
        title: 'Edit Profile',
        centerTitle: isLargeScreen,
        showBackButton: true,
        additionalActions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    ErrorDisplay(
                      message: _error!,
                      type: ErrorType.error,
                      isDismissible: true,
                      onDismiss: () {
                        setState(() {
                          _error = null;
                        });
                      },
                    ),

                  Center(
                    child: UserAvatar(
                      user: widget.user,
                      authUser: authProvider.currentUser,
                      showEditButton: true,
                      onEditTap: () {
                        // TODO: Implement image upload
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile image upload not implemented yet'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.sectionSpacing),
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.itemSpacing),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.itemSpacing),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                      hintText: '+27 82 123 4567',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // Basic phone validation - should contain only numbers, spaces, and + sign
                        // and be at least 10 characters
                        if (!RegExp(r'^[+\d\s()-]+$').hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        if (value.replaceAll(RegExp(r'[\s()-]'), '').length < 10) {
                          return 'Phone number is too short';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.itemSpacing),
                  AddressAutocomplete(
                    initialValue: widget.user.address,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                      hintText: 'Enter your full address',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty && value.length < 5) {
                        return 'Please enter a valid address';
                      }
                      return null;
                    },
                    onAddressSelected: (address) {
                      _addressController.text = address;
                    },
                  ),
                  const SizedBox(height: AppConstants.sectionSpacing),
                  Text(
                    'Email address cannot be changed',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppConstants.itemSpacing),
                  TextFormField(
                    initialValue: widget.user.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: AppConstants.sectionSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
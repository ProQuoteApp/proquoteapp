import 'package:flutter/material.dart';
import 'package:proquote/models/user.dart';
import 'package:provider/provider.dart';
import 'package:proquote/providers/auth_provider.dart';
import 'package:proquote/providers/user_provider.dart';
import 'package:proquote/models/auth_user.dart';
import 'package:proquote/models/user_profile.dart';
import 'package:proquote/utils/constants.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : (user == null && authUser == null)
                ? const Center(child: Text('No user data available'))
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Show error message if there is one
                        if (error != null)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    error,
                                    style: TextStyle(color: Colors.orange.shade800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        const SizedBox(height: 24),
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                child: _buildProfileImage(user, authUser),
                              ),
                              if (firestoreAvailable)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getName(user, authUser),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getEmail(user, authUser),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        
                        // Show profile creation button if no Firestore profile exists
                        if (user == null && authUser != null && firestoreAvailable) ...[
                          const SizedBox(height: 24),
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
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 24),
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
                                const SizedBox(height: 8),
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
                          const SizedBox(height: 32),
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
                          const SizedBox(height: 24),
                          _buildInfoSection(context, 'Preferences'),
                          SwitchListTile(
                            title: const Text('Notifications'),
                            subtitle: const Text('Receive push notifications'),
                            value: true, // This would come from user preferences
                            onChanged: firestoreAvailable ? (value) {
                              // TODO: Implement notification toggle
                            } : null,
                          ),
                          SwitchListTile(
                            title: const Text('Dark Mode'),
                            subtitle: const Text('Use dark theme'),
                            value: false, // TODO: Implement theme toggle
                            onChanged: (value) {
                              // TODO: Implement theme toggle
                            },
                          ),
                        ],
                        
                        const SizedBox(height: 24),
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
    );
  }

  Widget _buildProfileImage(User? user, dynamic authUser) {
    // First try to use the Firestore profile image
    final profileUrl = user?.profileImageUrl;
    
    // If no Firestore profile, try to use the auth user photo URL
    final authPhotoUrl = authUser?.photoURL;
    
    final imageUrl = profileUrl ?? authPhotoUrl;
    
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading profile image: $error');
            return const Icon(
              Icons.person,
              size: 60,
              color: Colors.grey,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      );
    } else {
      return const Icon(
        Icons.person,
        size: 60,
        color: Colors.grey,
      );
    }
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
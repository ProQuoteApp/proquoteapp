import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:proquote/models/user.dart';
import 'package:proquote/utils/mock_data.dart';
import 'package:provider/provider.dart';
import 'package:proquote/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User user = MockData.currentUser;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: CachedNetworkImageProvider(
                      user.profileImageUrl ?? 'https://via.placeholder.com/120',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? 'email@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to edit profile
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await authProvider.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Contact information
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone Number'),
              subtitle: Text(user.phoneNumber ?? 'Not provided'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Address'),
              subtitle: Text(user.address ?? 'Not provided'),
            ),
            const SizedBox(height: 32),

            // Profile sections
            _buildSection(
              context,
              'Personal Information',
              [
                _buildInfoRow(
                  context,
                  Icons.calendar_today,
                  'Member Since',
                  '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              'Account',
              [
                _buildActionRow(
                  context,
                  Icons.history,
                  'Job History',
                  () {
                    // Navigate to job history
                  },
                ),
                _buildActionRow(
                  context,
                  Icons.payment,
                  'Payment Methods',
                  () {
                    // Navigate to payment methods
                  },
                ),
                _buildActionRow(
                  context,
                  Icons.notifications,
                  'Notification Settings',
                  () {
                    // Navigate to notification settings
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              'Support',
              [
                _buildActionRow(
                  context,
                  Icons.help,
                  'Help Center',
                  () {
                    // Navigate to help center
                  },
                ),
                _buildActionRow(
                  context,
                  Icons.contact_support,
                  'Contact Support',
                  () {
                    // Navigate to contact support
                  },
                ),
                _buildActionRow(
                  context,
                  Icons.privacy_tip,
                  'Privacy Policy',
                  () {
                    // Navigate to privacy policy
                  },
                ),
                _buildActionRow(
                  context,
                  Icons.description,
                  'Terms of Service',
                  () {
                    // Navigate to terms of service
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
} 
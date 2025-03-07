import 'package:flutter/material.dart';
import 'package:proquote/models/user.dart';
import 'package:proquote/utils/constants.dart';

/// A reusable widget for displaying user avatars consistently across the app
class UserAvatar extends StatelessWidget {
  /// The user whose avatar to display
  final User? user;
  
  /// The auth user object (used as fallback if user is null)
  final dynamic authUser;
  
  /// The radius of the avatar
  final double radius;
  
  /// Whether to show the edit button
  final bool showEditButton;
  
  /// Callback when the edit button is tapped
  final VoidCallback? onEditTap;

  /// Constructor
  const UserAvatar({
    super.key,
    this.user,
    this.authUser,
    this.radius = AppConstants.avatarRadius,
    this.showEditButton = false,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    // First try to use the Firestore profile image
    final profileUrl = user?.profileImageUrl;
    
    // If no Firestore profile, try to use the auth user photo URL
    final authPhotoUrl = authUser?.photoURL;
    
    final imageUrl = profileUrl ?? authPhotoUrl;
    
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[200],
          child: _buildProfileImage(imageUrl),
        ),
        if (showEditButton)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading profile image: $error');
            return Icon(
              Icons.person,
              size: radius,
              color: Colors.grey,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    } else {
      return Icon(
        Icons.person,
        size: radius,
        color: Colors.grey,
      );
    }
  }
} 
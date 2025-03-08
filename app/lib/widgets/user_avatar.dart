import 'package:flutter/material.dart';
import 'package:proquote/models/user.dart';
import 'package:proquote/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          child: _buildProfileImage(imageUrl, context),
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

  Widget _buildProfileImage(String? imageUrl, BuildContext context) {
    // Get initials for fallback
    final initials = _getInitials();
    
    // If no image URL, show initials
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildInitialsAvatar(initials, context);
    }
    
    // Validate URL
    bool isValidUrl = false;
    try {
      final uri = Uri.parse(imageUrl);
      isValidUrl = uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      debugPrint('Invalid image URL: $e');
      return _buildInitialsAvatar(initials, context);
    }
    
    if (!isValidUrl) {
      return _buildInitialsAvatar(initials, context);
    }
    
    // Use CachedNetworkImage with fallback
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildInitialsAvatar(initials, context),
        errorWidget: (context, url, error) {
          debugPrint('Error loading profile image: $error');
          // Clear the cache for this URL to prevent future errors
          _clearImageCache(url);
          return _buildInitialsAvatar(initials, context);
        },
        // Add caching settings
        cacheKey: imageUrl,
        maxHeightDiskCache: 200,
        maxWidthDiskCache: 200,
        memCacheHeight: 200,
        memCacheWidth: 200,
      ),
    );
  }
  
  /// Clear the image cache for a specific URL
  void _clearImageCache(String url) {
    try {
      CachedNetworkImage.evictFromCache(url);
      debugPrint('Cleared cache for image: $url');
    } catch (e) {
      debugPrint('Error clearing image cache: $e');
    }
  }
  
  /// Build an avatar with user initials
  Widget _buildInitialsAvatar(String initials, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.8,
          ),
        ),
      ),
    );
  }
  
  /// Get the user's initials for the avatar placeholder
  String _getInitials() {
    String? displayName;
    
    // Try to get a name from various sources
    if (user?.name != null) {
      displayName = user!.name;
    } else if (authUser?.displayName != null) {
      displayName = authUser!.displayName as String;
    } else if (user?.email != null) {
      displayName = user!.email;
    } else if (authUser?.email != null) {
      displayName = authUser!.email as String;
    }
    
    // If no name is found, return a question mark
    if (displayName == null || displayName.isEmpty) {
      return '?';
    }
    
    // If email is used, get the part before @
    if (displayName.contains('@')) {
      displayName = displayName.split('@').first;
    }
    
    final nameParts = displayName.trim().split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts.first.isNotEmpty) {
      return nameParts.first[0].toUpperCase();
    } else {
      return '?';
    }
  }
} 
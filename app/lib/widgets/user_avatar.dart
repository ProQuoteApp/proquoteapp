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
  
  /// Static method to clear the entire image cache
  static void clearAllImageCache() {
    try {
      CachedNetworkImage.evictFromCache('');
      debugPrint('Cleared all image caches');
    } catch (e) {
      debugPrint('Error clearing all image caches: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // First try to use the Firestore profile image
    final profileUrl = user?.profileImageUrl;
    
    // If no Firestore profile, try to use the auth user photo URL
    final authPhotoUrl = authUser?.photoURL;
    
    final imageUrl = profileUrl ?? authPhotoUrl;
    
    debugPrint('UserAvatar: Building avatar with imageUrl: $imageUrl');
    
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
      debugPrint('UserAvatar: No image URL, showing initials: $initials');
      return _buildInitialsAvatar(initials, context);
    }
    
    // Simple URL validation
    bool isValidUrl = false;
    try {
      final uri = Uri.parse(imageUrl);
      isValidUrl = uri.isAbsolute && 
                  (uri.scheme == 'http' || uri.scheme == 'https') && 
                  uri.host.isNotEmpty;
      
      debugPrint('UserAvatar: URL validation - isAbsolute: ${uri.isAbsolute}, scheme: ${uri.scheme}, host: ${uri.host}');
    } catch (e) {
      debugPrint('UserAvatar: Invalid image URL format: $e');
      return _buildInitialsAvatar(initials, context);
    }
    
    if (!isValidUrl) {
      debugPrint('UserAvatar: URL failed validation: $imageUrl');
      return _buildInitialsAvatar(initials, context);
    }
    
    debugPrint('UserAvatar: Loading image from URL: $imageUrl');
    
    // Use CachedNetworkImage with fallback
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        placeholder: (context, url) {
          debugPrint('UserAvatar: Showing placeholder for: $url');
          return _buildInitialsAvatar(initials, context);
        },
        errorWidget: (context, url, error) {
          debugPrint('UserAvatar: Error loading profile image: $error for URL: $url');
          // Clear the cache for this URL to prevent future errors
          _clearImageCache(url);
          return _buildInitialsAvatar(initials, context);
        },
      ),
    );
  }
  
  /// Clear the image cache for a specific URL
  void _clearImageCache(String url) {
    try {
      CachedNetworkImage.evictFromCache(url);
      debugPrint('UserAvatar: Cleared cache for image: $url');
    } catch (e) {
      debugPrint('UserAvatar: Error clearing image cache: $e');
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
    if (user?.name != null && user!.name!.isNotEmpty) {
      displayName = user!.name;
      debugPrint('UserAvatar: Using user.name: $displayName');
    } else if (authUser?.displayName != null && (authUser?.displayName as String).isNotEmpty) {
      displayName = authUser!.displayName as String;
      debugPrint('UserAvatar: Using authUser.displayName: $displayName');
    } else if (user?.email != null && user!.email!.isNotEmpty) {
      displayName = user!.email;
      debugPrint('UserAvatar: Using user.email: $displayName');
    } else if (authUser?.email != null && (authUser?.email as String).isNotEmpty) {
      displayName = authUser!.email as String;
      debugPrint('UserAvatar: Using authUser.email: $displayName');
    } else {
      debugPrint('UserAvatar: No name or email found');
    }
    
    // If no name is found, return a question mark
    if (displayName == null || displayName.isEmpty) {
      debugPrint('UserAvatar: No display name, returning ?');
      return '?';
    }
    
    // If email is used, get the part before @
    if (displayName.contains('@')) {
      displayName = displayName.split('@').first;
      debugPrint('UserAvatar: Extracted name from email: $displayName');
    }
    
    final nameParts = displayName.trim().split(' ');
    if (nameParts.length > 1) {
      final initials = '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
      debugPrint('UserAvatar: Generated initials from full name: $initials');
      return initials;
    } else if (nameParts.isNotEmpty && nameParts.first.isNotEmpty) {
      final initial = nameParts.first[0].toUpperCase();
      debugPrint('UserAvatar: Generated initial from single name: $initial');
      return initial;
    } else {
      debugPrint('UserAvatar: No valid name parts, returning ?');
      return '?';
    }
  }
} 
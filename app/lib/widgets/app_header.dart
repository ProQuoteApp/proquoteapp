import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:proquote/providers/auth_provider.dart';
import 'package:proquote/providers/user_provider.dart';
import 'package:proquote/widgets/user_avatar.dart';
import 'package:proquote/utils/constants.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? additionalActions;
  final Widget? leading;
  final bool showBackButton;
  final bool showAvatar;
  final bool showNotifications;
  final VoidCallback? onBackPressed;

  const AppHeader({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.additionalActions,
    this.leading,
    this.showBackButton = false,
    this.showAvatar = true,
    this.showNotifications = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = userProvider.currentUser;
    final authUser = authProvider.currentUser;

    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      leading: showBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => context.pop(),
            )
          : leading,
      actions: [
        if (showNotifications)
          ShadIconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
        if (showAvatar)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                context.go('/profile');
              },
              child: UserAvatar(
                user: user,
                authUser: authUser,
                radius: AppConstants.smallAvatarRadius,
              ),
            ),
          ),
        if (additionalActions != null) ...additionalActions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 
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
    final theme = ShadTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          elevation: 0,
          backgroundColor: theme.colorScheme.background,
          foregroundColor: theme.colorScheme.foreground,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
          centerTitle: centerTitle,
          leading: showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22,
                    color: theme.colorScheme.foreground,
                  ),
                  onPressed: onBackPressed ?? () => context.pop(),
                  tooltip: 'Back',
                )
              : leading,
          actions: [
            if (showNotifications)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: theme.colorScheme.foreground,
                  ),
                  onPressed: () {
                    // Navigate to notifications
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications coming soon')),
                    );
                  },
                  tooltip: 'Notifications',
                ),
              ),
            if (additionalActions != null) ...additionalActions!,
            if (showAvatar)
              Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 8.0),
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
          ],
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: theme.colorScheme.border.withOpacity(0.2),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
} 
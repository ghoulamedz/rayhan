//UNUSED
import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.searchHint = 'Rechercher un ordre, un stock...',
    this.notificationCount = 3,
    required this.isAppBarVisible,
    this.onToggleSidebar,
    this.onNotificationTap,
  });

  final String searchHint;
  final int notificationCount;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onNotificationTap;
  final bool isAppBarVisible;
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              offset: isAppBarVisible ? Offset.zero : const Offset(0, -1),
              child: Container(
                height: 64,
                decoration: const BoxDecoration(
                  color: AppTheme.whiteSurface,
                  border: Border(bottom: BorderSide(color: Colors.black)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp24),
                child: Row(
                  children: [
                    if (onToggleSidebar != null) ...[
                      IconButton(
                        onPressed: onToggleSidebar,
                        icon: const Icon(Icons.menu_rounded),
                        color: Colors.black,
                        iconSize: 20,
                      ),
                      const SizedBox(width: AppTheme.sp8),
                    ],
                    // Search bar
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: searchHint,
                            prefixIcon:
                                const Icon(Icons.search_rounded, size: 18),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Notification bell
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          onPressed: onNotificationTap,
                          icon: const Icon(Icons.notifications_outlined),
                          iconSize: 22,
                          color: AppTheme.greyLight,
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppTheme.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '$notificationCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.history_rounded),
                      iconSize: 22,
                      color: AppTheme.greyLight,
                    ),
                    const SizedBox(width: AppTheme.sp8),
                    // User avatar
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black,
                      child: Text(
                        'USER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}

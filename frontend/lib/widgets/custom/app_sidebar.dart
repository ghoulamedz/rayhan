import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Navigation items definition
// ──────────────────────────────────────────────────────────────────────────────

enum NavSection { main, settings }

class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.section = NavSection.main,
    this.badgeCount,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final NavSection section;
  final int? badgeCount;
}

const List<NavItem> kNavItems = [
  NavItem(
    id: 'dashboard',
    label: 'Tableau de Bord',
    icon: Icons.dashboard_outlined,
    activeIcon: Icons.dashboard_rounded,
  ),
  NavItem(
    id: 'ventes',
    label: 'Gestion des Ventes',
    icon: Icons.shopping_cart_outlined,
    activeIcon: Icons.shopping_cart_rounded,
  ),
  NavItem(
    id: 'production',
    label: 'Suivi de Production',
    icon: Icons.precision_manufacturing_outlined,
    activeIcon: Icons.precision_manufacturing_rounded,
  ),
  NavItem(
    id: 'inventaire',
    label: 'Stocks & Matières',
    icon: Icons.inventory_2_outlined,
    activeIcon: Icons.inventory_2_rounded,
  ),
  NavItem(
    id: 'achats',
    label: 'Achats & Fournisseurs',
    icon: Icons.local_shipping_outlined,
    activeIcon: Icons.local_shipping_rounded,
  ),
  NavItem(
    id: 'maintenance',
    label: 'Maintenance Préventive',
    icon: Icons.build_outlined,
    activeIcon: Icons.build_rounded,
  ),
  NavItem(
    id: 'qualite',
    label: 'Contrôle Qualité',
    icon: Icons.fact_check_outlined,
    activeIcon: Icons.fact_check_rounded,
  ),
  NavItem(
    id: 'rapports',
    label: 'Analyses & Rapports',
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
  ),
];

const List<NavItem> kNavBottomItems = [
  NavItem(
    id: 'parametres',
    label: 'Paramètres',
    icon: Icons.settings_outlined,
    activeIcon: Icons.settings_rounded,
    section: NavSection.settings,
  ),
  NavItem(
    id: 'assistance',
    label: 'Assistance',
    icon: Icons.help_outline_rounded,
    activeIcon: Icons.help_rounded,
    section: NavSection.settings,
  ),
];

// ──────────────────────────────────────────────────────────────────────────────
// AppSidebar
// ──────────────────────────────────────────────────────────────────────────────

/// Left-side navigation panel matching the dark ERP sidebar in the mockups.
///
/// Pass the currently selected [selectedId] and an [onSelect] callback.
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selectedId,
    required this.onSelect,
    this.collapsed = false,
  });

  final String selectedId;
  final ValueChanged<String> onSelect;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final width =
        collapsed ? AppTheme.sidebarCollapsedWidth : AppTheme.sidebarWidth;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      color: AppTheme.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SidebarLogo(collapsed: collapsed),
          const SizedBox(height: AppTheme.sp8),
          _UserTile(collapsed: collapsed),
          const SizedBox(height: AppTheme.sp16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: collapsed ? 8 : AppTheme.sp12,
              ),
              children: kNavItems
                  .map(
                    (item) => _NavTile(
                      item: item,
                      isSelected: item.id == selectedId,
                      onTap: () => onSelect(item.id),
                      collapsed: collapsed,
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 8 : AppTheme.sp12,
              vertical: AppTheme.sp8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: kNavBottomItems
                  .map(
                    (item) => _NavTile(
                      item: item,
                      isSelected: item.id == selectedId,
                      onTap: () => onSelect(item.id),
                      collapsed: collapsed,
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppTheme.sp8),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Internal sidebar sub-widgets
// ──────────────────────────────────────────────────────────────────────────────

class _SidebarLogo extends StatelessWidget {
  const _SidebarLogo({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: collapsed ? 12 : AppTheme.sp20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.precision_manufacturing_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: AppTheme.sp12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RayhanERP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'La société Rayhan',
                  style: TextStyle(
                    color: AppTheme.sidebarText,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: collapsed ? 8 : AppTheme.sp12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp12,
        vertical: AppTheme.sp8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.sidebarHover,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary,
            child: const Text(
              'JD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: AppTheme.sp8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Jean Dupont',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Contremaître Principal',
                    style: TextStyle(
                      color: AppTheme.sidebarText,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.collapsed,
  });

  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Tooltip(
        message: collapsed ? item.label : '',
        //placement: TooltipPlacement.right,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 12 : AppTheme.sp12,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.sidebarHover : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 18,
                  color:
                      isSelected ? AppTheme.primaryLight : AppTheme.sidebarText,
                ),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.sidebarText,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.badgeCount != null) _Badge(count: item.badgeCount!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppTheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// AppTopBar
// ──────────────────────────────────────────────────────────────────────────────

/// Top application bar with search, notification bell, history, and user avatar.
// class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
//   const AppTopBar({
//     super.key,
//     this.searchHint = 'Rechercher un ordre, un stock...',
//     this.notificationCount = 3,
//     this.onToggleSidebar,
//     this.onNotificationTap,
//   });

//   final String searchHint;
//   final int notificationCount;
//   final VoidCallback? onToggleSidebar;
//   final VoidCallback? onNotificationTap;

//   @override
//   Size get preferredSize => const Size.fromHeight(64);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 64,
//       decoration: const BoxDecoration(
//         color: AppTheme.surface,
//         border: Border(bottom: BorderSide(color: AppTheme.border)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp24),
//       child: Row(
//         children: [
//           if (onToggleSidebar != null) ...[
//             IconButton(
//               onPressed: onToggleSidebar,
//               icon: const Icon(Icons.menu_rounded),
//               color: AppTheme.textSecondary,
//               iconSize: 20,
//             ),
//             const SizedBox(width: AppTheme.sp8),
//           ],
//           // Search bar
//           Expanded(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 480),
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: searchHint,
//                   prefixIcon: const Icon(Icons.search_rounded, size: 18),
//                   isDense: true,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 10,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const Spacer(),
//           // Notification bell
//           Stack(
//             clipBehavior: Clip.none,
//             children: [
//               IconButton(
//                 onPressed: onNotificationTap,
//                 icon: const Icon(Icons.notifications_outlined),
//                 iconSize: 22,
//                 color: AppTheme.textSecondary,
//               ),
//               if (notificationCount > 0)
//                 Positioned(
//                   top: 6,
//                   right: 6,
//                   child: Container(
//                     width: 16,
//                     height: 16,
//                     decoration: const BoxDecoration(
//                       color: AppTheme.error,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Text(
//                         '$notificationCount',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 9,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.history_rounded),
//             iconSize: 22,
//             color: AppTheme.textSecondary,
//           ),
//           const SizedBox(width: AppTheme.sp8),
//           // User avatar
//           CircleAvatar(
//             radius: 18,
//             backgroundColor: AppTheme.primary,
//             child: const Text(
//               'USER',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

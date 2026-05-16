import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  auth.isAuthenticated ? auth.user ?? 'VISITEUR' : 'VISITEUR',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  auth.role?.replaceAll('ROLE_', '') ?? 'VISITEUR',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Tableau de bord',
            route: '/dashboard',
            current: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.inventory_2_outlined,
            label: 'Articles',
            route: '/articles',
            current: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.shopping_cart_outlined,
            label: 'Ventes',
            route: '/ventes',
            current: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.local_shipping_outlined,
            label: 'Achats',
            route: '/achats',
            current: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.precision_manufacturing_outlined,
            label: 'Production',
            route: '/production',
            current: currentRoute,
          ),
          _DrawerItem(
            icon: Icons.warehouse_outlined,
            label: 'Stock',
            route: '/stock',
            current: currentRoute,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await auth.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == route;
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF374151);

    return ListTile(
      selected: selected,
      selectedTileColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.08),
      leading: Icon(icon, color: color),
      title: Text(label,
          style: TextStyle(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.pop(context);
        if (current != route) context.go(route);
      },
    );
  }
}

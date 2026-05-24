import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';

class BrandAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String currentRoute;
  final List<Widget>? actions;

  const BrandAppBar({
    super.key,
    required this.title,
    this.subtitle,
    required this.currentRoute,
    this.actions,
  });

  static double heightFor(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w > 900 ? 112 : kToolbarHeight + 12;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isDesktop = w > 900;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.kSurfaceWhite,
        boxShadow: [
          BoxShadow(
            color: AppTheme.kBlack.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDesktop) _buildBrandingRow(context),
          _buildTitleRow(context, isDesktop),
        ],
      ),
    );
  }

  Widget _buildBrandingRow(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.isAuthenticated ? (auth.user ?? 'Utilisateur') : 'Visiteur';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: const BoxDecoration(gradient: AppTheme.kPrimaryGradient),
      child: Row(
        children: [
          Builder(builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            color: AppTheme.kWhite,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Menu',
            iconSize: 20,
          )),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.kWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/images/rayhan_icon.png',
              width: 22,
              height: 22,
              color: AppTheme.kWhite,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Rayhan ERP',
            style: TextStyle(
              color: AppTheme.kWhite,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Icon(Icons.person_outline_rounded,
              color: AppTheme.kWhite.withValues(alpha: 0.8), size: 18),
          const SizedBox(width: 6),
          Text(
            userName,
            style: TextStyle(
              color: AppTheme.kWhite.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context, bool isDesktop) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24 : 4,
        vertical: 6,
      ),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              color: AppTheme.kTextPrimary,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              tooltip: 'Menu',
            )),
          if (!isDesktop) const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    style: AppTheme.titleMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle!,
                        style: AppTheme.bodySmall
                            .copyWith(color: AppTheme.kTextSecondary)),
                  ),
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

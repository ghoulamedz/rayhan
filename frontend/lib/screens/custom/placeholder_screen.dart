import 'package:flutter/material.dart';
import 'package:rayhan_erp/theme/app_theme.dart';

/// Stub screen shown for navigation items that are not yet implemented.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.navId});

  final String navId;

  static const Map<String, (IconData, String)> _meta = {
    'maintenance': (Icons.build_rounded, 'Maintenance Préventive'),
    'qualite': (Icons.fact_check_rounded, 'Contrôle Qualité'),
    'rapports': (Icons.bar_chart_rounded, 'Analyses & Rapports'),
    'parametres': (Icons.settings_rounded, 'Paramètres'),
    'assistance': (Icons.help_rounded, 'Assistance'),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, label) = _meta[navId] ?? (Icons.web_asset_outlined, navId);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radius2xl),
            ),
            child: Icon(icon, size: 32, color: AppTheme.textMuted),
          ),
          const SizedBox(height: AppTheme.sp16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.sp8),
          const Text(
            'Ce module est en cours de développement.',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: AppTheme.sp24),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Demander accès anticipé'),
          ),
        ],
      ),
    );
  }
}

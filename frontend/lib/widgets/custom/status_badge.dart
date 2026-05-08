import 'package:flutter/material.dart';
import '../../models/mock/index.dart';
import '../../theme/app_theme.dart';

/// A compact colored pill badge for displaying status labels.
///
/// Use the named constructors for typed model statuses:
/// ```dart
/// StatusBadge.fromCommande(statut: StatutCommande.valide)
/// StatusBadge.fromProduction(statut: StatutProduction.enCours)
/// StatusBadge.fromAchat(statut: StatutAchat.livre)
/// ```
/// Or the generic constructor for custom labels:
/// ```dart
/// StatusBadge(label: 'Actif', color: AppTheme.success)
/// ```
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
  });

  factory StatusBadge.fromCommande({
    Key? key,
    required StatutCommande statut,
  }) {
    final (color, bg) = _commandeColors(statut);
    return StatusBadge(
        key: key, label: statut.label, color: color, backgroundColor: bg);
  }

  factory StatusBadge.fromProduction({
    Key? key,
    required StatutProduction statut,
  }) {
    final (color, bg) = _productionColors(statut);
    return StatusBadge(
        key: key, label: statut.label, color: color, backgroundColor: bg);
  }

  factory StatusBadge.fromAchat({
    Key? key,
    required StatutAchat statut,
  }) {
    final (color, bg) = _achatColors(statut);
    return StatusBadge(
        key: key, label: statut.label, color: color, backgroundColor: bg);
  }

  factory StatusBadge.operational() => const StatusBadge(
        label: 'Opérationnel',
        color: AppTheme.success,
        backgroundColor: AppTheme.successSurface,
        icon: Icons.check_circle_outline_rounded,
      );

  factory StatusBadge.alert({required String label}) => StatusBadge(
        label: label,
        color: AppTheme.error,
        backgroundColor: AppTheme.errorSurface,
        icon: Icons.warning_amber_rounded,
      );

  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static (Color, Color) _commandeColors(StatutCommande s) => switch (s) {
        StatutCommande.valide => (AppTheme.success, AppTheme.successSurface),
        StatutCommande.livre => (AppTheme.info, AppTheme.infoSurface),
        StatutCommande.enCours => (AppTheme.warning, AppTheme.warningSurface),
        StatutCommande.annule => (AppTheme.error, AppTheme.errorSurface),
      };

  static (Color, Color) _productionColors(StatutProduction s) => switch (s) {
        StatutProduction.enCours => (AppTheme.primary, AppTheme.primarySurface),
        StatutProduction.planifie => (
            AppTheme.textMuted,
            AppTheme.surfaceVariant
          ),
        StatutProduction.termine => (AppTheme.success, AppTheme.successSurface),
        StatutProduction.annule => (AppTheme.error, AppTheme.errorSurface),
      };

  static (Color, Color) _achatColors(StatutAchat s) => switch (s) {
        StatutAchat.livre => (AppTheme.success, AppTheme.successSurface),
        StatutAchat.enCours => (AppTheme.info, AppTheme.infoSurface),
        StatutAchat.livraisonPartielle => (
            AppTheme.warning,
            AppTheme.warningSurface
          ),
        StatutAchat.refuse || StatutAchat.annule => (
            AppTheme.error,
            AppTheme.errorSurface
          ),
      };
}

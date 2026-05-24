//UNUSED
import 'package:flutter/material.dart';
import '../../models/mock/index.dart';
import '../../constants/app_theme.dart';

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
/// StatusBadge(label: 'Actif', color: AppTheme.greenBright)
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
        color: AppTheme.greenBright,
        backgroundColor: AppTheme.greenLight,
        icon: Icons.check_circle_outline_rounded,
      );

  factory StatusBadge.alert({required String label}) => StatusBadge(
        label: label,
        color: AppTheme.red,
        backgroundColor: AppTheme.red,
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
        borderRadius: BorderRadius.circular(6),
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
        StatutCommande.valide => (AppTheme.greenBright, AppTheme.greenLight),
        StatutCommande.livre => (AppTheme.blueLight, AppTheme.blueLightest),
        StatutCommande.enCours => (AppTheme.yellow, AppTheme.yellow),
        StatutCommande.annule => (AppTheme.red, AppTheme.red),
      };

  static (Color, Color) _productionColors(StatutProduction s) => switch (s) {
        StatutProduction.enCours => (Colors.black, Colors.black),
        StatutProduction.planifie => (
            AppTheme.greyLight,
            AppTheme.whiteSurface2
          ),
        StatutProduction.termine => (AppTheme.greenBright, AppTheme.greenLight),
        StatutProduction.annule => (AppTheme.red, AppTheme.red),
      };

  static (Color, Color) _achatColors(StatutAchat s) => switch (s) {
        StatutAchat.livre => (AppTheme.greenBright, AppTheme.greenLight),
        StatutAchat.enCours => (AppTheme.blueLight, AppTheme.blueLightest),
        StatutAchat.livraisonPartielle => (AppTheme.yellow, AppTheme.yellow),
        StatutAchat.refuse || StatutAchat.annule => (
            AppTheme.red,
            AppTheme.red
          ),
      };
}

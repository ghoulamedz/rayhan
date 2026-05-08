import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rayhan_erp/models/mock/mock_data.dart';
import 'dart:ui' as ui;

import 'package:rayhan_erp/models/mock/models.dart';
import 'package:rayhan_erp/theme/app_theme.dart';
import 'package:rayhan_erp/widgets/custom/dialogs.dart';
import 'package:rayhan_erp/widgets/custom/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/responsive.dart';
import 'package:rayhan_erp/widgets/custom/stat_card.dart';

/// "Contrôle Qualité" screen — inspection history, defect rate trends,
/// and non-conformity management.
class QualiteScreen extends StatefulWidget {
  const QualiteScreen({super.key});

  @override
  State<QualiteScreen> createState() => _QualiteScreenState();
}

class _QualiteScreenState extends State<QualiteScreen> {
  Inspection? _selected;

  @override
  void initState() {
    super.initState();
    _selected = MockData.inspections.first;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────
          ScreenHeader(
            title: 'Contrôle Qualité',
            subtitle: 'Inspections, non-conformités et taux de défauts.',
            actions: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 14),
                label: const Text('Rapport Qualité'),
              ),
              ElevatedButton.icon(
                onPressed: () => _showNewInspectionDialog(context),
                icon: const Icon(Icons.add_rounded, size: 14),
                label: const Text('Nouvelle Inspection'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // ── KPIs ───────────────────────────────────────────────────────
          _KpiRow(),
          const SizedBox(height: AppTheme.sp24),

          // ── Defect trend + statut breakdown ───────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _DefectTrendCard()),
              const SizedBox(width: AppTheme.sp20),
              Expanded(flex: 2, child: _StatutBreakdown()),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // ── Inspection table + detail ──────────────────────────────────
          AdaptiveLayout(
            breakpoint: 960,
            expanded: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _InspectionTable(
                    inspections: MockData.inspections,
                    selected: _selected,
                    onSelect: (i) => setState(() => _selected = i),
                  ),
                ),
                if (_selected != null) ...[
                  const SizedBox(width: AppTheme.sp20),
                  Expanded(
                      flex: 2,
                      child: _InspectionDetail(inspection: _selected!)),
                ],
              ],
            ),
            stacked: Column(
              children: [
                _InspectionTable(
                  inspections: MockData.inspections,
                  selected: _selected,
                  onSelect: (i) => setState(() => _selected = i),
                ),
                if (_selected != null) ...[
                  const SizedBox(height: AppTheme.sp16),
                  _InspectionDetail(inspection: _selected!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNewInspectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _NewInspectionDialog(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// KPI Row
// ──────────────────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final insp = MockData.inspections;
    final conformes =
        insp.where((i) => i.statut == StatutInspection.conforme).length;
    final nonConformes =
        insp.where((i) => i.statut == StatutInspection.nonConforme).length;
    final avgDefaut = insp.isEmpty
        ? 0.0
        : insp.map((i) => i.tauxDefaut).reduce((a, b) => a + b) / insp.length;
    final enAttente =
        insp.where((i) => i.statut == StatutInspection.enAttente).length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Lots conformes',
            value: '$conformes / ${insp.length}',
            subtitle: 'Ce mois-ci',
            icon: Icons.verified_outlined,
            iconColor: AppTheme.success,
            iconBackground: AppTheme.successSurface,
          ),
        ),
        const SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'Non-conformités',
            value: '$nonConformes',
            subtitle: 'Lots rejetés',
            alertLevel: nonConformes > 0 ? 'error' : null,
            icon: Icons.cancel_outlined,
            iconColor: AppTheme.error,
            iconBackground: AppTheme.errorSurface,
          ),
        ),
        const SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'Taux défaut moyen',
            value: '${(avgDefaut * 100).toStringAsFixed(2)}%',
            subtitle: 'Objectif: < 2%',
            icon: Icons.bar_chart_rounded,
            iconColor: AppTheme.info,
            iconBackground: AppTheme.infoSurface,
          ),
        ),
        const SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'En attente validation',
            value: '$enAttente',
            subtitle: 'Nécessite inspection',
            alertLevel: enAttente > 0 ? 'warning' : null,
            icon: Icons.pending_outlined,
            iconColor: AppTheme.warning,
            iconBackground: AppTheme.warningSurface,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Defect trend chart (custom painter — bar per inspection)
// ──────────────────────────────────────────────────────────────────────────────

class _DefectTrendCard extends StatelessWidget {
  // Simulated 7-day defect rates
  static const _labels = ['J-6', 'J-5', 'J-4', 'J-3', 'J-2', 'J-1', 'Auj.'];
  static const _values = [1.4, 2.1, 1.8, 3.2, 1.6, 2.8, 1.47];
  static const _targetLine = 2.0; // 2% target

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Évolution Taux de Défaut (7 jours)',
      subtitle: 'Pourcentage défauts / échantillon — seuil: 2.0%',
      child: SizedBox(
        height: 200,
        child: Column(
          children: [
            Expanded(
              child: CustomPaint(
                painter:
                    _DefectBarPainter(values: _values, target: _targetLine),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: AppTheme.sp8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _labels
                  .map((l) => Text(l,
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textMuted)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefectBarPainter extends CustomPainter {
  const _DefectBarPainter({required this.values, required this.target});
  final List<double> values;
  final double target;

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = values.reduce((a, b) => a > b ? a : b) * 1.2;
    final barW = (size.width / values.length) * 0.55;
    final gap = size.width / values.length;
    final h = size.height - 4;

    // target line
    final ty = h - (target / maxV) * h;
    canvas.drawLine(
      Offset(0, ty),
      Offset(size.width, ty),
      Paint()
        ..color = AppTheme.error.withOpacity(0.4)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    for (var i = 0; i < values.length; i++) {
      final frac = (values[i] / maxV).clamp(0.0, 1.0);
      final bh = frac * h;
      final x = gap * i + (gap - barW) / 2;
      final overTarget = values[i] > target;
      final color = overTarget ? AppTheme.error : AppTheme.primary;
      final isLast = i == values.length - 1;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, h - bh, barW, bh),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = isLast ? color : color.withOpacity(0.65)
          ..style = PaintingStyle.fill,
      );

      // value label
      final tp = TextPainter(
        text: TextSpan(
          text: '${values[i]}%',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: overTarget ? AppTheme.error : AppTheme.textSecondary,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(
          canvas, Offset(x + (barW - tp.width) / 2, h - bh - tp.height - 2));
    }
  }

  @override
  bool shouldRepaint(_DefectBarPainter old) => old.values != values;
}

// ──────────────────────────────────────────────────────────────────────────────
// Statut breakdown
// ──────────────────────────────────────────────────────────────────────────────

class _StatutBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final insp = MockData.inspections;
    final counts = {
      for (final s in StatutInspection.values)
        s: insp.where((i) => i.statut == s).length,
    };
    final total = insp.length;

    return AppCard(
      title: 'Répartition Inspections',
      subtitle: '$total inspections ce mois',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: StatutInspection.values.map((s) {
          final count = counts[s] ?? 0;
          final pct = total > 0 ? count / total : 0.0;
          final color = _statutColor(s);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.sp12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(s.label,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary)),
                    ),
                    Text(
                      '$count (${(pct * 100).round()}%)',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _statutColor(StatutInspection s) => switch (s) {
        StatutInspection.conforme => AppTheme.success,
        StatutInspection.nonConforme => AppTheme.error,
        StatutInspection.enAttente => AppTheme.warning,
        StatutInspection.conditionnel => AppTheme.info,
      };
}

// ──────────────────────────────────────────────────────────────────────────────
// Inspection table
// ──────────────────────────────────────────────────────────────────────────────

class _InspectionTable extends StatelessWidget {
  const _InspectionTable({
    required this.inspections,
    required this.selected,
    required this.onSelect,
  });
  final List<Inspection> inspections;
  final Inspection? selected;
  final ValueChanged<Inspection> onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Journal des Inspections',
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TableHeader(),
          ...inspections.map((i) => _InspectionRow(
                insp: i,
                isSelected: i.id == selected?.id,
                onTap: () => onSelect(i),
              )),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppTheme.textMuted,
        letterSpacing: 0.5);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp20, vertical: AppTheme.sp10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border))),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('RÉFÉRENCE', style: style)),
          Expanded(flex: 3, child: Text('PRODUIT', style: style)),
          Expanded(flex: 2, child: Text('DATE', style: style)),
          Expanded(flex: 2, child: Text('STATUT', style: style)),
          Expanded(
              flex: 1,
              child: Text('DÉFAUTS', style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _InspectionRow extends StatelessWidget {
  const _InspectionRow(
      {required this.insp, required this.isSelected, required this.onTap});
  final Inspection insp;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defautPct = (insp.tauxDefaut * 100).toStringAsFixed(2);
    final (badgeColor, badgeBg) = _statutStyle(insp.statut);

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primarySurface : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppTheme.divider)),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp20, vertical: AppTheme.sp14),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(insp.id,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary)),
            ),
            Expanded(
              flex: 3,
              child: Text(insp.produitDesignation,
                  style: theme.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('dd/MM/yy').format(insp.dateInspection),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                          color: badgeColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(insp.statut.label,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: badgeColor)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '$defautPct%',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: insp.tauxDefaut > 0.02
                      ? AppTheme.error
                      : AppTheme.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (Color, Color) _statutStyle(StatutInspection s) => switch (s) {
        StatutInspection.conforme => (
            AppTheme.success,
            AppTheme.successSurface
          ),
        StatutInspection.nonConforme => (AppTheme.error, AppTheme.errorSurface),
        StatutInspection.enAttente => (
            AppTheme.warning,
            AppTheme.warningSurface
          ),
        StatutInspection.conditionnel => (AppTheme.info, AppTheme.infoSurface),
      };
}

// ──────────────────────────────────────────────────────────────────────────────
// Inspection detail panel
// ──────────────────────────────────────────────────────────────────────────────

class _InspectionDetail extends StatelessWidget {
  const _InspectionDetail({required this.inspection});
  final Inspection inspection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('dd MMM. yyyy – HH:mm');
    final defautPct = (inspection.tauxDefaut * 100).toStringAsFixed(2);
    final isOk = inspection.tauxDefaut <= 0.02;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(inspection.id,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(color: AppTheme.primary)),
              ),
              _statusBadge(inspection.statut),
            ],
          ),
          const SizedBox(height: AppTheme.sp4),
          Text(inspection.produitDesignation,
              style: theme.textTheme.titleLarge),
          const SizedBox(height: AppTheme.sp4),
          Text('LOT: ${inspection.lotReference}',
              style: theme.textTheme.bodySmall),
          const SizedBox(height: AppTheme.sp16),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.sp16),

          // Defect rate gauge
          Center(
            child: Column(
              children: [
                Text(
                  '$defautPct%',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: isOk ? AppTheme.success : AppTheme.error,
                  ),
                ),
                Text('taux de défaut', style: theme.textTheme.bodySmall),
                const SizedBox(height: AppTheme.sp8),
                SizedBox(
                  width: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: inspection.tauxDefaut.clamp(0.0, 0.1) / 0.1,
                      minHeight: 8,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isOk ? AppTheme.success : AppTheme.error),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sp20),

          // Metrics
          InfoRow(label: 'Inspecteur', value: inspection.inspecteur),
          InfoRow(label: 'Date', value: fmt.format(inspection.dateInspection)),
          InfoRow(
              label: 'Échantillon',
              value: '${inspection.echantillonSize} unités'),
          InfoRow(
              label: 'Défauts',
              value: '${inspection.defautsDetectes} détectés'),
          InfoRow(
              label: 'Tolérance',
              value:
                  '+${inspection.tolerancePositive} / -${inspection.toleranceNegative} mm'),
          InfoRow(
              label: 'Mesure réelle', value: '${inspection.mesureReelle} mm'),

          if (inspection.commentaire.isNotEmpty) ...[
            const SizedBox(height: AppTheme.sp16),
            const Text('COMMENTAIRE',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.6)),
            const SizedBox(height: AppTheme.sp8),
            Container(
              padding: const EdgeInsets.all(AppTheme.sp12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Text(
                inspection.commentaire,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(height: 1.5, color: AppTheme.textPrimary),
              ),
            ),
          ],
          const SizedBox(height: AppTheme.sp20),

          // Actions
          if (inspection.statut == StatutInspection.enAttente)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check_rounded, size: 15),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success),
                  ),
                ),
                const SizedBox(width: AppTheme.sp8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close_rounded, size: 15),
                    label: const Text('Rejeter'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.error),
                  ),
                ),
              ],
            ),
          if (inspection.statut == StatutInspection.nonConforme)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.assignment_outlined, size: 15),
                label: const Text('Ouvrir fiche NC'),
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(StatutInspection s) {
    final color = switch (s) {
      StatutInspection.conforme => AppTheme.success,
      StatutInspection.nonConforme => AppTheme.error,
      StatutInspection.enAttente => AppTheme.warning,
      StatutInspection.conditionnel => AppTheme.info,
    };
    final bg = switch (s) {
      StatutInspection.conforme => AppTheme.successSurface,
      StatutInspection.nonConforme => AppTheme.errorSurface,
      StatutInspection.enAttente => AppTheme.warningSurface,
      StatutInspection.conditionnel => AppTheme.infoSurface,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
      child: Text(s.label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// New Inspection Dialog
// ──────────────────────────────────────────────────────────────────────────────

class _NewInspectionDialog extends StatefulWidget {
  const _NewInspectionDialog();

  @override
  State<_NewInspectionDialog> createState() => _NewInspectionDialogState();
}

class _NewInspectionDialogState extends State<_NewInspectionDialog> {
  final _form = GlobalKey<FormState>();
  final _lot = TextEditingController();
  final _inspecteur = TextEditingController();
  final _echantillon = TextEditingController(text: '100');
  final _defauts = TextEditingController(text: '0');
  String? _produitId;

  @override
  void dispose() {
    _lot.dispose();
    _inspecteur.dispose();
    _echantillon.dispose();
    _defauts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Nouvelle Inspection',
      subtitle: 'Enregistrer un contrôle qualité sur un lot de production.',
      icon: Icons.fact_check_outlined,
      iconColor: AppTheme.info,
      width: 540,
      actions: [
        OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler')),
        ElevatedButton(onPressed: _submit, child: const Text('Enregistrer')),
      ],
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormSectionLabel('Identification lot'),
            FormRow(
              left: ErpTextField(
                label: 'Référence lot',
                required: true,
                controller: _lot,
                hint: 'LOT-2023-XXX',
                prefixIcon: Icons.inventory_2_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
              right: ErpDropdown<String>(
                label: 'Produit',
                required: true,
                value: _produitId,
                hint: 'Sélectionner...',
                onChanged: (v) => setState(() => _produitId = v),
                items: MockData.produits
                    .map((p) => DropdownMenuItem(
                        value: p.id, child: Text(p.designation)))
                    .toList(),
              ),
            ),
            const FormGap(),
            const FormSectionLabel('Mesures'),
            FormRow(
              left: ErpTextField(
                label: 'Taille échantillon',
                required: true,
                controller: _echantillon,
                keyboardType: TextInputType.number,
                suffixText: 'unités',
              ),
              right: ErpTextField(
                label: 'Défauts détectés',
                required: true,
                controller: _defauts,
                keyboardType: TextInputType.number,
                suffixText: 'pcs',
              ),
            ),
            const FormGap(),
            ErpTextField(
              label: 'Inspecteur',
              required: true,
              controller: _inspecteur,
              hint: 'Nom de l\'inspecteur',
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Champ requis' : null,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_form.currentState?.validate() ?? false) {
      Navigator.of(context).pop();
      AppToast.success(context, 'Inspection enregistrée avec succès.');
    }
  }
}

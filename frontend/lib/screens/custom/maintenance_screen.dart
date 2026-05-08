import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rayhan_erp/models/mock/mock_data.dart';
import 'package:rayhan_erp/models/mock/models.dart';
import 'package:rayhan_erp/theme/app_theme.dart';
import 'package:rayhan_erp/widgets/custom/dialogs.dart';
import 'package:rayhan_erp/widgets/custom/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/responsive.dart';
import 'package:rayhan_erp/widgets/custom/stat_card.dart';

/// "Maintenance Préventive" screen — equipment fleet status,
/// maintenance order queue, and calendar-style upcoming schedule.
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);
  OrdreMaintenance? _selected;

  @override
  void initState() {
    super.initState();
    _selected = MockData.ordresMaintenance.first;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Page header ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppTheme.sp24, AppTheme.sp24, AppTheme.sp24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenHeader(
                title: 'Maintenance Préventive',
                subtitle:
                    'Gestion du parc machine et planification des interventions.',
                actions: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.calendar_month_outlined, size: 14),
                    label: const Text('Planning'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showNewOrdreDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 14),
                    label: const Text('Nouvel Ordre'),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.sp20),
              // KPIs
              _KpiRow(),
              const SizedBox(height: AppTheme.sp20),
              // Tabs
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                ),
                child: TabBar(
                  controller: _tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 2,
                  labelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w400),
                  tabs: const [
                    Tab(text: 'Parc Machine'),
                    Tab(text: 'Ordres de Travail'),
                    Tab(text: 'Calendrier'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Tab content ────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _ParcMachineTab(),
              _OrdresTab(
                selected: _selected,
                onSelect: (o) => setState(() => _selected = o),
              ),
              _CalendrierTab(),
            ],
          ),
        ),
      ],
    );
  }

  void _showNewOrdreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _NewOrdreDialog(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// KPI Row
// ──────────────────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ops =
        MockData.equipements.where((e) => e.statut == 'operationnel').length;
    final total = MockData.equipements.length;
    final critiques = MockData.ordresMaintenance
        .where((o) =>
            o.priorite == PrioriteMaintenance.critique &&
            o.statut != StatutMaintenance.terminee)
        .length;
    final enCours = MockData.ordresMaintenance
        .where((o) => o.statut == StatutMaintenance.enCours)
        .length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Machines opérationnelles',
            value: '$ops / $total',
            subtitle: 'Disponibilité du parc',
            icon: Icons.precision_manufacturing_rounded,
            iconColor: AppTheme.primary,
            iconBackground: AppTheme.primarySurface,
          ),
        ),
        const SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'Interventions en cours',
            value: '$enCours',
            subtitle: 'Techniciens mobilisés',
            icon: Icons.engineering_outlined,
            iconColor: AppTheme.info,
            iconBackground: AppTheme.infoSurface,
          ),
        ),
        const SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'Alertes critiques',
            value: '$critiques',
            subtitle: 'Action immédiate requise',
            alertLevel: critiques > 0 ? 'error' : null,
            icon: Icons.warning_amber_rounded,
            iconColor: AppTheme.error,
            iconBackground: AppTheme.errorSurface,
          ),
        ),
        const SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'OEE Moyen Parc',
            value: '${(_avgOee * 100).toStringAsFixed(1)}%',
            subtitle: 'Performance globale',
            icon: Icons.speed_rounded,
            iconColor: AppTheme.success,
            iconBackground: AppTheme.successSurface,
          ),
        ),
      ],
    );
  }

  double get _avgOee {
    final ops = MockData.equipements.where((e) => e.statut == 'operationnel');
    if (ops.isEmpty) return 0;
    return ops.map((e) => e.oeePct).reduce((a, b) => a + b) / ops.length;
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 1 — Parc Machine
// ──────────────────────────────────────────────────────────────────────────────

class _ParcMachineTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final equips = MockData.equipements;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveGrid(
            compact: 1,
            medium: 2,
            expanded: 2,
            spacing: AppTheme.sp16,
            runSpacing: AppTheme.sp16,
            children:
                equips.map((e) => _EquipementCard(equipement: e)).toList(),
          ),
        ],
      ),
    );
  }
}

class _EquipementCard extends StatelessWidget {
  const _EquipementCard({required this.equipement});
  final Equipement equipement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusColor, statusBg, statusLabel) =
        _statusStyle(equipement.statut);

    return Container(
      padding: const EdgeInsets.all(AppTheme.sp20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: equipement.alerte != null
              ? AppTheme.error.withOpacity(0.4)
              : AppTheme.border,
          width: equipement.alerte != null ? 1.5 : 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(Icons.precision_manufacturing_rounded,
                    size: 20, color: statusColor),
              ),
              const SizedBox(width: AppTheme.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(equipement.nom, style: theme.textTheme.titleMedium),
                    Text(equipement.ligne, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              _StatusPill(
                  label: statusLabel, color: statusColor, background: statusBg),
            ],
          ),

          // ── Alert ───────────────────────────────────────────────────
          if (equipement.alerte != null) ...[
            const SizedBox(height: AppTheme.sp12),
            Container(
              padding: const EdgeInsets.all(AppTheme.sp10),
              decoration: BoxDecoration(
                color: AppTheme.errorSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 14, color: AppTheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      equipement.alerte!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.error,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppTheme.sp16),

          // ── Metrics grid ─────────────────────────────────────────────
          Row(
            children: [
              _MetricChip(
                  label: 'OEE',
                  value: '${(equipement.oeePct * 100).toStringAsFixed(1)}%'),
              const SizedBox(width: AppTheme.sp8),
              _MetricChip(
                  label: 'Temp.',
                  value: '${equipement.temperatureC.toInt()}°C'),
              const SizedBox(width: AppTheme.sp8),
              _MetricChip(label: 'Vibration', value: equipement.vibration),
              const SizedBox(width: AppTheme.sp8),
              _MetricChip(
                  label: 'Cadence',
                  value: equipement.cadence > 0
                      ? '${equipement.cadence} u/min'
                      : '—'),
            ],
          ),

          const SizedBox(height: AppTheme.sp16),

          // ── Revision bar ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Révision',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.textMuted)),
                        const Spacer(),
                        Text(
                          '${equipement.heuresDepuisRevision}h / ${equipement.heuresRevisionMax}h',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: equipement.pctRevision,
                        minHeight: 6,
                        backgroundColor: AppTheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          equipement.pctRevision > 0.9
                              ? AppTheme.error
                              : equipement.pctRevision > 0.7
                                  ? AppTheme.warning
                                  : AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static (Color, Color, String) _statusStyle(String statut) => switch (statut) {
        'operationnel' => (
            AppTheme.success,
            AppTheme.successSurface,
            'Opérationnel'
          ),
        'maintenance' => (
            AppTheme.warning,
            AppTheme.warningSurface,
            'En maintenance'
          ),
        'arret' => (AppTheme.error, AppTheme.errorSurface, 'À l\'arrêt'),
        _ => (AppTheme.textMuted, AppTheme.surfaceVariant, statut),
      };
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(
      {required this.label, required this.color, required this.background});
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppTheme.sp8, horizontal: AppTheme.sp8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 2 — Ordres de Travail
// ──────────────────────────────────────────────────────────────────────────────

class _OrdresTab extends StatelessWidget {
  const _OrdresTab({required this.selected, required this.onSelect});
  final OrdreMaintenance? selected;
  final ValueChanged<OrdreMaintenance> onSelect;

  @override
  Widget build(BuildContext context) {
    final ordres = MockData.ordresMaintenance;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: AdaptiveLayout(
        breakpoint: 900,
        expanded: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _OrdresList(
                  ordres: ordres, selected: selected, onSelect: onSelect),
            ),
            const SizedBox(width: AppTheme.sp20),
            if (selected != null)
              Expanded(flex: 2, child: _OrdreDetail(ordre: selected!)),
          ],
        ),
        stacked: Column(
          children: [
            _OrdresList(ordres: ordres, selected: selected, onSelect: onSelect),
            if (selected != null) ...[
              const SizedBox(height: AppTheme.sp16),
              _OrdreDetail(ordre: selected!),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrdresList extends StatelessWidget {
  const _OrdresList(
      {required this.ordres, required this.selected, required this.onSelect});
  final List<OrdreMaintenance> ordres;
  final OrdreMaintenance? selected;
  final ValueChanged<OrdreMaintenance> onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: 'Ordres de Travail',
      trailing: Text(
        '${ordres.length} ordres',
        style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500),
      ),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: ordres
            .map((o) => _OrdreTile(
                  ordre: o,
                  isSelected: o.id == selected?.id,
                  onTap: () => onSelect(o),
                ))
            .toList(),
      ),
    );
  }
}

class _OrdreTile extends StatelessWidget {
  const _OrdreTile(
      {required this.ordre, required this.isSelected, required this.onTap});
  final OrdreMaintenance ordre;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (prioColor, prioBg) = _prioStyle(ordre.priorite);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority dot
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4),
              decoration:
                  BoxDecoration(color: prioColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppTheme.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ordre.id,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Spacer(),
                      _StatutBadgeMaint(statut: ordre.statut),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ordre.equipementNom,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ordre.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _TypeBadge(type: ordre.type),
                      const Spacer(),
                      const Icon(Icons.person_outline_rounded,
                          size: 12, color: AppTheme.textMuted),
                      const SizedBox(width: 3),
                      Text(ordre.technicien,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static (Color, Color) _prioStyle(PrioriteMaintenance p) => switch (p) {
        PrioriteMaintenance.critique => (AppTheme.error, AppTheme.errorSurface),
        PrioriteMaintenance.haute => (
            AppTheme.warning,
            AppTheme.warningSurface
          ),
        PrioriteMaintenance.moyenne => (AppTheme.info, AppTheme.infoSurface),
        PrioriteMaintenance.basse => (
            AppTheme.textMuted,
            AppTheme.surfaceVariant
          ),
      };
}

class _StatutBadgeMaint extends StatelessWidget {
  const _StatutBadgeMaint({required this.statut});
  final StatutMaintenance statut;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (statut) {
      StatutMaintenance.enCours => (AppTheme.primary, AppTheme.primarySurface),
      StatutMaintenance.planifiee => (
          AppTheme.textMuted,
          AppTheme.surfaceVariant
        ),
      StatutMaintenance.terminee => (AppTheme.success, AppTheme.successSurface),
      StatutMaintenance.annulee => (AppTheme.error, AppTheme.errorSurface),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
      child: Text(statut.label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final TypeMaintenance type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      TypeMaintenance.corrective => AppTheme.error,
      TypeMaintenance.preventive => AppTheme.primary,
      TypeMaintenance.predictive => AppTheme.info,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.label,
        style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.4),
      ),
    );
  }
}

// ── Ordre detail ──────────────────────────────────────────────────────────────

class _OrdreDetail extends StatelessWidget {
  const _OrdreDetail({required this.ordre});
  final OrdreMaintenance ordre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('dd MMM. yyyy – HH:mm');

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(ordre.id,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(color: AppTheme.primary)),
              ),
              _StatutBadgeMaint(statut: ordre.statut),
            ],
          ),
          const SizedBox(height: AppTheme.sp4),
          Text(ordre.equipementNom, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppTheme.sp16),
          const Divider(height: 1),
          const SizedBox(height: AppTheme.sp16),

          // Detail rows
          InfoRow(label: 'Type', value: ordre.type.label),
          InfoRow(label: 'Priorité', value: ordre.priorite.label),
          InfoRow(label: 'Technicien', value: ordre.technicien),
          InfoRow(label: 'Début', value: fmt.format(ordre.dateDebut)),
          if (ordre.dateFin != null)
            InfoRow(label: 'Fin', value: fmt.format(ordre.dateFin!)),
          InfoRow(label: 'Durée estimée', value: '${ordre.dureeEstimeeH}h'),
          if (ordre.pieceRequise.isNotEmpty)
            InfoRow(label: 'Pièce requise', value: ordre.pieceRequise),
          const SizedBox(height: AppTheme.sp16),

          // Description
          const Text('DESCRIPTION',
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
            child: Text(ordre.description,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(height: 1.5, color: AppTheme.textPrimary)),
          ),
          const SizedBox(height: AppTheme.sp20),

          // Actions
          Row(
            children: [
              if (ordre.statut == StatutMaintenance.planifiee)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.play_arrow_rounded, size: 16),
                    label: const Text('Démarrer'),
                  ),
                ),
              if (ordre.statut == StatutMaintenance.enCours) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Terminer'),
                  ),
                ),
                const SizedBox(width: AppTheme.sp8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.pause_rounded, size: 16),
                    label: const Text('Suspendre'),
                  ),
                ),
              ],
              if (ordre.statut == StatutMaintenance.terminee)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Rapport PDF'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 3 — Calendrier
// ──────────────────────────────────────────────────────────────────────────────

class _CalendrierTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final upcoming = MockData.ordresMaintenance
        .where((o) => o.statut != StatutMaintenance.terminee)
        .toList()
      ..sort((a, b) => a.dateDebut.compareTo(b.dateDebut));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            title: 'Interventions planifiées',
            subtitle: 'Prochaines 4 semaines',
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: upcoming.map((o) => _CalendrierTile(ordre: o)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendrierTile extends StatelessWidget {
  const _CalendrierTile({required this.ordre});
  final OrdreMaintenance ordre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prioColor = switch (ordre.priorite) {
      PrioriteMaintenance.critique => AppTheme.error,
      PrioriteMaintenance.haute => AppTheme.warning,
      PrioriteMaintenance.moyenne => AppTheme.info,
      PrioriteMaintenance.basse => AppTheme.textMuted,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp20, vertical: AppTheme.sp16),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.divider))),
      child: Row(
        children: [
          // Date block
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.sp8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(ordre.dateDebut),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('MMM').format(ordre.dateDebut),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.sp16),
          // Left accent bar
          Container(
              width: 3,
              height: 48,
              decoration: BoxDecoration(
                color: prioColor,
                borderRadius: BorderRadius.circular(2),
              )),
          const SizedBox(width: AppTheme.sp12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ordre.equipementNom, style: theme.textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(ordre.description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.sp16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatutBadgeMaint(statut: ordre.statut),
              const SizedBox(height: 4),
              Text(
                '${ordre.dureeEstimeeH}h — ${ordre.technicien}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// New Ordre Dialog
// ──────────────────────────────────────────────────────────────────────────────

class _NewOrdreDialog extends StatefulWidget {
  const _NewOrdreDialog();

  @override
  State<_NewOrdreDialog> createState() => _NewOrdreDialogState();
}

class _NewOrdreDialogState extends State<_NewOrdreDialog> {
  final _form = GlobalKey<FormState>();
  TypeMaintenance _type = TypeMaintenance.preventive;
  PrioriteMaintenance _priorite = PrioriteMaintenance.moyenne;
  final _desc = TextEditingController();
  final _tech = TextEditingController();
  final _piece = TextEditingController();

  @override
  void dispose() {
    _desc.dispose();
    _tech.dispose();
    _piece.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Nouvel Ordre de Maintenance',
      subtitle: 'Créer une intervention planifiée ou corrective.',
      icon: Icons.build_circle_outlined,
      width: 560,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Créer l\'ordre'),
        ),
      ],
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const FormSectionLabel('Identification'),
            FormRow(
              left: ErpDropdown<TypeMaintenance>(
                label: 'Type',
                required: true,
                value: _type,
                onChanged: (v) => setState(() => _type = v ?? _type),
                items: TypeMaintenance.values
                    .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.label)))
                    .toList(),
              ),
              right: ErpDropdown<PrioriteMaintenance>(
                label: 'Priorité',
                required: true,
                value: _priorite,
                onChanged: (v) => setState(() => _priorite = v ?? _priorite),
                items: PrioriteMaintenance.values
                    .map(
                        (p) => DropdownMenuItem(value: p, child: Text(p.label)))
                    .toList(),
              ),
            ),
            const FormGap(),
            ErpDropdown<String>(
              label: 'Équipement',
              required: true,
              value: null,
              onChanged: (_) {},
              hint: 'Sélectionner un équipement...',
              items: MockData.equipements
                  .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nom)))
                  .toList(),
            ),
            const FormGap(),
            const FormSectionLabel('Intervention'),
            ErpTextField(
              label: 'Description',
              required: true,
              controller: _desc,
              hint: 'Décrivez les travaux à effectuer...',
              maxLines: 3,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Champ requis' : null,
            ),
            const FormGap(),
            FormRow(
              left: ErpTextField(
                label: 'Technicien responsable',
                required: true,
                controller: _tech,
                hint: 'Nom du technicien',
                prefixIcon: Icons.person_outline_rounded,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
              right: ErpTextField(
                label: 'Durée estimée (h)',
                controller: TextEditingController(text: '2'),
                keyboardType: TextInputType.number,
                suffixText: 'heures',
              ),
            ),
            const FormGap(),
            ErpTextField(
              label: 'Pièce requise',
              controller: _piece,
              hint: 'Référence pièce (optionnel)',
              prefixIcon: Icons.settings_outlined,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_form.currentState?.validate() ?? false) {
      Navigator.of(context).pop();
      AppToast.success(context, 'Ordre de maintenance créé avec succès.');
    }
  }
}

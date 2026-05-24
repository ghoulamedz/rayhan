//UNUSED
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rayhan_erp/models/mock/enums.dart';
import 'package:rayhan_erp/models/mock/mock_data.dart';
import 'package:rayhan_erp/models/mock/models.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/widgets/final/common/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/status_badge.dart';

/// "Suivi de Production" screen — mirrors the FOREMAN DIGITAL mockup (Image 3).
class SuiviProductionScreen extends StatelessWidget {
  const SuiviProductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productions = MockData.productions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          ScreenHeader(
            title: 'Suivi de Production',
            subtitle: 'Vue d\'ensemble en temps réel',
            actions: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.notification_add_outlined, size: 16),
                label: const Text('Nouvelle Alerte'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // ── KPI row ────────────────────────────────────────────────────────
          _KpiRow(),
          const SizedBox(height: AppTheme.sp24),

          // ── Lots + Equipment panel ─────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _LotsSection(productions: productions)),
              const SizedBox(width: AppTheme.sp20),
              Expanded(flex: 2, child: _EquipementPanel()),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// KPI row
// ──────────────────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'EFFICACITÉ GLOBALE',
            value: '94.2%',
            trend: '+2.4% vs hier',
            trendPositive: true,
          ),
        ),
        SizedBox(width: AppTheme.sp16),
        Expanded(
          child: _KpiCard(
            label: 'LOTS ACTIFS',
            value: '08',
            trend: '4 en cours, 4 en attente',
            trendPositive: true,
          ),
        ),
        SizedBox(width: AppTheme.sp16),
        Expanded(
          child: _KpiCard(
            label: 'UNITÉS PRODUITES',
            value: '1,284',
            trend: 'Objectif: 1,500',
            trendPositive: false,
          ),
        ),
        SizedBox(width: AppTheme.sp16),
        Expanded(
          child: _KpiCard(
            label: 'ALERTES QUALITÉ',
            value: '02',
            trend: 'Action requise immédiate',
            trendPositive: false,
            isAlert: true,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendPositive,
    this.isAlert = false,
  });

  final String label;
  final String value;
  final String trend;
  final bool trendPositive;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final valueColor = isAlert ? AppTheme.red : Colors.black;
    final alertBorderColor = isAlert
        ? AppTheme.red.withOpacity(0.4)
        : AppTheme.whiteTintedorGreyAddAlpha02;

    return Container(
      padding: const EdgeInsets.all(AppTheme.sp20),
      decoration: BoxDecoration(
        color: AppTheme.whiteSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertBorderColor, width: isAlert ? 1.5 : 1),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.greyLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppTheme.sp8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: valueColor,
              height: 1,
            ),
          ),
          const SizedBox(height: AppTheme.sp8),
          Row(
            children: [
              if (isAlert)
                const Icon(Icons.warning_amber_rounded,
                    size: 14, color: AppTheme.red)
              else
                Icon(
                  trendPositive
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 14,
                  color: trendPositive ? AppTheme.greenBright : AppTheme.red,
                ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 11,
                    color: isAlert
                        ? AppTheme.red
                        : trendPositive
                            ? AppTheme.greenBright
                            : AppTheme.greyLight,
                  ),
                  overflow: TextOverflow.ellipsis,
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
// Lots section
// ──────────────────────────────────────────────────────────────────────────────

class _LotsSection extends StatelessWidget {
  const _LotsSection({required this.productions});

  final List<Production> productions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text(
              'Lots de Production Actifs',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('Voir tout →'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.sp12),
        ...productions.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.sp12),
              child: _LotCard(production: p),
            )),
      ],
    );
  }
}

class _LotCard extends StatelessWidget {
  const _LotCard({required this.production});

  final Production production;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnCours = production.statut == StatutProduction.enCours;
    final isPlanifie = production.statut == StatutProduction.planifie;

    return Container(
      padding: const EdgeInsets.all(AppTheme.sp20),
      decoration: BoxDecoration(
        color: AppTheme.whiteSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.whiteTintedorGreyAddAlpha02),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.whiteSurface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings_rounded,
                    size: 18, color: AppTheme.grey),
              ),
              const SizedBox(width: AppTheme.sp12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        production.lotReference,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.greyLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge.fromProduction(statut: production.statut),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    production.produitDesignation,
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
              const Spacer(),
              if (isEnCours)
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Valider Fin'),
                )
              else if (isPlanifie)
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Lancer'),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.sp16),

          // Details row
          Row(
            children: [
              _LotDetail(
                label: 'RESPONSABLE',
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.black,
                      child: Text(
                        'JD',
                        style: TextStyle(fontSize: 8, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(production.responsableNom,
                        style: theme.textTheme.labelLarge),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.sp24),
              _LotDetail(
                label: isEnCours ? 'DÉBUT' : 'PLANIFIÉ',
                child: Text(
                  DateFormat('hh:mm a').format(production.dateDebut),
                  style: theme.textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: AppTheme.sp24),
              _LotDetail(
                label: 'VOLUME',
                child: Text(
                  isEnCours
                      ? '${(production.quantite * production.progression).round()} / ${production.quantite.toInt()} pcs'
                      : '0 / ${production.quantite.toInt()} pcs',
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ],
          ),

          // Progress bar (only for en cours)
          if (isEnCours) ...[
            const SizedBox(height: AppTheme.sp16),
            Row(
              children: [
                Text(
                  'Progression',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  '${(production.progression * 100).round()}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.sp8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: production.progression,
                minHeight: 8,
                backgroundColor: AppTheme.whiteSurface2,
                valueColor: const AlwaysStoppedAnimation(Colors.black),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LotDetail extends StatelessWidget {
  const _LotDetail({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.greyLight,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Equipment panel
// ──────────────────────────────────────────────────────────────────────────────

class _EquipementPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // OEE gauge card
        Container(
          padding: const EdgeInsets.all(AppTheme.sp20),
          decoration: BoxDecoration(
            color: AppTheme.blueStrongHighlight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Statut Équipement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.sensors_rounded, color: Colors.black, size: 18),
                ],
              ),
              SizedBox(height: AppTheme.sp20),
              Center(child: _OeeGauge(value: 0.88)),
              SizedBox(height: AppTheme.sp20),
              _EquipTile(
                  label: 'Température',
                  value: '42°C',
                  icon: Icons.thermostat_rounded),
              SizedBox(height: AppTheme.sp8),
              _EquipTile(
                  label: 'Vibration',
                  value: 'Nominal',
                  icon: Icons.waves_rounded),
              SizedBox(height: AppTheme.sp8),
              _EquipTile(
                  label: 'Cadence',
                  value: '12.5 u/min',
                  icon: Icons.speed_rounded),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.sp16),

        // Events journal
        _EventsJournal(),
      ],
    );
  }
}

class _OeeGauge extends StatelessWidget {
  const _OeeGauge({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 10,
            backgroundColor: AppTheme.greenStrong,
            valueColor: const AlwaysStoppedAnimation(Colors.black),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'OEE',
              style: TextStyle(
                color: AppTheme.blueStrongHighlight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EquipTile extends StatelessWidget {
  const _EquipTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp12,
        vertical: AppTheme.sp10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.greenStrong,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.black),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.blueStrongHighlight,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Events journal
// ──────────────────────────────────────────────────────────────────────────────

class _EventsJournal extends StatelessWidget {
  static const List<_EventData> _events = [
    _EventData(
      time: '10:45 AM',
      title: 'Lot LOT-2023-442 : Phase 2 terminée',
      detail: 'Inspection qualité réussie – Tolérance +/- 0.01mm',
      isAlert: false,
    ),
    _EventData(
      time: '09:30 AM',
      title: 'Alerte Maintenance : Robot-A4',
      detail:
          'Surchauffe détectée sur le bras articulé. Refroidissement actif.',
      isAlert: true,
    ),
    _EventData(
      time: '08:15 AM',
      title: 'Lancement Production',
      detail: "Nouvelle session initiée par Chef d'Équipe M. Lefebvre.",
      isAlert: false,
    ),
    _EventData(
      time: 'Hier, 06:00 PM',
      title: 'Rapport de Fin de Poste',
      detail: 'Objectifs atteints à 102%.',
      isAlert: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'JOURNAL DES ÉVÉNEMENTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.greyLight,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppTheme.sp16),
          ..._events.map((e) => _EventItem(event: e)),
          const SizedBox(height: AppTheme.sp8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: const Text("Charger l'historique complet"),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventItem extends StatelessWidget {
  const _EventItem({required this.event});

  final _EventData event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sp12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 3),
            decoration: BoxDecoration(
              color: event.isAlert ? AppTheme.red : AppTheme.greyLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.time,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  event.title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: event.isAlert ? AppTheme.red : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.detail,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventData {
  const _EventData({
    required this.time,
    required this.title,
    required this.detail,
    required this.isAlert,
  });

  final String time;
  final String title;
  final String detail;
  final bool isAlert;
}

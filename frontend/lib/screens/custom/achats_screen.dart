import 'package:flutter/material.dart';
import 'package:rayhan_erp/models/fournisseur.dart';
import 'package:rayhan_erp/models/mock/enums.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/widgets/final/common/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/stat_card.dart';
import 'package:rayhan_erp/widgets/custom/status_badge.dart';

/// "Gestion des Achats & Fournisseurs" screen.
class AchatsScreen extends StatefulWidget {
  const AchatsScreen({super.key});

  @override
  State<AchatsScreen> createState() => _AchatsScreenState();
}

class _AchatsScreenState extends State<AchatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(
            title: 'Achats & Fournisseurs',
            subtitle: 'Gestion des approvisionnements en matières premières.',
            actions: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Nouvel Achat'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),
          _KpiRow(),
          const SizedBox(height: AppTheme.sp24),

          // Tab bar
          Container(
            decoration: const BoxDecoration(
              border: Border(
                  bottom:
                      BorderSide(color: AppTheme.whiteTintedorGreyAddAlpha02)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: AppTheme.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 2,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              tabs: const [
                Tab(text: 'Commandes Achat'),
                Tab(text: 'Fournisseurs'),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sp20),

          SizedBox(
            height: 500,
            child: TabBarView(
              controller: _tabController,
              children: const [
                _AchatsTable(),
                _FournisseursTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// KPI row

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Commandes en cours',
            value: '12',
            subtitle: 'Fournisseurs actifs',
            icon: Icons.local_shipping_outlined,
            iconColor: Colors.black,
            iconBackground: Colors.black,
          ),
        ),
        SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'Valeur totale commandée',
            value: '€48.2K',
            subtitle: 'Ce mois-ci',
            trend: '+8%',
            trendPositive: true,
            icon: Icons.receipt_long_outlined,
            iconColor: AppTheme.blueLight,
            iconBackground: AppTheme.blueLightest,
          ),
        ),
        SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'Livraisons en retard',
            value: '03',
            subtitle: 'Nécessite suivi',
            alertLevel: 'warning',
            icon: Icons.schedule_outlined,
            iconColor: AppTheme.yellow,
            iconBackground: AppTheme.yellow,
          ),
        ),
        SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'Score fournisseurs moyen',
            value: '4.3/5',
            subtitle: 'Basé sur 8 fournisseurs',
            icon: Icons.star_outline_rounded,
            iconColor: AppTheme.greenBright,
            iconBackground: AppTheme.greenLight,
          ),
        ),
      ],
    );
  }
}

// Achats table

class _AchatsTable extends StatelessWidget {
  const _AchatsTable();

  static final List<_AchatRow> _rows = [
    const _AchatRow(
      ref: 'ACH-2023-041',
      matiere: 'HDPE — Granulés',
      fournisseur: 'PolyChim Industries',
      qteCommandee: '5,000 kg',
      qteRecue: '5,000 kg',
      datePrevue: '20 Oct. 2023',
      statut: StatutAchat.livre,
    ),
    const _AchatRow(
      ref: 'ACH-2023-042',
      matiere: 'LDPE — Granulés',
      fournisseur: 'EuroPlast SA',
      qteCommandee: '3,200 kg',
      qteRecue: '1,600 kg',
      datePrevue: '24 Oct. 2023',
      statut: StatutAchat.livraisonPartielle,
    ),
    const _AchatRow(
      ref: 'ACH-2023-043',
      matiere: 'Colorant Noir Carbone',
      fournisseur: 'ChemColor GmbH',
      qteCommandee: '800 kg',
      qteRecue: '0 kg',
      datePrevue: '28 Oct. 2023',
      statut: StatutAchat.enCours,
    ),
    const _AchatRow(
      ref: 'ACH-2023-044',
      matiere: 'Additifs Anti-UV',
      fournisseur: 'PolyChim Industries',
      qteCommandee: '200 kg',
      qteRecue: '0 kg',
      datePrevue: '30 Oct. 2023',
      statut: StatutAchat.refuse,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AchatHeader(),
          ..._rows.map((r) => _AchatTile(row: r)),
        ],
      ),
    );
  }
}

class _AchatHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppTheme.greyLight,
      letterSpacing: 0.5,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp20, vertical: AppTheme.sp12),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppTheme.whiteTintedorGreyAddAlpha02)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('RÉFÉRENCE', style: style)),
          Expanded(flex: 3, child: Text('MATIÈRE', style: style)),
          Expanded(flex: 3, child: Text('FOURNISSEUR', style: style)),
          Expanded(flex: 2, child: Text('QTÉ COMMANDÉE', style: style)),
          Expanded(flex: 2, child: Text('QTÉ REÇUE', style: style)),
          Expanded(flex: 2, child: Text('DATE PRÉVUE', style: style)),
          Expanded(flex: 2, child: Text('STATUT', style: style)),
        ],
      ),
    );
  }
}

class _AchatTile extends StatelessWidget {
  const _AchatTile({required this.row});

  final _AchatRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp20, vertical: AppTheme.sp14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.blueLightest)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              row.ref,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
              flex: 3,
              child: Text(row.matiere, style: theme.textTheme.bodyMedium)),
          Expanded(
              flex: 3,
              child: Text(row.fournisseur, style: theme.textTheme.bodyMedium)),
          Expanded(
              flex: 2,
              child: Text(row.qteCommandee, style: theme.textTheme.labelLarge)),
          Expanded(
            flex: 2,
            child: Text(
              row.qteRecue,
              style: theme.textTheme.labelLarge?.copyWith(
                color: row.statut == StatutAchat.livre
                    ? AppTheme.greenBright
                    : Colors.black,
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: Text(row.datePrevue, style: theme.textTheme.bodyMedium)),
          Expanded(
            flex: 2,
            child: StatusBadge.fromAchat(statut: row.statut),
          ),
        ],
      ),
    );
  }
}

class _AchatRow {
  const _AchatRow({
    required this.ref,
    required this.matiere,
    required this.fournisseur,
    required this.qteCommandee,
    required this.qteRecue,
    required this.datePrevue,
    required this.statut,
  });

  final String ref;
  final String matiere;
  final String fournisseur;
  final String qteCommandee;
  final String qteRecue;
  final String datePrevue;
  final StatutAchat statut;
}

// Fournisseurs table

class _FournisseursTable extends StatelessWidget {
  const _FournisseursTable();

  static final List<Fournisseur> _data = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _data.map((f) => _FournisseurCard(fournisseur: f)).toList(),
    );
  }
}

class _FournisseurCard extends StatelessWidget {
  const _FournisseurCard({required this.fournisseur});

  final Fournisseur fournisseur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sp12),
      padding: const EdgeInsets.all(AppTheme.sp16),
      decoration: BoxDecoration(
        color: AppTheme.whiteSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.whiteTintedorGreyAddAlpha02),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: fournisseur.actif ? Colors.black : AppTheme.whiteSurface2,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                fournisseur.raisonSociale.substring(0, 2).toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: fournisseur.actif ? Colors.black : AppTheme.greyLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.sp16),

          // Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(fournisseur.raisonSociale,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: fournisseur.actif ? 'Actif' : 'Inactif',
                      color: fournisseur.actif
                          ? AppTheme.greenBright
                          : AppTheme.greyLight,
                      backgroundColor: fournisseur.actif
                          ? AppTheme.greenLight
                          : AppTheme.whiteSurface2,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(fournisseur.raisonSociale,
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ),

          // Matériaux
          Expanded(
            flex: 2,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: []
                  .map(
                    (m) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.whiteSurface2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        m,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Délai
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  '${fournisseur.raisonSociale}j',
                  style: theme.textTheme.titleLarge,
                ),
                const Text(
                  'Délai moyen',
                  style: TextStyle(fontSize: 11, color: AppTheme.greyLight),
                ),
              ],
            ),
          ),

          // Score stars
          const Expanded(
            flex: 2,
            child: _ScoreStars(score: 10),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 16),
                tooltip: 'Modifier',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                tooltip: 'Passer commande',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreStars extends StatelessWidget {
  const _ScoreStars({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          final filled = i < score.floor();
          final half = !filled && i < score;
          return Icon(
            half ? Icons.star_half_rounded : Icons.star_rounded,
            size: 14,
            color: (filled || half) ? AppTheme.yellow : AppTheme.whiteSurface2,
          );
        }),
        const SizedBox(width: 4),
        Text(
          score.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey,
          ),
        ),
      ],
    );
  }
}

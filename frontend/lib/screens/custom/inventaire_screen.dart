import 'package:flutter/material.dart';
import 'package:rayhan_erp/models/mock/enums.dart';
import 'package:rayhan_erp/models/mock/mock_data.dart';
import 'package:rayhan_erp/models/mock/models.dart';
import 'package:rayhan_erp/theme/app_theme.dart';
import 'package:rayhan_erp/widgets/custom/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/stat_card.dart';
import 'package:rayhan_erp/widgets/custom/stock_level_indicator.dart';

/// "Stocks & Matières — Inventaire Global" screen — mirrors Image 5.
class InventaireScreen extends StatelessWidget {
  const InventaireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb + header
          _Breadcrumb(),
          const SizedBox(height: AppTheme.sp8),
          ScreenHeader(
            title: 'Inventaire Global',
            actions: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Exporter Rapport'),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Ajouter MatierePremiere'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // KPI cards
          _KpiRow(),
          const SizedBox(height: AppTheme.sp24),

          // Silos + movements
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _SilosSection()),
              const SizedBox(width: AppTheme.sp20),
              Expanded(flex: 2, child: _MovementsPanel()),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // Products table
          _ProduitsTable(),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────

class _Breadcrumb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, color: AppTheme.textMuted);
    const sep = Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text('/', style: style),
    );
    return Row(
      children: const [
        Text('RayhanERP', style: style),
        sep,
        Text('Production', style: style),
        sep,
        Text(
          'Gestion des Stocks',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: StatCard(
            title: "Total SKU 'Produit'",
            value: '1,284',
            subtitle: 'Articles actifs en production',
            trend: '+12%',
            trendPositive: true,
            icon: Icons.inventory_2_rounded,
            iconColor: AppTheme.primary,
            iconBackground: AppTheme.primarySurface,
          ),
        ),
        SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: "Valeur d'inventaire",
            value: '€2.4M',
            subtitle: 'Estimation basée sur le coût FIFO',
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppTheme.info,
            iconBackground: AppTheme.infoSurface,
          ),
        ),
        SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'Alertes stock bas',
            value: '18',
            subtitle: 'Nécessite une action immédiate',
            alertLevel: 'error',
            icon: Icons.warning_amber_rounded,
            iconColor: AppTheme.error,
            iconBackground: AppTheme.errorSurface,
          ),
        ),
        SizedBox(width: AppTheme.sp16),
        Expanded(
          child: StatCard(
            title: 'Rotation de stock',
            value: '4.2',
            subtitle: 'x/an — Performance industrielle optimale',
            icon: Icons.autorenew_rounded,
            iconColor: AppTheme.success,
            iconBackground: AppTheme.successSurface,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Silos section
// ──────────────────────────────────────────────────────────────────────────────

class _SilosSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hdpe = MockData.matieresPremieres
        .firstWhere((m) => m.type == TypeMatiere.hdpe);
    final ldpe = MockData.matieresPremieres
        .firstWhere((m) => m.type == TypeMatiere.ldpe);

    final hdpePct = (hdpe.stockActuel / 44.0).clamp(0.0, 1.0);
    final ldpePct = (ldpe.stockActuel / 40.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text(
              'Silos de Matières Premières',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Text(
                'SURVEILLANCE DIRECTE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.sp16),
        Row(
          children: [
            Expanded(
              child: SiloIndicator(
                label: 'HDPE',
                subtitle: 'High-Density Polyethylene',
                level: hdpePct,
                poids: hdpe.stockActuel,
                unite: hdpe.unite,
                actionLabel: 'DÉTAILS CAPTEURS',
              ),
            ),
            const SizedBox(width: AppTheme.sp16),
            Expanded(
              child: SiloIndicator(
                label: 'LDPE',
                subtitle: 'Low-Density Polyethylene',
                level: ldpePct,
                poids: ldpe.stockActuel,
                unite: ldpe.unite,
                actionLabel: 'COMMANDER STOCK',
                actionColor: AppTheme.error,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Movements journal
// ──────────────────────────────────────────────────────────────────────────────

class _MovementsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mouvements = MockData.mouvements;
    return AppCard(
      title: 'Journal des Mouvements',
      trailing: TextButton(
        onPressed: () {},
        child: const Text('Voir tout'),
      ),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.sp16,
              vertical: AppTheme.sp8,
            ),
            child: Row(
              children: const [
                Text(
                  'DERNIÈRE HEURE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.6,
                  ),
                ),
                Spacer(),
                Icon(Icons.refresh_rounded,
                    size: 14, color: AppTheme.textMuted),
              ],
            ),
          ),
          ...mouvements.map((m) => _JournalTile(mouvement: m)),
        ],
      ),
    );
  }
}

class _JournalTile extends StatelessWidget {
  const _JournalTile({required this.mouvement});

  final MouvementStock mouvement;

  @override
  Widget build(BuildContext context) {
    final isEntree = mouvement.isEntree;
    final color = isEntree ? AppTheme.success : AppTheme.error;
    final sign = isEntree ? '+' : '-';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp16,
        vertical: AppTheme.sp12,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MouvementStock #${mouvement.id.split('-').last}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mouvement.designation,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Par: ${mouvement.operateur} • ${_fmtTime(mouvement.date)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _MovBadge(
            isEntree: isEntree,
            label: isEntree ? 'Entrée' : 'Sortie',
          ),
          const SizedBox(width: AppTheme.sp8),
          Text(
            '$sign${mouvement.quantite.toStringAsFixed(0)} ${isEntree ? "kg" : "u"}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _MovBadge extends StatelessWidget {
  const _MovBadge({required this.isEntree, required this.label});

  final bool isEntree;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = isEntree ? AppTheme.success : AppTheme.error;
    final bg = isEntree ? AppTheme.successSurface : AppTheme.errorSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style:
            TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Produits table
// ──────────────────────────────────────────────────────────────────────────────

class _ProduitsTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final produits = MockData.produits;
    return AppCard(
      title: 'Produits Finis & Composants',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DropdownBtn(label: 'Toutes les Catégories'),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProduitTableHeader(),
          ...produits.map((p) => _ProduitRow(produit: p)),
          Padding(
            padding: const EdgeInsets.all(AppTheme.sp16),
            child: Row(
              children: const [
                Text(
                  'AFFICHAGE 1–15 SUR 1,284 PRODUITS',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownBtn extends StatelessWidget {
  const _DropdownBtn({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded,
              size: 16, color: AppTheme.textMuted),
        ],
      ),
    );
  }
}

class _ProduitTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppTheme.textMuted,
      letterSpacing: 0.5,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp20,
        vertical: AppTheme.sp12,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('SKU CODE', style: style)),
          Expanded(flex: 4, child: Text("DÉSIGNATION 'PRODUIT'", style: style)),
          Expanded(flex: 2, child: Text('CATÉGORIE', style: style)),
          Expanded(flex: 2, child: Text('EN STOCK', style: style)),
          Expanded(flex: 2, child: Text('NIVEAU DE RÉAPPRO.', style: style)),
          Expanded(
              flex: 1,
              child: Text('ACTIONS', style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _ProduitRow extends StatelessWidget {
  const _ProduitRow({required this.produit});

  final Produit produit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLow = produit.isStockBas;
    final stockColor = isLow ? AppTheme.error : AppTheme.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp20,
        vertical: AppTheme.sp16,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              produit.skuCode,
              style:
                  theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: const Icon(Icons.widgets_outlined,
                      size: 16, color: AppTheme.textMuted),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    produit.designation,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                produit.categorie,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${_fmtQty(produit.stockActuel)} unités',
              style: theme.textTheme.labelLarge?.copyWith(color: stockColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              width: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: produit.niveauReapprovisionnement,
                  minHeight: 6,
                  backgroundColor: AppTheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLow ? AppTheme.error : AppTheme.primary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined),
                  iconSize: 16,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtQty(double q) {
    if (q >= 1000)
      return '${(q / 1000).toStringAsFixed(q % 1000 == 0 ? 0 : 1)}K';
    return q.toStringAsFixed(0);
  }
}

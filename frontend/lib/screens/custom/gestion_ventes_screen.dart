import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rayhan_erp/models/mock/mock_data.dart';
import 'package:rayhan_erp/models/mock/models.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/widgets/final/common/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/stat_card.dart';
import 'package:rayhan_erp/widgets/custom/status_badge.dart';

/// "Gestion des Ventes" screen — mirrors Image 4.
class GestionVentesScreen extends StatefulWidget {
  const GestionVentesScreen({super.key});

  @override
  State<GestionVentesScreen> createState() => _GestionVentesScreenState();
}

class _GestionVentesScreenState extends State<GestionVentesScreen> {
  Vente? _selected;
  final _currencyFmt = NumberFormat.currency(locale: 'fr_FR', symbol: '€');

  @override
  void initState() {
    super.initState();
    _selected = MockData.ventes.first;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          ScreenHeader(
            title: 'Gestion des Ventes',
            subtitle:
                'Surveillance et exécution des commandes client en temps réel.',
            actions: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Exporter CSV'),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Créer Facture'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // ── KPI row ────────────────────────────────────────────────────────
          const Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Ventes Totales',
                  value: '142 580,00 €',
                  trend: '+12%',
                  trendPositive: true,
                  icon: Icons.euro_rounded,
                  iconColor: Colors.black,
                  iconBackground: Colors.black,
                ),
              ),
              SizedBox(width: AppTheme.sp16),
              Expanded(
                child: StatCard(
                  title: 'Commandes en cours',
                  value: '24',
                  subtitle: 'Actif',
                  icon: Icons.pending_actions_rounded,
                  iconColor: AppTheme.blueLight,
                  iconBackground: AppTheme.blueLightest,
                ),
              ),
              SizedBox(width: AppTheme.sp16),
              Expanded(
                child: StatCard(
                  title: 'Taux de Livraison',
                  value: '98.2%',
                  subtitle: 'Objectif industriel: >95%',
                  icon: Icons.local_shipping_outlined,
                  iconColor: AppTheme.greenBright,
                  iconBackground: AppTheme.greenLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp24),

          // ── Main content ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ventes table
              Expanded(
                flex: 3,
                child: _VentesTable(
                  ventes: MockData.ventes,
                  selected: _selected,
                  onSelect: (v) => setState(() => _selected = v),
                  currencyFmt: _currencyFmt,
                ),
              ),
              const SizedBox(width: AppTheme.sp20),
              // Detail panel
              if (_selected != null)
                Expanded(
                  flex: 2,
                  child: _VenteDetailPanel(
                    vente: _selected!,
                    currencyFmt: _currencyFmt,
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
// Ventes table
// ──────────────────────────────────────────────────────────────────────────────

class _VentesTable extends StatelessWidget {
  const _VentesTable({
    required this.ventes,
    required this.selected,
    required this.onSelect,
    required this.currencyFmt,
  });

  final List<Vente> ventes;
  final Vente? selected;
  final ValueChanged<Vente> onSelect;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Table header row
          const Row(
            children: [
              Text(
                'Registre des Ventes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Spacer(),
              _FilterChip(label: 'Filtre: Tout'),
              SizedBox(width: AppTheme.sp8),
              _FilterChip(label: 'Tri: Date Desc.'),
            ],
          ),
          const SizedBox(height: AppTheme.sp16),

          // Column labels
          _TableHeader(),
          const Divider(height: 1),

          // Rows
          ...ventes.map(
            (v) => _VenteRow(
              vente: v,
              isSelected: v.id == selected?.id,
              onTap: () => onSelect(v),
              currencyFmt: currencyFmt,
            ),
          ),

          const SizedBox(height: AppTheme.sp8),
          const _Pagination(label: 'AFFICHAGE 1–4 SUR 128 VENTES'),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.whiteSurface2,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.whiteTintedorGreyAddAlpha02),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppTheme.grey,
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppTheme.greyLight,
      letterSpacing: 0.5,
    );
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppTheme.sp8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('RÉF. COMMANDE', style: style)),
          Expanded(flex: 3, child: Text('CLIENT', style: style)),
          Expanded(flex: 2, child: Text('DATE', style: style)),
          Expanded(flex: 2, child: Text('STATUT', style: style)),
          Expanded(
            flex: 2,
            child: Text(
              'TOTAL (TTC)',
              style: style,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _VenteRow extends StatelessWidget {
  const _VenteRow({
    required this.vente,
    required this.isSelected,
    required this.onTap,
    required this.currencyFmt,
  });

  final Vente vente;
  final bool isSelected;
  final VoidCallback onTap;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppTheme.sp12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                vente.id,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vente.client, style: theme.textTheme.labelLarge),
                  if (vente.client == 'Industries Mécaniques SARL')
                    const Text(
                      'ID: ENT-402',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.greyLight,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('dd/MM/yyyy').format(vente.dateCommande),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: StatusBadge.fromCommande(statut: vente.statut),
            ),
            Expanded(
              flex: 2,
              child: Text(
                currencyFmt.format(vente.montantTTC),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.greyLight),
        ),
        const Spacer(),
        TextButton(onPressed: () {}, child: const Text('Précédent')),
        const SizedBox(width: 4),
        TextButton(onPressed: () {}, child: const Text('Suivant')),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Vente detail panel
// ──────────────────────────────────────────────────────────────────────────────

class _VenteDetailPanel extends StatelessWidget {
  const _VenteDetailPanel({
    required this.vente,
    required this.currencyFmt,
  });

  final Vente vente;
  final NumberFormat currencyFmt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Focus card
        AppCard(
          color: AppTheme.blueStrongHighlight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                children: [
                  Text(
                    'FOCUS COMMANDE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.blueStrongHighlight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Colors.black),
                ],
              ),
              const SizedBox(height: AppTheme.sp12),
              Text(
                vente.id,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                vente.client,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.blueStrongHighlight,
                ),
              ),
              const SizedBox(height: AppTheme.sp16),
              Row(
                children: [
                  Expanded(
                    child: _DarkMetric(
                      label: 'ÉCHÉANCE',
                      value: DateFormat('dd MMM. yyyy')
                          .format(vente.dateLivraisonSouhaitee),
                    ),
                  ),
                  const Expanded(
                    child: _DarkMetric(
                      label: 'PAIEMENT',
                      value: '30 Jours Net',
                      valueColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.sp16),

        // Line items
        AppCard(
          title: 'Détails Lignes Produits',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.whiteSurface2,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${vente.lignesProduits.length} items',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.grey,
              ),
            ),
          ),
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: vente.lignesProduits.isEmpty
                ? [
                    const Padding(
                      padding: EdgeInsets.all(AppTheme.sp16),
                      child: Text(
                        'Aucune ligne produit',
                        style:
                            TextStyle(fontSize: 12, color: AppTheme.greyLight),
                      ),
                    )
                  ]
                : vente.lignesProduits
                    .map((l) => _LigneProduitTile(ligne: l))
                    .toList(),
          ),
        ),
        const SizedBox(height: AppTheme.sp16),

        // Flux logistique
        const AppCard(
          title: 'Flux Logistique',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LogisticsStep(
                label: 'Validation Administrative',
                detail: 'Effectuée par J. Dupont',
                done: true,
              ),
              _LogisticsStep(
                label: 'Préparation Entrepôt',
                detail: 'En cours (Zone B-12)',
                done: false,
                active: true,
              ),
              _LogisticsStep(
                label: 'Expédition Client',
                detail: 'Prévu le 28/10',
                done: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.sp16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            child: const Text('MODIFIER LES ARTICLES'),
          ),
        ),
      ],
    );
  }
}

class _DarkMetric extends StatelessWidget {
  const _DarkMetric({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
  });

  final String label;
  final String value;
  final Color valueColor;

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
            color: AppTheme.blueStrongHighlight,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _LigneProduitTile extends StatelessWidget {
  const _LigneProduitTile({required this.ligne});

  final LigneProduit ligne;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp16,
        vertical: AppTheme.sp12,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.blueLightest)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.whiteSurface2,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.widgets_outlined,
                size: 16, color: AppTheme.greyLight),
          ),
          const SizedBox(width: AppTheme.sp12),
          Expanded(
            child: Text(
              ligne.designation,
              style: theme.textTheme.labelLarge,
            ),
          ),
          Text(
            '${ligne.quantite} ${ligne.unite}',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LogisticsStep extends StatelessWidget {
  const _LogisticsStep({
    required this.label,
    required this.detail,
    required this.done,
    this.active = false,
  });

  final String label;
  final String detail;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = done
        ? AppTheme.greenBright
        : active
            ? Colors.black
            : AppTheme.greyLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sp12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppTheme.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: done || active ? Colors.black : AppTheme.greyLight,
                  ),
                ),
                Text(detail, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

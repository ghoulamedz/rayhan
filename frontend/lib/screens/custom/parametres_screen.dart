import 'package:flutter/material.dart';
import 'package:rayhan_erp/models/mock/enums.dart';
import 'package:rayhan_erp/models/mock/mock_data.dart';
import 'package:rayhan_erp/models/mock/models.dart';
import 'package:rayhan_erp/theme/app_theme.dart';
import 'package:rayhan_erp/widgets/custom/dialogs.dart';
import 'package:rayhan_erp/widgets/custom/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/status_badge.dart';

/// "Paramètres" screen — user management, system preferences,
/// notification rules, and integration settings.
class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);

  // System preferences state
  bool _darkMode = false;
  bool _notifsEmail = true;
  bool _notifsInApp = true;
  bool _notifsCritiquesOnly = false;
  bool _autoBackup = true;
  String _langue = 'Français';
  String _devise = 'EUR (€)';
  String _fuseau = 'Europe/Paris';

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
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppTheme.sp24, AppTheme.sp24, AppTheme.sp24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                title: 'Paramètres',
                subtitle:
                    'Configuration système, utilisateurs et intégrations.',
              ),
              const SizedBox(height: AppTheme.sp20),
              Container(
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.border))),
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
                    Tab(text: 'Utilisateurs'),
                    Tab(text: 'Général'),
                    Tab(text: 'Notifications'),
                    Tab(text: 'Intégrations'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _UsersTab(),
              _GeneralTab(
                darkMode: _darkMode,
                langue: _langue,
                devise: _devise,
                fuseau: _fuseau,
                autoBackup: _autoBackup,
                onDarkMode: (v) => setState(() => _darkMode = v),
                onLangue: (v) => setState(() => _langue = v ?? _langue),
                onDevise: (v) => setState(() => _devise = v ?? _devise),
                onFuseau: (v) => setState(() => _fuseau = v ?? _fuseau),
                onAutoBackup: (v) => setState(() => _autoBackup = v),
              ),
              _NotifsTab(
                email: _notifsEmail,
                inApp: _notifsInApp,
                critiquesOnly: _notifsCritiquesOnly,
                onEmail: (v) => setState(() => _notifsEmail = v),
                onInApp: (v) => setState(() => _notifsInApp = v),
                onCritiquesOnly: (v) =>
                    setState(() => _notifsCritiquesOnly = v),
              ),
              const _IntegrationsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 1 — Utilisateurs
// ──────────────────────────────────────────────────────────────────────────────

class _UsersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final users = MockData.utilisateurs;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Utilisateurs actifs — ${users.length} comptes',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_add_outlined, size: 14),
                label: const Text('Ajouter'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp16),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _UserTableHeader(),
                ...users.map((u) => _UserRow(user: u)),
                // Spacer demo rows
                ..._demoUsers.map((u) => _UserRow(user: u)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final List<Utilisateur> _demoUsers = [
    Utilisateur(
      id: 'u4',
      nom: 'Blanc',
      prenom: 'Sophie',
      email: 's.blanc@plastiquerp.fr',
      role: Role.responsableAchat,
      statut: 'actif',
      creeLe: DateTime(2023, 4, 1),
    ),
    Utilisateur(
      id: 'u5',
      nom: 'Moreau',
      prenom: 'Pierre',
      email: 'p.moreau@plastiquerp.fr',
      role: Role.responsableProduction,
      statut: 'inactif',
      creeLe: DateTime(2022, 11, 15),
    ),
  ];
}

class _UserTableHeader extends StatelessWidget {
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
          Expanded(flex: 1, child: Text('', style: style)),
          Expanded(flex: 3, child: Text('NOM', style: style)),
          Expanded(flex: 3, child: Text('EMAIL', style: style)),
          Expanded(flex: 2, child: Text('RÔLE', style: style)),
          Expanded(flex: 1, child: Text('STATUT', style: style)),
          Expanded(
              flex: 1,
              child: Text('ACTIONS', style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});
  final Utilisateur user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = user.statut == 'actif';
    final initials = '${user.prenom[0]}${user.nom[0]}'.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp20, vertical: AppTheme.sp12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.divider))),
      child: Row(
        children: [
          // Avatar
          Expanded(
            flex: 1,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: isActive ? AppTheme.primary : AppTheme.textMuted,
              child: Text(
                initials,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nomComplet, style: theme.textTheme.labelLarge),
              ],
            ),
          ),
          Expanded(
              flex: 3,
              child: Text(user.email,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                user.role.label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: StatusBadge(
              label: isActive ? 'Actif' : 'Inactif',
              color: isActive ? AppTheme.success : AppTheme.textMuted,
              backgroundColor:
                  isActive ? AppTheme.successSurface : AppTheme.surfaceVariant,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  tooltip: 'Modifier',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    isActive
                        ? Icons.lock_outline_rounded
                        : Icons.lock_open_outlined,
                    size: 15,
                  ),
                  tooltip: isActive ? 'Désactiver' : 'Activer',
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
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 2 — Général
// ──────────────────────────────────────────────────────────────────────────────

class _GeneralTab extends StatelessWidget {
  const _GeneralTab({
    required this.darkMode,
    required this.langue,
    required this.devise,
    required this.fuseau,
    required this.autoBackup,
    required this.onDarkMode,
    required this.onLangue,
    required this.onDevise,
    required this.onFuseau,
    required this.onAutoBackup,
  });

  final bool darkMode;
  final String langue;
  final String devise;
  final String fuseau;
  final bool autoBackup;
  final ValueChanged<bool> onDarkMode;
  final ValueChanged<String?> onLangue;
  final ValueChanged<String?> onDevise;
  final ValueChanged<String?> onFuseau;
  final ValueChanged<bool> onAutoBackup;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apparence
          AppCard(
            title: 'Apparence',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToggleSetting(
                  icon: Icons.dark_mode_outlined,
                  label: 'Mode sombre',
                  subtitle: 'Thème sombre pour l\'interface.',
                  value: darkMode,
                  onChanged: onDarkMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sp16),

          // Régionalisation
          AppCard(
            title: 'Région & Langue',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormRow(
                  left: ErpDropdown<String>(
                    label: 'Langue',
                    value: langue,
                    onChanged: onLangue,
                    items: const [
                      DropdownMenuItem(
                          value: 'Français', child: Text('Français')),
                      DropdownMenuItem(
                          value: 'English', child: Text('English')),
                      DropdownMenuItem(
                          value: 'Deutsch', child: Text('Deutsch')),
                    ],
                  ),
                  right: ErpDropdown<String>(
                    label: 'Devise',
                    value: devise,
                    onChanged: onDevise,
                    items: const [
                      DropdownMenuItem(
                          value: 'EUR (€)', child: Text('EUR (€)')),
                      DropdownMenuItem(
                          value: 'USD (\$)', child: Text('USD (\$)')),
                      DropdownMenuItem(
                          value: 'GBP (£)', child: Text('GBP (£)')),
                    ],
                  ),
                ),
                const FormGap(),
                ErpDropdown<String>(
                  label: 'Fuseau horaire',
                  value: fuseau,
                  onChanged: onFuseau,
                  items: const [
                    DropdownMenuItem(
                        value: 'Europe/Paris',
                        child: Text('Europe/Paris (UTC+1)')),
                    DropdownMenuItem(
                        value: 'Europe/London',
                        child: Text('Europe/London (UTC+0)')),
                    DropdownMenuItem(
                        value: 'America/New_York',
                        child: Text('America/New_York (UTC-5)')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sp16),

          // Données & Backup
          AppCard(
            title: 'Données & Sauvegarde',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToggleSetting(
                  icon: Icons.backup_outlined,
                  label: 'Sauvegarde automatique',
                  subtitle: 'Sauvegarde quotidienne à 02:00.',
                  value: autoBackup,
                  onChanged: onAutoBackup,
                ),
                const SizedBox(height: AppTheme.sp12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.download_rounded, size: 14),
                        label: const Text('Exporter données'),
                      ),
                    ),
                    const SizedBox(width: AppTheme.sp12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.upload_rounded, size: 14),
                        label: const Text('Importer données'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sp16),

          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Enregistrer les paramètres'),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 3 — Notifications
// ──────────────────────────────────────────────────────────────────────────────

class _NotifsTab extends StatelessWidget {
  const _NotifsTab({
    required this.email,
    required this.inApp,
    required this.critiquesOnly,
    required this.onEmail,
    required this.onInApp,
    required this.onCritiquesOnly,
  });

  final bool email;
  final bool inApp;
  final bool critiquesOnly;
  final ValueChanged<bool> onEmail;
  final ValueChanged<bool> onInApp;
  final ValueChanged<bool> onCritiquesOnly;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        children: [
          AppCard(
            title: 'Canaux de Notification',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ToggleSetting(
                  icon: Icons.email_outlined,
                  label: 'Notifications par email',
                  subtitle:
                      'Recevoir les alertes sur jean.dupont@plastiquerp.fr',
                  value: email,
                  onChanged: onEmail,
                ),
                const Divider(height: AppTheme.sp24),
                _ToggleSetting(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications in-app',
                  subtitle:
                      'Afficher la cloche de notifications dans l\'interface.',
                  value: inApp,
                  onChanged: onInApp,
                ),
                const Divider(height: AppTheme.sp24),
                _ToggleSetting(
                  icon: Icons.warning_amber_outlined,
                  label: 'Alertes critiques uniquement',
                  subtitle:
                      'Filtrer pour ne recevoir que les urgences critiques.',
                  value: critiquesOnly,
                  onChanged: onCritiquesOnly,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sp16),
          AppCard(
            title: 'Règles par Module',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: CategorieNotif.values
                  .map((c) => _ModuleNotifRow(categorie: c))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleNotifRow extends StatefulWidget {
  const _ModuleNotifRow({required this.categorie});
  final CategorieNotif categorie;

  @override
  State<_ModuleNotifRow> createState() => _ModuleNotifRowState();
}

class _ModuleNotifRowState extends State<_ModuleNotifRow> {
  bool _enabled = true;

  IconData get _icon => switch (widget.categorie) {
        CategorieNotif.vente => Icons.shopping_cart_outlined,
        CategorieNotif.stock => Icons.inventory_2_outlined,
        CategorieNotif.achat => Icons.local_shipping_outlined,
        CategorieNotif.production => Icons.precision_manufacturing_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.sp12),
      child: Row(
        children: [
          Icon(_icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.sp12),
          Expanded(
            child: Text(
              widget.categorie.label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary),
            ),
          ),
          Switch.adaptive(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tab 4 — Intégrations
// ──────────────────────────────────────────────────────────────────────────────

class _IntegrationsTab extends StatelessWidget {
  const _IntegrationsTab();

  static const List<_IntegrationItem> _items = [
    _IntegrationItem(
      name: 'API REST',
      description: 'Connexion aux systèmes tiers via JSON/REST.',
      icon: Icons.api_outlined,
      connected: true,
      endpoint: 'https://api.plastiquerp.fr/v1',
    ),
    _IntegrationItem(
      name: 'Webhook Ventes',
      description: 'Notifications temps réel vers votre CRM.',
      icon: Icons.webhook_outlined,
      connected: true,
      endpoint: 'https://crm.example.com/webhook',
    ),
    _IntegrationItem(
      name: 'ERP Comptabilité',
      description: 'Export automatique vers Sage / SAP.',
      icon: Icons.account_balance_outlined,
      connected: false,
    ),
    _IntegrationItem(
      name: 'Capteurs IoT',
      description: 'Lecture temps réel des silos et machines.',
      icon: Icons.sensors_outlined,
      connected: true,
      endpoint: 'mqtt://iot.plastiquerp.fr:1883',
    ),
    _IntegrationItem(
      name: 'Messagerie SMTP',
      description: 'Envoi d\'emails via serveur SMTP.',
      icon: Icons.mail_outline_rounded,
      connected: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp24),
      child: Column(
        children: _items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.sp12),
                  child: _IntegrationCard(item: item),
                ))
            .toList(),
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  const _IntegrationCard({required this.item});
  final _IntegrationItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppTheme.sp20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: item.connected
              ? AppTheme.success.withOpacity(0.3)
              : AppTheme.border,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.connected
                  ? AppTheme.successSurface
                  : AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              item.icon,
              size: 22,
              color: item.connected ? AppTheme.success : AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: AppTheme.sp16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.titleMedium),
                Text(item.description, style: theme.textTheme.bodySmall),
                if (item.endpoint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.endpoint!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppTheme.sp16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(
                label: item.connected ? 'Connecté' : 'Déconnecté',
                color: item.connected ? AppTheme.success : AppTheme.textMuted,
                backgroundColor: item.connected
                    ? AppTheme.successSurface
                    : AppTheme.surfaceVariant,
                icon: item.connected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
              ),
              const SizedBox(height: AppTheme.sp8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(fontSize: 11),
                ),
                child: Text(item.connected ? 'Configurer' : 'Connecter'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntegrationItem {
  const _IntegrationItem({
    required this.name,
    required this.description,
    required this.icon,
    required this.connected,
    this.endpoint,
  });
  final String name;
  final String description;
  final IconData icon;
  final bool connected;
  final String? endpoint;
}

// ──────────────────────────────────────────────────────────────────────────────
// Shared setting toggle row
// ──────────────────────────────────────────────────────────────────────────────

class _ToggleSetting extends StatelessWidget {
  const _ToggleSetting({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: value ? AppTheme.primarySurface : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Icon(
            icon,
            size: 18,
            color: value ? AppTheme.primary : AppTheme.textMuted,
          ),
        ),
        const SizedBox(width: AppTheme.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.titleMedium),
              Text(subtitle, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primary,
        ),
      ],
    );
  }
}

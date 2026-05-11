import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/mock/index.dart';

/// Slide-in notification drawer used from the top bar bell icon.
///
/// Wrap the scaffold body in a [Stack] and overlay this widget, or use it
/// inside a [Drawer] / [EndDrawer].
class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({super.key, this.onClose});

  final VoidCallback? onClose;

  static final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'n1',
      destinataireId: 'u1',
      message:
          'Stock LDPE en dessous du seuil minimal (12%). Commander immédiatement.',
      categorie: CategorieNotif.stock,
      urgence: NiveauUrgence.critique,
      lu: false,
      dateEnvoi: DateTime.now().subtract(const Duration(minutes: 5)),
      lienModuleSource: 'inventaire',
    ),
    NotificationModel(
      id: 'n2',
      destinataireId: 'u1',
      message: 'Commande VTE-2023-087 validée par le responsable vente.',
      categorie: CategorieNotif.vente,
      urgence: NiveauUrgence.info,
      lu: false,
      dateEnvoi: DateTime.now().subtract(const Duration(minutes: 32)),
      lienModuleSource: 'ventes',
    ),
    NotificationModel(
      id: 'n3',
      destinataireId: 'u1',
      message:
          'Lot LOT-2023-442 atteint 75% de progression — Phase 3 imminente.',
      categorie: CategorieNotif.production,
      urgence: NiveauUrgence.avertissement,
      lu: false,
      dateEnvoi: DateTime.now().subtract(const Duration(hours: 1)),
      lienModuleSource: 'production',
    ),
    NotificationModel(
      id: 'n4',
      destinataireId: 'u1',
      message:
          "Achat ACH-2023-041 : livraison PolyChim Industries confirmée pour aujourd'hui.",
      categorie: CategorieNotif.achat,
      urgence: NiveauUrgence.info,
      lu: true,
      dateEnvoi: DateTime.now().subtract(const Duration(hours: 3)),
      lienModuleSource: 'achats',
    ),
    NotificationModel(
      id: 'n5',
      destinataireId: 'u1',
      message: 'Rapport journalier de production disponible. OEE: 94.2%.',
      categorie: CategorieNotif.production,
      urgence: NiveauUrgence.info,
      lu: true,
      dateEnvoi: DateTime.now().subtract(const Duration(hours: 8)),
      lienModuleSource: 'rapports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.lu).length;

    return Container(
      width: 380,
      decoration: const BoxDecoration(
        color: AppTheme.whiteSurface,
        border: Border(left: BorderSide(color: Colors.black)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 20,
            offset: Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.sp20,
              vertical: AppTheme.sp16,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black)),
            ),
            child: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                if (unread > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: const Text(
                    'Tout marquer lu',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 18,
                    color: Colors.white,
                  ),
              ],
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.sp16,
              vertical: AppTheme.sp10,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterPill(label: 'Tout', selected: true),
                  _FilterPill(label: 'Stock'),
                  _FilterPill(label: 'Production'),
                  _FilterPill(label: 'Vente'),
                  _FilterPill(label: 'Achat'),
                ],
              ),
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, i) =>
                  _NotifTile(notification: _notifications[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? Colors.black : AppTheme.whiteSurface2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppTheme.greyLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final (color, bg, icon) = _urgenceStyle(n.urgence);
    final catColor = _catColor(n.categorie);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: n.lu
            ? AppTheme.whiteSurface
            : AppTheme.whiteSurface.withOpacity(0.4),
        border: const Border(
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp16,
            vertical: AppTheme.sp12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: AppTheme.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            n.categorie.label.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: catColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _timeAgo(n.dateEnvoi),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.greyLight,
                          ),
                        ),
                        if (!n.lu) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      n.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: n.lu ? Colors.white : Colors.white,
                        height: 1.4,
                        fontWeight: n.lu ? FontWeight.w400 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static (Color, Color, IconData) _urgenceStyle(NiveauUrgence u) => switch (u) {
        NiveauUrgence.critique => (
            AppTheme.red,
            AppTheme.red,
            Icons.error_outline_rounded,
          ),
        NiveauUrgence.avertissement => (
            AppTheme.yellow,
            AppTheme.yellow,
            Icons.warning_amber_rounded,
          ),
        NiveauUrgence.info => (
            AppTheme.greenBright,
            AppTheme.greenBright,
            Icons.info_outline_rounded,
          ),
      };

  static Color _catColor(CategorieNotif c) => switch (c) {
        CategorieNotif.stock => AppTheme.yellow,
        CategorieNotif.production => Colors.black,
        CategorieNotif.vente => AppTheme.greenBright,
        CategorieNotif.achat => AppTheme.blueLight,
      };

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return DateFormat('dd/MM').format(dt);
  }
}

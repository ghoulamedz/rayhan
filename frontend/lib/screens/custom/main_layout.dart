import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/widgets/custom/app_sidebar.dart';
import 'package:rayhan_erp/widgets/custom/app_topbar.dart';
import 'package:rayhan_erp/widgets/custom/notifications_panel.dart';
import 'dashboard_screen.dart';
import 'gestion_ventes_screen.dart';
import 'inventaire_screen.dart';
import 'suivi_production_screen.dart';
import 'achats_screen.dart';
import 'placeholder_screen.dart';
import 'rapports_screen.dart';
import 'maintenance_screen.dart';
import 'qualite_screen.dart';
import 'parametres_screen.dart';

/// Root scaffold composing [AppSidebar], [AppTopBar], and the active screen.
/// Also hosts the animated [NotificationsPanel] slide-over overlay.
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  String _selectedId = 'dashboard';
  bool _sidebarCollapsed = false;
  bool _notifPanelOpen = false;
  //AppTopBar hide on scroll (using a ScrollController):
  final ScrollController _scrollController = ScrollController();
  double _previousOffset = 0;
  bool _isAppBarVisible = true;

  late final AnimationController _notifController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  late final Animation<Offset> _notifSlide = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _notifController, curve: Curves.easeOut),
  );
  // onscroll setstate method :
  void _onScroll() {
    double currentOffset = _scrollController.offset;

    if (currentOffset > _previousOffset) {
      if (_isAppBarVisible) {
        setState(() => _isAppBarVisible = false);
      }
    } else if (currentOffset < _previousOffset) {
      if (!_isAppBarVisible) {
        setState(() => _isAppBarVisible = true);
      }
    }

    _previousOffset = currentOffset;
  }

  // initState :
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _notifController.dispose();
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onSelect(String id) => setState(() => _selectedId = id);

  void _toggleSidebar() =>
      setState(() => _sidebarCollapsed = !_sidebarCollapsed);

  void _openNotifs() {
    setState(() => _notifPanelOpen = true);
    _notifController.forward();
  }

  Future<void> _closeNotifs() async {
    await _notifController.reverse();
    if (mounted) setState(() => _notifPanelOpen = false);
  }

  Widget _screenFor(String id) => switch (id) {
        'dashboard' => const DashboardScreen(),
        'ventes' => const GestionVentesScreen(),
        'production' => const SuiviProductionScreen(),
        'inventaire' => const InventaireScreen(),
        'achats' => const AchatsScreen(),
        'rapports' => const RapportsScreen(),
        'maintenance' => const MaintenanceScreen(),
        'qualite' => const QualiteScreen(),
        'parametres' => const ParametresScreen(),
        _ => PlaceholderScreen(navId: id),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteSurface,
      body: Stack(
        children: [
          // ── Core two-column layout ─────────────────────────────────────
          Row(
            children: [
              AppSidebar(
                selectedId: _selectedId,
                onSelect: _onSelect,
                collapsed: _sidebarCollapsed,
              ),
              Expanded(
                child: Column(
                  children: [
                    AppTopBar(
                      isAppBarVisible: _isAppBarVisible,
                      onToggleSidebar: _toggleSidebar,
                      onNotificationTap: _openNotifs,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: KeyedSubtree(
                          key: ValueKey(_selectedId),
                          child: _screenFor(_selectedId),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Notification panel overlay ─────────────────────────────────
          if (_notifPanelOpen) ...[
            GestureDetector(
              onTap: _closeNotifs,
              child: Container(color: Colors.black.withValues(alpha: 0.25)),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _notifSlide,
                child: NotificationsPanel(onClose: _closeNotifs),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

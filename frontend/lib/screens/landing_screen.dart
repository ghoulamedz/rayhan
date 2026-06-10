import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/constants/app_text.dart';
import 'package:rayhan_erp/constants/colors.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  double _scrollOffset = 0;
  late final ScrollController _scrollCtrl;
  late final AnimationController _heroAnimCtrl;
  late final Animation<double> _heroTitleFade;
  late final Animation<Offset> _heroTitleSlide;
  late final Animation<double> _heroSubtitleFade;
  late final Animation<Offset> _heroSubtitleSlide;
  late final Animation<double> _heroBadgesFade;
  late final Animation<Offset> _heroBadgesSlide;
  late final Animation<double> _heroDividerFade;
  late final Animation<Offset> _heroDividerSlide;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()..addListener(_onScroll);
    _heroAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
    _heroTitleFade = CurvedAnimation(
        parent: _heroAnimCtrl,
        curve: const Interval(0, 0.5, curve: Curves.easeOut));
    _heroTitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _heroAnimCtrl,
        curve: const Interval(0, 0.5, curve: Curves.easeOut)));
    _heroSubtitleFade = CurvedAnimation(
        parent: _heroAnimCtrl,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut));
    _heroSubtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _heroAnimCtrl,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut)));
    _heroBadgesFade = CurvedAnimation(
        parent: _heroAnimCtrl,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut));
    _heroBadgesSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _heroAnimCtrl,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut)));
    _heroDividerFade = CurvedAnimation(
        parent: _heroAnimCtrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut));
    _heroDividerSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _heroAnimCtrl,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _heroAnimCtrl.dispose();
    super.dispose();
  }

  void _onScroll() => setState(() => _scrollOffset = _scrollCtrl.offset);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroSection(),
                _withReveal(startOffset: 200, child: _buildProductsSection()),
                _withReveal(startOffset: 1000, child: _buildPourquoiSection()),
                _withReveal(startOffset: 1600, child: _buildModulesSection()),
                _withReveal(startOffset: 2000, child: _buildFooter()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Parallax helper ──────────────────────────────────────────────
  Widget _withParallax({
    required Widget child,
    required double factor,
    double startOffset = 0,
  }) {
    final offset = max(0, _scrollOffset - startOffset) * factor;
    return Transform.translate(
      offset: Offset(0, -offset),
      child: child,
    );
  }

  Widget _withReveal({
    required Widget child,
    required double startOffset,
    double distance = 400,
  }) {
    final t = ((_scrollOffset - startOffset) / distance).clamp(0.0, 1.0);
    return Opacity(
      opacity: t,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - t)),
        child: child,
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────
  Widget _buildAppBar() {
    final collapsed = _scrollOffset > 30;
    return SliverAppBar(
      centerTitle: false,
      floating: false,
      pinned: true,
      expandedHeight: 80,
      elevation: collapsed ? 1 : 0,
      backgroundColor: collapsed
          ? AppTheme.kDeepIndustrialBlue.withValues(alpha: 0.95)
          : Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: collapsed
            ? null
            : BoxDecoration(
                gradient: AppTheme.kPrimaryGradient,
              ),
        child: FlexibleSpaceBar(
          titlePadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/rayhan_icon.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'RayhanERP',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Se connecter'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero Section ────────────────────────────────────────────────
  Widget _buildHeroSection() {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: _withParallax(
            factor: 0.3,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.deepIndustrialBlue,
                    AppColors.primary,
                    AppColors.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: _withParallax(
            factor: 0.3,
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: const [Colors.transparent, Colors.white],
                stops: const [0.4, 0.7],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/factory_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(64, 60, 64, 120),
          child: _heroTextContent(),
        ),
      ],
    );
  }

  Widget _heroTextContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _heroTitleFade,
            child: SlideTransition(
              position: _heroTitleSlide,
              child: Text(
                AppText.heroTitle,
                style: AppTheme.displayLarge.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _heroSubtitleFade,
            child: SlideTransition(
              position: _heroSubtitleSlide,
              child: Text(
                AppText.heroSubtitle,
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeTransition(
            opacity: _heroBadgesFade,
            child: SlideTransition(
              position: _heroBadgesSlide,
              child: Row(
                children: [
                  _badge(Icons.check_circle, 'Certifié ISO 9001'),
                  const SizedBox(width: 16),
                  _badge(Icons.local_shipping, 'Livraison Express'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _heroDividerFade,
            child: SlideTransition(
              position: _heroDividerSlide,
              child: Row(
                children: [
                  Container(
                    height: 3,
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.growthGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Depuis 1992',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontFamily: 'Inter')),
        ],
      ),
    );
  }

  // ── Products Section ────────────────────────────────────────────
  Widget _buildProductsSection() {
    return AppTheme.glassBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 32),
        child: Column(
          children: [
            Text(AppText.productsTitle,
                style: AppTheme.headlineLarge
                    .copyWith(color: AppTheme.kTextPrimary)),
            const SizedBox(height: 12),
            Text(AppText.productsSubtitle,
                textAlign: TextAlign.center,
                style: AppTheme.bodyLarge
                    .copyWith(color: AppTheme.kTextSecondary)),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (ctx, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 600
                        ? 2
                        : 1;
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 460,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  children: [
                    _productCard(
                      title: AppText.productSacs,
                      desc: AppText.productSacsDesc,
                      icon: Icons.inventory_2_rounded,
                      accent: AppColors.deepIndustrialBlue,
                      imagePath: 'assets/images/products/product_sacs.jpg',
                    ),
                    _productCard(
                      title: AppText.productFilm,
                      desc: AppText.productFilmDesc,
                      icon: Icons.wrap_text_rounded,
                      accent: AppColors.growthGreen,
                      imagePath: 'assets/images/products/product_film.jpg',
                    ),
                    _productCard(
                      title: AppText.productSangles,
                      desc: AppText.productSanglesDesc,
                      icon: Icons.link_rounded,
                      accent: AppColors.safetyOrange,
                      imagePath: 'assets/images/products/product_sangles.jpg',
                    ),
                    _productCard(
                      title: AppText.productPoubelle,
                      desc: AppText.productPoubelleDesc,
                      icon: Icons.cleaning_services_rounded,
                      accent: AppColors.primaryContainer,
                      imagePath: 'assets/images/products/product_poubelle.jpg',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color accent,
    required String imagePath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(icon, color: accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(title,
                            style: AppTheme.titleSmall.copyWith(
                                fontSize: 16, color: AppTheme.kTextPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(desc,
                        style: AppTheme.bodySmall
                            .copyWith(color: AppTheme.kTextSecondary)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/catalogue'),
                      style: AppTheme.primaryButton.copyWith(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                      child: const Text('Commander',
                          style: TextStyle(fontSize: 22)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pourquoi Section ────────────────────────────────────────────
  Widget _buildPourquoiSection() {
    return Stack(
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.topCenter,
      children: [
        Positioned.fill(
          child: _withParallax(
            factor: 0.1,
            startOffset: 1400,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.deepIndustrialBlue,
                    AppColors.primary,
                    AppColors.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: _withParallax(
            factor: 0.1,
            startOffset: 1400,
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: const [
                  Colors.white,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.white
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'assets/images/factory_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 64),
          child: Column(
            children: [
              Text(AppText.pourquoiTitle,
                  style: AppTheme.headlineLarge.copyWith(color: Colors.white)),
              const SizedBox(height: 12),
              Text(
                'Découvrez pourquoi les plus grands industriels tunisiens nous font confiance.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 48),
              LayoutBuilder(
                builder: (ctx, constraints) {
                  return Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    alignment: WrapAlignment.center,
                    children: [
                      _pourquoiCard(
                        icon: Icons.verified_rounded,
                        title: AppText.pourquoiQuality,
                        desc: AppText.pourquoiQualityDesc,
                      ),
                      _pourquoiCard(
                        icon: Icons.flash_on_rounded,
                        title: AppText.pourquoiDelivery,
                        desc: AppText.pourquoiDeliveryDesc,
                      ),
                      _pourquoiCard(
                        icon: Icons.auto_awesome_rounded,
                        title: AppText.pourquoiExpertise,
                        desc: AppText.pourquoiExpertiseDesc,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pourquoiCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppTheme.titleLarge.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(desc,
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              )),
        ],
      ),
    );
  }

  // ── Modules Section ────────────────────────────────────────────
  Widget _buildModulesSection() {
    return Container(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 32),
        child: Column(
          children: [
            Text(AppText.modulesTitle,
                style: AppTheme.headlineLarge
                    .copyWith(color: AppTheme.kTextPrimary)),
            const SizedBox(height: 12),
            Text(AppText.modulesSubtitle,
                textAlign: TextAlign.center,
                style: AppTheme.bodyLarge
                    .copyWith(color: AppTheme.kTextSecondary)),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (ctx, constraints) {
                return Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _moduleCard(
                      icon: Icons.dashboard_rounded,
                      title: 'Tableau de bord',
                      desc: 'Indicateurs en temps réel',
                      accent: AppColors.deepIndustrialBlue,
                    ),
                    _moduleCard(
                      icon: Icons.shopping_cart_rounded,
                      title: 'Gestion des ventes',
                      desc: 'Commandes, factures, clients',
                      accent: AppColors.growthGreen,
                    ),
                    _moduleCard(
                      icon: Icons.local_shipping_rounded,
                      title: 'Gestion des achats',
                      desc: 'Approvisionnement, fournisseurs',
                      accent: AppColors.safetyOrange,
                    ),
                    _moduleCard(
                      icon: Icons.precision_manufacturing_rounded,
                      title: 'Production',
                      desc: 'OF, BOM, suivi atelier',
                      accent: AppColors.primaryContainer,
                    ),
                    _moduleCard(
                      icon: Icons.warehouse_rounded,
                      title: 'Gestion de stock',
                      desc: 'Mouvements, alertes, inventaire',
                      accent: AppColors.growthGreen,
                    ),
                    _moduleCard(
                      icon: Icons.inventory_2_rounded,
                      title: 'Articles & Produits',
                      desc: 'MP, PSF, PF, nomenclatures',
                      accent: AppColors.deepIndustrialBlue,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color accent,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: AppTheme.titleSmall
                  .copyWith(fontSize: 16, color: AppTheme.kTextPrimary)),
          const SizedBox(height: 6),
          Text(desc,
              style:
                  AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
        ],
      ),
    );
  }

  // ── Footer ──────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.deepIndustrialBlue,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.factory_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Text(
                'RayhanERP',
                style: AppTheme.headlineMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            AppText.footerTagline,
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Text(
            '© ${DateTime.now().year} ${AppText.footerCopyright}',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppText.footerRights,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

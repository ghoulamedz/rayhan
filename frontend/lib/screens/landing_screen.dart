import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/constants/app_text.dart';
import 'package:rayhan_erp/providers/auth_provider.dart';
import 'package:rayhan_erp/mock/mock_config.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  double _scrollOffset = 0;
  late final ScrollController _scrollCtrl;
  late final AnimationController _heroAnimCtrl;
  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()..addListener(_onScroll);
    _heroAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _heroFade = CurvedAnimation(
        parent: _heroAnimCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut));
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _heroAnimCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _scrollCtrl.dispose();
    _heroAnimCtrl.dispose();
    super.dispose();
  }

  void _onScroll() => setState(() => _scrollOffset = _scrollCtrl.offset);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_usernameCtrl.text, _passwordCtrl.text);
    if (!mounted) return;
    if (ok) {
      context.go('/dashboard');
    }
  }

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
              children: [
                _buildHeroSection(),
                _buildProductsSection(),
                _buildPourquoiSection(),
                _buildModulesSection(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final scrollRatio = (_scrollOffset / 80).clamp(0.0, 1.0);
    final easedRatio = Curves.easeOut.transform(scrollRatio);

    return SliverAppBar(
      centerTitle: false,
      floating: false,
      pinned: true,
      expandedHeight: 80,
      elevation: 2 * easedRatio,
      backgroundColor: Color.lerp(Colors.transparent, AppTheme.kSurfaceWhite, easedRatio),
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: scrollRatio < 1
              ? LinearGradient(
                  colors: [
                    Color.lerp(AppTheme.kPrimaryNavy, AppTheme.kSurfaceWhite, easedRatio)!,
                    Color.lerp(AppTheme.kPrimaryTeal, AppTheme.kSurfaceWhite, easedRatio)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: scrollRatio >= 1 ? AppTheme.kSurfaceWhite : null,
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
                      color: Color.lerp(
                        Colors.white.withValues(alpha: 0.2),
                        AppTheme.kPrimaryTeal,
                        easedRatio,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/rayhan_icon.png',
                      width: 22,
                      height: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'RayhanERP',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Color.lerp(Colors.white, AppTheme.kTextPrimary, easedRatio),
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => _scrollTo(0),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text('Se connecter'),
                style: FilledButton.styleFrom(
                  backgroundColor: Color.lerp(
                    Colors.white.withValues(alpha: 0.2),
                    AppTheme.kPrimaryTeal,
                    easedRatio,
                  ),
                  foregroundColor: Color.lerp(
                    Colors.white,
                    AppTheme.kWhite,
                    easedRatio,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.kPrimaryNavy,
            AppTheme.kPrimaryTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
      child: FadeTransition(
        opacity: _heroFade,
        child: SlideTransition(
          position: _heroSlide,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 800;
              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 3, child: _heroTextContent()),
                        const SizedBox(width: 40),
                        Expanded(flex: 2, child: _loginCard()),
                      ],
                    )
                  : Column(
                      children: [
                        _heroTextContent(),
                        const SizedBox(height: 40),
                        _loginCard(),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _heroTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          AppText.heroTitle,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppText.heroSubtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.85),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Certifié ISO 9001',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_shipping, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('Livraison Express',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: AppTheme.kSecondaryAmber,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Depuis 1992',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _loginCard() {
    final auth = context.watch<AuthProvider>();
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.kSurfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppText.heroLoginTitle,
                style: AppTheme.headlineSmall.copyWith(fontSize: 20)),
            const SizedBox(height: 6),
            Text(AppText.heroLoginSubtitle,
                style: AppTheme.bodySmall
                    .copyWith(color: AppTheme.kTextSecondary)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Obligatoire' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              validator: (v) => v == null || v.isEmpty ? 'Obligatoire' : null,
            ),
            if (auth.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.kErrorRedLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.kErrorRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(auth.errorMessage!,
                          style: const TextStyle(
                              color: AppTheme.kErrorRed, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
            if (MockConfig.useMock) ...[
              const SizedBox(height: 16),
              _buildMockUsersHint(),
            ],
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : _login,
                style: AppTheme.primaryButton,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Se connecter',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(AppText.forgotPasswordLink,
                      style: TextStyle(
                          color: AppTheme.kPrimaryTeal, fontSize: 12)),
                ),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: Text(AppText.signupLink,
                      style: TextStyle(
                          color: AppTheme.kPrimaryTeal, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockUsersHint() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _showMockUsersDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.kBorderLight),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.people_outline, size: 16, color: AppTheme.kPrimaryBurgundyLight),
              const SizedBox(width: 8),
              Text('Compte de démonstration',
                  style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.kTextSecondary, fontWeight: FontWeight.w500)),
              const Spacer(),
              Icon(Icons.chevron_right, size: 16, color: AppTheme.kTextHint),
            ],
          ),
        ),
      ),
    );
  }

  void _showMockUsersDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        title: Row(
          children: [
            Icon(Icons.people_outline, size: 20, color: AppTheme.kPrimaryBurgundy),
            const SizedBox(width: 8),
            Text('Comptes de démonstration',
                style: AppTheme.titleSmall),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: MockConfig.mockUsers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final user = MockConfig.mockUsers[i];
              return ListTile(
                dense: true,
                leading: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _roleColor(user.role),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(user.username,
                    style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600)),
                subtitle: Text(_roleShortLabel(user.role),
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
                trailing: Text('••••••',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextHint)),
                onTap: () {
                  _usernameCtrl.text = user.username;
                  _passwordCtrl.text = user.password;
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Fermer',
                style: TextStyle(color: AppTheme.kPrimaryBurgundy)),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ROLE_PDG': return AppTheme.kPrimaryNavy;
      case 'ROLE_RESPONSABLE_VENTE': return AppTheme.kPrimaryTeal;
      case 'ROLE_RESPONSABLE_ACHAT': return AppTheme.kCtaOrange;
      case 'ROLE_RESPONSABLE_PRODUCTION': return AppTheme.kWarningAmber;
      case 'ROLE_MAGASINIER': return AppTheme.kSuccessGreen;
      case 'ROLE_CLIENT': return AppTheme.kPrimaryTeal;
      default: return AppTheme.kTextHint;
    }
  }

  String _roleShortLabel(String role) {
    switch (role) {
      case 'ROLE_PDG': return 'Gérant';
      case 'ROLE_RESPONSABLE_VENTE': return 'Ventes';
      case 'ROLE_RESPONSABLE_ACHAT': return 'Achats';
      case 'ROLE_RESPONSABLE_PRODUCTION': return 'Production';
      case 'ROLE_MAGASINIER': return 'Magasin';
      case 'ROLE_CLIENT': return 'Client';
      default: return role;
    }
  }

  void _scrollTo(double offset) {
    _scrollCtrl.animateTo(offset,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  Widget _buildProductsSection() {
    return Container(
      color: AppTheme.kBackgroundOffWhite,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          Text(AppText.productsTitle,
              style: AppTheme.headlineLarge.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text(AppText.productsSubtitle,
              textAlign: TextAlign.center,
              style:
                  AppTheme.bodyMedium.copyWith(color: AppTheme.kTextSecondary)),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _productCard(
                    title: AppText.productSacs,
                    desc: AppText.productSacsDesc,
                    icon: Icons.inventory_2_rounded,
                    color: AppTheme.kPrimaryTeal,
                    imagePath: 'assets/images/product_sacs.jpg',
                  ),
                  _productCard(
                    title: AppText.productFilm,
                    desc: AppText.productFilmDesc,
                    icon: Icons.wrap_text_rounded,
                    color: AppTheme.kSecondaryAmber,
                    imagePath: 'assets/images/product_film.jpg',
                  ),
                  _productCard(
                    title: AppText.productSangles,
                    desc: AppText.productSanglesDesc,
                    icon: Icons.link_rounded,
                    color: AppTheme.kCtaOrange,
                    imagePath: 'assets/images/product_sangles.jpg',
                  ),
                  _productCard(
                    title: AppText.productPoubelle,
                    desc: AppText.productPoubelleDesc,
                    icon: Icons.cleaning_services_rounded,
                    color: AppTheme.kPrimaryTealDark,
                    imagePath: 'assets/images/product_poubelle.jpg',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _productCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required String imagePath,
  }) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppTheme.kSurfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowMd,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(title,
                          style: AppTheme.titleSmall.copyWith(fontSize: 15)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(desc,
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.kTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPourquoiSection() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.kPrimaryNavy,
            AppTheme.kPrimaryTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          Text(AppText.pourquoiTitle,
              style: AppTheme.headlineLarge
                  .copyWith(fontSize: 28, color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Découvrez pourquoi les plus grands industriels tunisiens nous font confiance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
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
    );
  }

  Widget _pourquoiCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17)),
          const SizedBox(height: 8),
          Text(desc,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.5,
              )),
        ],
      ),
    );
  }

  Widget _buildModulesSection() {
    return Container(
      color: AppTheme.kBackgroundOffWhite,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        children: [
          Text(AppText.modulesTitle,
              style: AppTheme.headlineLarge.copyWith(fontSize: 28)),
          const SizedBox(height: 8),
          Text(AppText.modulesSubtitle,
              textAlign: TextAlign.center,
              style:
                  AppTheme.bodyMedium.copyWith(color: AppTheme.kTextSecondary)),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (ctx, constraints) {
              final isWide = constraints.maxWidth > 700;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _moduleCard(
                    icon: Icons.dashboard_rounded,
                    title: 'Tableau de bord',
                    desc: 'Indicateurs en temps réel',
                    color: AppTheme.kPrimaryTeal,
                  ),
                  _moduleCard(
                    icon: Icons.shopping_cart_rounded,
                    title: 'Gestion des ventes',
                    desc: 'Commandes, factures, clients',
                    color: AppTheme.kSecondaryAmber,
                  ),
                  _moduleCard(
                    icon: Icons.local_shipping_rounded,
                    title: 'Gestion des achats',
                    desc: 'Approvisionnement, fournisseurs',
                    color: AppTheme.kCtaOrange,
                  ),
                  _moduleCard(
                    icon: Icons.precision_manufacturing_rounded,
                    title: 'Production',
                    desc: 'OF, BOM, suivi atelier',
                    color: AppTheme.kPrimaryTealDark,
                  ),
                  _moduleCard(
                    icon: Icons.warehouse_rounded,
                    title: 'Gestion de stock',
                    desc: 'Mouvements, alertes, inventaire',
                    color: AppTheme.kSuccessGreen,
                  ),
                  _moduleCard(
                    icon: Icons.inventory_2_rounded,
                    title: 'Articles & Produits',
                    desc: 'MP, PSF, PF, nomenclatures',
                    color: AppTheme.kSecondaryAmber,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _moduleCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.kSurfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: AppTheme.titleSmall
                  .copyWith(fontSize: 15, color: AppTheme.kTextPrimary)),
          const SizedBox(height: 4),
          Text(desc,
              style:
                  AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF131B2E), Color(0xFF1A2338)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/rayhan_icon.png',
                  width: 24,
                  height: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'RayhanERP',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppText.footerTagline,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '© ${DateTime.now().year} ${AppText.footerCopyright}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppText.footerRights,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

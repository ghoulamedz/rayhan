import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rayhan_erp/screens/custom/main_layout.dart';
import 'package:rayhan_erp/theme/app_theme.dart';
import 'package:rayhan_erp/widgets/custom/box_shadow_logo.dart';
import 'package:rayhan_erp/widgets/custom/brand_panel.dart';
import 'package:rayhan_erp/widgets/custom/carousel_card.dart';
import 'package:rayhan_erp/widgets/custom/demo_hint.dart';
import 'package:rayhan_erp/widgets/custom/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/rayhan_logo.dart';
import 'package:rayhan_erp/widgets/custom/system_status_chip.dart';
import '../providers/auth_provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  double _scrollOffset = 0;
  int _carouselIndex = 0;
  Timer? _carouselTimer;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final Animation<double> _fadeIn =
      CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  late final Animation<Offset> _slideIn = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));

  late ScrollController _scrollController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(_onCarouselScroll);
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _anim.dispose();
    _scrollController.dispose();
    _pageController.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _onCarouselScroll() {
    setState(() {
      _carouselIndex = _pageController.page?.round() ?? 0;
    });
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainLayout(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
      // context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final carouselItems = [
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1505228395891-9a51e7e86e81?w=400&h=300&fit=crop',
        'heading': 'Beautiful Landscape',
        'description':
            'Explore stunning natural sceneries and breathtaking views',
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
        'heading': 'Mountain Adventure',
        'description':
            'Experience the thrill of mountain climbing and exploration',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      // extendBodyBehindAppBar: true,
      // appBar: AppBar(
      //   elevation: 10,
      //   title: const Text('Rayhan Logo'),
      //   backgroundColor: Colors.transparent,
      //   flexibleSpace: const FlexibleSpaceBar(
      //     title: Text('SliverAppBar'),
      //     background: FlutterLogo(),
      //   ),
      // ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            stretch: true,
            floating: false,
            pinned: true,
            onStretchTrigger: () async {
              // Triggers when stretching
            },
            // [stretchTriggerOffset] describes the amount of overscroll that must occur
            // to trigger [onStretchTrigger]
            //
            // Setting [stretchTriggerOffset] to a value of 300.0 will trigger
            // [onStretchTrigger] when the user has overscrolled by 300.0 pixels.
            stretchTriggerOffset: 300.0,
            expandedHeight: 200.0,
            elevation: _scrollOffset > 100 ? 10 : 0,
            backgroundColor: Color.lerp(
              Colors.black12,
              AppTheme.primary,
              (_scrollOffset / 300).clamp(0, 1),
            ),
            leading: const RayhanLogo(),
            flexibleSpace: FlexibleSpaceBar(
              title: Opacity(
                opacity: (_scrollOffset / 200).clamp(0, 1),
                child: const Text(
                  'RayhanERP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryLight, AppTheme.primaryDark],
                  ),
                ),
                child: Center(
                  child: Opacity(
                    opacity: 1 - (_scrollOffset / 300).clamp(0, 1),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        BoxShadowLogo(),
                        SizedBox(height: 16),
                        Text(
                          'Welcome to RayhanERP',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      const Text(
                        'Featured Items',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: carouselItems.length,
                          itemBuilder: (context, index) {
                            final item = carouselItems[index];
                            return CarouselCard(
                              imageUrl: item['imageUrl'] as String,
                              heading: item['heading'] as String,
                              description: item['description'] as String,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Carousel Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          carouselItems.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: index == _carouselIndex ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: index == _carouselIndex
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32), //   const BrandPanel(),
                Center(
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideIn,
                      child: Container(
                        //  width: 420,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF0F172A), // slate-900
                              Color(0xFF0D9488), // teal-600
                            ],
                            stops: [0.0, 1.0],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.sp24, vertical: AppTheme.sp20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Column(
                                  children: [
                                    Text(
                                      'La performance industrielle à portée de main.',
                                      style: TextStyle(
                                        color: AppTheme.infoSurface,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: AppTheme.sp12),
                                    Text(
                                      'Gérez vos ventes, votre production, vos stocks et '
                                      'vos achats depuis une interface unifiée et temps réel.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 320),
                                Column(
                                  children: [
                                    const SizedBox(width: AppTheme.sp8),

                                    // Feature list
                                    ...[
                                      (
                                        Icons.speed_rounded,
                                        'Tableau de bord en temps réel'
                                      ),
                                      (
                                        Icons.precision_manufacturing_rounded,
                                        'Suivi production OEE'
                                      ),
                                      (
                                        Icons.inventory_2_rounded,
                                        'Gestion stocks & silos'
                                      ),
                                      (
                                        Icons.shopping_cart_rounded,
                                        'Commandes & facturation'
                                      ),
                                    ].map(
                                      (item) => Padding(
                                        padding: const EdgeInsets.only(
                                            left: AppTheme.sp24,
                                            bottom: AppTheme.sp12),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Icon(item.$1,
                                                  size: 15,
                                                  color: AppTheme.primaryLight),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              item.$2,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),

                            // Footer
                            Text(
                              '© ${DateTime.now().year} RayhanERP — v1.0.0',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // body: Center(
      //   child: SingleChildScrollView(
      //     padding: const EdgeInsets.all(24),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         const BoxShadowLogo(),
      //         Text(
      //           'Système de Gestion Intégré',
      //           style: theme.textTheme.bodyMedium?.copyWith(
      //             color: Colors.grey[600],
      //           ),
      //         ),
      //         const SizedBox(height: 40),

      //         // Carte de connexion
      //         Container(
      //           constraints: const BoxConstraints(maxWidth: 420),
      //           decoration: BoxDecoration(
      //             color: Colors.white,
      //             borderRadius: BorderRadius.circular(16),
      //             boxShadow: [
      //               BoxShadow(
      //                 color: Colors.black.withValues(alpha: 0.08),
      //                 blurRadius: 24,
      //                 offset: const Offset(0, 4),
      //               ),
      //             ],
      //           ),
      //           padding: const EdgeInsets.all(32),
      //           child: Form(
      //             key: _formKey,
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.stretch,
      //               children: [
      //                 Text(
      //                   'Connexion',
      //                   style: theme.textTheme.titleLarge?.copyWith(
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 const SizedBox(height: 8),
      //                 Text(
      //                   'Entrez vos identifiants pour accéder au système',
      //                   style: theme.textTheme.bodySmall?.copyWith(
      //                     color: Colors.grey[600],
      //                   ),
      //                 ),
      //                 const SizedBox(height: 28),

      //                 // Champ nom d'utilisateur
      //                 TextFormField(
      //                   controller: _usernameController,
      //                   decoration: InputDecoration(
      //                     labelText: 'Nom d\'utilisateur',
      //                     prefixIcon: const Icon(Icons.person_outline),
      //                     border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     filled: true,
      //                     fillColor: const Color(0xFFF8F9FA),
      //                   ),
      //                   textInputAction: TextInputAction.next,
      //                   validator: (v) => (v == null || v.trim().isEmpty)
      //                       ? 'Champ obligatoire'
      //                       : null,
      //                 ),
      //                 const SizedBox(height: 16),

      //                 // Champ mot de passe
      //                 TextFormField(
      //                   controller: _passwordController,
      //                   obscureText: _obscurePassword,
      //                   decoration: InputDecoration(
      //                     labelText: 'Mot de passe',
      //                     prefixIcon: const Icon(Icons.lock_outline),
      //                     suffixIcon: IconButton(
      //                       icon: Icon(_obscurePassword
      //                           ? Icons.visibility_off_outlined
      //                           : Icons.visibility_outlined),
      //                       onPressed: () => setState(
      //                           () => _obscurePassword = !_obscurePassword),
      //                     ),
      //                     border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(10),
      //                     ),
      //                     filled: true,
      //                     fillColor: const Color(0xFFF8F9FA),
      //                   ),
      //                   textInputAction: TextInputAction.done,
      //                   onFieldSubmitted: (_) => _submit(),
      //                   validator: (v) => (v == null || v.isEmpty)
      //                       ? 'Champ obligatoire'
      //                       : null,
      //                 ),
      //                 const SizedBox(height: 12),

      //                 // Message d'erreur
      //                 if (auth.errorMessage != null)
      //                   Container(
      //                     padding: const EdgeInsets.all(12),
      //                     decoration: BoxDecoration(
      //                       color: Colors.red[50],
      //                       borderRadius: BorderRadius.circular(8),
      //                       border: Border.all(color: Colors.red[200]!),
      //                     ),
      //                     child: Row(
      //                       children: [
      //                         Icon(Icons.error_outline,
      //                             color: Colors.red[700], size: 18),
      //                         const SizedBox(width: 8),
      //                         Expanded(
      //                           child: Text(
      //                             auth.errorMessage!,
      //                             style: TextStyle(
      //                                 color: Colors.red[700], fontSize: 13),
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),

      //                 const SizedBox(height: 24),

      //                 // Bouton connexion
      //                 SizedBox(
      //                   height: 50,
      //                   child: ElevatedButton(
      //                     onPressed: auth.isLoading ? null : _submit,
      //                     style: ElevatedButton.styleFrom(
      //                       backgroundColor: theme.colorScheme.primary,
      //                       foregroundColor: Colors.white,
      //                       shape: RoundedRectangleBorder(
      //                         borderRadius: BorderRadius.circular(10),
      //                       ),
      //                       elevation: 2,
      //                     ),
      //                     child: auth.isLoading
      //                         ? const SizedBox(
      //                             width: 22,
      //                             height: 22,
      //                             child: CircularProgressIndicator(
      //                               strokeWidth: 2,
      //                               color: Colors.white,
      //                             ),
      //                           )
      //                         : const Text(
      //                             'Se connecter',
      //                             style: TextStyle(
      //                               fontSize: 16,
      //                               fontWeight: FontWeight.w600,
      //                             ),
      //                           ),
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),

      //         const SizedBox(height: 32),
      //         Text(
      //           '© 2026 SUARL Rayhan — Tataouine, Tunisie',
      //           style: TextStyle(color: Colors.grey[500], fontSize: 12),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}

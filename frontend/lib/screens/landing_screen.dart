import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:rayhan_erp/constants/app_text.dart';
import 'package:rayhan_erp/screens/custom/main_layout.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/screens/dashboard_screen.dart';
import 'package:rayhan_erp/screens/final/landing_page_sections/dashboard_section.dart';
import 'package:rayhan_erp/screens/final/landing_page_sections/footer_section.dart';
import 'package:rayhan_erp/screens/final/landing_page_sections/hero_section.dart';
import 'package:rayhan_erp/screens/final/landing_page_sections/module_grid_section.dart';
import 'package:rayhan_erp/screens/final/landing_page_sections/nav_bar.dart';
import 'package:rayhan_erp/screens/final/landing_page_sections/trust_and_cta_sections.dart';
import 'package:rayhan_erp/screens/final/landing_page_sections/value_proposition_section.dart';
import 'package:rayhan_erp/widgets/custom/box_shadow_logo.dart';
import 'package:rayhan_erp/widgets/custom/brand_panel.dart';
import 'package:rayhan_erp/widgets/custom/carousel_card.dart';
import 'package:rayhan_erp/widgets/custom/demo_hint.dart';
import 'package:rayhan_erp/widgets/final/common/layout_widgets.dart';
import 'package:rayhan_erp/widgets/custom/parallax_section.dart';

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
  // final _formKey = GlobalKey<FormState>();
  // final _usernameController = TextEditingController();
  // final _passwordController = TextEditingController();
  // bool _obscurePassword = true;
  double _scrollOffset = 0;
  // int _carouselIndex = 0;
  // Timer? _carouselTimer;

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
  // late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // _pageController = PageController(viewportFraction: 0.85);
    // _pageController.addListener(_onCarouselScroll);
    // // _startCarouselTimer();
  }

  @override
  void dispose() {
    // _usernameController.dispose();
    // _passwordController.dispose();
    _anim.dispose();
    _scrollController.dispose();
    // _pageController.dispose();
    // _carouselTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  // void _onCarouselScroll() {
  //   setState(() {
  //     _carouselIndex = _pageController.page?.round() ?? 0;
  //   });
  // }

  // void _startCarouselTimer() {
  //   _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
  //     _pageController.nextPage(
  //       duration: const Duration(milliseconds: 800),
  //       curve: Curves.easeInOut,
  //     );
  //   });
  // }

  // Future<void> _submit() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   final auth = context.read<AuthProvider>();
  //   final success = await auth.login(
  //     _usernameController.text.trim(),
  //     _passwordController.text,
  //   );
  //   if (success && mounted) {
  //     Navigator.of(context).pushReplacement(
  //       PageRouteBuilder(
  //         pageBuilder: (_, __, ___) => const DashboardScreen(),
  //         transitionDuration: const Duration(milliseconds: 400),
  //         transitionsBuilder: (_, anim, __, child) =>
  //             FadeTransition(opacity: anim, child: child),
  //       ),
  //     );
  //     // context.go('/dashboard');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final auth = context.watch<AuthProvider>();
    // final carouselItems = [
    //   {
    //     'imageUrl':
    //         'https://images.unsplash.com/photo-1505228395891-9a51e7e86e81?w=400&h=300&fit=crop',
    //     'heading': 'Beautiful Landscape',
    //     'description':
    //         'Explore stunning natural sceneries and breathtaking views',
    //   },
    //   {
    //     'imageUrl':
    //         'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
    //     'heading': 'Mountain Adventure',
    //     'description':
    //         'Experience the thrill of mountain climbing and exploration',
    //   },
    // ];

    return Scaffold(
      backgroundColor: AppTheme.whiteSurface,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            centerTitle: true,
            stretch: true,
            floating: false,
            pinned: true,
            expandedHeight: 85.0,
            elevation: _scrollOffset > 100 ? 10 : 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.blueLightest,
                    AppTheme.blueLightTinted.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                centerTitle: false,
                title: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Logo(),
                    Opacity(
                      opacity: (1 - (_scrollOffset / 100)).clamp(0.0, 1.0),
                      child: Text(
                        'Welcome to RayhanERP',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.blueStrongHighlight,
                                ),
                      ),
                    ),
                    NavActions()
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideIn,
                  child: const Column(
                    children: [
                      HeroSection(),
                      ValuePropositionSection(),
                      DashboardSection(),
                      ModuleGridSection(),
                      TrustSection(),
                      CtaSection(),
                      FooterSection(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//_____________________________________________________________________________

// Container(
//                         decoration: const BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               Color(0xFF0F172A), // slate-900
//                               Color(0xFF0D9488), // teal-600
//                             ],
//                             stops: [0.0, 1.0],
//                           ),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: AppTheme.sp24, vertical: AppTheme.sp20),
//                         child: Column(
//                           children: [
//                             const Text(
//                               'Featured Items',
//                               style: TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             SizedBox(
//                               height: 260,
//                               child: PageView.builder(
//                                 controller: _pageController,
//                                 itemCount: carouselItems.length,
//                                 itemBuilder: (context, index) {
//                                   final item = carouselItems[index];
//                                   return CarouselCard(
//                                     imageUrl: item['imageUrl'] as String,
//                                     heading: item['heading'] as String,
//                                     description: item['description'] as String,
//                                   );
//                                 },
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             // Carousel Indicators
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: List.generate(
//                                 carouselItems.length,
//                                 (index) => AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   width: index == _carouselIndex ? 24 : 8,
//                                   height: 8,
//                                   margin:
//                                       const EdgeInsets.symmetric(horizontal: 4),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(4),
//                                     color: index == _carouselIndex
//                                         ? Colors.blue
//                                         : Colors.grey.shade300,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
                      // const SizedBox(height: 32), //   const BrandPanel(),
                      // const SizedBox(height: 32),
                      // // Parallax Sections
                      // ParallaxSection(
                      //   title: AppText.head1,
                      //   offset: _scrollOffset * 0.5,
                      //   color: Colors.orange,
                      //   text: AppText.para1,
                      // ),
                      // const SizedBox(height: 32),
                      // ParallaxSection(
                      //   title: AppText.head2,
                      //   offset: _scrollOffset * 0.4,
                      //   color: Colors.purple,
                      //   text: AppText.para2,
                      // ),
                      // const SizedBox(height: 32),
                      // ParallaxSection(
                      //   title: AppText.head3,
                      //   offset: _scrollOffset * 0.3,
                      //   color: Colors.teal,
                      //   text: AppText.para3,
                      // ),
                      // const SizedBox(height: 32),
                      // ParallaxSection(
                      //   title: AppText.head4,
                      //   offset: _scrollOffset * 0.2,
                      //   color: Colors.orange,
                      //   text: AppText.para4,
                      // ),
                      // const SizedBox(height: 32),
                      // ParallaxSection(
                      //   title: AppText.head5,
                      //   offset: _scrollOffset * 0.1,
                      //   color: Colors.purple,
                      //   text: AppText.para5,
                      // ),
                      // const SizedBox(height: 32),
                      // Container(
                      //   decoration: const BoxDecoration(
                      //     gradient: LinearGradient(
                      //       begin: Alignment.topLeft,
                      //       end: Alignment.bottomRight,
                      //       colors: [
                      //         AppTheme.blueStrongHighlight, // slate-900
                      //         Colors.black, // teal-600
                      //       ],
                      //       stops: [0.0, 1.0],
                      //     ),
                      //   ),
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: AppTheme.sp24, vertical: AppTheme.sp20),
                      //   child: Column(
                      //     children: [
                      //       Row(
                      //         children: [
                      //           const Column(
                      //             children: [
                      //               Text(
                      //                 'La performance industrielle à portée de main.',
                      //                 style: TextStyle(
                      //                   color: AppTheme.blueLightest,
                      //                   fontSize: 32,
                      //                   fontWeight: FontWeight.w800,
                      //                   height: 1.2,
                      //                 ),
                      //               ),
                      //               SizedBox(height: AppTheme.sp12),
                      //               Text(
                      //                 'Gérez vos ventes, votre production, vos stocks et '
                      //                 'vos achats depuis une interface unifiée et temps réel.',
                      //                 style: TextStyle(
                      //                   color: Colors.white70,
                      //                   fontSize: 14,
                      //                   height: 1.6,
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //           const Spacer(),
                      //           Column(
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             mainAxisAlignment: MainAxisAlignment.start,
                      //             children: [
                      //               const SizedBox(width: AppTheme.sp8),

                      //               // Feature list
                      //               ...[
                      //                 (
                      //                   Icons.speed_rounded,
                      //                   'Tableau de bord en temps réel'
                      //                 ),
                      //                 (
                      //                   Icons.precision_manufacturing_rounded,
                      //                   'Suivi production OEE'
                      //                 ),
                      //                 (
                      //                   Icons.inventory_2_rounded,
                      //                   'Gestion stocks & silos'
                      //                 ),
                      //                 (
                      //                   Icons.shopping_cart_rounded,
                      //                   'Commandes & facturation'
                      //                 ),
                      //               ].map(
                      //                 (item) => Padding(
                      //                   padding: const EdgeInsets.only(
                      //                       bottom: AppTheme.sp12),
                      //                   child: Row(
                      //                     children: [
                      //                       Container(
                      //                         width: 28,
                      //                         height: 28,
                      //                         decoration: BoxDecoration(
                      //                           color: Colors.white
                      //                               .withValues(alpha: 0.12),
                      //                           borderRadius:
                      //                               BorderRadius.circular(6),
                      //                         ),
                      //                         child: Icon(item.$1,
                      //                             size: 15,
                      //                             color: Colors.black),
                      //                       ),
                      //                       const SizedBox(width: 10),
                      //                       Text(
                      //                         item.$2,
                      //                         style: const TextStyle(
                      //                           color: Colors.white,
                      //                           fontSize: 13,
                      //                           fontWeight: FontWeight.w500,
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           )
                      //         ],
                      //       ),

                      //       // Footer
                      //       Text(
                      //         '© ${DateTime.now().year} RayhanERP — v1.0.0',
                      //         style: const TextStyle(
                      //             color: Colors.white38, fontSize: 11),
                      //       ),
                      //     ],
                      //   ),
                      // ),



















//______________________________________________________________________________
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

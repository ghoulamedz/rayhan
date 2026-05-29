import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/services/auth_service.dart';
import 'package:rayhan_erp/services/dashboard_service.dart';
import 'package:rayhan_erp/services/sales_order_service.dart';
import 'package:rayhan_erp/services/article_service.dart';
import 'package:rayhan_erp/services/purchase_order_service.dart';
import 'package:rayhan_erp/services/production_service.dart';
import 'package:rayhan_erp/services/stock_service.dart';
import 'package:rayhan_erp/services/client_service.dart';
import 'package:rayhan_erp/services/fournisseur_service.dart';
import 'package:rayhan_erp/services/pdf_service.dart';
import 'package:rayhan_erp/services/service_factory.dart';
import 'package:rayhan_erp/mock/mock_services.dart';
import 'package:rayhan_erp/providers/auth_provider.dart';
import 'package:rayhan_erp/providers/dashboard_provider.dart';
import 'package:rayhan_erp/providers/article_provider.dart';
import 'package:rayhan_erp/providers/ventes_provider.dart';
import 'package:rayhan_erp/providers/achats_provider.dart';
import 'package:rayhan_erp/providers/production_provider.dart';
import 'package:rayhan_erp/providers/stock_provider.dart';
import 'package:rayhan_erp/providers/clients_provider.dart';
import 'package:rayhan_erp/providers/fournisseurs_provider.dart';
import 'package:rayhan_erp/screens/landing_screen.dart';
import 'package:rayhan_erp/screens/dashboard_screen.dart';
import 'package:rayhan_erp/screens/articles_screen.dart';
import 'package:rayhan_erp/screens/ventes_screen.dart';
import 'package:rayhan_erp/screens/achats_screen.dart';
import 'package:rayhan_erp/screens/production_screen.dart';
import 'package:rayhan_erp/screens/stock_screen.dart';
import 'package:rayhan_erp/screens/signup_screen.dart';
import 'package:rayhan_erp/screens/forgot_password_screen.dart';
import 'package:rayhan_erp/screens/rapports_screen.dart';
import 'package:rayhan_erp/screens/clients_screen.dart';
import 'package:rayhan_erp/screens/fournisseurs_screen.dart';
import 'package:rayhan_erp/widgets/role_guard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PdfService.init();
  await initializeDateFormatting('fr_FR');
  await initializeDateFormatting('fr_TN');

  final auth = AuthProvider(
    authService: ServiceFactory.resolve(() => RealAuthService(), () => MockAuthService()),
  );
  await auth.checkAuth();

  final salesOrderService = ServiceFactory.resolve(() => RealSalesOrderService(), () => MockSalesOrderService());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        Provider<SalesOrderService>.value(value: salesOrderService),
        ChangeNotifierProvider(create: (_) => DashboardProvider(
          dashboardService: ServiceFactory.resolve(() => RealDashboardService(), () => MockDashboardService()),
        )),
        ChangeNotifierProvider(create: (_) => ArticleProvider(
          articleService: ServiceFactory.resolve(() => RealArticleService(), () => MockArticleService()),
        )),
        ChangeNotifierProvider(create: (_) => VentesProvider(
          salesOrderService: salesOrderService,
        )),
        ChangeNotifierProvider(create: (_) => AchatsProvider(
          purchaseOrderService: ServiceFactory.resolve(() => RealPurchaseOrderService(), () => MockPurchaseOrderService()),
        )),
        ChangeNotifierProvider(create: (_) => ProductionProvider(
          productionService: ServiceFactory.resolve(() => RealProductionService(), () => MockProductionService()),
        )),
        ChangeNotifierProvider(create: (_) => StockProvider(
          stockService: ServiceFactory.resolve(() => RealStockService(), () => MockStockService()),
        )),
        ChangeNotifierProvider(create: (_) => ClientsProvider(
          clientService: ServiceFactory.resolve(() => RealClientService(), () => MockClientService()),
        )),
        ChangeNotifierProvider(create: (_) => FournisseursProvider(
          fournisseurService: ServiceFactory.resolve(() => RealFournisseurService(), () => MockFournisseurService()),
        )),
      ],
      child: const RayhanApp(),
    ),
  );
}

class RayhanApp extends StatefulWidget {
  const RayhanApp({super.key});

  @override
  State<RayhanApp> createState() => _RayhanAppState();
}

class _RayhanAppState extends State<RayhanApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_router == null) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _router = GoRouter(
        initialLocation: '/login',
        refreshListenable: auth,
        redirect: (_, state) {
          final loggedIn = auth.isAuthenticated;
          final role = auth.role;
          final onLogin = state.matchedLocation == '/login';
          final publicRoutes = ['/login', '/signup', '/forgot-password'];

          if (!loggedIn && !publicRoutes.contains(state.matchedLocation)) {
            return '/login';
          }
          if (loggedIn && onLogin) {
            return RoleGuard.getDefaultRoute(role);
          }
          if (loggedIn && !publicRoutes.contains(state.matchedLocation)) {
            if (!RoleGuard.hasAccess(role, state.matchedLocation)) {
              return RoleGuard.getDefaultRoute(role);
            }
          }
          return null;
        },
        routes: [
          GoRoute(path: '/login', builder: (_, __) => const LandingScreen()),
          GoRoute(
              path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(
              path: '/articles', builder: (_, __) => const ArticlesScreen()),
          GoRoute(path: '/ventes', builder: (_, __) => const VentesScreen()),
          GoRoute(path: '/achats', builder: (_, __) => const AchatsScreen()),
          GoRoute(
              path: '/production',
              builder: (_, __) => const ProductionScreen()),
          GoRoute(path: '/stock', builder: (_, __) => const StockScreen()),
          GoRoute(path: '/clients', builder: (_, __) => const ClientsScreen()),
          GoRoute(path: '/fournisseurs', builder: (_, __) => const FournisseursScreen()),
          GoRoute(path: '/rapports', builder: (_, __) => const RapportsScreen()),
          GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
          GoRoute(
              path: '/forgot-password',
              builder: (_, __) => const ForgotPasswordScreen()),
        ],
      );
    }
  }

  @override
  void dispose() {
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_router == null) return const SizedBox.shrink();
    return MaterialApp.router(
      title: 'RayhanERP | La Précision Industrielle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router!,
      //scrollBehavior: const _WebScrollBehavior(),
    );
  }
}

class _WebScrollBehavior extends MaterialScrollBehavior {
  const _WebScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rayhan_erp/theme/app_theme.dart';

import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/article_provider.dart';
import 'providers/ventes_provider.dart';
import 'providers/achats_provider.dart';
import 'providers/production_provider.dart';
import 'providers/stock_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/articles_screen.dart';
import 'screens/ventes_screen.dart';
import 'screens/achats_screen.dart';
import 'screens/production_screen.dart';
import 'screens/stock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await initializeDateFormatting('fr_TN');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => VentesProvider()),
        ChangeNotifierProvider(create: (_) => AchatsProvider()),
        ChangeNotifierProvider(create: (_) => ProductionProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
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
          final onLogin = state.matchedLocation == '/login';
          if (!loggedIn && !onLogin) return '/login';
          if (loggedIn && onLogin) return '/dashboard';
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
      title: 'Rayhan ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router!,
    );
  }
}

//UNUSED
import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';

class BrandPanel extends StatelessWidget {
  const BrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Hide on narrow screens
      if (MediaQuery.of(context).size.width < 800) {
        return const SizedBox.shrink();
      }
      return Container(
        width: 420,
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
        padding: const EdgeInsets.all(AppTheme.sp40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RayhanERP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'La société Rayhan',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),

            const Text(
              'La performance\nindustrielle\nà portée de main.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppTheme.sp20),
            const Text(
              'Gérez vos ventes, votre production, vos stocks et '
              'vos achats depuis une interface unifiée et temps réel.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppTheme.sp40),

            // Feature list
            ...[
              (Icons.speed_rounded, 'Tableau de bord en temps réel'),
              (Icons.precision_manufacturing_rounded, 'Suivi production OEE'),
              (Icons.inventory_2_rounded, 'Gestion stocks & silos'),
              (Icons.shopping_cart_rounded, 'Commandes & facturation'),
            ].map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.sp12),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(item.$1, size: 15, color: Colors.black),
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
            const Spacer(),

            // Footer
            Text(
              '© ${DateTime.now().year} RayhanERP — v1.0.0',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      );
    });
  }
}

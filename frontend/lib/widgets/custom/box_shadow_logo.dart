import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';

class BoxShadowLogo extends StatelessWidget {
  const BoxShadowLogo({super.key});
  @override
  Widget build(BuildContext build) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.factory, size: 48, color: Colors.white),
      ),
      const SizedBox(height: 24),
      Text('RAYHAN ERP',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.primary,
            letterSpacing: 2,
          )),
      const SizedBox(height: 10),
    ]);
  }
}

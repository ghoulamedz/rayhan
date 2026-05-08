import 'package:flutter/material.dart';
import 'package:rayhan_erp/theme/app_theme.dart';

class DemoHint extends StatelessWidget {
  const DemoHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.sp12),
      decoration: BoxDecoration(
        color: AppTheme.infoSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.info.withValues(alpha: 0.25)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: AppTheme.info),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Compte démo:\nadmin / 123456',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.info,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

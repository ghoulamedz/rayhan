//UNUSED
import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';

class DemoHint extends StatelessWidget {
  const DemoHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.sp12),
      decoration: BoxDecoration(
        color: AppTheme.whiteSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: AppTheme.blueStrongHighlight.withValues(alpha: 0.25)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: Colors.black),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Compte démo:\nadmin / 123456',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.blueStrongHighlight,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

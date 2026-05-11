import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rayhan_erp/constants/app_theme.dart';

class SystemStatusChip extends StatelessWidget {
  const SystemStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.sp16,
        vertical: AppTheme.sp8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.greenLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greenBright.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 14, color: AppTheme.greenBright),
          const SizedBox(width: 6),
          const Text(
            'Système: Opérationnel',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.greenBright,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            DateFormat('HH:mm').format(DateTime.now()),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.greyLight,
            ),
          ),
        ],
      ),
    );
  }
}

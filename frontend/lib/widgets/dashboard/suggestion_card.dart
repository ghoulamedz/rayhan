import 'package:flutter/material.dart';
import '../../models/suggestion.dart';
import '../../constants/app_theme.dart';

class SuggestionCard extends StatelessWidget {
  final Suggestion suggestion;
  final VoidCallback? onDismiss;

  const SuggestionCard({
    super.key,
    required this.suggestion,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (suggestion.type) {
      'warning' => AppTheme.kErrorRed,
      'success' => AppTheme.kSuccessGreen,
      _ => AppTheme.kPrimaryTeal,
    };
    final icon = switch (suggestion.type) {
      'warning' => Icons.warning_amber_rounded,
      'success' => Icons.check_circle_rounded,
      _ => Icons.lightbulb_outline_rounded,
    };
    return AppTheme.withGlass(
      radius: 12,
      blur: 12,
      opacity: 0.65,
      margin: const EdgeInsets.only(bottom: 8),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(suggestion.title,
                              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                          if (suggestion.description.isNotEmpty)
                            Text(suggestion.description,
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                                style: AppTheme.bodySmall.copyWith(color: AppTheme.kTextSecondary, fontSize: 11)),
                          if (suggestion.impact.isNotEmpty)
                            Text('Impact: ${suggestion.impact}',
                                style: AppTheme.bodySmall.copyWith(color: color, fontSize: 10)),
                        ],
                      ),
                    ),
                    if (onDismiss != null)
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: AppTheme.kTextHint, size: 18),
                        onSelected: (val) {
                          if (val == 'dismiss') onDismiss!();
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'dismiss', child: Row(
                            children: [Icon(Icons.close, size: 18), SizedBox(width: 8), Text('Ignorer')],
                          )),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
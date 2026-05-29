import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

class ActivityFeed extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const ActivityFeed({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Activité récente',
              style: AppTheme.titleSmall.copyWith(fontSize: 15)),
        ),
        AppTheme.withGlass(
          radius: 16,
          blur: 16,
          opacity: 0.7,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: activities.map<Widget>((item) {
                final color = Color(item['color'] as int);
                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item['icon'] as IconData,
                        color: color, size: 18),
                  ),
                  title: Text(item['text'] as String,
                      style: AppTheme.bodyMedium
                          .copyWith(fontSize: 13)),
                  trailing: Text(item['time'] as String,
                      style: AppTheme.bodySmall
                          .copyWith(color: AppTheme.kTextHint)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
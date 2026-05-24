//UNUSED
import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';

class RayhanLogo extends StatelessWidget {
  const RayhanLogo({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >= 800) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.precision_manufacturing_rounded,
              color: AppTheme.blueLight, size: 18),
        ),
        const SizedBox(width: 10),
        const Text(
          'Rayhan_ERP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.iconSize = 22,
    this.textSize,
    this.textColor,
    this.containerPadding,
    this.containerColor,
    this.containerBorderRadius,
  });

  final double iconSize;
  final double? textSize;
  final Color? textColor;
  final EdgeInsetsGeometry? containerPadding;
  final Color? containerColor;
  final double? containerBorderRadius;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        const SizedBox(width: 10),
        Text(
          'RayhanERP',
          style: TextStyle(
            fontFamily: 'LeckerliOne',
            fontWeight: FontWeight.w400,
            fontSize: textSize ?? 16,
            color: textColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    final icon = Image.asset(
      'assets/images/rayhan_icon.png',
      width: iconSize,
      height: iconSize,
    );

    if (containerPadding == null) return icon;

    return Container(
      padding: containerPadding!,
      decoration: BoxDecoration(
        color: containerColor ?? AppTheme.kWhite.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(containerBorderRadius ?? 8),
      ),
      child: icon,
    );
  }
}

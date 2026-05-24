//UNUSED
import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggle,
  });
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Mot de passe',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppTheme.sp4),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: (v) =>
              (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 16),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 16,
                color: AppTheme.greyLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

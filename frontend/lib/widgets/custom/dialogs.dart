import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
// AppDialog
// ──────────────────────────────────────────────────────────────────────────────

/// Standard modal dialog shell used throughout the ERP.
///
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => AppDialog(
///     title: 'Nouvelle Vente',
///     width: 560,
///     actions: [
///       OutlinedButton(onPressed: () => Navigator.pop(context), child: Text('Annuler')),
///       ElevatedButton(onPressed: () {}, child: Text('Créer')),
///     ],
///     child: MyFormContent(),
///   ),
/// );
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions = const [],
    this.width = 520,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final double width;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp24, vertical: AppTheme.sp40),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppTheme.whiteSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(
                  AppTheme.sp24, AppTheme.sp20, AppTheme.sp20, AppTheme.sp20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black)),
              ),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (iconColor ?? Colors.black).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: iconColor ?? Colors.black,
                      ),
                    ),
                    const SizedBox(width: AppTheme.sp12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: theme.textTheme.headlineMedium),
                        if (subtitle != null)
                          Text(subtitle!, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 18,
                    color: AppTheme.greyLight,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.sp24),
                child: child,
              ),
            ),

            // ── Footer ──────────────────────────────────────────────────
            if (actions.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(
                    AppTheme.sp24, AppTheme.sp16, AppTheme.sp24, AppTheme.sp20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppTheme.sp8),
                      actions[i],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// ConfirmDialog
// ──────────────────────────────────────────────────────────────────────────────

/// Lightweight confirmation dialog for destructive / irreversible actions.
///
/// Returns `true` when the user confirms, `false` / `null` on cancel.
///
/// ```dart
/// final ok = await ConfirmDialog.show(
///   context,
///   title: 'Supprimer la commande ?',
///   message: 'Cette action est irréversible.',
///   confirmLabel: 'Supprimer',
///   destructive: true,
/// );
/// ```
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirmer',
    this.cancelLabel = 'Annuler',
    this.destructive = false,
    this.icon,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;
  final IconData? icon;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    bool destructive = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confirmColor = destructive ? AppTheme.red : Colors.black;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(AppTheme.sp24),
        decoration: BoxDecoration(
          color: AppTheme.whiteSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.shadowLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: destructive ? AppTheme.red : AppTheme.yellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon ??
                        (destructive
                            ? Icons.delete_outline_rounded
                            : Icons.help_outline_rounded),
                    size: 20,
                    color: destructive ? AppTheme.red : AppTheme.yellow,
                  ),
                ),
                const SizedBox(width: AppTheme.sp12),
                Expanded(
                  child: Text(title, style: theme.textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.sp16),
            Text(message,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppTheme.greyLight, height: 1.5)),
            const SizedBox(height: AppTheme.sp24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelLabel),
                ),
                const SizedBox(width: AppTheme.sp8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                  ),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Form field helpers
// ──────────────────────────────────────────────────────────────────────────────

/// Labeled text field with consistent ERP styling.
///
/// ```dart
/// ErpTextField(
///   label: 'Désignation',
///   controller: _ctrl,
///   hint: 'Entrez la désignation...',
///   required: true,
/// )
/// ```
class ErpTextField extends StatelessWidget {
  const ErpTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.required = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixText,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool required;
  final bool enabled;
  final IconData? prefixIcon;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.greyLight,
            ),
            children: required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppTheme.red),
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: AppTheme.sp4),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          inputFormatters: inputFormatters,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 16) : null,
            suffix: suffixText != null
                ? Text(suffixText!,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.greyLight))
                : null,
          ),
        ),
      ],
    );
  }
}

/// Labeled dropdown field with consistent ERP styling.
class ErpDropdown<T> extends StatelessWidget {
  const ErpDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.required = false,
    this.hint = 'Sélectionner...',
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool required;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style:
                theme.textTheme.titleSmall?.copyWith(color: AppTheme.greyLight),
            children: required
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppTheme.red),
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: AppTheme.sp4),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          hint: Text(hint,
              style: const TextStyle(fontSize: 13, color: AppTheme.greyLight)),
          style: theme.textTheme.bodyLarge,
          decoration: const InputDecoration(),
          dropdownColor: AppTheme.whiteSurface,
          borderRadius: BorderRadius.circular(8),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: AppTheme.greyLight),
        ),
      ],
    );
  }
}

/// Horizontal row of two form fields with a gap.
class FormRow extends StatelessWidget {
  const FormRow({super.key, required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          const SizedBox(width: AppTheme.sp16),
          Expanded(child: right),
        ],
      );
}

/// Vertical spacer for form sections.
class FormGap extends StatelessWidget {
  const FormGap({super.key, this.height = AppTheme.sp16});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// Form section label (bold divider-like heading between groups of fields).
class FormSectionLabel extends StatelessWidget {
  const FormSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.sp8, bottom: AppTheme.sp12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.greyLight,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppTheme.sp8),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// ToastNotification
// ──────────────────────────────────────────────────────────────────────────────

/// Show a brief success/error/info snackbar toast.
///
/// ```dart
/// AppToast.success(context, 'Commande créée avec succès.');
/// AppToast.error(context, 'Une erreur est survenue.');
/// ```
abstract final class AppToast {
  static void success(BuildContext context, String message) =>
      _show(context, message, AppTheme.greenBright, Icons.check_circle_rounded);

  static void error(BuildContext context, String message) =>
      _show(context, message, AppTheme.red, Icons.error_outline_rounded);

  static void info(BuildContext context, String message) =>
      _show(context, message, AppTheme.greenBright, Icons.info_outline_rounded);

  static void warning(BuildContext context, String message) =>
      _show(context, message, AppTheme.yellow, Icons.warning_amber_rounded);

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(AppTheme.sp24),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:rayhan_erp/widgets/custom/responsive_layout.dart';
import 'package:rayhan_erp/widgets/final/common/login_form.dart';
import '../../../constants/app_theme.dart';

// ──────────────────────────────────────────────────────────────────────────────
// SectionHeader
// ──────────────────────────────────────────────────────────────────────────────

/// A row with a bold heading on the left and an optional action widget on the right.
///
/// ```dart
/// SectionHeader(
///   title: 'Lots de Production Actifs',
///   action: TextButton(onPressed: () {}, child: Text('Voir tout →')),
/// )
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.alignment = TextAlign.center,
    this.titleColor,
  });

  final String? eyebrow;
  final String title;
  final String? subtitle;
  final TextAlign alignment;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: switch (alignment) {
        TextAlign.left => CrossAxisAlignment.start,
        TextAlign.right => CrossAxisAlignment.end,
        _ => CrossAxisAlignment.center,
      },
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            textAlign: alignment,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: cs.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          title,
          textAlign: alignment,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: titleColor ?? cs.onSurface,
                letterSpacing: -0.5,
                height: 1.15,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            textAlign: alignment,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 16,
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// AppCard
// ──────────────────────────────────────────────────────────────────────────────

/// A consistent card container with optional [title] header.
///
/// ```dart
/// AppCard(
///   title: 'État des stocks',
///   child: StockLevelIndicator(label: 'HDPE', level: 0.78),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding,
    this.color,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHeader = title != null;

    return Container(
      decoration: BoxDecoration(
        color: color ?? AppTheme.whiteSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.whiteTintedorGreyAddAlpha02),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.sp20,
                AppTheme.sp16,
                AppTheme.sp20,
                AppTheme.sp12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title!, style: theme.textTheme.titleLarge),
                        if (subtitle != null)
                          Text(subtitle!, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.sp20),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// ScreenHeader
// ──────────────────────────────────────────────────────────────────────────────

/// Top-of-screen heading with title, subtitle, and optional action buttons.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.headlineLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: theme.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: AppTheme.sp16),
          Wrap(
            spacing: AppTheme.sp8,
            children: actions,
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// EmptyState
// ──────────────────────────────────────────────────────────────────────────────

/// Displayed when a list or table has no data.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.sp32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTheme.greyLight),
            const SizedBox(height: AppTheme.sp12),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.sp16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// InfoRow
// ──────────────────────────────────────────────────────────────────────────────

/// A label–value pair used in detail panels.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A unified button component that maps to the four button styles used
/// across the RayhanERP landing page.
enum AppButtonVariant { primary, secondary, outlined, ghost }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.prefixIcon,
    this.fontSize = 14,
    this.padding,
  });

  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final IconData? prefixIcon;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final edge = widget.padding ??
        EdgeInsets.symmetric(
          horizontal: widget.fontSize < 16 ? 20 : 32,
          vertical: widget.fontSize < 16 ? 8 : 16,
        );

    final (bg, fg, border) = switch (widget.variant) {
      AppButtonVariant.primary => (
          AppTheme.greenMatte,
          AppTheme.blueLightest,
          BorderSide.none,
        ),
      AppButtonVariant.secondary => (
          _hovered ? cs.surfaceContainerHighest : cs.surfaceContainerHigh,
          cs.onSurface,
          BorderSide.none,
        ),
      AppButtonVariant.outlined => (
          _hovered ? AppTheme.greenMatte : Colors.transparent,
          _hovered ? AppTheme.blueStrongHighlight : AppTheme.greenMatte,
          const BorderSide(color: AppTheme.greenMatte, width: 2),
        ),
      AppButtonVariant.ghost => (
          _hovered
              ? cs.primaryFixed.withValues(alpha: 0.2)
              : Colors.transparent,
          cs.onSurface,
          BorderSide.none,
        ),
    };

    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
        ),
      ],
    );

    if (widget.prefixIcon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(widget.prefixIcon, color: fg, size: widget.fontSize + 4),
          const SizedBox(width: 8),
          child,
        ],
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform:
              _hovered ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
          padding: edge,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: border == BorderSide.none
                ? null
                : Border.fromBorderSide(border),
          ),
          child: child,
        ),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Image.asset(
            'assets/images/logo.png',
            width: 42,
            height: 42,
            fit: BoxFit.fitHeight,
            color: AppTheme.whiteTintedorGreyAddAlpha02.withValues(alpha: 0.2),
            colorBlendMode: BlendMode.srcATop,
          ),
          hoverColor: Colors.transparent,
          onPressed: () {
            // Handle tap
          },
        ),
        if (context.isDesktop)
          Text(
            'RayhanERP',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
      ],
    );
  }
}

class NavLinks extends StatelessWidget {
  const NavLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: ['Products,Features,PricingS'].map((label) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: cs.onSurface,
                ),
          ),
        );
      }).toList(),
    );
  }
}

class NavActions extends StatelessWidget {
  const NavActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        AppButton(
          prefixIcon: Icons.login,
          label: '',
          variant: AppButtonVariant.primary,
          padding: const EdgeInsets.all(11),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const Dialog(
                elevation: 5,
                shadowColor: AppTheme.blueStrongHighlight,
                surfaceTintColor: AppTheme.blueLightTinted,
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: LoginFormWidget(
                    height: 400,
                    width: 300,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

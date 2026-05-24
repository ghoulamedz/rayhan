//UNUSED
import 'package:flutter/material.dart';
import 'package:rayhan_erp/widgets/custom/responsive_layout.dart';
import 'package:rayhan_erp/widgets/final/common/layout_widgets.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  static const double _height = 70;

  static const _navLinks = [
    ('Product', true),
    ('Features', false),
    ('Pricing', false),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .85),
        elevation: 10,
        shadowColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Row(
            children: [
              _Logo(),
              const Spacer(),
              if (context.isDesktop) ...[
                _NavLinks(),
                const SizedBox(width: 40),
              ],
              _Actions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Image.asset(
            'assets/images/logo.png',
            width: 42,
            height: 42,
            fit: BoxFit.cover,
            //color: Colors.white,
            colorBlendMode: BlendMode.srcIn,
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

class _NavLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: NavBar._navLinks.map((link) {
        final (label, isActive) = link;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isActive ? cs.onSurface : cs.onSurfaceVariant,
                ),
          ),
        );
      }).toList(),
    );
  }
}

class _Actions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        AppButton(
          label: 'Crèer compte',
          variant: AppButtonVariant.ghost,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        ),
        SizedBox(width: 8),
        AppButton(
          label: 'S\'identifier',
          variant: AppButtonVariant.primary,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        ),
      ],
    );
  }
}

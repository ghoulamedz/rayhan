import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/widgets/custom/responsive_layout.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  static const _links = [
    'Privacy Policy',
    'Terms of Service',
    'System Status',
    'Technical Support',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.blueLightTinted,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
      child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.md) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _BrandColumn(),
              const Spacer(),
              _FooterLinks(),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BrandColumn(),
            const SizedBox(height: 32),
            _FooterLinks(),
          ],
        );
      }),
    );
  }
}

class _BrandColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RayhanERP',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            '© 2024 RayhanERP Industrial Systems.\nBuilt for Precision Manufacturing.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  color: AppTheme.blueStrongHighlight,
                  height: 1.55,
                ),
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 12,
      children:
          FooterSection._links.map((link) => _FooterLink(label: link)).toList(),
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink({required this.label});
  final String label;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: Text(
          widget.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 13,
                color: _hovered ? Colors.black : AppTheme.greyLight,
              ),
        ),
      ),
    );
  }
}

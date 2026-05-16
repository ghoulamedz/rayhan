import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';
import 'package:rayhan_erp/widgets/custom/responsive_layout.dart';
import 'package:rayhan_erp/widgets/final/common/layout_widgets.dart';

class HeroSection extends StatelessWidget {
  final Function(double) onScrollToOffset;
  const HeroSection({
    super.key,
    required this.onScrollToOffset,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 640),
      color: cs.surface,
      child: Stack(
        children: [
          // ── Background image ─────────────────────────────
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/factory_bg.png',
                fit: BoxFit.cover,
                color: Colors.grey,
                colorBlendMode: BlendMode.saturation,
              ),
            ),
          ),
          // ── Gradient overlay ─────────────────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    cs.surface,
                    cs.surface.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // ── Content ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 80, 48, 48),
            child: _HeroContent(
              onScrollToOffset: onScrollToOffset,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  final Function(double) onScrollToOffset;

  const _HeroContent({
    required this.onScrollToOffset,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Eyebrow chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.greenStrong,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            'INDUSTRY 4.0 READY',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppTheme.blueLightest,
                ),
          ),
        ),
        const SizedBox(height: 24),

        // Headline
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: context.isMobile ? 40 : 56,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  height: 1.1,
                  letterSpacing: -1.5,
                ),
            children: const [
              TextSpan(text: 'La Précision Industrielle,\n'),
              TextSpan(
                text: 'Pilotée par l\'IA',
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Subheading
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Optimisez votre production de plastique, de la matière première au produit fini avec RayhanERP. Une plateforme unifiée conçue pour l\'excellence opérationnelle.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: cs.onSurfaceVariant,
                  height: 1.65,
                ),
          ),
        ),
        const SizedBox(height: 36),

        // CTA buttons
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            AppButton(
              onTap: () => onScrollToOffset(
                500,
              ),
              label: 'Réduisez les Coûts, Augmentez la Productivité',
              variant: AppButtonVariant.primary,
              fontSize: 17,
            ),
            AppButton(
              onTap: () => onScrollToOffset(
                1900,
              ),
              label: 'Les Modules Intégrées',
              variant: AppButtonVariant.outlined,
              // prefixIcon: Icons.play_circle_outline,
              fontSize: 17,
            ),
          ],
        ),
        const SizedBox(height: 36),

        // Social proof
        Row(
          children: [
            const Icon(Icons.verified),
            const SizedBox(width: 16),
            Text(
              'Rejoint par +150 leaders de l\'industrie',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );

    return content;
  }
}

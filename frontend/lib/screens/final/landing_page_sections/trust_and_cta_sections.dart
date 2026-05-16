import 'package:flutter/material.dart';
import 'package:rayhan_erp/constants/app_theme.dart';

// ── Trust Section ─────────────────────────────────────────────────────────────

class TrustSection extends StatelessWidget {
  const TrustSection({super.key});

  static const _brands = [
    'Emballage',
    'Bâtiment et construction',
    'Automobile et transport',
    'Électronique et appareils électroménagers',
    'Textile et fibres synthétiques',
    'Recyclage et valorisation',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 64),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: AppTheme.blueLightest, // outlineVariant / 10
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Conçu pour les industriels du plastique'.toUpperCase(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.5,
                  color: AppTheme.blueStrongHighlight,
                ),
          ),
          const SizedBox(height: 40),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 48,
            runSpacing: 24,
            children: _brands
                .map(
                  (b) => Opacity(
                    opacity: 0.4,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        AppTheme.blueLightTinted,
                        BlendMode.saturation,
                      ),
                      child: Text(
                        b,
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.blueStrongHighlight,
                                ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── CTA Section ───────────────────────────────────────────────────────────────

class CtaSection extends StatelessWidget {
  const CtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.blueLightest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.blueStrongHighlight,
            borderRadius: BorderRadius.circular(32),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Decorative background icon
              const Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width: 260,
                child: Opacity(
                  opacity: 0.08,
                  child: Icon(
                    Icons.precision_manufacturing,
                    size: 260,
                    color: Colors.white,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 56,
                  vertical: 72,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _CtaContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtaContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prêt à transformer\nvotre usine ?',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppTheme.blueLightest,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 24),
        Text(
          'Rejoignez la nouvelle ère de la plasturgie digitale. Planifiez une démonstration personnalisée avec un expert métier.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppTheme.blueLightest,
                height: 1.65,
              ),
        ),
        const SizedBox(height: 40),
        const Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _CtaButton(
              label: 'Demander une Démo',
              filled: true,
            ),
            _CtaButton(
              label: 'Contactez Nous',
              filled: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _CtaButton extends StatefulWidget {
  const _CtaButton({required this.label, required this.filled});
  final String label;
  final bool filled;

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          transform:
              _hovered ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
          decoration: BoxDecoration(
            color: widget.filled
                ? AppTheme.greenMatte
                : (_hovered ? AppTheme.greenMatte : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
            border: widget.filled
                ? null
                : Border.all(color: AppTheme.greenMatte, width: 0),
          ),
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 17,
                  fontWeight: widget.filled ? FontWeight.w800 : FontWeight.w700,
                  color: widget.filled
                      ? AppTheme.blueLightest
                      : (_hovered
                          ? AppTheme.blueStrongHighlight
                          : AppTheme.blueLightest),
                ),
          ),
        ),
      ),
    );
  }
}

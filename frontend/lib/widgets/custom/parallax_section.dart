import 'package:flutter/material.dart';

class ParallaxSection extends StatelessWidget {
  const ParallaxSection({
    super.key,
    required this.title,
    required this.text,
    required this.offset,
    required this.color,
  });

  final String title;
  final String text;
  final double offset;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        height: 500,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Parallax Background Element
            Transform.translate(
              offset: Offset(0, -offset * 0.3),
              child: const Opacity(
                opacity: 0.3,
                child: Center(
                  child: Icon(
                    Icons.flutter_dash,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 12,
                          ),
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                              fontSize: 20,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

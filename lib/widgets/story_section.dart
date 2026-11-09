import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/widgets/store_primitives.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key});

  static const details = [
    (
      '01',
      'BETTER MATERIALS',
      'Heavyweight cotton with a soft hand feel. Made to hold its shape, wash after wash.',
    ),
    (
      '02',
      'MADE TO MOVE',
      'A relaxed, considered fit for all-day wear. Find your usual size for an easy silhouette.',
    ),
    (
      '03',
      'LESS, DONE WELL',
      'Small, intentional runs. Fewer throwaway trends and more pieces you reach for.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StoreColors.ink,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('THE URBAN.THREADS STANDARD'),
              const SizedBox(height: 12),
              Text(
                'GOOD CLOTHES.\nNO COMPLICATIONS.',
                style: TextStyle(
                  color: StoreColors.paper,
                  fontSize: MediaQuery.sizeOf(context).width < 700 ? 34 : 48,
                  height: 1.03,
                  letterSpacing: -1.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth < 700 ? 1 : 3;
                  const gap = 1.0;
                  final cardWidth =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final detail in details)
                        SizedBox(
                          width: cardWidth,
                          child: _StoryCard(detail: detail),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.detail});

  final (String, String, String) detail;

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFF22221F),
        constraints: const BoxConstraints(minHeight: 190),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.$1,
              style: const TextStyle(
                color: StoreColors.accent,
                fontSize: 11,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              detail.$2,
              style: const TextStyle(
                color: StoreColors.paper,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              detail.$3,
              style: const TextStyle(
                color: Color(0xFFB8B3AB),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
}

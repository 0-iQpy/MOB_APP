import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/widgets/store_primitives.dart';

class StoreFooter extends StatelessWidget {
  const StoreFooter({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 700;
                const wordmark = StoreWordmark();
                const copyright = Text(
                  '© 2026 URBAN.THREADS · MADE FOR EVERYDAY',
                  style: TextStyle(
                    color: StoreColors.muted,
                    fontSize: 9,
                    letterSpacing: 0.8,
                  ),
                );
                if (compact) {
                  return const Column(
                    children: [
                      wordmark,
                      SizedBox(height: 14),
                      copyright,
                    ],
                  );
                }
                return const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [wordmark, copyright],
                );
              },
            ),
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';

class BenefitsTicker extends StatelessWidget {
  const BenefitsTicker({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      'FREE SHIPPING OVER ₱1,500',
      'HEAVYWEIGHT COTTON',
      'SMALL BATCH, LESS WASTE',
    ];
    return Container(
      color: StoreColors.accent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runSpacing: 12,
        spacing: 24,
        children: [
          for (var index = 0; index < items.length; index++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0) ...[
                  const Icon(Icons.circle, size: 5, color: Colors.white),
                  const SizedBox(width: 12),
                ],
                Text(
                  items[index],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

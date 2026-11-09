import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/widgets/store_primitives.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({required this.onShopPressed, super.key});

  final VoidCallback onShopPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final content = _HeroCopy(
          compact: compact,
          onShopPressed: onShopPressed,
        );
        const image = RemotePhoto(
          url:
              'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=1200&h=1400&fit=crop&auto=format',
          label: 'Streetwear collection editorial',
          icon: Icons.checkroom_outlined,
          fit: BoxFit.cover,
        );

        return ColoredBox(
          color: StoreColors.ink,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 22 : 36,
                  vertical: compact ? 38 : 52,
                ),
                child: compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          content,
                          const SizedBox(height: 32),
                          const AspectRatio(
                            aspectRatio: 1.08,
                            child: image,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: content,
                          ),
                          const SizedBox(width: 40),
                          const Expanded(
                            flex: 5,
                            child: AspectRatio(
                              aspectRatio: 0.88,
                              child: image,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.compact,
    required this.onShopPressed,
  });

  final bool compact;
  final VoidCallback onShopPressed;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final headingSize = compact
        ? (width * 0.17).clamp(56.0, 76.0)
        : (width * 0.105).clamp(76.0, 128.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow('NEW DROP / BUILT FOR EVERYDAY'),
        const SizedBox(height: 22),
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: StoreColors.paper,
              fontSize: headingSize,
              height: 0.88,
              letterSpacing: -headingSize * 0.055,
              fontWeight: FontWeight.w900,
            ),
            children: const [
              TextSpan(text: 'WEAR\nNO\n'),
              TextSpan(
                text: 'LABELS',
                style: TextStyle(color: StoreColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: const Text(
            'Everyday essentials, made to move with you. No noise. Just good clothes.',
            style: TextStyle(
              color: Color(0xFFB8B3AB),
              fontSize: 16,
              height: 1.65,
            ),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: onShopPressed,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text(
            'SHOP THE COLLECTION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: StoreColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            shape: const RoundedRectangleBorder(),
          ),
        ),
      ],
    );
  }
}

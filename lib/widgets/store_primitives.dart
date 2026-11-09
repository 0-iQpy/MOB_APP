import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';

class StoreWordmark extends StatelessWidget {
  const StoreWordmark({this.light = false, super.key});

  final bool light;

  @override
  Widget build(BuildContext context) {
    final color = light ? StoreColors.paper : StoreColors.ink;
    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
        ),
        children: const [
          TextSpan(text: 'URBAN'),
          TextSpan(text: '.', style: TextStyle(color: StoreColors.accent)),
          TextSpan(text: 'THREADS'),
        ],
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: StoreColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      );
}

class RemotePhoto extends StatelessWidget {
  const RemotePhoto({
    required this.url,
    required this.label,
    required this.icon,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final String label;
  final IconData icon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: fit,
        semanticLabel: label,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            _PhotoPlaceholder(label: 'IMAGE UNAVAILABLE', icon: icon),
      );
    }
    return Image.network(
      url,
      fit: fit,
      semanticLabel: label,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _PhotoPlaceholder(label: 'LOADING IMAGE', icon: icon);
      },
      errorBuilder: (context, error, stackTrace) =>
          _PhotoPlaceholder(label: 'IMAGE UNAVAILABLE', icon: icon),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: StoreColors.imageSurface,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 38, color: StoreColors.muted),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: StoreColors.muted,
                  fontSize: 10,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
}

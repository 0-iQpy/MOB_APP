import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/models/product.dart';
import 'package:urban_threads/widgets/mobile_product_card.dart';

class MobileSavedScreen extends StatelessWidget {
  const MobileSavedScreen({
    required this.products,
    required this.onProductTap,
    required this.onToggleSaved,
    required this.onShopTap,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onToggleSaved;
  final VoidCallback onShopTap;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE5DC),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: StoreColors.ink,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Keep the good ones close',
                style: TextStyle(
                  color: StoreColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Tap the heart on a style to save it here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: StoreColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onShopTap,
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.ink,
                  foregroundColor: StoreColors.paper,
                ),
                child: const Text('EXPLORE THE SHOP'),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Saved for later · ${products.length}',
              style: const TextStyle(
                color: StoreColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverGrid.builder(
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return MobileProductCard(
                product: product,
                isSaved: true,
                onTap: () => onProductTap(product),
                onToggleSaved: () => onToggleSaved(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

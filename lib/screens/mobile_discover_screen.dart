import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/models/product.dart';
import 'package:urban_threads/widgets/mobile_product_card.dart';
import 'package:urban_threads/widgets/store_primitives.dart';

class MobileDiscoverScreen extends StatelessWidget {
  const MobileDiscoverScreen({
    required this.products,
    required this.savedProducts,
    required this.onProductTap,
    required this.onToggleSaved,
    required this.onShopTap,
    super.key,
  });

  final List<Product> products;
  final List<Product> savedProducts;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onToggleSaved;
  final VoidCallback onShopTap;

  @override
  Widget build(BuildContext context) {
    final featured = products.take(4).toList();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR DAILY UNIFORM',
                  style: TextStyle(
                    color: StoreColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Made for your\\nevery day.',
                  style: TextStyle(
                    color: StoreColors.ink,
                    height: 1.06,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 18),
                _CollectionCard(onShopTap: onShopTap),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Popular right now',
                        style: TextStyle(
                          color: StoreColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onShopTap,
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 258,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: featured.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = featured[index];
                return SizedBox(
                  width: 158,
                  child: MobileProductCard(
                    product: product,
                    isSaved: savedProducts.any((item) => item.id == product.id),
                    onTap: () => onProductTap(product),
                    onToggleSaved: () => onToggleSaved(product),
                  ),
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAE5DC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_shipping_outlined, color: StoreColors.ink),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Free delivery on orders over ₱1,500',
                      style: TextStyle(
                        color: StoreColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 13, color: StoreColors.muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.onShopTap});

  final VoidCallback onShopTap;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 210,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const RemotePhoto(
                url:
                    'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?w=900&h=700&fit=crop&auto=format',
                label: 'Streetwear collection',
                icon: Icons.checkroom_outlined,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xCC171715), Color(0x00171715)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'THE NEW\nESSENTIALS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 11),
                    FilledButton(
                      onPressed: onShopTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: StoreColors.paper,
                        foregroundColor: StoreColors.ink,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('EXPLORE COLLECTION'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

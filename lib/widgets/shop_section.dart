import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/models/product.dart';
import 'package:urban_threads/utils/format_peso.dart';
import 'package:urban_threads/widgets/store_primitives.dart';

class ShopSection extends StatelessWidget {
  const ShopSection({
    required this.filter,
    required this.products,
    required this.selectedSizes,
    required this.onFilterChanged,
    required this.onSizeChanged,
    required this.onAddToCart,
    super.key,
  });

  final String filter;
  final List<Product> products;
  final Map<String, String> selectedSizes;
  final ValueChanged<String> onFilterChanged;
  final void Function(Product product, String size) onSizeChanged;
  final ValueChanged<Product> onAddToCart;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = constraints.maxWidth;
        final compact = contentWidth < 700;
        final padding = compact ? 20.0 : 36.0;
        final availableWidth =
            (contentWidth - padding * 2).clamp(0.0, 1320.0).toDouble();
        final columns = availableWidth >= 1080
            ? 4
            : availableWidth >= 720
                ? 3
                : 2;
        final gap = compact ? 10.0 : 16.0;
        final cardWidth = (availableWidth - gap * (columns - 1)) / columns;
        final cardHeight = cardWidth * 1.25 + 184;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1392),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: compact ? 52 : 76,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('THE LINEUP'),
                  const SizedBox(height: 10),
                  Text(
                    'SHOP ALL',
                    style: TextStyle(
                      color: StoreColors.ink,
                      fontSize: compact ? 44 : 60,
                      height: 1,
                      letterSpacing: -2.4,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'The everyday rotation. Pick your fit.',
                    style: TextStyle(color: StoreColors.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final option in const [
                        ('ALL', 'ALL'),
                        ('T-SHIRTS', 'T-SHIRTS'),
                        ('HOODIES', 'HOODIES'),
                        ('JACKETS', 'JACKETS'),
                        ('SHIRTS', 'SHIRTS'),
                        ('BOTTOMS', 'BOTTOMS'),
                        ('ACCESSORIES', 'ACCESSORIES'),
                      ])
                        _ShopFilter(
                          label: option.$2,
                          selected: filter == option.$1,
                          onPressed: () => onFilterChanged(option.$1),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text('No items in this collection yet.'),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: gap,
                        mainAxisSpacing: gap,
                        mainAxisExtent: cardHeight,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          selectedSize: selectedSizes[product.id] ??
                              product.sizes[
                                  2.clamp(0, product.sizes.length - 1).toInt()],
                          onSizeChanged: (size) => onSizeChanged(product, size),
                          onAddToCart: () => onAddToCart(product),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShopFilter extends StatelessWidget {
  const _ShopFilter({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? StoreColors.ink : Colors.transparent,
          foregroundColor: selected ? StoreColors.paper : StoreColors.ink,
          side: BorderSide(
            color: selected ? StoreColors.ink : StoreColors.line,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          shape: const RoundedRectangleBorder(),
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        child: Text(label),
      );
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.selectedSize,
    required this.onSizeChanged,
    required this.onAddToCart,
    super.key,
  });

  final Product product;
  final String selectedSize;
  final ValueChanged<String> onSizeChanged;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: StoreColors.paper),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RemotePhoto(
                  url: product.imageUrl,
                  label: '${product.name}, ${product.color}',
                  icon: Icons.checkroom_outlined,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    color: product.tag == 'LIMITED'
                        ? StoreColors.accent
                        : StoreColors.paper,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(
                      product.tag,
                      style: TextStyle(
                        color: product.tag == 'LIMITED'
                            ? Colors.white
                            : StoreColors.ink,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 12, 11, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: StoreColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    product.color,
                    style: const TextStyle(
                      color: StoreColors.muted,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatPeso(product.price),
                    style: const TextStyle(
                      color: StoreColors.ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    children: [
                      for (final size in product.sizes)
                        _SizeOption(
                          size: size,
                          selected: size == selectedSize,
                          onPressed: () => onSizeChanged(size),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 38,
                    child: FilledButton(
                      onPressed: onAddToCart,
                      style: FilledButton.styleFrom(
                        backgroundColor: StoreColors.ink,
                        foregroundColor: StoreColors.paper,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        shape: const RoundedRectangleBorder(),
                        textStyle: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                      ),
                      child: const Text('ADD TO BAG'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({
    required this.size,
    required this.selected,
    required this.onPressed,
  });

  final String size;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 26,
        height: 27,
        child: Material(
          color: selected ? StoreColors.ink : StoreColors.paper,
          child: InkWell(
            onTap: onPressed,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? StoreColors.ink : StoreColors.line,
                ),
              ),
              child: Center(
                child: Text(
                  size,
                  style: TextStyle(
                    color: selected ? StoreColors.paper : StoreColors.ink,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

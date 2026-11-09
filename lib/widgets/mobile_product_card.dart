import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/models/product.dart';
import 'package:urban_threads/utils/format_peso.dart';
import 'package:urban_threads/widgets/store_primitives.dart';

class MobileProductCard extends StatelessWidget {
  const MobileProductCard({
    required this.product,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSaved,
    super.key,
  });

  final Product product;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) => Material(
        color: StoreColors.paper,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: RemotePhoto(
                        url: product.imageUrl,
                        label: '${product.name}, ${product.color}',
                        icon: Icons.checkroom_outlined,
                      ),
                    ),
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: StoreColors.paper.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.tag,
                          style: const TextStyle(
                            color: StoreColors.ink,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: IconButton.filledTonal(
                        tooltip: isSaved ? 'Remove from saved' : 'Save item',
                        onPressed: onToggleSaved,
                        visualDensity: VisualDensity.compact,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              StoreColors.paper.withValues(alpha: 0.94),
                          foregroundColor:
                              isSaved ? StoreColors.accent : StoreColors.ink,
                        ),
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          size: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 10, 2, 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: StoreColors.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            product.color,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: StoreColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatPeso(product.price),
                      style: const TextStyle(
                        color: StoreColors.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

Future<void> showMobileProductDetails({
  required BuildContext context,
  required Product product,
  required bool isSaved,
  required VoidCallback onToggleSaved,
  required ValueChanged<String> onAddToBag,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: StoreColors.paper,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _ProductDetailsSheet(
      product: product,
      isSaved: isSaved,
      onToggleSaved: onToggleSaved,
      onAddToBag: onAddToBag,
    ),
  );
}

class _ProductDetailsSheet extends StatefulWidget {
  const _ProductDetailsSheet({
    required this.product,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onAddToBag,
  });

  final Product product;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final ValueChanged<String> onAddToBag;

  @override
  State<_ProductDetailsSheet> createState() => _ProductDetailsSheetState();
}

class _ProductDetailsSheetState extends State<_ProductDetailsSheet> {
  late String _selectedSize;
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _selectedSize =
        widget.product.sizes[2.clamp(0, widget.product.sizes.length - 1)];
    _isSaved = widget.isSaved;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.65,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: RemotePhoto(
                url: product.imageUrl,
                label: '${product.name}, ${product.color}',
                icon: Icons.checkroom_outlined,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: StoreColors.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.color,
                      style: const TextStyle(
                        color: StoreColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatPeso(product.price),
                style: const TextStyle(
                  color: StoreColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: _isSaved ? 'Remove from saved' : 'Save item',
                onPressed: () {
                  widget.onToggleSaved();
                  setState(() => _isSaved = !_isSaved);
                },
                icon: Icon(
                  _isSaved ? Icons.favorite : Icons.favorite_border,
                  color: _isSaved ? StoreColors.accent : StoreColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'SELECT SIZE',
            style: TextStyle(
              color: StoreColors.ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final size in product.sizes)
                ChoiceChip(
                  label: Text(size),
                  selected: _selectedSize == size,
                  onSelected: (_) => setState(() => _selectedSize = size),
                  selectedColor: StoreColors.ink,
                  backgroundColor: StoreColors.paper,
                  labelStyle: TextStyle(
                    color: _selectedSize == size
                        ? StoreColors.paper
                        : StoreColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: _selectedSize == size
                        ? StoreColors.ink
                        : StoreColors.line,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                widget.onAddToBag(_selectedSize);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: StoreColors.ink,
                foregroundColor: StoreColors.paper,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('ADD TO BAG'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Easy everyday fit · Free shipping over ₱1,500',
            textAlign: TextAlign.center,
            style: TextStyle(color: StoreColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

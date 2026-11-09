import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/models/product.dart';
import 'package:urban_threads/widgets/mobile_product_card.dart';

class MobileCatalogScreen extends StatefulWidget {
  const MobileCatalogScreen({
    required this.products,
    required this.savedProducts,
    required this.onProductTap,
    required this.onToggleSaved,
    super.key,
  });

  final List<Product> products;
  final List<Product> savedProducts;
  final ValueChanged<Product> onProductTap;
  final ValueChanged<Product> onToggleSaved;

  @override
  State<MobileCatalogScreen> createState() => _MobileCatalogScreenState();
}

class _MobileCatalogScreenState extends State<MobileCatalogScreen> {
  final _searchController = TextEditingController();
  String _category = 'ALL';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final visible = widget.products.where((product) {
      final matchesCategory =
          _category == 'ALL' || product.category == _category;
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.color.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find your next favorite',
                  style: TextStyle(
                    color: StoreColors.ink,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search styles or colors',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final category in const [
                        'ALL',
                        'T-SHIRTS',
                        'HOODIES',
                        'JACKETS',
                        'SHIRTS',
                        'BOTTOMS',
                        'ACCESSORIES'
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                                category == 'ALL' ? 'All items' : category),
                            selected: _category == category,
                            onSelected: (_) =>
                                setState(() => _category = category),
                            selectedColor: StoreColors.ink,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: _category == category
                                  ? StoreColors.paper
                                  : StoreColors.ink,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: _category == category
                                  ? StoreColors.ink
                                  : StoreColors.line,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${visible.length} ${visible.length == 1 ? 'STYLE' : 'STYLES'}',
                  style: const TextStyle(
                    color: StoreColors.muted,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (visible.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'No styles found',
                style: TextStyle(color: StoreColors.muted),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.builder(
              itemCount: visible.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) {
                final product = visible[index];
                return MobileProductCard(
                  product: product,
                  isSaved:
                      widget.savedProducts.any((item) => item.id == product.id),
                  onTap: () => widget.onProductTap(product),
                  onToggleSaved: () => widget.onToggleSaved(product),
                );
              },
            ),
          ),
      ],
    );
  }
}

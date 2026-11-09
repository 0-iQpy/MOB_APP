import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/data/products.dart';
import 'package:urban_threads/models/cart_model.dart';
import 'package:urban_threads/models/product.dart';
import 'package:urban_threads/screens/mobile_store_layout.dart';
import 'package:urban_threads/widgets/benefits_ticker.dart';
import 'package:urban_threads/widgets/cart_panel.dart';
import 'package:urban_threads/widgets/hero_section.dart';
import 'package:urban_threads/widgets/mobile_product_card.dart';
import 'package:urban_threads/widgets/shop_section.dart';
import 'package:urban_threads/widgets/simulated_checkout_sheet.dart';
import 'package:urban_threads/widgets/store_footer.dart';
import 'package:urban_threads/widgets/store_header.dart';
import 'package:urban_threads/widgets/story_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _cart = CartModel();
  final _shopKey = GlobalKey();
  final Map<String, String> _selectedSizes = {};
  final Set<String> _savedProductIds = {};
  String _filter = 'ALL';
  int _mobileTab = 0;

  List<Product> get _filteredProducts => _filter == 'ALL'
      ? products
      : products.where((product) => product.category == _filter).toList();

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  void _scrollToShop() {
    final shopContext = _shopKey.currentContext;
    if (shopContext != null) {
      unawaited(
        Scrollable.ensureVisible(
          shopContext,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  void _openCart() {
    final screenSize = MediaQuery.sizeOf(context);
    if (screenSize.width < 700) {
      setState(() => _mobileTab = 3);
      return;
    }

    if (screenSize.width >= 700) {
      showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(32),
          backgroundColor: StoreColors.paper,
          shape: const RoundedRectangleBorder(),
          child: SizedBox(
            width: 480,
            height: math.min(720.0, screenSize.height - 64).toDouble(),
            child: CartPanel(
              cart: _cart,
              onClose: () => Navigator.of(context).pop(),
              onCheckout: _showCheckoutMessage,
            ),
          ),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: StoreColors.paper,
      shape: const RoundedRectangleBorder(),
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.92,
        child: CartPanel(
          cart: _cart,
          onClose: () => Navigator.of(context).pop(),
          onCheckout: _showCheckoutMessage,
        ),
      ),
    );
  }

  void _showCheckoutMessage() {
    if (_cart.lines.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SimulatedCheckoutSheet(
        cart: _cart,
        onOrderPlaced: () {
          setState(() {
            _cart.clear();
          });
        },
      ),
    );
  }

  void _addToCart(Product product) {
    final size = _selectedSizes[product.id] ??
        product.sizes[2.clamp(0, product.sizes.length - 1).toInt()];
    _addSizeToCart(product, size);
  }

  void _addSizeToCart(Product product, String size) {
    _cart.add(product, size);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('${product.name} · SIZE $size added to your bag'),
          action: SnackBarAction(
            label: 'VIEW BAG',
            textColor: StoreColors.paper,
            onPressed: _openCart,
          ),
        ),
      );
  }

  void _toggleSaved(Product product) {
    setState(() {
      if (!_savedProductIds.add(product.id)) {
        _savedProductIds.remove(product.id);
      }
    });
  }

  void _openProduct(Product product) {
    showMobileProductDetails(
      context: context,
      product: product,
      isSaved: _savedProductIds.contains(product.id),
      onToggleSaved: () => _toggleSaved(product),
      onAddToBag: (size) => _addSizeToCart(product, size),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 700) {
      return MobileStoreLayout(
        cart: _cart,
        products: products,
        savedProducts: products
            .where((product) => _savedProductIds.contains(product.id))
            .toList(),
        onToggleSaved: _toggleSaved,
        onProductTap: _openProduct,
        onCheckout: _showCheckoutMessage,
        selectedTab: _mobileTab,
        onTabChanged: (tab) => setState(() => _mobileTab = tab),
      );
    }

    return Scaffold(
      appBar: StoreHeader(
        cart: _cart,
        onCartPressed: _openCart,
        onShopPressed: _scrollToShop,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HeroSection(onShopPressed: _scrollToShop),
            const BenefitsTicker(),
            ShopSection(
              key: _shopKey,
              filter: _filter,
              products: _filteredProducts,
              selectedSizes: _selectedSizes,
              onFilterChanged: (filter) => setState(() => _filter = filter),
              onSizeChanged: (product, size) {
                setState(() => _selectedSizes[product.id] = size);
              },
              onAddToCart: _addToCart,
            ),
            const StorySection(),
            const StoreFooter(),
          ],
        ),
      ),
    );
  }
}

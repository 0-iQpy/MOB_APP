import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/models/cart_model.dart';
import 'package:urban_threads/models/product.dart';
import 'package:urban_threads/widgets/cart_panel.dart';
import 'package:urban_threads/screens/mobile_catalog_screen.dart';
import 'package:urban_threads/screens/mobile_discover_screen.dart';
import 'package:urban_threads/screens/mobile_saved_screen.dart';
import 'package:urban_threads/widgets/store_header.dart';

class MobileStoreLayout extends StatelessWidget {
  const MobileStoreLayout({
    required this.cart,
    required this.products,
    required this.savedProducts,
    required this.onToggleSaved,
    required this.onProductTap,
    required this.onCheckout,
    required this.selectedTab,
    required this.onTabChanged,
    super.key,
  });

  final CartModel cart;
  final List<Product> products;
  final List<Product> savedProducts;
  final ValueChanged<Product> onToggleSaved;
  final ValueChanged<Product> onProductTap;
  final VoidCallback onCheckout;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StoreHeader(
        cart: cart,
        onCartPressed: () => onTabChanged(3),
        onShopPressed: () => onTabChanged(1),
        compactAppBar: true,
      ),
      body: IndexedStack(
        index: selectedTab,
        children: [
          MobileDiscoverScreen(
            products: products,
            savedProducts: savedProducts,
            onProductTap: onProductTap,
            onToggleSaved: onToggleSaved,
            onShopTap: () => onTabChanged(1),
          ),
          MobileCatalogScreen(
            products: products,
            savedProducts: savedProducts,
            onProductTap: onProductTap,
            onToggleSaved: onToggleSaved,
          ),
          MobileSavedScreen(
            products: savedProducts,
            onProductTap: onProductTap,
            onToggleSaved: onToggleSaved,
            onShopTap: () => onTabChanged(1),
          ),
          CartPanel(
            cart: cart,
            onClose: () => onTabChanged(1),
            onCheckout: onCheckout,
            showCloseButton: false,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: onTabChanged,
        backgroundColor: StoreColors.paper,
        indicatorColor: StoreColors.accent.withValues(alpha: 0.12),
        elevation: 3,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Shop',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: AnimatedBuilder(
              animation: cart,
              builder: (context, _) => Badge(
                isLabelVisible: cart.count > 0,
                label: Text('${cart.count}'),
                backgroundColor: StoreColors.accent,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
            selectedIcon: AnimatedBuilder(
              animation: cart,
              builder: (context, _) => Badge(
                isLabelVisible: cart.count > 0,
                label: Text('${cart.count}'),
                backgroundColor: StoreColors.accent,
                child: const Icon(Icons.shopping_bag),
              ),
            ),
            label: 'Bag',
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/models/cart_model.dart';
import 'package:urban_threads/widgets/store_primitives.dart';

class StoreHeader extends StatelessWidget implements PreferredSizeWidget {
  const StoreHeader({
    required this.cart,
    required this.onCartPressed,
    required this.onShopPressed,
    this.compactAppBar = false,
    super.key,
  });

  final CartModel cart;
  final VoidCallback onCartPressed;
  final VoidCallback onShopPressed;
  final bool compactAppBar;

  @override
  Size get preferredSize => Size.fromHeight(compactAppBar ? 58 : 68);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700 && !compactAppBar;
    final foreground = compactAppBar ? StoreColors.ink : StoreColors.paper;
    return AppBar(
      toolbarHeight: compactAppBar ? 58 : 68,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      backgroundColor: compactAppBar ? StoreColors.paper : StoreColors.ink,
      foregroundColor: foreground,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Padding(
        padding: EdgeInsets.only(left: wide ? 32 : 20),
        child: StoreWordmark(light: !compactAppBar),
      ),
      actions: [
        if (wide) ...[
          TextButton(
            onPressed: onShopPressed,
            child: const Text(
              'SHOP',
              style: TextStyle(
                color: StoreColors.paper,
                letterSpacing: 1.3,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        AnimatedBuilder(
          animation: cart,
          builder: (context, _) => Padding(
            padding: EdgeInsets.only(right: wide ? 32 : 12),
            child: IconButton(
              key: const ValueKey('open-cart'),
              onPressed: onCartPressed,
              tooltip: 'Open bag',
              icon: Badge(
                isLabelVisible: cart.count > 0,
                label: Text('${cart.count}'),
                backgroundColor: StoreColors.accent,
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 21,
                  color: foreground,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

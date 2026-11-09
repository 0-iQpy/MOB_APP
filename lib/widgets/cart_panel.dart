import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/models/cart_line.dart';
import 'package:urban_threads/models/cart_model.dart';
import 'package:urban_threads/utils/format_peso.dart';
import 'package:urban_threads/widgets/store_primitives.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({
    required this.cart,
    required this.onClose,
    required this.onCheckout,
    this.showCloseButton = true,
    super.key,
  });

  final CartModel cart;
  final VoidCallback onClose;
  final VoidCallback onCheckout;
  final bool showCloseButton;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: cart,
        builder: (context, _) => Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                showCloseButton ? 20 : 22,
                showCloseButton ? 18 : 24,
                16,
                16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      showCloseButton ? 'YOUR BAG (${cart.count})' : 'YOUR BAG',
                      style: const TextStyle(
                        color: StoreColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      tooltip: 'Close bag',
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: StoreColors.line),
            if (cart.isEmpty)
              Expanded(child: _EmptyBag(onContinueShopping: onClose))
            else ...[
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: cart.lines.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 24,
                    color: StoreColors.line,
                  ),
                  itemBuilder: (context, index) {
                    final line = cart.lines[index];
                    return _CartItem(
                      line: line,
                      onDecrease: () =>
                          cart.changeQuantity(line.product, line.size, -1),
                      onIncrease: () =>
                          cart.changeQuantity(line.product, line.size, 1),
                      onRemove: () => cart.remove(line.product, line.size),
                    );
                  },
                ),
              ),
              _CartSummary(cart: cart, onCheckout: onCheckout),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyBag extends StatelessWidget {
  const _EmptyBag({required this.onContinueShopping});

  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 42,
                color: StoreColors.muted,
              ),
              const SizedBox(height: 16),
              const Text(
                'YOUR BAG IS EMPTY',
                style: TextStyle(
                  color: StoreColors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Good things are only a scroll away.',
                style: TextStyle(color: StoreColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 22),
              OutlinedButton(
                onPressed: onContinueShopping,
                style: OutlinedButton.styleFrom(
                  foregroundColor: StoreColors.ink,
                  side: const BorderSide(color: StoreColors.ink),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text('CONTINUE SHOPPING'),
              ),
            ],
          ),
        ),
      );
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.line,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final CartLine line;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            height: 92,
            child: RemotePhoto(
              url: line.product.imageUrl,
              label: line.product.name,
              icon: Icons.checkroom_outlined,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: StoreColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'SIZE ${line.size} · ${line.product.color}',
                  style: const TextStyle(
                    color: StoreColors.muted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QuantityButton(
                      tooltip: 'Decrease quantity',
                      icon: Icons.remove,
                      onPressed: onDecrease,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${line.quantity}',
                        style: const TextStyle(
                          color: StoreColors.ink,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      tooltip: 'Increase quantity',
                      icon: Icons.add,
                      onPressed: onIncrease,
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Remove ${line.product.name}',
                      onPressed: onRemove,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: StoreColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatPeso(line.product.price * line.quantity),
            style: const TextStyle(
              color: StoreColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 30,
        height: 30,
        child: IconButton(
          tooltip: tooltip,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          style: IconButton.styleFrom(
            foregroundColor: StoreColors.ink,
            side: const BorderSide(color: StoreColors.line),
            shape: const RoundedRectangleBorder(),
          ),
        ),
      );
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({required this.cart, required this.onCheckout});

  static const _freeShippingThreshold = 1500;
  static const _shippingFee = 120;

  final CartModel cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final shipping = cart.subtotal >= _freeShippingThreshold ? 0 : _shippingFee;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: StoreColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SUBTOTAL',
                style: TextStyle(
                  color: StoreColors.ink,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              Text(
                formatPeso(cart.subtotal),
                style: const TextStyle(
                  color: StoreColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SHIPPING',
                style: TextStyle(
                  color: StoreColors.ink,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              Text(
                shipping == 0 ? 'FREE' : formatPeso(shipping),
                style: const TextStyle(
                  color: StoreColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: StoreColors.line),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  color: StoreColors.ink,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Text(
                formatPeso(cart.subtotal + shipping),
                style: const TextStyle(
                  color: StoreColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                backgroundColor: StoreColors.accent,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text(
                'CONTINUE TO CHECKOUT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'FREE SHIPPING ON ORDERS OVER ₱1,500',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: StoreColors.muted,
              fontSize: 9,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

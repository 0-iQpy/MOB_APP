import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/models/cart_line.dart';
import 'package:urban_threads/models/cart_model.dart';
import 'package:urban_threads/utils/format_peso.dart';
import 'package:urban_threads/widgets/store_primitives.dart';

enum _CheckoutStep {
  review,
  processing,
  success,
}

class SimulatedCheckoutSheet extends StatefulWidget {
  const SimulatedCheckoutSheet({
    required this.cart,
    required this.onOrderPlaced,
    super.key,
  });

  final CartModel cart;
  final VoidCallback onOrderPlaced;

  @override
  State<SimulatedCheckoutSheet> createState() => _SimulatedCheckoutSheetState();
}

class _SimulatedCheckoutSheetState extends State<SimulatedCheckoutSheet> {
  static const _freeShippingThreshold = 1500;
  static const _shippingFee = 120;

  _CheckoutStep _step = _CheckoutStep.review;
  String _selectedPayment = 'GCash';
  final String _orderReference = '#UT-84920';

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _startProcessing() async {
    setState(() {
      _step = _CheckoutStep.processing;
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _step = _CheckoutStep.success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final maxHeight = mediaQuery.size.height * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: StoreColors.paper,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: StoreColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 12, 10),
                child: Row(
                  children: [
                    const Text(
                      'CHECKOUT',
                      style: TextStyle(
                        color: StoreColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: StoreColors.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: StoreColors.accent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Text(
                        'SIMULATED DEMO',
                        style: TextStyle(
                          color: StoreColors.accent,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Close checkout',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      icon: const Icon(
                        Icons.close,
                        color: StoreColors.ink,
                        size: 20,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: StoreColors.line),
              Flexible(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case _CheckoutStep.review:
        return _buildReviewStep();
      case _CheckoutStep.processing:
        return _buildProcessingStep();
      case _CheckoutStep.success:
        return _buildSuccessStep();
    }
  }

  Widget _buildReviewStep() {
    final subtotal = widget.cart.subtotal;
    final shipping = subtotal >= _freeShippingThreshold ? 0 : _shippingFee;
    final total = subtotal + shipping;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: [
              _buildSectionHeader('DELIVERY ADDRESS'),
              const SizedBox(height: 12),
              _buildAddressInputs(),
              const SizedBox(height: 24),
              _buildSectionHeader('PAYMENT METHOD'),
              const SizedBox(height: 12),
              _buildPaymentMethods(),
              const SizedBox(height: 24),
              _buildSectionHeader('ORDER ITEMS (${widget.cart.count})'),
              const SizedBox(height: 12),
              _buildOrderItems(),
              const SizedBox(height: 16),
              _buildOrderTotals(subtotal, shipping, total),
              const SizedBox(height: 20),
              _buildDisclaimerBanner(),
            ],
          ),
        ),
        _buildBottomCta(total),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: StoreColors.ink,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildAddressInputs() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'RECIPIENT NAME',
          hintText: 'Enter full name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _phoneController,
          label: 'PHONE NUMBER',
          hintText: 'Enter mobile number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _addressController,
          label: 'STREET / UNIT / CITY',
          hintText: 'Enter delivery address',
          icon: Icons.place_outlined,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 13,
        color: StoreColors.ink,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          fontSize: 10,
          color: StoreColors.muted,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w700,
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 12,
          color: StoreColors.muted,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, size: 18, color: StoreColors.muted),
        filled: true,
        fillColor: StoreColors.imageSurface.withValues(alpha: 0.35),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StoreColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: StoreColors.ink, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final methods = [
      (
        id: 'GCash',
        name: 'GCash',
        subtitle: 'Simulated e-wallet',
        icon: Icons.account_balance_wallet_outlined,
      ),
      (
        id: 'Maya',
        name: 'Maya',
        subtitle: 'Simulated digital bank',
        icon: Icons.credit_card_outlined,
      ),
      (
        id: 'Card',
        name: 'Card',
        subtitle: 'Visa / Mastercard',
        icon: Icons.payment_outlined,
      ),
      (
        id: 'Cash on Delivery',
        name: 'Cash on Delivery',
        subtitle: 'Pay when delivered',
        icon: Icons.local_shipping_outlined,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: methods.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final method = methods[index];
        final isSelected = _selectedPayment == method.id;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedPayment = method.id;
              });
            },
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? StoreColors.imageSurface.withValues(alpha: 0.6)
                    : StoreColors.paper,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? StoreColors.ink : StoreColors.line,
                  width: isSelected ? 1.6 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    method.icon,
                    size: 18,
                    color: isSelected ? StoreColors.ink : StoreColors.muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: StoreColors.ink,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          method.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: StoreColors.muted,
                            fontSize: 8.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: StoreColors.ink,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderItems() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.cart.lines.length,
      separatorBuilder: (_, __) => const Divider(
        height: 16,
        color: StoreColors.line,
      ),
      itemBuilder: (context, index) {
        final line = widget.cart.lines[index];
        return _CheckoutItemTile(line: line);
      },
    );
  }

  Widget _buildOrderTotals(int subtotal, int shipping, int total) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StoreColors.imageSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: StoreColors.line),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SUBTOTAL',
                style: TextStyle(
                  color: StoreColors.muted,
                  fontSize: 11,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatPeso(subtotal),
                style: const TextStyle(
                  color: StoreColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'SHIPPING',
                    style: TextStyle(
                      color: StoreColors.muted,
                      fontSize: 11,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (shipping == 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: StoreColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'FREE',
                        style: TextStyle(
                          color: StoreColors.accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                shipping == 0 ? '₱0' : formatPeso(shipping),
                style: const TextStyle(
                  color: StoreColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: StoreColors.line),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL',
                style: TextStyle(
                  color: StoreColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              Text(
                formatPeso(total),
                style: const TextStyle(
                  color: StoreColors.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: StoreColors.imageSurface.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: StoreColors.line),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 16, color: StoreColors.muted),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Demo Mode · No real charge or credit card required',
              style: TextStyle(
                color: StoreColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: StoreColors.line)),
      ),
      child: SizedBox(
        height: 50,
        child: FilledButton(
          onPressed: _startProcessing,
          style: FilledButton.styleFrom(
            backgroundColor: StoreColors.accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            'PLACE ORDER · ${formatPeso(total)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingStep() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(StoreColors.accent),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Securing simulated payment...',
              style: TextStyle(
                color: StoreColors.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Connecting to simulated transaction gateway',
              style: TextStyle(
                color: StoreColors.muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStep() {
    final subtotal = widget.cart.subtotal;
    final shipping = subtotal >= _freeShippingThreshold ? 0 : _shippingFee;
    final total = subtotal + shipping;

    final customerName = _nameController.text.trim().isEmpty
        ? 'Customer'
        : _nameController.text.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: StoreColors.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: StoreColors.accent.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 34,
              color: StoreColors.accent,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ORDER CONFIRMED',
            style: TextStyle(
              color: StoreColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Reference: $_orderReference',
            style: const TextStyle(
              color: StoreColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StoreColors.imageSurface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: StoreColors.line),
            ),
            child: Column(
              children: [
                const _ConfirmationRow(
                  label: 'STATUS',
                  value: 'Simulated payment approved',
                ),
                const Divider(height: 18, color: StoreColors.line),
                const _ConfirmationRow(
                  label: 'ESTIMATED DELIVERY',
                  value: 'Estimated delivery: 2-3 business days',
                ),
                const Divider(height: 18, color: StoreColors.line),
                _ConfirmationRow(
                  label: 'DELIVER TO',
                  value: customerName,
                ),
                const Divider(height: 18, color: StoreColors.line),
                _ConfirmationRow(
                  label: 'PAYMENT METHOD',
                  value: '$_selectedPayment (Simulated)',
                ),
                const Divider(height: 18, color: StoreColors.line),
                _ConfirmationRow(
                  label: 'TOTAL CHARGED',
                  value: formatPeso(total),
                  isBold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                widget.onOrderPlaced();
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: StoreColors.ink,
                foregroundColor: StoreColors.paper,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'CONTINUE SHOPPING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  const _CheckoutItemTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 44,
          height: 54,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: RemotePhoto(
              url: line.product.imageUrl,
              label: line.product.name,
              icon: Icons.checkroom_outlined,
            ),
          ),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 3),
              Text(
                'SIZE ${line.size} · QTY ${line.quantity}',
                style: const TextStyle(
                  color: StoreColors.muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Text(
          formatPeso(line.product.price * line.quantity),
          style: const TextStyle(
            color: StoreColors.ink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: StoreColors.muted,
            fontSize: 10,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: StoreColors.ink,
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

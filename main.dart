import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const UrbanThreadsApp());

// ─────────────────────────────────────────────────────────────
// THEME
// ─────────────────────────────────────────────────────────────

class AppColors {
  static const background = Color(0xFFF5F2EE);
  static const foreground = Color(0xFF0A0A0A);
  static const muted = Color(0xFFD4CFC9);
  static const mutedForeground = Color(0xFF6B6560);
  static const accent = Color(0xFFE63312);
  static const tickerFg = Color(0xFF4A4A4A);
  static const tickerBorder = Color(0xFF2A2A2A);
  static const heroSub = Color(0xFFA09890);
  static const imageBg = Color(0xFFE8E4DF);
}

class AppText {
  // CSS letter-spacing is in em, Flutter wants logical pixels.
  static TextStyle condensed({
    double size = 16,
    FontWeight weight = FontWeight.w700,
    double spacingEm = 0,
    Color color = AppColors.foreground,
    double? height,
  }) =>
      GoogleFonts.barlowCondensed(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacingEm * size,
        color: color,
        height: height,
      );

  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    double spacingEm = 0,
    Color color = AppColors.foreground,
  }) =>
      GoogleFonts.spaceMono(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacingEm * size,
        color: color,
      );

  static TextStyle body({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.foreground,
    double? height,
  }) =>
      GoogleFonts.barlow(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );
}

// ─────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────

class Product {
  final int id;
  final String name;
  final int price;
  final String color;
  final String tag;
  final String img;
  final String alt;
  final List<String> sizes;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.color,
    required this.tag,
    required this.img,
    required this.alt,
    required this.sizes,
  });

  String get defaultSize => sizes[sizes.length ~/ 2];
}

const products = <Product>[
  Product(
    id: 1,
    name: 'CCC CLASSIC TEE',
    price: 300,
    color: 'Black',
    tag: 'BESTSELLER',
    img: 'assets/images/Untitled design (1).png',
    alt: 'Black t-shirt on hanger',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
  ),
  Product(
    id: 2,
    name: 'CCC CLASIC TEE',
    price: 320,
    color: 'White',
    tag: 'NEW',
    img: 'assets/images/Untitled design (2).png',
    alt: 'White t-shirt on hanger',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
  ),
  Product(
    id: 3,
    name: 'Acid Washed TEE',
    price: 350,
    color: 'Black',
    tag: 'LIMITED',
    img: 'assets/images/Untitled design (3).png',
    alt: 'White graphic t-shirt flat lay',
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
  ),
  Product(
    id: 4,
    name: 'Hoodie',
    price: 800,
    color: 'White',
    tag: 'NEW',
    img: 'assets/images/Untitled design (4).png',
    alt: 'Assorted colour shirts hanging on rack',
    sizes: ['S', 'M', 'L', 'XL'],
  ),
];

class CartItem {
  final int id;
  final String name;
  final int price;
  final String size;
  int qty;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.size,
    this.qty = 1,
  });
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get count => _items.fold(0, (a, c) => a + c.qty);
  int get total => _items.fold(0, (a, c) => a + c.price * c.qty);
  bool get isEmpty => _items.isEmpty;

  void add(Product p, String size) {
    final existing = _items.where((c) => c.id == p.id && c.size == size);
    if (existing.isNotEmpty) {
      existing.first.qty += 1;
    } else {
      _items.add(CartItem(id: p.id, name: p.name, price: p.price, size: size));
    }
    notifyListeners();
  }

  void remove(int id, String size) {
    _items.removeWhere((c) => c.id == id && c.size == size);
    notifyListeners();
  }
}

// ─────────────────────────────────────────────────────────────
// APP
// ─────────────────────────────────────────────────────────────

class UrbanThreadsApp extends StatelessWidget {
  const UrbanThreadsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'URBAN.THREADS',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          surface: AppColors.background,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _shopKey = GlobalKey();
  final _cart = CartModel();
  final Map<int, String> _selectedSizes = {};
  String _filter = 'ALL';

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }

  void _openCart() => _scaffoldKey.currentState?.openEndDrawer();
  void _closeCart() => _scaffoldKey.currentState?.closeEndDrawer();

  void _scrollToShop() {
    final ctx = _shopKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Product> get _filtered => _filter == 'ALL'
      ? products
      : products.where((p) => p.color == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _NavBar(cart: _cart, onCartTap: _openCart),
      endDrawer: _CartDrawer(cart: _cart, onClose: _closeCart),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _Hero(onShopNow: _scrollToShop),
            _ShopSection(
              key: _shopKey,
              filter: _filter,
              onFilter: (f) => setState(() => _filter = f),
              items: _filtered,
              selectedSizes: _selectedSizes,
              onSelectSize: (id, s) => setState(() => _selectedSizes[id] = s),
              onAdd: (p) =>
                  _cart.add(p, _selectedSizes[p.id] ?? p.defaultSize),
            ),
            const _AboutSection(),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHARED BITS
// ─────────────────────────────────────────────────────────────

/// Square-cornered button used all over the design.
class BlockButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color background;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const BlockButton({
    super.key,
    required this.child,
    required this.onTap,
    required this.background,
    this.borderColor,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: Border.all(
        color: borderColor ?? Colors.transparent,
        width: borderColor == null ? 0 : 2,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Center(widthFactor: 1, heightFactor: 1, child: child),
        ),
      ),
    );
  }
}

class _MaxWidth extends StatelessWidget {
  final Widget child;
  const _MaxWidth({required this.child});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: child,
        ),
      );
}

// ─────────────────────────────────────────────────────────────
// NAV BAR
// ─────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget implements PreferredSizeWidget {
  final CartModel cart;
  final VoidCallback onCartTap;

  const _NavBar({required this.cart, required this.onCartTap});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.foreground,
      foregroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 56,
      titleSpacing: 24,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Text.rich(
        TextSpan(
          style: AppText.condensed(
            size: 24,
            weight: FontWeight.w900,
            spacingEm: 0.15,
            color: AppColors.background,
          ),
          children: const [
            TextSpan(text: 'URBAN'),
            TextSpan(text: '.', style: TextStyle(color: AppColors.accent)),
            TextSpan(text: 'THREADS'),
          ],
        ),
      ),
      actions: [
        ListenableBuilder(
          listenable: cart,
          builder: (context, _) => InkWell(
            onTap: onCartTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 40, 8),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'CART',
                        style: AppText.mono(
                          spacingEm: 0.15,
                          color: AppColors.background,
                        ),
                      ),
                    ],
                  ),
                  if (cart.count > 0)
                    Positioned(
                      top: -8,
                      right: -16,
                      child: Container(
                        width: 20,
                        height: 20,
                        color: AppColors.accent,
                        alignment: Alignment.center,
                        child: Text(
                          '${cart.count}',
                          style: AppText.mono(
                            size: 10,
                            weight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HERO + TICKER
// ─────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  final VoidCallback onShopNow;
  const _Hero({required this.onShopNow});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final wide = width >= 768;
    final titleSize = (width * 0.10).clamp(64.0, 144.0);

    final text = Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '— SHOP THE BACK-TO-SCHOOL COLLECTION NOW!',
            style: AppText.mono(
              spacingEm: 0.3,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: AppText.condensed(
                size: titleSize,
                weight: FontWeight.w900,
                spacingEm: -0.02,
                color: AppColors.background,
                height: 1,
              ),
              children: const [
                TextSpan(text: 'WEAR\nNO\n'),
                TextSpan(
                  text: 'LABELS',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              'Essential streetwear. No logos, no noise. Just form and fabric.',
              style: AppText.body(
                size: 18,
                color: AppColors.heroSub,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 32),
          BlockButton(
            onTap: onShopNow,
            background: AppColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SHOP NOW',
                  style: AppText.condensed(
                    size: 18,
                    spacingEm: 0.15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );

    final image = SizedBox(
      height: 560,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.7,
            child: Image.network(
              'https://images.unsplash.com/photo-1517502166878-35c93a0072f0?w=800&h=900&fit=crop&auto=format',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              semanticLabel: 'White clothes hangers on rack',
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: AppColors.tickerBorder),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment(0.2, 0),
                colors: [AppColors.foreground, Color(0x000A0A0A)],
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      color: AppColors.foreground,
      child: Column(
        children: [
          _MaxWidth(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: text),
                        Expanded(child: image),
                      ],
                    )
                  : SizedBox(width: double.infinity, child: text),
            ),
          ),
          const _Ticker(),
        ],
      ),
    );
  }
}

class _Ticker extends StatefulWidget {
  const _Ticker();

  @override
  State<_Ticker> createState() => _TickerState();
}

class _TickerState extends State<_Ticker> with SingleTickerProviderStateMixin {
  static const _items = [
    'FREE SHIPPING OVER \$120',
    'PREMIUM COTTON BLEND',
    'LIMITED DROPS WEEKLY',
  ];
  static const _pixelsPerSecond = 40.0;

  final _controller = ScrollController();
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (_controller.hasClients) {
        _controller.jumpTo(elapsed.inMilliseconds / 1000 * _pixelsPerSecond);
      }
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppText.body(
      size: 14,
      weight: FontWeight.w700,
      color: AppColors.tickerFg,
    ).copyWith(letterSpacing: 2.8);

    return Container(
      height: 46,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.tickerBorder)),
      ),
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          final isSep = i.isOdd;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Text(
                isSep ? '✦' : _items[(i ~/ 2) % _items.length],
                style: isSep ? style.copyWith(color: AppColors.accent) : style,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SHOP SECTION
// ─────────────────────────────────────────────────────────────

class _ShopSection extends StatelessWidget {
  final String filter;
  final ValueChanged<String> onFilter;
  final List<Product> items;
  final Map<int, String> selectedSizes;
  final void Function(int id, String size) onSelectSize;
  final ValueChanged<Product> onAdd;

  const _ShopSection({
    super.key,
    required this.filter,
    required this.onFilter,
    required this.items,
    required this.selectedSizes,
    required this.onSelectSize,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = width >= 1024 ? 4 : (width >= 640 ? 2 : 1);
    final wide = width >= 768;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '— THE LINEUP',
          style: AppText.mono(spacingEm: 0.3, color: AppColors.accent),
        ),
        const SizedBox(height: 8),
        Text(
          'SHOP ALL',
          style: AppText.condensed(
            size: 60,
            weight: FontWeight.w900,
            spacingEm: -0.02,
          ),
        ),
      ],
    );

    final filters = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final f in const ['ALL', 'White', 'Black']) ...[
          BlockButton(
            onTap: () => onFilter(f),
            background:
                filter == f ? AppColors.foreground : AppColors.background,
            borderColor: AppColors.foreground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              f.toUpperCase(),
              style: AppText.mono(
                spacingEm: 0.15,
                color:
                    filter == f ? AppColors.background : AppColors.foreground,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );

    // Product grid with 1px black gaps, like the original.
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += cols) {
      final cells = <Widget>[];
      for (var j = 0; j < cols; j++) {
        final idx = i + j;
        if (j > 0) cells.add(const SizedBox(width: 1));
        cells.add(
          Expanded(
            child: idx < items.length
                ? _ProductCard(
                    product: items[idx],
                    selectedSize:
                        selectedSizes[items[idx].id] ?? items[idx].defaultSize,
                    onSelectSize: (s) => onSelectSize(items[idx].id, s),
                    onAdd: () => onAdd(items[idx]),
                  )
                : const ColoredBox(color: AppColors.background),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 1));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: cells,
          ),
        ),
      );
    }

    return _MaxWidth(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 64, 24, 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [heading, filters],
              )
            else ...[
              heading,
              const SizedBox(height: 16),
              filters,
            ],
            const SizedBox(height: 40),
            Container(
              color: AppColors.foreground,
              child: Column(children: rows),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final String selectedSize;
  final ValueChanged<String> onSelectSize;
  final VoidCallback onAdd;

  const _ProductCard({
    required this.product,
    required this.selectedSize,
    required this.onSelectSize,
    required this.onAdd,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _added = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleAdd() {
    widget.onAdd();
    setState(() => _added = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _added = false);
    });
  }

  Color _tagBg(String tag) {
    switch (tag) {
      case 'LIMITED':
        return AppColors.accent;
      case 'NEW':
        return AppColors.foreground;
      default:
        return AppColors.background;
    }
  }

  Color _tagFg(String tag) =>
      tag == 'BESTSELLER' ? AppColors.foreground : Colors.white;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: AppColors.imageBg,
                  child: Image.asset(
                    p.img,
                    fit: BoxFit.cover,
                    semanticLabel: p.alt,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.checkroom,
                        size: 48,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    color: _tagBg(p.tag),
                    child: Text(
                      p.tag,
                      style: AppText.condensed(
                        size: 12,
                        spacingEm: 0.15,
                        color: _tagFg(p.tag),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.foreground, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name.toUpperCase(),
                              style: AppText.condensed(
                                size: 20,
                                spacingEm: -0.01,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              p.color,
                              style: AppText.mono(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '₱${p.price}',
                        style: AppText.condensed(
                          size: 24,
                          weight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in p.sizes)
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: BlockButton(
                            onTap: () => widget.onSelectSize(s),
                            background: s == widget.selectedSize
                                ? AppColors.foreground
                                : AppColors.background,
                            borderColor: AppColors.foreground,
                            padding: EdgeInsets.zero,
                            child: Text(
                              s,
                              style: AppText.mono(
                                color: s == widget.selectedSize
                                    ? AppColors.background
                                    : AppColors.foreground,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(height: 16),
                  BlockButton(
                    onTap: _handleAdd,
                    background:
                        _added ? AppColors.accent : AppColors.background,
                    borderColor:
                        _added ? AppColors.accent : AppColors.foreground,
                    child: Text(
                      _added ? '✓ ADDED' : 'ADD TO CART',
                      style: AppText.condensed(
                        size: 14,
                        spacingEm: 0.15,
                        color: _added ? Colors.white : AppColors.foreground,
                      ),
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

// ─────────────────────────────────────────────────────────────
// ABOUT + FOOTER
// ─────────────────────────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  static const _cards = [
    ('01', 'MATERIAL',
        '180gsm heavyweight ringspun cotton. Pre-shrunk. Built to outlast your last drop.'),
    ('02', 'FIT',
        'Boxy oversized cut. Drop shoulder. Unisex sizing runs true.'),
    ('03', 'ETHICS',
        'Produced in fair-wage facilities. Limited runs. No overstock, no waste.'),
  ];

  Widget _card((String, String, String) c) => Container(
        color: AppColors.foreground,
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              c.$1,
              style: AppText.mono(spacingEm: 0.15, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            Text(
              c.$2,
              style: AppText.condensed(
                size: 30,
                weight: FontWeight.w900,
                spacingEm: -0.01,
                color: AppColors.background,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              c.$3,
              style: AppText.body(color: AppColors.heroSub, height: 1.6),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 768;

    final Widget grid = wide
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < _cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 1),
                  Expanded(child: _card(_cards[i])),
                ],
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 1),
                _card(_cards[i]),
              ],
            ],
          );

    return Container(
      width: double.infinity,
      color: AppColors.foreground,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: _MaxWidth(
        child: Container(color: AppColors.tickerBorder, child: grid),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 768;

    final logo = Text.rich(
      TextSpan(
        style: AppText.condensed(
          size: 20,
          weight: FontWeight.w900,
          spacingEm: 0.15,
        ),
        children: const [
          TextSpan(text: 'URBAN'),
          TextSpan(text: '.', style: TextStyle(color: AppColors.accent)),
          TextSpan(text: 'THREADS'),
        ],
      ),
    );

    final copy = Text(
      '© 2026 URBAN.THREADS — ALL RIGHTS RESERVED',
      textAlign: wide ? TextAlign.left : TextAlign.center,
      style: AppText.mono(
        spacingEm: 0.1,
        color: AppColors.mutedForeground,
      ),
    );

    final links = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final l in const ['Instagram', 'Privacy', 'Returns']) ...[
          // TODO: hook these up to url_launcher or real screens.
          Text(
            l.toUpperCase(),
            style: AppText.mono(
              spacingEm: 0.15,
              color: AppColors.mutedForeground,
            ),
          ),
          if (l != 'Returns') const SizedBox(width: 24),
        ],
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.foreground, width: 2),
        ),
      ),
      child: _MaxWidth(
        child: wide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [logo, Flexible(child: copy), links],
              )
            : Column(
                children: [
                  logo,
                  const SizedBox(height: 16),
                  copy,
                  const SizedBox(height: 16),
                  links,
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CART DRAWER
// ─────────────────────────────────────────────────────────────

class _CartDrawer extends StatelessWidget {
  final CartModel cart;
  final VoidCallback onClose;

  const _CartDrawer({required this.cart, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final width = math.min(420.0, MediaQuery.of(context).size.width);

    return Drawer(
      width: width,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: cart,
          builder: (context, _) => Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.foreground, width: 2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YOUR CART (${cart.count})',
                      style: AppText.condensed(
                        size: 24,
                        weight: FontWeight.w900,
                      ),
                    ),
                    InkWell(
                      onTap: onClose,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          '✕ CLOSE',
                          style: AppText.mono(spacingEm: 0.15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: cart.isEmpty
                    ? _EmptyCart(onShopNow: onClose)
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          final item = cart.items[i];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.foreground,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name.toUpperCase(),
                                        style: AppText.condensed(size: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'SIZE: ${item.size} · QTY: ${item.qty}',
                                        style: AppText.mono(
                                          color: AppColors.mutedForeground,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '₱${item.price * item.qty}',
                                  style: AppText.condensed(
                                    size: 18,
                                    weight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => cart.remove(item.id, item.size),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      '✕',
                                      style: AppText.mono(
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Footer
              if (!cart.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.foreground, width: 2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'TOTAL',
                            style: AppText.mono(size: 14, spacingEm: 0.15),
                          ),
                          Text(
                            '₱${cart.total}',
                            style: AppText.condensed(
                              size: 30,
                              weight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BlockButton(
                        // TODO: wire up real checkout (PayMongo, GCash, etc.)
                        onTap: () {},
                        background: AppColors.accent,
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'CHECKOUT',
                          style: AppText.condensed(
                            size: 18,
                            spacingEm: 0.15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'FREE SHIPPING ON ORDERS OVER \$120',
                        textAlign: TextAlign.center,
                        style: AppText.mono(
                          size: 10,
                          spacingEm: 0.05,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback onShopNow;
  const _EmptyCart({required this.onShopNow});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'EMPTY',
            style: AppText.condensed(
              size: 48,
              weight: FontWeight.w900,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is waiting to be filled.',
            style: AppText.body(color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 16),
          BlockButton(
            onTap: onShopNow,
            background: AppColors.foreground,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(
              'SHOP NOW',
              style: AppText.body(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.background,
              ).copyWith(letterSpacing: 2.1),
            ),
          ),
        ],
      ),
    );
  }
}

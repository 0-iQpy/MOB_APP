import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_threads/app.dart';
import 'package:urban_threads/data/products.dart';
import 'package:urban_threads/screens/mobile_catalog_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('uses app navigation and filters the mobile catalog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const UrbanThreadsApp());

    expect(find.text('YOUR DAILY UNIFORM'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Shop').last);
    await tester.pumpAndSettle();

    expect(find.text('Find your next favorite'), findsOneWidget);
    expect(find.text('CLASSIC BOX TEE'), findsOneWidget);

    await tester.tap(find.text('HOODIES'));
    await tester.pumpAndSettle();

    expect(find.text('EVERYDAY HOODIE'), findsOneWidget);
    expect(find.text('CLASSIC BOX TEE'), findsNothing);
  });

  testWidgets('adds a chosen size and updates bag quantity', (tester) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const UrbanThreadsApp());

    await tester.tap(find.text('Shop').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('CLASSIC BOX TEE').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('XL').first);
    await tester.tap(find.text('ADD TO BAG').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('open-cart')));
    await tester.pumpAndSettle();

    expect(find.text('YOUR BAG'), findsOneWidget);
    expect(find.text('SIZE XL · Washed black'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pumpAndSettle();

    expect(find.text('YOUR BAG'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(find.text('₱1,380'), findsNWidgets(2));
    expect(find.text('₱1,500'), findsOneWidget);
  });

  testWidgets('saves a style to the Saved destination', (tester) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const UrbanThreadsApp());
    await tester.tap(find.text('Shop').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save item').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved').last);
    await tester.pumpAndSettle();

    expect(find.text('Saved for later · 1'), findsOneWidget);
    expect(find.text('CLASSIC BOX TEE'), findsOneWidget);
  });

  testWidgets('verifies expanded catalog with local assets and category filters', (
    tester,
  ) async {
    expect(products.length, greaterThanOrEqualTo(10));
    expect(products.length, equals(12));

    for (final p in products) {
      expect(p.imageUrl, startsWith('assets/images/products/'));
    }

    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const UrbanThreadsApp());
    await tester.tap(find.text('Shop').last);
    await tester.pumpAndSettle();

    expect(find.text('12 STYLES'), findsOneWidget);

    // Verify local image widgets are rendered with AssetImage
    expect(find.byType(Image), findsWidgets);
    final imageWidgets = tester.widgetList<Image>(find.byType(Image));
    expect(
      imageWidgets.any((img) => img.image is AssetImage),
      isTrue,
    );

    final catalogList = find.descendant(
      of: find.byType(MobileCatalogScreen),
      matching: find.byType(ListView),
    );

    Future<void> selectCategory(String name) async {
      int guard = 0;
      while (find.text(name).evaluate().isEmpty && guard < 10) {
        await tester.drag(catalogList, const Offset(-150, 0));
        await tester.pumpAndSettle();
        guard++;
      }
      if (tester.getCenter(find.text(name)).dx > 280) {
        await tester.drag(catalogList, const Offset(-120, 0));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    Future<void> selectAll() async {
      int guard = 0;
      while (find.text('All items').evaluate().isEmpty && guard < 10) {
        await tester.drag(catalogList, const Offset(150, 0));
        await tester.pumpAndSettle();
        guard++;
      }
      if (tester.getCenter(find.text('All items')).dx < 60) {
        await tester.drag(catalogList, const Offset(80, 0));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('All items'));
      await tester.pumpAndSettle();
    }

    // Filter by JACKETS
    await selectCategory('JACKETS');
    expect(find.text('VINTAGE DENIM JACKET'), findsOneWidget);
    expect(find.text('CLASSIC BOX TEE'), findsNothing);

    // Filter by BOTTOMS
    await selectCategory('BOTTOMS');
    expect(find.text('RELAXED CARGO PANT'), findsOneWidget);

    // Filter by ACCESSORIES
    await selectCategory('ACCESSORIES');
    expect(find.text('STRUCTURED 6-PANEL CAP'), findsOneWidget);

    // Reset back to All items
    await selectAll();
    expect(find.text('12 STYLES'), findsOneWidget);
  });

  testWidgets('completes simulated checkout flow and confirms order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const UrbanThreadsApp());

    // Navigate to Shop and add an item to bag
    await tester.tap(find.text('Shop').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('CLASSIC BOX TEE').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('XL').first);
    await tester.tap(find.text('ADD TO BAG').first);
    await tester.pumpAndSettle();

    // Open bag via SnackBar action or header button
    await tester.tap(find.text('VIEW BAG'));
    await tester.pumpAndSettle();

    expect(find.text('YOUR BAG'), findsOneWidget);
    expect(find.text('CONTINUE TO CHECKOUT'), findsOneWidget);

    // Tap checkout
    await tester.tap(find.text('CONTINUE TO CHECKOUT'));
    await tester.pumpAndSettle();

    // Verify simulated checkout sheet appears
    expect(find.text('CHECKOUT'), findsOneWidget);
    expect(find.text('SIMULATED DEMO'), findsOneWidget);
    expect(find.text('DELIVERY ADDRESS'), findsOneWidget);
    expect(find.text('PAYMENT METHOD'), findsOneWidget);
    expect(find.text('GCash'), findsOneWidget);
    expect(find.text('Maya'), findsOneWidget);
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('Cash on Delivery'), findsOneWidget);

    // Tap place order button
    final placeOrderFinder = find.textContaining('PLACE ORDER');
    expect(placeOrderFinder, findsOneWidget);
    await tester.tap(placeOrderFinder);
    await tester.pump();

    // Verify processing state
    expect(find.text('Securing simulated payment...'), findsOneWidget);

    // Settle to complete simulated delay and enter order confirmed state
    await tester.pumpAndSettle();

    expect(find.text('ORDER CONFIRMED'), findsOneWidget);
    expect(find.textContaining('Reference: #UT-'), findsOneWidget);
    expect(find.text('Estimated delivery: 2-3 business days'), findsOneWidget);
    expect(find.text('CONTINUE SHOPPING'), findsOneWidget);

    // Tap continue shopping
    await tester.tap(find.text('CONTINUE SHOPPING'));
    await tester.pumpAndSettle();

    // Verify bag is cleared
    expect(find.text('YOUR BAG IS EMPTY'), findsOneWidget);
  });
}

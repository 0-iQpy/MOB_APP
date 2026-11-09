import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:urban_threads/app.dart';

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
}

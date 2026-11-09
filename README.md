# URBAN.THREADS

A responsive streetwear storefront built with Flutter for Android, iOS, and web.

## Run locally

Install the Flutter SDK, then from the repository root run:

```sh
flutter pub get
flutter run
```

Product photography is loaded from Unsplash and requires an internet connection.
If an image cannot be loaded, the app displays an accessible placeholder.

On phones, the app uses Home, Shop, Saved, and Bag destinations, with search,
category filters, product detail sheets, size selection, saved items, and a
shopping bag with quantity controls and shipping estimates. Wider screens use a
responsive storefront layout. The checkout is a preview; payment processing is
not connected.

## Source structure

- `lib/main.dart` — application entry point.
- `lib/app.dart` — app-level theme and root widget.
- `lib/core/theme/` — shared colors and theme values.
- `lib/data/` — product catalog data.
- `lib/models/` — product and cart models.
- `lib/screens/` — page-level state and storefront composition.
- `lib/widgets/` — reusable header, hero, catalog, story, footer, and bag UI.
- `lib/utils/` — shared formatting helpers.

## Verify

```sh
flutter analyze
flutter test
```

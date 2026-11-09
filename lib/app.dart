import 'package:flutter/material.dart';
import 'package:urban_threads/core/theme/store_colors.dart';
import 'package:urban_threads/screens/home_page.dart';

class UrbanThreadsApp extends StatelessWidget {
  const UrbanThreadsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: StoreColors.accent,
      brightness: Brightness.light,
    ).copyWith(
      surface: StoreColors.paper,
      onSurface: StoreColors.ink,
      primary: StoreColors.ink,
      onPrimary: StoreColors.paper,
      secondary: StoreColors.accent,
    );

    return MaterialApp(
      title: 'URBAN.THREADS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: StoreColors.paper,
        appBarTheme: const AppBarTheme(
          backgroundColor: StoreColors.ink,
          foregroundColor: StoreColors.paper,
          surfaceTintColor: Colors.transparent,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: StoreColors.ink,
          contentTextStyle: TextStyle(color: StoreColors.paper),
        ),
      ),
      home: const HomePage(),
    );
  }
}

import 'package:flutter/material.dart';

class AppColors {
  static const bg     = Color(0xFFF7F5FF);
  static const surf   = Color(0xFFFFFFFF);
  static const surf2  = Color(0xFFEFECFA);
  static const surf3  = Color(0xFFE4E0F5);

  static const txt    = Color(0xFF1A1535);
  static const txt2   = Color(0xFF6B6490);
  static const txt3   = Color(0xFFACA8C6);

  static const purple  = Color(0xFF7C5CE8);
  static const purpleL = Color(0xFFEDE8FD);
  static const mint    = Color(0xFF00C897);
  static const mintL   = Color(0xFFD8F8F0);
  static const coral   = Color(0xFFFF6B57);
  static const coralL  = Color(0xFFFFECE9);
  static const gold    = Color(0xFFF5A623);
  static const goldL   = Color(0xFFFFF3DC);
  static const orange  = Color(0xFFFF8C42);
  static const blue    = Color(0xFF4A90E2);
  static const blueL   = Color(0xFFE8F2FF);

  static const divider = Color(0xFFE8E4F4);
  static const shadow  = Color(0x14000000);

  static const accentColors = [purple, mint, gold, coral, orange, blue];
  static const accentLights = [purpleL, mintL, goldL, coralL, goldL, blueL];
  static const accentNames  = ['Purple','Mint','Gold','Coral','Orange','Blue'];

  static Color lightFor(Color c) {
    final i = accentColors.indexOf(c);
    return i >= 0 ? accentLights[i] : purpleL;
  }
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.purple, brightness: Brightness.light),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.txt),
      iconTheme: IconThemeData(color: AppColors.txt),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surf,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.divider),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surf,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.purple, width: 2)),
      hintStyle: const TextStyle(color: AppColors.txt3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

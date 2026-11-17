import 'package:flutter/material.dart';

class AppTheme {
  // Warna Khas Naruto
  static const Color primary = Color(0xFFFF7A00);        // Naruto Signature Orange
  static const Color primaryDark = Color(0xFFE65100);    // Deep Orange
  static const Color primaryLight = Color(0xFFFFF3E0);   // Soft Cream Orange
  static const Color accent = Color(0xFF1E293B);          // Konoha Dark Slate
  static const Color background = Color(0xFFF8FAFC);      // Clean Light Background
  static const Color surface = Colors.white;              // Card & Sheet Background

  // Warna Teks
  static const Color textPrimary = Color(0xFF0F172A);    // Dark Slate
  static const Color textSecondary = Color(0xFF64748B);  // Muted Slate Gray
  static const Color textLight = Colors.white;

  // Garis & Status
  static const Color border = Color(0xFFE2E8F0);
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF94A3B8),
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        prefixIconColor: primary,
      ),
    );
  }
}

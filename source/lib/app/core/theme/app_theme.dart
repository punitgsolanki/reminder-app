import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.card,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.background,
      background: AppColors.background,
      error: AppColors.destructive,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.foreground),
      bodyMedium: TextStyle(color: AppColors.foreground),
      titleLarge: TextStyle(color: AppColors.foreground),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.ring),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryForeground,
    scaffoldBackgroundColor: AppColors.foreground,
    cardColor: AppColors.card,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryForeground,
      secondary: AppColors.secondaryForeground,
      surface: AppColors.foreground,
      background: AppColors.foreground,
      error: AppColors.destructive,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.background),
      bodyMedium: TextStyle(color: AppColors.background),
      titleLarge: TextStyle(color: AppColors.background),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.ring),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
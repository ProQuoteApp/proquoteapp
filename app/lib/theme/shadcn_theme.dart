import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Initializes the shadcn_ui theme with the app's color scheme
class ShadcnTheme {
  /// Get the shadcn_ui theme builder for Material
  static ThemeData Function(BuildContext, ThemeData) getMaterialThemeBuilder() {
    return (context, theme) {
      // Get the current shadcn theme
      final shadTheme = ShadTheme.of(context);
      
      return theme.copyWith(
        // Use the shadcn theme colors instead of AppTheme colors
        colorScheme: ColorScheme(
          brightness: shadTheme.brightness,
          primary: shadTheme.colorScheme.primary,
          onPrimary: shadTheme.colorScheme.primaryForeground,
          secondary: shadTheme.colorScheme.secondary,
          onSecondary: shadTheme.colorScheme.secondaryForeground,
          error: shadTheme.colorScheme.destructive,
          onError: shadTheme.colorScheme.destructiveForeground,
          surface: shadTheme.colorScheme.card,
          onSurface: shadTheme.colorScheme.cardForeground,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: shadTheme.colorScheme.primary,
            foregroundColor: shadTheme.colorScheme.primaryForeground,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: shadTheme.colorScheme.primary,
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: shadTheme.colorScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: shadTheme.colorScheme.primary,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: shadTheme.colorScheme.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: shadTheme.colorScheme.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: shadTheme.colorScheme.destructive),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
    };
  }
} 
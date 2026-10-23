import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Khởi tạo ColorScheme Material 3 tối giản cho MOVEN.
class AppColorSchemes {
  AppColorSchemes._();

  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.accent,
    onSecondary: AppColors.onAccent,
    secondaryContainer: AppColors.beige,
    onSecondaryContainer: AppColors.primary,
    tertiary: AppColors.accent,
    onTertiary: AppColors.onAccent,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF991B1B),
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.border,
    outlineVariant: AppColors.warmGray,
    shadow: Color(0x1A000000),
    scrim: Color(0x66000000),
  );
}

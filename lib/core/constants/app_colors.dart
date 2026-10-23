import 'package:flutter/material.dart';

/// Bảng màu chuẩn của MOVEN theo tinh thần tối giản, hiện đại (Coolmate-style minimalism).
/// Bảng màu gồm: trắng, đen, xám, kem, be, nâu nhạt với tương phản thị giác cao.
class AppColors {
  AppColors._();

  // Primary & Dark tones
  static const Color primary = Color(0xFF111827); // Charcoal / Deep Black
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1F2937);
  static const Color onPrimaryContainer = Color(0xFFF9FAFB);

  // Background & Surfaces
  static const Color background = Color(0xFFF9FAFB); // Off-white nhẹ nhàng
  static const Color onBackground = Color(0xFF111827);
  static const Color surface = Color(0xFFFFFFFF); // Card, dialog, sheet trắng tinh
  static const Color onSurface = Color(0xFF111827);
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Neutral gray
  static const Color onSurfaceVariant = Color(0xFF4B5563);

  // Accent & Earth tones (Nâu nhạt, Be, Kem)
  static const Color accent = Color(0xFF854D0E); // Warm tan / Muted brown
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color beige = Color(0xFFF5F3EF); // Màu be kem làm nền banner/card
  static const Color warmGray = Color(0xFFE5E7EB);

  // Borders & Dividers
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocused = Color(0xFF111827);

  // Text colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status & Feedback
  static const Color success = Color(0xFF059669);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFD97706);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color info = Color(0xFF2563EB);
  static const Color onInfo = Color(0xFFFFFFFF);
}

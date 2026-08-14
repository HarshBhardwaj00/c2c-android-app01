import 'package:flutter/material.dart';

/// Centralized Figma Design Token Palette for Campus2Corporate (c2c_android)
class AppColors {
  // --- Brand & Accent Colors ---
  static const Color primary = Color(0xFF6366F1); // Main Vibrant Purple/Indigo
  static const Color primaryDark = Color(
    0xFF4F46E5,
  ); // Darker Indigo for active states
  static const Color primaryLight = Color(
    0xFFECE6FE,
  ); // Soft Lavender for active pills/badges
  static const Color accentViolet = Color(0xFF7C3AED); // Vibrant Violet Accent
  static const Color accent = Color(0xFF7C3AED); // Alias for accentViolet

  // --- Background & Surface Colors ---
  static const Color background = Color(
    0xFFF8FAFC,
  ); // Off-white Ultra-Soft Background
  static const Color surface = Color(0xFFFFFFFF); // Pure White Card Surface
  static const Color cardDark = Color(0xFF0F172A); // Dark Charcoal Card
  static const Color cardShadow = Color(
    0x0A000000,
  ); // Subtle 4% Opacity Elevation Shadow
  static const Color inputFill = Color(0xFFF1F5F9); // Soft Grey Input Fill
  static const Color border = Color(0xFFE2E8F0); // Soft Grey Border

  // --- Text Colors ---
  static const Color textPrimary = Color(0xFF0F172A); // Dark Slate Navy Text
  static const Color textSecondary = Color(0xFF64748B); // Muted Slate Grey Text
  static const Color textMuted = Color(0xFF94A3B8); // Light Grey Subtitle Text
  static const Color textOnPrimary = Color(
    0xFFFFFFFF,
  ); // White Text on Purple Buttons

  // --- Status & Metric Colors ---
  static const Color success = Color(
    0xFF10B981,
  ); // Green for High Match % & Verified
  static const Color successLight = Color(
    0xFFD1FAE5,
  ); // Light Green Pill Background
  static const Color warning = Color(
    0xFFF59E0B,
  ); // Amber for Medium Risk / Pending
  static const Color warningLight = Color(
    0xFFFEF3C7,
  ); // Light Amber Pill Background
  static const Color error = Color(0xFFEF4444); // Red for High At-Risk
  static const Color errorLight = Color(
    0xFFFEE2E2,
  ); // Light Red Pill Background

  // --- Badge & Tag Colors ---
  static const Color tagBackground = Color(0xFFF1F5F9); // Light Grey Tag Pill
  static const Color tagText = Color(0xFF475569); // Slate Tag Text
  static const Color aiBadgeBg = Color(
    0xFFF3E8FF,
  ); // AI Highlight Lavender Badge
  static const Color aiBadgeText = Color(0xFF7C3AED); // AI Highlight Text
}

/// Centralized Dark Design Token Palette for Campus2Corporate (c2c_android).
/// Brand colors are reused from [AppColors]; only surface/text tokens differ.
class AppColDark {
  AppColDark._();

  static const Color background = Color(0xFF0B1220); // Deep Slate Background
  static const Color surface = Color(0xFF111A2E); // Card Surface
  static const Color surfaceAlt = Color(0xFF16203A); // Elevated / Input Fill
  static const Color border = Color(0xFF22304D); // Soft Border

  static const Color textPrimary = Color(0xFFF1F5F9); // Near-White Text
  static const Color textSecondary = Color(0xFF94A3B8); // Slate Secondary
  static const Color textMuted = Color(0xFF64748B); // Muted Grey
  static const Color textOnPrimary = Color(0xFFFFFFFF);
}

/// Dynamic theme-aware helper extension on [BuildContext]
extension ThemeColorsExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg => isDark ? AppColDark.background : AppColors.background;
  Color get surf => isDark ? AppColDark.surface : AppColors.surface;
  Color get surfAlt => isDark ? AppColDark.surfaceAlt : AppColors.inputFill;
  Color get txtPrimary => isDark ? AppColDark.textPrimary : AppColors.textPrimary;
  Color get txtSecondary => isDark ? AppColDark.textSecondary : AppColors.textSecondary;
  Color get txtMuted => isDark ? AppColDark.textMuted : AppColors.textMuted;
  Color get brdr => isDark ? AppColDark.border : AppColors.border;
  Color get priLight => isDark ? const Color(0xFF28254E) : AppColors.primaryLight;
  Color get aiBadgeBgColor => isDark ? const Color(0xFF2D1B4E) : AppColors.aiBadgeBg;
}

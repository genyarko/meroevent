import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Application-wide text style constants
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  // Base text style (using Inter font)
  static TextStyle get _baseTextStyle => GoogleFonts.inter();

  // Display Styles (Large headings)
  static TextStyle get displayLarge => _baseTextStyle.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        height: 1.16,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => _baseTextStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.22,
        color: AppColors.textPrimary,
      );

  // Headline Styles
  static TextStyle get headlineLarge => _baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => _baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: AppColors.textPrimary,
      );

  // Title Styles
  static TextStyle get titleLarge => _baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.50,
        letterSpacing: 0.15,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.10,
        color: AppColors.textPrimary,
      );

  // Body Styles
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.50,
        letterSpacing: 0.50,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: 0.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.40,
        color: AppColors.textSecondary,
      );

  // Label Styles
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.10,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.50,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.50,
        color: AppColors.textSecondary,
      );

  // Button Styles
  static TextStyle get button => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.10,
        color: AppColors.white,
      );

  static TextStyle get buttonLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.50,
        letterSpacing: 0.10,
        color: AppColors.white,
      );

  static TextStyle get buttonSmall => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.10,
        color: AppColors.white,
      );

  // Caption Styles
  static TextStyle get caption => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.40,
        color: AppColors.textSecondary,
      );

  // Overline Styles
  static TextStyle get overline => _baseTextStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.60,
        letterSpacing: 1.50,
        color: AppColors.textSecondary,
      );

  // Special Styles
  static TextStyle get price => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.33,
        color: AppColors.primary,
      );

  static TextStyle get priceSmall => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.33,
        color: AppColors.primary,
      );

  static TextStyle get eventTitle => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.30,
        color: AppColors.textPrimary,
      );

  static TextStyle get eventSubtitle => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: AppColors.textSecondary,
      );

  static TextStyle get link => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        decoration: TextDecoration.underline,
        color: AppColors.primary,
      );

  static TextStyle get error => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: AppColors.error,
      );

  static TextStyle get success => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: AppColors.success,
      );

  static TextStyle get warning => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: AppColors.warning,
      );

  // Dark Mode Variations
  static TextStyle get displayLargeDark => displayLarge.copyWith(
        color: AppColors.textPrimaryDark,
      );

  static TextStyle get headlineLargeDark => headlineLarge.copyWith(
        color: AppColors.textPrimaryDark,
      );

  static TextStyle get bodyLargeDark => bodyLarge.copyWith(
        color: AppColors.textPrimaryDark,
      );

  static TextStyle get bodyMediumDark => bodyMedium.copyWith(
        color: AppColors.textSecondaryDark,
      );
}

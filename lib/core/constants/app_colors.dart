import 'package:flutter/material.dart';

/// Application-wide color constants
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryVariant = Color(0xFF4338CA);

  // Secondary Colors
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color secondaryLight = Color(0xFFF472B6);
  static const Color secondaryDark = Color(0xFFDB2777);

  // Accent Colors
  static const Color accent = Color(0xFF10B981); // Green
  static const Color accentLight = Color(0xFF34D399);
  static const Color accentDark = Color(0xFF059669);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Dark Mode Text Colors
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textTertiaryDark = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);

  // Divider Colors
  static const Color divider = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Category Colors (for event categories)
  static const Color categoryMusic = Color(0xFFEC4899);
  static const Color categorySports = Color(0xFF10B981);
  static const Color categoryArts = Color(0xFFF59E0B);
  static const Color categoryFood = Color(0xFFEF4444);
  static const Color categoryBusiness = Color(0xFF3B82F6);
  static const Color categoryTechnology = Color(0xFF8B5CF6);
  static const Color categoryEducation = Color(0xFF06B6D4);
  static const Color categoryHealth = Color(0xFF14B8A6);

  // Ticket Type Colors
  static const Color ticketGeneral = Color(0xFF6366F1);
  static const Color ticketVip = Color(0xFFF59E0B);
  static const Color ticketEarlyBird = Color(0xFF10B981);
  static const Color ticketStudent = Color(0xFF3B82F6);

  // Social Colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color twitter = Color(0xFF1DA1F2);
  static const Color instagram = Color(0xFFE4405F);
  static const Color linkedin = Color(0xFF0A66C2);
  static const Color whatsapp = Color(0xFF25D366);

  // Payment Colors
  static const Color stripe = Color(0xFF635BFF);
  static const Color paypal = Color(0xFF003087);
  static const Color applePay = Color(0xFF000000);
  static const Color googlePay = Color(0xFF4285F4);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [grey900, grey800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

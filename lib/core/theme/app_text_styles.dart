import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  // Display / Hero
  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.w700, height: 1.12);

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.w700, height: 1.15);

  static TextStyle displaySmall(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w600, height: 1.2);

  // Headline
  static TextStyle headlineLarge(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, height: 1.25);

  static TextStyle headlineMedium(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, height: 1.29);

  static TextStyle headlineSmall(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33);

  // Title
  static TextStyle titleLarge(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, height: 1.27);

  static TextStyle titleMedium(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, height: 1.5, letterSpacing: 0.15);

  static TextStyle titleSmall(BuildContext context) =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, height: 1.43, letterSpacing: 0.1);

  // Body
  static TextStyle bodyLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.5);

  static TextStyle bodyMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.43, letterSpacing: 0.25);

  static TextStyle bodySmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.33, letterSpacing: 0.4);

  // Label
  static TextStyle labelLarge(BuildContext context) =>
      GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.43, letterSpacing: 0.1);

  static TextStyle labelMedium(BuildContext context) =>
      GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.5);

  static TextStyle labelSmall(BuildContext context) =>
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, letterSpacing: 0.5);

  // Amount (special style for money display)
  static TextStyle amount({double size = 24, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.poppins(fontSize: size, fontWeight: weight, letterSpacing: -0.5);

  static TextStyle amountLarge() =>
      GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1);

  static TextStyle amountSmall() =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3);
}

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF4F46E5); // Deep Indigo
  static const Color secondary = Color(0xFF06B6D4); // Vibrant Teal
  static const Color accent = Color(0xFFF97316); // Coral/Orange

  // Semantic colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFF43F5E); // Rose (Expense)
  static const Color income = Color(0xFF22C55E); // Green
  static const Color expense = Color(0xFFF43F5E); // Rose
  static const Color savings = Color(0xFFF59E0B); // Amber
  static const Color warning = Color(0xFFF59E0B); // Amber

  // Background
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);

  // Surface colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Card colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Divider
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0284C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient savingsGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Chart colors
  static const List<Color> chartColors = [
    Color(0xFF4F46E5),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFF10B981),
    Color(0xFFF43F5E),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFF6366F1),
  ];

  // Category colors
  static const Color catFood = Color(0xFFFF6B6B);
  static const Color catTransport = Color(0xFF4ECDC4);
  static const Color catShopping = Color(0xFF45B7D1);
  static const Color catBills = Color(0xFFFFA07A);
  static const Color catRent = Color(0xFF98D8C8);
  static const Color catEntertainment = Color(0xFFDDA0DD);
  static const Color catHealth = Color(0xFF90EE90);
  static const Color catEducation = Color(0xFF87CEEB);
  static const Color catEmi = Color(0xFFFFB347);
  static const Color catMisc = Color(0xFFB0C4DE);
  static const Color catSalary = Color(0xFF22C55E);
  static const Color catFreelance = Color(0xFF06B6D4);
  static const Color catBusiness = Color(0xFF4F46E5);
  static const Color catInvestment = Color(0xFFF59E0B);
  static const Color catGift = Color(0xFFEC4899);
  static const Color catEmergency = Color(0xFFF43F5E);
  static const Color catSip = Color(0xFF8B5CF6);
  static const Color catFd = Color(0xFF14B8A6);
}

import 'package:flutter/material.dart';

/// A wrapper for category data used in default seeding.
class DefaultCategoryData {
  final String id;
  final String name;
  final String icon; // Material icon codepoint as hex string
  final Color color;
  final String type; // 'expense' | 'income' | 'savings'

  const DefaultCategoryData({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class DefaultCategories {
  DefaultCategories._();

  // ── EXPENSE CATEGORIES ──────────────────────────────────────────────────────

  static const DefaultCategoryData tea = DefaultCategoryData(
    id: 'cat_tea',
    name: 'Tea',
    icon: 'e30d', // local_cafe
    color: Color(0xFF78350F),
    type: 'expense',
  );

  static const DefaultCategoryData food = DefaultCategoryData(
    id: 'cat_food',
    name: 'Food & Dining',
    icon: 'e56c', // restaurant
    color: Color(0xFFDC2626),
    type: 'expense',
  );

  static const DefaultCategoryData transport = DefaultCategoryData(
    id: 'cat_transport',
    name: 'Transport',
    icon: 'e1d8', // directions_car
    color: Color(0xFF2563EB),
    type: 'expense',
  );

  static const DefaultCategoryData household = DefaultCategoryData(
    id: 'cat_household',
    name: 'Household',
    icon: 'e53a', // home_filled / kitchen: e53a = kitchen
    color: Color(0xFF16A34A),
    type: 'expense',
  );

  static const DefaultCategoryData apparel = DefaultCategoryData(
    id: 'cat_apparel',
    name: 'Apparel',
    icon: 'e60c', // storefront — use checkroom: e3af or dry_cleaning: e603; use e60c for storefront
    color: Color(0xFF7C3AED),
    type: 'expense',
  );

  static const DefaultCategoryData grooming = DefaultCategoryData(
    id: 'cat_grooming',
    name: 'Grooming',
    icon: 'eb3e', // content_cut (scissors)
    color: Color(0xFF0891B2),
    type: 'expense',
  );

  static const DefaultCategoryData socialLife = DefaultCategoryData(
    id: 'cat_social_life',
    name: 'Social Life',
    icon: 'e7ef', // groups / domain: e7ef = domain, groups: ef7c
    color: Color(0xFFDB2777),
    type: 'expense',
  );

  static const DefaultCategoryData health = DefaultCategoryData(
    id: 'cat_health',
    name: 'Health & Medical',
    icon: 'e548', // local_hospital
    color: Color(0xFF059669),
    type: 'expense',
  );

  static const DefaultCategoryData bills = DefaultCategoryData(
    id: 'cat_bills',
    name: 'Bills & Utilities',
    icon: 'e50d', // receipt_long
    color: Color(0xFFD97706),
    type: 'expense',
  );

  static const DefaultCategoryData education = DefaultCategoryData(
    id: 'cat_education',
    name: 'Education',
    icon: 'e3dd', // menu_book
    color: Color(0xFF0284C7),
    type: 'expense',
  );

  static const DefaultCategoryData emi = DefaultCategoryData(
    id: 'cat_emi',
    name: 'EMI',
    icon: 'e482', // payments
    color: Color(0xFF9333EA),
    type: 'expense',
  );

  static const DefaultCategoryData rent = DefaultCategoryData(
    id: 'cat_rent',
    name: 'Rent',
    icon: 'e328', // house
    color: Color(0xFFB45309),
    type: 'expense',
  );

  static const DefaultCategoryData shopping = DefaultCategoryData(
    id: 'cat_shopping',
    name: 'Shopping',
    icon: 'e54c', // shopping_bag
    color: Color(0xFFE11D48),
    type: 'expense',
  );

  static const DefaultCategoryData investment = DefaultCategoryData(
    id: 'cat_investment',
    name: 'Investment',
    icon: 'e6de', // trending_up
    color: Color(0xFF15803D),
    type: 'expense',
  );

  static const DefaultCategoryData miscExpense = DefaultCategoryData(
    id: 'cat_misc_expense',
    name: 'Miscellaneous',
    icon: 'e14f', // category
    color: Color(0xFF6B7280),
    type: 'expense',
  );

  // ── INCOME CATEGORIES ───────────────────────────────────────────────────────

  static const DefaultCategoryData salary = DefaultCategoryData(
    id: 'cat_salary',
    name: 'Salary',
    icon: 'e943', // payments / work: e943 = work_outline; use e0af = work
    color: Color(0xFF16A34A),
    type: 'income',
  );

  static const DefaultCategoryData freelance = DefaultCategoryData(
    id: 'cat_freelance',
    name: 'Freelance',
    icon: 'eb3b', // laptop
    color: Color(0xFF2563EB),
    type: 'income',
  );

  static const DefaultCategoryData business = DefaultCategoryData(
    id: 'cat_business',
    name: 'Business',
    icon: 'e0af', // work
    color: Color(0xFF7C3AED),
    type: 'income',
  );

  static const DefaultCategoryData investmentReturns = DefaultCategoryData(
    id: 'cat_investment_returns',
    name: 'Investment Returns',
    icon: 'e6de', // trending_up
    color: Color(0xFF059669),
    type: 'income',
  );

  static const DefaultCategoryData gift = DefaultCategoryData(
    id: 'cat_gift',
    name: 'Gift',
    icon: 'e8f6', // card_giftcard
    color: Color(0xFFDB2777),
    type: 'income',
  );

  static const DefaultCategoryData otherIncome = DefaultCategoryData(
    id: 'cat_other_income',
    name: 'Other Income',
    icon: 'e8b1', // account_balance_wallet
    color: Color(0xFFD97706),
    type: 'income',
  );

  static const DefaultCategoryData received = DefaultCategoryData(
    id: 'cat_received',
    name: 'Received / Transfer',
    icon: 'e8b4', // swap_horiz / account_balance: e8f9; send: e163; swap: e8d5
    color: Color(0xFF0891B2),
    type: 'income',
  );

  // ── SAVINGS CATEGORIES ──────────────────────────────────────────────────────

  static const DefaultCategoryData emergencyFund = DefaultCategoryData(
    id: 'cat_emergency',
    name: 'Emergency Fund',
    icon: 'e83a', // security
    color: Color(0xFFDC2626),
    type: 'savings',
  );

  static const DefaultCategoryData fd = DefaultCategoryData(
    id: 'cat_fd',
    name: 'Fixed Deposit',
    icon: 'e8f9', // account_balance
    color: Color(0xFF0284C7),
    type: 'savings',
  );

  static const DefaultCategoryData sip = DefaultCategoryData(
    id: 'cat_sip',
    name: 'SIP / Mutual Funds',
    icon: 'e6de', // show_chart
    color: Color(0xFF16A34A),
    type: 'savings',
  );

  static const DefaultCategoryData otherSavings = DefaultCategoryData(
    id: 'cat_other_savings',
    name: 'Other Savings',
    icon: 'e906', // savings
    color: Color(0xFFD97706),
    type: 'savings',
  );

  static List<DefaultCategoryData> get allExpense => [
        tea, food, transport, household, apparel, grooming,
        socialLife, health, bills, education, emi, rent,
        shopping, investment, miscExpense,
      ];

  static List<DefaultCategoryData> get allIncome => [
        salary, freelance, business, investmentReturns, gift, otherIncome, received,
      ];

  static List<DefaultCategoryData> get allSavings => [
        emergencyFund, fd, sip, otherSavings,
      ];

  static List<DefaultCategoryData> get all => [
        ...allExpense,
        ...allIncome,
        ...allSavings,
      ];
}

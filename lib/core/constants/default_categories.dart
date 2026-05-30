import 'package:flutter/material.dart';
import '../utils/category_icon_utils.dart';

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
  static final DefaultCategoryData food = DefaultCategoryData(
    id: 'cat_food',
    name: 'Food & Dining',
    icon: CategoryIconUtils.code(Icons.restaurant),
    color: const Color(0xFFFF6B6B),
    type: 'expense',
  );

  static final DefaultCategoryData transport = DefaultCategoryData(
    id: 'cat_transport',
    name: 'Transport',
    icon: CategoryIconUtils.code(Icons.directions_car),
    color: const Color(0xFF4ECDC4),
    type: 'expense',
  );

  static final DefaultCategoryData shopping = DefaultCategoryData(
    id: 'cat_shopping',
    name: 'Shopping',
    icon: CategoryIconUtils.code(Icons.shopping_bag),
    color: const Color(0xFF45B7D1),
    type: 'expense',
  );

  static final DefaultCategoryData bills = DefaultCategoryData(
    id: 'cat_bills',
    name: 'Bills & Utilities',
    icon: CategoryIconUtils.code(Icons.receipt_long),
    color: const Color(0xFFFFA07A),
    type: 'expense',
  );

  static final DefaultCategoryData rent = DefaultCategoryData(
    id: 'cat_rent',
    name: 'Rent',
    icon: CategoryIconUtils.code(Icons.home),
    color: const Color(0xFF98D8C8),
    type: 'expense',
  );

  static final DefaultCategoryData entertainment = DefaultCategoryData(
    id: 'cat_entertainment',
    name: 'Entertainment',
    icon: CategoryIconUtils.code(Icons.movie),
    color: const Color(0xFFDDA0DD),
    type: 'expense',
  );

  static final DefaultCategoryData health = DefaultCategoryData(
    id: 'cat_health',
    name: 'Health & Medical',
    icon: CategoryIconUtils.code(Icons.medical_services),
    color: const Color(0xFF90EE90),
    type: 'expense',
  );

  static final DefaultCategoryData education = DefaultCategoryData(
    id: 'cat_education',
    name: 'Education',
    icon: CategoryIconUtils.code(Icons.school),
    color: const Color(0xFF87CEEB),
    type: 'expense',
  );

  static final DefaultCategoryData emi = DefaultCategoryData(
    id: 'cat_emi',
    name: 'EMI',
    icon: CategoryIconUtils.code(Icons.payments),
    color: const Color(0xFFFFB347),
    type: 'expense',
  );

  static final DefaultCategoryData grooming = DefaultCategoryData(
    id: 'cat_grooming',
    name: 'Grooming',
    icon: CategoryIconUtils.code(Icons.content_cut),
    color: const Color(0xFFE8A0BF),
    type: 'expense',
  );

  static final DefaultCategoryData miscExpense = DefaultCategoryData(
    id: 'cat_misc_expense',
    name: 'Miscellaneous',
    icon: CategoryIconUtils.code(Icons.more_horiz),
    color: const Color(0xFFB0C4DE),
    type: 'expense',
  );

  // ── INCOME CATEGORIES ───────────────────────────────────────────────────────
  static final DefaultCategoryData salary = DefaultCategoryData(
    id: 'cat_salary',
    name: 'Salary',
    icon: CategoryIconUtils.code(Icons.work),
    color: const Color(0xFF22C55E),
    type: 'income',
  );

  static final DefaultCategoryData freelance = DefaultCategoryData(
    id: 'cat_freelance',
    name: 'Freelance',
    icon: CategoryIconUtils.code(Icons.laptop),
    color: const Color(0xFF06B6D4),
    type: 'income',
  );

  static final DefaultCategoryData business = DefaultCategoryData(
    id: 'cat_business',
    name: 'Business',
    icon: CategoryIconUtils.code(Icons.business),
    color: const Color(0xFF4F46E5),
    type: 'income',
  );

  static final DefaultCategoryData investment = DefaultCategoryData(
    id: 'cat_investment',
    name: 'Investment Returns',
    icon: CategoryIconUtils.code(Icons.trending_up),
    color: const Color(0xFFF59E0B),
    type: 'income',
  );

  static final DefaultCategoryData gift = DefaultCategoryData(
    id: 'cat_gift',
    name: 'Gift',
    icon: CategoryIconUtils.code(Icons.card_giftcard),
    color: const Color(0xFFEC4899),
    type: 'income',
  );

  static final DefaultCategoryData received = DefaultCategoryData(
    id: 'cat_received',
    name: 'Received / Transfer',
    icon: CategoryIconUtils.code(Icons.account_balance_wallet),
    color: const Color(0xFF14B8A6),
    type: 'income',
  );

  static final DefaultCategoryData otherIncome = DefaultCategoryData(
    id: 'cat_other_income',
    name: 'Other Income',
    icon: CategoryIconUtils.code(Icons.payments),
    color: const Color(0xFF6366F1),
    type: 'income',
  );

  // ── SAVINGS CATEGORIES ──────────────────────────────────────────────────────
  static final DefaultCategoryData emergencyFund = DefaultCategoryData(
    id: 'cat_emergency',
    name: 'Emergency Fund',
    icon: CategoryIconUtils.code(Icons.security),
    color: const Color(0xFFF43F5E),
    type: 'savings',
  );

  static final DefaultCategoryData sip = DefaultCategoryData(
    id: 'cat_sip',
    name: 'SIP / Mutual Funds',
    icon: CategoryIconUtils.code(Icons.show_chart),
    color: const Color(0xFF8B5CF6),
    type: 'savings',
  );

  static final DefaultCategoryData fd = DefaultCategoryData(
    id: 'cat_fd',
    name: 'Fixed Deposit',
    icon: CategoryIconUtils.code(Icons.account_balance),
    color: const Color(0xFF14B8A6),
    type: 'savings',
  );

  static final DefaultCategoryData otherSavings = DefaultCategoryData(
    id: 'cat_other_savings',
    name: 'Other Savings',
    icon: CategoryIconUtils.code(Icons.savings),
    color: const Color(0xFFF59E0B),
    type: 'savings',
  );

  static List<DefaultCategoryData> get allExpense => [
        food,
        transport,
        shopping,
        bills,
        rent,
        entertainment,
        health,
        education,
        emi,
        grooming,
        miscExpense,
      ];

  static List<DefaultCategoryData> get allIncome => [
        salary,
        freelance,
        business,
        investment,
        gift,
        received,
        otherIncome,
      ];

  static List<DefaultCategoryData> get allSavings => [
        emergencyFund,
        sip,
        fd,
        otherSavings,
      ];

  static List<DefaultCategoryData> get all => [
        ...allExpense,
        ...allIncome,
        ...allSavings,
      ];
}

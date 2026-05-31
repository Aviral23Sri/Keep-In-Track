import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/budget_model.dart';
import '../models/merchant_model.dart';
import '../models/app_settings_model.dart';
import '../models/subcategory_model.dart';
import '../../core/constants/default_categories.dart';
import '../../core/utils/category_color_utils.dart';
import '../../core/constants/default_merchants.dart';
import '../../core/constants/default_subcategories.dart';
import 'package:uuid/uuid.dart';

class HiveDatabase {
  static const _uuid = Uuid();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
    _initialized = true;
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(AppConstants.transactionTypeId)) {
      Hive.registerAdapter(_TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.categoryTypeId)) {
      Hive.registerAdapter(_CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.budgetTypeId)) {
      Hive.registerAdapter(_BudgetModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.merchantTypeId)) {
      Hive.registerAdapter(_MerchantModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.appSettingsTypeId)) {
      Hive.registerAdapter(_AppSettingsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.subcategoryTypeId)) {
      Hive.registerAdapter(_SubcategoryModelAdapter());
    }
  }

  static Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<TransactionModel>(AppConstants.transactionBox),
      Hive.openBox<CategoryModel>(AppConstants.categoryBox),
      Hive.openBox<BudgetModel>(AppConstants.budgetBox),
      Hive.openBox<MerchantModel>(AppConstants.merchantBox),
      Hive.openBox<AppSettingsModel>(AppConstants.settingsBox),
      Hive.openBox<SubcategoryModel>(AppConstants.subcategoryBox),
    ]);
  }

  static Box<TransactionModel> get transactions =>
      Hive.box<TransactionModel>(AppConstants.transactionBox);
  static Box<CategoryModel> get categories =>
      Hive.box<CategoryModel>(AppConstants.categoryBox);
  static Box<BudgetModel> get budgets =>
      Hive.box<BudgetModel>(AppConstants.budgetBox);
  static Box<MerchantModel> get merchants =>
      Hive.box<MerchantModel>(AppConstants.merchantBox);
  static Box<AppSettingsModel> get settings =>
      Hive.box<AppSettingsModel>(AppConstants.settingsBox);
  static Box<SubcategoryModel> get subcategories =>
      Hive.box<SubcategoryModel>(AppConstants.subcategoryBox);

  /// Seed default data on first launch
  static Future<void> seedIfNeeded() async {
    final settingsBox = settings;
    AppSettingsModel appSettings;

    if (settingsBox.isEmpty) {
      appSettings = AppSettingsModel();
      await settingsBox.put('settings', appSettings);
    } else {
      appSettings = settingsBox.get('settings') ?? AppSettingsModel();
    }

    if (!appSettings.seedDone) {
      await _seedCategories();
      await _seedMerchants();
      await _seedSampleTransactions();
      appSettings = appSettings.copyWith(seedDone: true);
      await settingsBox.put('settings', appSettings);
    }

    // Subcategory seed runs independently — safe for existing installs
    if (!appSettings.subcategorySeedDone) {
      await _seedSubcategories();
      appSettings = appSettings.copyWith(subcategorySeedDone: true);
      await settingsBox.put('settings', appSettings);
    }

    // Also seed any new default categories that were added after first install
    await _seedNewDefaultCategories();

    // Also seed any new merchants that were added
    await _seedNewMerchants();

    await _syncDefaultCategoryIcons();
    await _normalizeCategoryColors();
  }

  /// Seed categories that exist in DefaultCategories but not yet in the box
  static Future<void> _seedNewDefaultCategories() async {
    final box = categories;
    for (final cat in DefaultCategories.all) {
      if (box.get(cat.id) == null) {
        final model = CategoryModel(
          id: cat.id,
          name: cat.name,
          icon: cat.icon,
          color: cat.color.toARGB32().toRadixString(16).toUpperCase(),
          type: cat.type,
          isDefault: true,
          isHidden: false,
        );
        await box.put(cat.id, model);
      }
    }
  }

  /// Keep built-in category icons in sync when defaults are updated.
  static Future<void> _syncDefaultCategoryIcons() async {
    final box = categories;
    for (final cat in DefaultCategories.all) {
      final existing = box.get(cat.id);
      if (existing != null && existing.isDefault && existing.icon != cat.icon) {
        await box.put(cat.id, existing.copyWith(icon: cat.icon));
      }
    }
  }

  /// Normalize stored category colors (e.g. strip legacy `0x` prefixes).
  static Future<void> _normalizeCategoryColors() async {
    final box = categories;
    for (final cat in box.values) {
      final normalized = CategoryColorUtils.code(
        CategoryColorUtils.fromHex(cat.color),
      );
      if (cat.color != normalized) {
        await box.put(cat.id, cat.copyWith(color: normalized));
      }
    }
  }

  static Future<void> _seedCategories() async {
    final box = categories;
    if (box.isNotEmpty) return;
    for (final cat in DefaultCategories.all) {
      final model = CategoryModel(
        id: cat.id,
        name: cat.name,
        icon: cat.icon,
        color: cat.color.toARGB32().toRadixString(16).toUpperCase(),
        type: cat.type,
        isDefault: true,
        isHidden: false,
      );
      await box.put(cat.id, model);
    }
  }

  static Future<void> _seedSubcategories() async {
    final box = subcategories;
    for (final sub in DefaultSubcategories.all) {
      // Only add if not already present (idempotent)
      if (box.get(sub.id) == null) {
        final model = SubcategoryModel(
          id: sub.id,
          name: sub.name,
          categoryId: sub.categoryId,
          isDefault: true,
        );
        await box.put(sub.id, model);
      }
    }
  }

  static Future<void> _seedMerchants() async {
    final box = merchants;
    if (box.isNotEmpty) return;
    for (final m in DefaultMerchants.all) {
      final id = _uuid.v4();
      final model = MerchantModel(
        id: id,
        name: m.name,
        nameVariants: m.nameVariants,
        categoryId: m.categoryId,
        subcategoryId: m.subcategoryId,
        typicalAmount: m.typicalAmount,
        paymentMode: m.paymentMode,
        isDefault: true,
        usageCount: 0,
      );
      await box.put(id, model);
    }
  }

  static Future<void> _seedNewMerchants() async {
    final box = merchants;
    for (final m in DefaultMerchants.all) {
      // Check if merchant already exists by exact name
      final exists = box.values.any((existing) => existing.name == m.name);
      if (!exists) {
        final id = _uuid.v4();
        final model = MerchantModel(
          id: id,
          name: m.name,
          nameVariants: m.nameVariants,
          categoryId: m.categoryId,
          subcategoryId: m.subcategoryId,
          typicalAmount: m.typicalAmount,
          paymentMode: m.paymentMode,
          isDefault: true,
          usageCount: 0,
        );
        await box.put(id, model);
      }
    }
  }

  static Future<void> _seedSampleTransactions() async {
    final box = transactions;
    if (box.isNotEmpty) return;
    final now = DateTime.now();
    final samples = [
      TransactionModel(
        id: _uuid.v4(), type: 'income', amount: 50000,
        categoryId: 'cat_salary', title: 'Monthly Salary',
        date: DateTime(now.year, now.month, 1),
        paymentMode: 'bankTransfer', isRecurring: true,
        recurringFrequency: 'monthly', createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(), type: 'expense', amount: 8345,
        categoryId: 'cat_rent', title: 'Room Rent',
        date: DateTime(now.year, now.month, 2),
        paymentMode: 'UPI', isRecurring: false, createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(), type: 'expense', amount: 250,
        categoryId: 'cat_food', subcategoryId: 'sub_food_eating_out',
        title: 'Dinner with friends',
        date: DateTime(now.year, now.month, 5),
        paymentMode: 'UPI', isRecurring: false, createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(), type: 'expense', amount: 448,
        categoryId: 'cat_bills', subcategoryId: 'sub_bi_mobile',
        title: 'Jio Recharge',
        date: DateTime(now.year, now.month, 6),
        paymentMode: 'UPI', isRecurring: true,
        recurringFrequency: 'monthly', createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(), type: 'savings', amount: 5000,
        categoryId: 'cat_sip', title: 'SIP Investment',
        date: DateTime(now.year, now.month, 7),
        paymentMode: 'bankTransfer', isRecurring: true,
        recurringFrequency: 'monthly', createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(), type: 'expense', amount: 46,
        categoryId: 'cat_transport', subcategoryId: 'sub_tr_uber',
        title: 'Uber ride', merchantName: 'Uber',
        date: DateTime(now.year, now.month, 8),
        paymentMode: 'UPI', isRecurring: false, createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(), type: 'expense', amount: 1200,
        categoryId: 'cat_bills', subcategoryId: 'sub_bi_electricity',
        title: 'Electricity Bill',
        date: DateTime(now.year, now.month, 10),
        paymentMode: 'UPI', isRecurring: false, createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(), type: 'expense', amount: 25,
        categoryId: 'cat_health', subcategoryId: 'sub_he_medicine',
        title: 'Medicine',
        date: DateTime(now.year, now.month, 12),
        paymentMode: 'Cash', isRecurring: false, createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(), type: 'income', amount: 8000,
        categoryId: 'cat_freelance', subcategoryId: 'sub_fr_project',
        title: 'Freelance Project',
        date: DateTime(now.year, now.month, 14),
        paymentMode: 'bankTransfer', isRecurring: false, createdAt: now,
      ),
      TransactionModel(
        id: _uuid.v4(), type: 'expense', amount: 12,
        categoryId: 'cat_tea', title: 'Evening Tea',
        merchantName: 'Rajendra',
        date: DateTime(now.year, now.month, 15),
        paymentMode: 'UPI', isRecurring: false, createdAt: now,
      ),
    ];
    for (final t in samples) {
      await box.put(t.id, t);
    }
  }

  static Future<void> clearAll() async {
    await Future.wait([
      transactions.clear(),
      categories.clear(),
      budgets.clear(),
      merchants.clear(),
      subcategories.clear(),
    ]);
    final s = settings.get('settings') ?? AppSettingsModel();
    await settings.put('settings', s.copyWith(seedDone: false, subcategorySeedDone: false));
  }
}

// ── Manual Hive Adapters (avoids build_runner) ────────────────────────────────

class _TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = AppConstants.transactionTypeId;

  @override
  TransactionModel read(BinaryReader reader) {
    final fields = reader.readMap();
    return TransactionModel(
      id: fields[0] as String,
      type: fields[1] as String,
      amount: (fields[2] as num).toDouble(),
      categoryId: fields[3] as String,
      title: fields[4] as String?,
      note: fields[5] as String?,
      date: fields[6] as DateTime,
      paymentMode: fields[7] as String,
      isRecurring: fields[8] as bool,
      recurringFrequency: fields[9] as String?,
      recurringEndDate: fields[10] as DateTime?,
      createdAt: fields[11] as DateTime,
      merchantName: fields[12] as String?,
      subcategoryId: fields[13] as String?,
      bankRefNumber: fields[14] as String?,
      importedFromBank: (fields[15] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer.writeMap({
      0: obj.id, 1: obj.type, 2: obj.amount, 3: obj.categoryId,
      4: obj.title, 5: obj.note, 6: obj.date, 7: obj.paymentMode,
      8: obj.isRecurring, 9: obj.recurringFrequency,
      10: obj.recurringEndDate, 11: obj.createdAt, 12: obj.merchantName,
      13: obj.subcategoryId, 14: obj.bankRefNumber, 15: obj.importedFromBank,
    });
  }
}

class _CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = AppConstants.categoryTypeId;

  @override
  CategoryModel read(BinaryReader reader) {
    final f = reader.readMap();
    return CategoryModel(
      id: f[0] as String, name: f[1] as String, icon: f[2] as String,
      color: f[3] as String, type: f[4] as String,
      isDefault: f[5] as bool, isHidden: (f[6] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer.writeMap({
      0: obj.id, 1: obj.name, 2: obj.icon, 3: obj.color,
      4: obj.type, 5: obj.isDefault, 6: obj.isHidden,
    });
  }
}

class _BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = AppConstants.budgetTypeId;

  @override
  BudgetModel read(BinaryReader reader) {
    final f = reader.readMap();
    return BudgetModel(
      id: f[0] as String, categoryId: f[1] as String?,
      amount: (f[2] as num).toDouble(),
      month: f[3] as int, year: f[4] as int,
      period: (f[5] as String?) ?? 'monthly',
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer.writeMap({
      0: obj.id, 1: obj.categoryId, 2: obj.amount,
      3: obj.month, 4: obj.year, 5: obj.period,
    });
  }
}

class _MerchantModelAdapter extends TypeAdapter<MerchantModel> {
  @override
  final int typeId = AppConstants.merchantTypeId;

  @override
  MerchantModel read(BinaryReader reader) {
    final f = reader.readMap();
    return MerchantModel(
      id: f[0] as String, name: f[1] as String,
      nameVariants: (f[2] as List).cast<String>(),
      categoryId: f[3] as String,
      typicalAmount: (f[4] as num?)?.toDouble(),
      paymentMode: f[5] as String?,
      isDefault: f[6] as bool,
      usageCount: (f[7] as int?) ?? 0,
      lastUsed: f[8] as DateTime?,
      subcategoryId: f[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MerchantModel obj) {
    writer.writeMap({
      0: obj.id, 1: obj.name, 2: obj.nameVariants,
      3: obj.categoryId, 4: obj.typicalAmount, 5: obj.paymentMode,
      6: obj.isDefault, 7: obj.usageCount, 8: obj.lastUsed,
      9: obj.subcategoryId,
    });
  }
}

class _AppSettingsModelAdapter extends TypeAdapter<AppSettingsModel> {
  @override
  final int typeId = AppConstants.appSettingsTypeId;

  @override
  AppSettingsModel read(BinaryReader reader) {
    final f = reader.readMap();
    return AppSettingsModel(
      themeMode: (f[0] as String?) ?? 'system',
      isPinEnabled: (f[1] as bool?) ?? false,
      pinHash: f[2] as String?,
      isBiometricEnabled: (f[3] as bool?) ?? false,
      monthStartDay: (f[4] as int?) ?? 1,
      budgetAlerts: (f[5] as bool?) ?? true,
      recurringReminders: (f[6] as bool?) ?? true,
      reminderTime: (f[7] as String?) ?? '09:00',
      seedDone: (f[8] as bool?) ?? false,
      dailyBudget: (f[9] as num?)?.toDouble(),
      weeklyBudget: (f[10] as num?)?.toDouble(),
      subcategorySeedDone: (f[11] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettingsModel obj) {
    writer.writeMap({
      0: obj.themeMode, 1: obj.isPinEnabled, 2: obj.pinHash,
      3: obj.isBiometricEnabled, 4: obj.monthStartDay,
      5: obj.budgetAlerts, 6: obj.recurringReminders,
      7: obj.reminderTime, 8: obj.seedDone,
      9: obj.dailyBudget, 10: obj.weeklyBudget,
      11: obj.subcategorySeedDone,
    });
  }
}

class _SubcategoryModelAdapter extends TypeAdapter<SubcategoryModel> {
  @override
  final int typeId = AppConstants.subcategoryTypeId;

  @override
  SubcategoryModel read(BinaryReader reader) {
    final f = reader.readMap();
    return SubcategoryModel(
      id: f[0] as String,
      name: f[1] as String,
      categoryId: f[2] as String,
      isDefault: (f[3] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, SubcategoryModel obj) {
    writer.writeMap({
      0: obj.id, 1: obj.name, 2: obj.categoryId, 3: obj.isDefault,
    });
  }
}

/// Default subcategory seed data.
/// Each entry maps to a parent category via categoryId.
class DefaultSubcategoryData {
  final String id;
  final String name;
  final String categoryId;

  const DefaultSubcategoryData({
    required this.id,
    required this.name,
    required this.categoryId,
  });
}

class DefaultSubcategories {
  DefaultSubcategories._();

  // ── FOOD & DINING ────────────────────────────────────────────────────────────
  static const _food = [
    DefaultSubcategoryData(id: 'sub_food_lunch',      name: 'Lunch',      categoryId: 'cat_food'),
    DefaultSubcategoryData(id: 'sub_food_dinner',     name: 'Dinner',     categoryId: 'cat_food'),
    DefaultSubcategoryData(id: 'sub_food_breakfast',  name: 'Breakfast',  categoryId: 'cat_food'),
    DefaultSubcategoryData(id: 'sub_food_eating_out', name: 'Eating Out', categoryId: 'cat_food'),
    DefaultSubcategoryData(id: 'sub_food_beverages',  name: 'Beverages',  categoryId: 'cat_food'),
    DefaultSubcategoryData(id: 'sub_food_pani_puri',  name: 'Pani Puri',  categoryId: 'cat_food'),
    DefaultSubcategoryData(id: 'sub_food_snacks',     name: 'Snacks',     categoryId: 'cat_food'),
    DefaultSubcategoryData(id: 'sub_food_other',      name: 'Other',      categoryId: 'cat_food'),
  ];

  // ── TRANSPORT ────────────────────────────────────────────────────────────────
  static const _transport = [
    DefaultSubcategoryData(id: 'sub_tr_bus',    name: 'Bus',    categoryId: 'cat_transport'),
    DefaultSubcategoryData(id: 'sub_tr_uber',   name: 'Uber',   categoryId: 'cat_transport'),
    DefaultSubcategoryData(id: 'sub_tr_rapido', name: 'Rapido', categoryId: 'cat_transport'),
    DefaultSubcategoryData(id: 'sub_tr_auto',   name: 'Auto',   categoryId: 'cat_transport'),
    DefaultSubcategoryData(id: 'sub_tr_train',  name: 'Train',  categoryId: 'cat_transport'),
    DefaultSubcategoryData(id: 'sub_tr_other',  name: 'Other',  categoryId: 'cat_transport'),
  ];

  // ── HOUSEHOLD ────────────────────────────────────────────────────────────────
  static const _household = [
    DefaultSubcategoryData(id: 'sub_hh_kitchen',  name: 'Kitchen',          categoryId: 'cat_household'),
    DefaultSubcategoryData(id: 'sub_hh_grocery',  name: 'Grocery',          categoryId: 'cat_household'),
    DefaultSubcategoryData(id: 'sub_hh_bedding',  name: 'Blanket & Bedding',categoryId: 'cat_household'),
    DefaultSubcategoryData(id: 'sub_hh_brush',    name: 'Brush & Comb',     categoryId: 'cat_household'),
    DefaultSubcategoryData(id: 'sub_hh_other',    name: 'Other',            categoryId: 'cat_household'),
  ];

  // ── APPAREL ──────────────────────────────────────────────────────────────────
  static const _apparel = [
    DefaultSubcategoryData(id: 'sub_ap_hoodies', name: 'Hoodies', categoryId: 'cat_apparel'),
    DefaultSubcategoryData(id: 'sub_ap_tshirts', name: 'T-Shirts', categoryId: 'cat_apparel'),
    DefaultSubcategoryData(id: 'sub_ap_jeans',   name: 'Jeans',   categoryId: 'cat_apparel'),
    DefaultSubcategoryData(id: 'sub_ap_shoes',   name: 'Shoes',   categoryId: 'cat_apparel'),
    DefaultSubcategoryData(id: 'sub_ap_other',   name: 'Other',   categoryId: 'cat_apparel'),
  ];

  // ── GROOMING ─────────────────────────────────────────────────────────────────
  static const _grooming = [
    DefaultSubcategoryData(id: 'sub_gr_haircut',  name: 'Haircut',  categoryId: 'cat_grooming'),
    DefaultSubcategoryData(id: 'sub_gr_shaving',  name: 'Shaving',  categoryId: 'cat_grooming'),
    DefaultSubcategoryData(id: 'sub_gr_skincare', name: 'Skincare', categoryId: 'cat_grooming'),
    DefaultSubcategoryData(id: 'sub_gr_other',    name: 'Other',    categoryId: 'cat_grooming'),
  ];

  // ── SOCIAL LIFE ───────────────────────────────────────────────────────────────
  static const _socialLife = [
    DefaultSubcategoryData(id: 'sub_sl_friend',  name: 'Friend Outing', categoryId: 'cat_social_life'),
    DefaultSubcategoryData(id: 'sub_sl_movies',  name: 'Movies',        categoryId: 'cat_social_life'),
    DefaultSubcategoryData(id: 'sub_sl_party',   name: 'Party',         categoryId: 'cat_social_life'),
    DefaultSubcategoryData(id: 'sub_sl_other',   name: 'Other',         categoryId: 'cat_social_life'),
  ];

  // ── HEALTH & MEDICAL ──────────────────────────────────────────────────────────
  static const _health = [
    DefaultSubcategoryData(id: 'sub_he_medicine', name: 'Medicine',           categoryId: 'cat_health'),
    DefaultSubcategoryData(id: 'sub_he_doctor',   name: 'Doctor',             categoryId: 'cat_health'),
    DefaultSubcategoryData(id: 'sub_he_vitamins', name: 'Vitamins & Supplements', categoryId: 'cat_health'),
    DefaultSubcategoryData(id: 'sub_he_other',    name: 'Other',              categoryId: 'cat_health'),
  ];

  // ── BILLS & UTILITIES ─────────────────────────────────────────────────────────
  static const _bills = [
    DefaultSubcategoryData(id: 'sub_bi_electricity', name: 'Electricity',        categoryId: 'cat_bills'),
    DefaultSubcategoryData(id: 'sub_bi_internet',    name: 'Internet',           categoryId: 'cat_bills'),
    DefaultSubcategoryData(id: 'sub_bi_mobile',      name: 'Mobile Recharge',    categoryId: 'cat_bills'),
    DefaultSubcategoryData(id: 'sub_bi_ott',         name: 'OTT Subscriptions',  categoryId: 'cat_bills'),
    DefaultSubcategoryData(id: 'sub_bi_other',       name: 'Other',              categoryId: 'cat_bills'),
  ];

  // ── EDUCATION ─────────────────────────────────────────────────────────────────
  static const _education = [
    DefaultSubcategoryData(id: 'sub_ed_fees',        name: 'Course Fees', categoryId: 'cat_education'),
    DefaultSubcategoryData(id: 'sub_ed_books',       name: 'Books',       categoryId: 'cat_education'),
    DefaultSubcategoryData(id: 'sub_ed_stationery',  name: 'Stationery',  categoryId: 'cat_education'),
    DefaultSubcategoryData(id: 'sub_ed_other',       name: 'Other',       categoryId: 'cat_education'),
  ];

  // ── EMI ───────────────────────────────────────────────────────────────────────
  static const _emi = [
    DefaultSubcategoryData(id: 'sub_em_home',     name: 'Home Loan',     categoryId: 'cat_emi'),
    DefaultSubcategoryData(id: 'sub_em_vehicle',  name: 'Vehicle Loan',  categoryId: 'cat_emi'),
    DefaultSubcategoryData(id: 'sub_em_personal', name: 'Personal Loan', categoryId: 'cat_emi'),
    DefaultSubcategoryData(id: 'sub_em_other',    name: 'Other',         categoryId: 'cat_emi'),
  ];

  // ── SHOPPING ──────────────────────────────────────────────────────────────────
  static const _shopping = [
    DefaultSubcategoryData(id: 'sub_sh_online',      name: 'Online Shopping', categoryId: 'cat_shopping'),
    DefaultSubcategoryData(id: 'sub_sh_clothing',    name: 'Clothing',        categoryId: 'cat_shopping'),
    DefaultSubcategoryData(id: 'sub_sh_electronics', name: 'Electronics',     categoryId: 'cat_shopping'),
    DefaultSubcategoryData(id: 'sub_sh_other',       name: 'Other',           categoryId: 'cat_shopping'),
  ];

  // ── INVESTMENT (expense) ──────────────────────────────────────────────────────
  static const _investment = [
    DefaultSubcategoryData(id: 'sub_inv_sip',   name: 'SIP / Mutual Fund', categoryId: 'cat_investment'),
    DefaultSubcategoryData(id: 'sub_inv_stock', name: 'Stock Trading',     categoryId: 'cat_investment'),
    DefaultSubcategoryData(id: 'sub_inv_fd',    name: 'Fixed Deposit',     categoryId: 'cat_investment'),
    DefaultSubcategoryData(id: 'sub_inv_other', name: 'Other',             categoryId: 'cat_investment'),
  ];

  // ── INCOME: FREELANCE ─────────────────────────────────────────────────────────
  static const _freelance = [
    DefaultSubcategoryData(id: 'sub_fr_project',     name: 'Project Payment', categoryId: 'cat_freelance'),
    DefaultSubcategoryData(id: 'sub_fr_consulting',  name: 'Consulting',      categoryId: 'cat_freelance'),
    DefaultSubcategoryData(id: 'sub_fr_other',       name: 'Other',           categoryId: 'cat_freelance'),
  ];

  // ── INCOME: INVESTMENT RETURNS ────────────────────────────────────────────────
  static const _investmentReturns = [
    DefaultSubcategoryData(id: 'sub_ir_dividends', name: 'Dividends',       categoryId: 'cat_investment_returns'),
    DefaultSubcategoryData(id: 'sub_ir_trading',   name: 'Trading Profit',  categoryId: 'cat_investment_returns'),
    DefaultSubcategoryData(id: 'sub_ir_interest',  name: 'Interest',        categoryId: 'cat_investment_returns'),
    DefaultSubcategoryData(id: 'sub_ir_other',     name: 'Other',           categoryId: 'cat_investment_returns'),
  ];

  // ── INCOME: RECEIVED / TRANSFER ───────────────────────────────────────────────
  static const _received = [
    DefaultSubcategoryData(id: 'sub_rc_friend',  name: 'From Friend',    categoryId: 'cat_received'),
    DefaultSubcategoryData(id: 'sub_rc_self',    name: 'Self Transfer',  categoryId: 'cat_received'),
    DefaultSubcategoryData(id: 'sub_rc_family',  name: 'Family',         categoryId: 'cat_received'),
    DefaultSubcategoryData(id: 'sub_rc_other',   name: 'Other',          categoryId: 'cat_received'),
  ];

  static List<DefaultSubcategoryData> get all => [
        ..._food,
        ..._transport,
        ..._household,
        ..._apparel,
        ..._grooming,
        ..._socialLife,
        ..._health,
        ..._bills,
        ..._education,
        ..._emi,
        ..._shopping,
        ..._investment,
        ..._freelance,
        ..._investmentReturns,
        ..._received,
      ];
}

class DefaultMerchantData {
  final String name;
  final List<String> nameVariants;
  final String categoryId;
  final String? subcategoryId;
  final double? typicalAmount;
  final String? paymentMode;

  const DefaultMerchantData({
    required this.name,
    required this.nameVariants,
    required this.categoryId,
    this.subcategoryId,
    this.typicalAmount,
    this.paymentMode,
  });
}

class DefaultMerchants {
  DefaultMerchants._();

  static const List<DefaultMerchantData> all = [
    // ── TEA ─────────────────────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'Rajendra', nameVariants: ['rajendra', 'RAJENDRA'],
      categoryId: 'cat_tea', typicalAmount: 12, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'CHANCHAL', nameVariants: ['chanchal', 'CHANCHAL'],
      categoryId: 'cat_tea', typicalAmount: 12, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'BISHANPA', nameVariants: ['bishanpa', 'BISHANPA'],
      categoryId: 'cat_tea', typicalAmount: 10, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'DEEPAK C', nameVariants: ['deepak c', 'DEEPAK C', 'deepak'],
      categoryId: 'cat_tea', typicalAmount: 10, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'BAJRANGI', nameVariants: ['bajrangi', 'BAJRANGI'],
      categoryId: 'cat_tea', typicalAmount: 20, paymentMode: 'UPI',
    ),

    // ── FOOD & DINING ─────────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'Swiggy', nameVariants: ['swiggy', 'SWIGGY'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_eating_out',
      typicalAmount: 250, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Zomato', nameVariants: ['zomato', 'ZOMATO'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_eating_out',
      typicalAmount: 200, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Dominos', nameVariants: ['dominos', 'DOMINOS', 'domino'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_eating_out',
      typicalAmount: 103, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'LITE CAFE', nameVariants: ['lite cafe', 'LITE CAFE', 'litecafe'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_eating_out',
      typicalAmount: 150, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'SUNIL', nameVariants: ['sunil', 'SUNIL'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_pani_puri',
      typicalAmount: 10, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'JUME ALI', nameVariants: ['jume ali', 'JUME ALI', 'jumeali'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_beverages',
      typicalAmount: 30, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'KARAN SI', nameVariants: ['karan si', 'KARAN SI', 'karan'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_lunch',
      typicalAmount: 75, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'PYARE LAL', nameVariants: ['pyare lal', 'PYARE LAL', 'pyarelal'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_lunch',
      typicalAmount: 60, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'VIJAY PAL', nameVariants: ['vijay pal', 'VIJAY PAL', 'vijaypal'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_lunch',
      typicalAmount: 60, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'SAKSHI', nameVariants: ['sakshi', 'SAKSHI'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_breakfast',
      typicalAmount: 30, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'RAMESH', nameVariants: ['ramesh', 'RAMESH'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_lunch',
      typicalAmount: 40, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Baladev', nameVariants: ['baladev', 'BALADEV'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_snacks',
      typicalAmount: 10, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'NARENDER', nameVariants: ['narender', 'NARENDER'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_beverages',
      typicalAmount: 20, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Munesh', nameVariants: ['munesh', 'MUNESH'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_snacks',
      typicalAmount: 15, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'FATEMA', nameVariants: ['fatema', 'FATEMA'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_snacks',
      typicalAmount: 50, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'MRS URMI', nameVariants: ['mrs urmi', 'MRS URMI', 'urmi'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_lunch',
      typicalAmount: 60, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Santosh', nameVariants: ['santosh', 'SANTOSH'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_breakfast',
      typicalAmount: 40, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Food Court', nameVariants: ['food court', 'FOOD COURT', 'foodcourt'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_eating_out',
      typicalAmount: 60, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'ANUSHKA', nameVariants: ['anushka', 'ANUSHKA'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_beverages',
      paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'GOVIND G', nameVariants: ['govind g', 'GOVIND G', 'govind'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_snacks',
      paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'BABU DIN', nameVariants: ['babu din', 'BABU DIN'],
      categoryId: 'cat_food', subcategoryId: 'sub_food_snacks',
      paymentMode: 'UPI',
    ),

    // ── TRANSPORT ────────────────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'Uber', nameVariants: ['uber', 'UBER', 'UBER IND', 'uber ind'],
      categoryId: 'cat_transport', subcategoryId: 'sub_tr_uber',
      typicalAmount: 100, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'YOGESH S', nameVariants: ['yogesh s', 'YOGESH S', 'yogesh'],
      categoryId: 'cat_transport', subcategoryId: 'sub_tr_uber',
      typicalAmount: 46, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Rapido', nameVariants: ['rapido', 'RAPIDO'],
      categoryId: 'cat_transport', subcategoryId: 'sub_tr_rapido',
      typicalAmount: 50, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Redbus', nameVariants: ['redbus', 'REDBUS'],
      categoryId: 'cat_transport', subcategoryId: 'sub_tr_bus',
      typicalAmount: 300, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'INDIAN R', nameVariants: ['indian r', 'INDIAN R', 'indian rail', 'irctc', 'IRCTC'],
      categoryId: 'cat_transport', subcategoryId: 'sub_tr_train',
      typicalAmount: 700, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Ola', nameVariants: ['ola', 'OLA', 'OLA CAB'],
      categoryId: 'cat_transport', subcategoryId: 'sub_tr_uber',
      typicalAmount: 80, paymentMode: 'UPI',
    ),

    // ── HOUSEHOLD / GROCERY ───────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'Zepto', nameVariants: ['zepto', 'ZEPTO'],
      categoryId: 'cat_household', subcategoryId: 'sub_hh_grocery',
      typicalAmount: 200, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Blinkit', nameVariants: ['blinkit', 'BLINKIT'],
      categoryId: 'cat_household', subcategoryId: 'sub_hh_grocery',
      typicalAmount: 333, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'JioMart', nameVariants: ['jiomart', 'JIOMART', 'jiom', 'jio mart'],
      categoryId: 'cat_household', subcategoryId: 'sub_hh_grocery',
      typicalAmount: 114, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'AVENUE S', nameVariants: ['avenue s', 'AVENUE S', 'avenue super', 'D-MART', 'dmart'],
      categoryId: 'cat_household', subcategoryId: 'sub_hh_grocery',
      typicalAmount: 500, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'BigBasket', nameVariants: ['bigbasket', 'BIGBASKET', 'big basket'],
      categoryId: 'cat_household', subcategoryId: 'sub_hh_grocery',
      typicalAmount: 400, paymentMode: 'UPI',
    ),

    // ── SHOPPING ─────────────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'FLIPKART', nameVariants: ['flipkart', 'FLIPKART', 'flipkart net'],
      categoryId: 'cat_shopping', subcategoryId: 'sub_sh_online',
      typicalAmount: 118, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'MEESHO', nameVariants: ['meesho', 'MEESHO'],
      categoryId: 'cat_shopping', subcategoryId: 'sub_sh_online',
      typicalAmount: 199, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Amazon', nameVariants: ['amazon', 'AMAZON', 'amazon pay'],
      categoryId: 'cat_shopping', subcategoryId: 'sub_sh_online',
      typicalAmount: 299, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Myntra', nameVariants: ['myntra', 'MYNTRA'],
      categoryId: 'cat_shopping', subcategoryId: 'sub_sh_clothing',
      typicalAmount: 500, paymentMode: 'UPI',
    ),

    // ── GROOMING ─────────────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'SHARIF', nameVariants: ['sharif', 'SHARIF'],
      categoryId: 'cat_grooming', subcategoryId: 'sub_gr_haircut',
      typicalAmount: 140, paymentMode: 'UPI',
    ),

    // ── SOCIAL LIFE ──────────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'PVR INOX', nameVariants: ['pvr inox', 'PVR INOX', 'pvr', 'inox'],
      categoryId: 'cat_social_life', subcategoryId: 'sub_sl_movies',
      typicalAmount: 300, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'BookMyShow', nameVariants: ['bookmyshow', 'BOOKMYSHOW', 'book my show'],
      categoryId: 'cat_social_life', subcategoryId: 'sub_sl_movies',
      typicalAmount: 300, paymentMode: 'UPI',
    ),

    // ── HEALTH & MEDICAL ─────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'RAHILA', nameVariants: ['rahila', 'RAHILA'],
      categoryId: 'cat_health', subcategoryId: 'sub_he_medicine',
      typicalAmount: 48, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'SHREE MA', nameVariants: ['shree ma', 'SHREE MA', 'shreemanau', 'shreema'],
      categoryId: 'cat_health', subcategoryId: 'sub_he_doctor',
      typicalAmount: 2100, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'HEALING', nameVariants: ['healing', 'HEALING'],
      categoryId: 'cat_health', subcategoryId: 'sub_he_medicine',
      typicalAmount: 25, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'PharmEasy', nameVariants: ['pharmeasy', 'PHARMEASY', 'pharma easy'],
      categoryId: 'cat_health', subcategoryId: 'sub_he_medicine',
      typicalAmount: 200, paymentMode: 'UPI',
    ),

    // ── BILLS & UTILITIES ────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'JIO', nameVariants: ['jio', 'JIO', 'jio recharge', 'reliance jio'],
      categoryId: 'cat_bills', subcategoryId: 'sub_bi_mobile',
      typicalAmount: 448, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Google I', nameVariants: ['google i', 'GOOGLE I', 'google play', 'gpay', 'gpayutili'],
      categoryId: 'cat_bills', subcategoryId: 'sub_bi_ott',
      typicalAmount: 1093, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'NSDL E G', nameVariants: ['nsdl e g', 'NSDL E G', 'nsdl'],
      categoryId: 'cat_bills', subcategoryId: 'sub_bi_other',
      typicalAmount: 107, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Netflix', nameVariants: ['netflix', 'NETFLIX'],
      categoryId: 'cat_bills', subcategoryId: 'sub_bi_ott',
      typicalAmount: 499, paymentMode: 'Card',
    ),
    DefaultMerchantData(
      name: 'Airtel', nameVariants: ['airtel', 'AIRTEL'],
      categoryId: 'cat_bills', subcategoryId: 'sub_bi_mobile',
      typicalAmount: 299, paymentMode: 'UPI',
    ),

    // ── INVESTMENT ───────────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'ZERODHA', nameVariants: ['zerodha', 'ZERODHA'],
      categoryId: 'cat_investment', subcategoryId: 'sub_inv_stock',
      typicalAmount: 1000, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Groww', nameVariants: ['groww', 'GROWW'],
      categoryId: 'cat_investment', subcategoryId: 'sub_inv_sip',
      typicalAmount: 1000, paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'Kuvera', nameVariants: ['kuvera', 'KUVERA'],
      categoryId: 'cat_investment', subcategoryId: 'sub_inv_sip',
      typicalAmount: 2000, paymentMode: 'UPI',
    ),

    // ── RENT ─────────────────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'SUPRIYA', nameVariants: ['supriya', 'SUPRIYA'],
      categoryId: 'cat_rent',
      typicalAmount: 8345, paymentMode: 'UPI',
    ),

    // ── MISCELLANEOUS ────────────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'POPTECH', nameVariants: ['poptech', 'POPTECH'],
      categoryId: 'cat_misc_expense',
      typicalAmount: 1102, paymentMode: 'UPI',
    ),

    // ── RECEIVED / TRANSFER ───────────────────────────────────────────────────
    DefaultMerchantData(
      name: 'AVIRAL S', nameVariants: ['aviral s', 'AVIRAL S', 'aviral'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_self',
      paymentMode: 'UPI',
    ),
    DefaultMerchantData(
      name: 'CDM', nameVariants: ['cdm', 'CDM'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_self',
    ),
    DefaultMerchantData(
      name: 'SEEMA SR', nameVariants: ['seema sr', 'SEEMA SR', 'seema'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_family',
    ),
    DefaultMerchantData(
      name: 'Manan', nameVariants: ['manan', 'MANAN'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_friend',
    ),
    DefaultMerchantData(
      name: 'RATI SRI', nameVariants: ['rati sri', 'RATI SRI', 'rati'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_friend',
    ),
    DefaultMerchantData(
      name: 'RAKESH', nameVariants: ['rakesh', 'RAKESH'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_friend',
    ),
    DefaultMerchantData(
      name: 'MRITUNJA', nameVariants: ['mritunja', 'MRITUNJA'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_friend',
    ),
    DefaultMerchantData(
      name: 'SHREYANS', nameVariants: ['shreyans', 'SHREYANS'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_friend',
    ),
    DefaultMerchantData(
      name: 'ADITYA K', nameVariants: ['aditya k', 'ADITYA K', 'aditya'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_friend',
    ),
    DefaultMerchantData(
      name: 'SASWAT', nameVariants: ['saswat', 'SASWAT'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_friend',
    ),
    DefaultMerchantData(
      name: 'KASHISH', nameVariants: ['kashish', 'KASHISH'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_friend',
    ),
    DefaultMerchantData(
      name: 'SACHIN K', nameVariants: ['sachin k', 'SACHIN K', 'sachin'],
      categoryId: 'cat_received', subcategoryId: 'sub_rc_friend',
    ),

    // ── MISCELLANEOUS OVERRIDES ──────────────────────────────────────────────
    DefaultMerchantData(name: 'MANOJ', nameVariants: ['manoj', 'MANOJ'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Arjit Ku', nameVariants: ['arjit ku', 'ARJIT KU', 'arjit'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Abhishek', nameVariants: ['abhishek', 'ABHISHEK'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'AKASH MI', nameVariants: ['akash mi', 'AKASH MI', 'akash'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Anuj', nameVariants: ['anuj', 'ANUJ'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'ASHISH T', nameVariants: ['ashish t', 'ASHISH T'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'ANKIT KH', nameVariants: ['ankit kh', 'ANKIT KH'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'SAURAV B', nameVariants: ['saurav b', 'SAURAV B'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Mrs km J', nameVariants: ['mrs km j', 'MRS KM J'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'HARSHITA', nameVariants: ['harshita', 'HARSHITA'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'VINAY SW', nameVariants: ['vinay sw', 'VINAY SW'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'RAN SINGH', nameVariants: ['ran singh', 'RAN SINGH'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'BAIJ NAT', nameVariants: ['baij nat', 'BAIJ NAT'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'MOENKHAN', nameVariants: ['moenkhan', 'MOENKHAN'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Mr Himan', nameVariants: ['mr himan', 'MR HIMAN'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'SAFARU DIN', nameVariants: ['safaru din', 'SAFARU DIN'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Lokesh y', nameVariants: ['lokesh y', 'LOKESH Y'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'VISHNU M', nameVariants: ['vishnu m', 'VISHNU M'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Dubagga', nameVariants: ['dubagga', 'DUBAGGA'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'MANISH', nameVariants: ['manish', 'MANISH'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'SUNDARI', nameVariants: ['sundari', 'SUNDARI'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'GOLDY MO', nameVariants: ['goldy mo', 'GOLDY MO'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'NEM SINGH', nameVariants: ['nem singh', 'NEM SINGH'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'TASLEEM', nameVariants: ['tasleem', 'TASLEEM'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'CHETRAM', nameVariants: ['chetram', 'CHETRAM'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'HIRA KUMAR', nameVariants: ['hira kumar', 'HIRA KUMAR'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'ANKIT RA', nameVariants: ['ankit ra', 'ANKIT RA'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'SACHIN G', nameVariants: ['sachin g', 'SACHIN G'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'SHUBHAMR', nameVariants: ['shubhamr', 'SHUBHAMR'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'ASHISH S', nameVariants: ['ashish s', 'ASHISH S'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Ansh Fue', nameVariants: ['ansh fue', 'ANSH FUE'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Pranshu', nameVariants: ['pranshu', 'PRANSHU'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'ARVIND G', nameVariants: ['arvind g', 'ARVIND G'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'SAJJAD A', nameVariants: ['sajjad a', 'SAJJAD A'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'PRASHANT', nameVariants: ['prashant', 'PRASHANT'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'AJAY VAS', nameVariants: ['ajay vas', 'AJAY VAS'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'MR MOHD', nameVariants: ['mr mohd', 'MR MOHD'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'AVINASH', nameVariants: ['avinash', 'AVINASH'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'MOHD ATE', nameVariants: ['mohd ate', 'MOHD ATE'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Usha Devi', nameVariants: ['usha devi', 'USHA DEVI'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'SARJIT', nameVariants: ['sarjit', 'SARJIT'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'FULTARAN', nameVariants: ['fultaran', 'FULTARAN'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'MOHD RAH', nameVariants: ['mohd rah', 'MOHD RAH'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Shafij K', nameVariants: ['shafij k', 'SHAFIJ K'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Shriram', nameVariants: ['shriram', 'SHRIRAM'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'RAM SING', nameVariants: ['ram sing', 'RAM SING'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'MOHAN BA', nameVariants: ['mohan ba', 'MOHAN BA'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Mr KRIPA', nameVariants: ['mr kripa', 'MR KRIPA'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'RENU DEVI', nameVariants: ['renu devi', 'RENU DEVI'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'KAPIL PAL', nameVariants: ['kapil pal', 'KAPIL PAL'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Ankit', nameVariants: ['ankit', 'ANKIT'], categoryId: 'cat_misc_expense'),
    DefaultMerchantData(name: 'Pannu Fa', nameVariants: ['pannu fa', 'PANNU FA'], categoryId: 'cat_misc_expense'),
  ];
}

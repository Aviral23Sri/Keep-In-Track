/// Pre-loaded merchant seed data for first-launch population.
class DefaultMerchantData {
  final String name;
  final List<String> nameVariants;
  final String categoryId;
  final double? typicalAmount;
  final String? paymentMode;

  const DefaultMerchantData({
    required this.name,
    required this.nameVariants,
    required this.categoryId,
    this.typicalAmount,
    this.paymentMode,
  });
}

class DefaultMerchants {
  DefaultMerchants._();

  static List<DefaultMerchantData> get all => [
        // ── Tea ──────────────────────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'Rajendra',
          nameVariants: ['RAJENDRA', 'rajendra'],
          categoryId: 'cat_food',
          typicalAmount: 12,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'CHANCHAL',
          nameVariants: ['chanchal', 'Chanchal'],
          categoryId: 'cat_food',
          typicalAmount: 12,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'BISHANPA',
          nameVariants: ['bishanpa', 'Bishanpa'],
          categoryId: 'cat_food',
          typicalAmount: 12,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'DEEPAK C',
          nameVariants: ['deepak c', 'Deepak C', 'DEEPAKC'],
          categoryId: 'cat_food',
          typicalAmount: 12,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'BAJRANGI',
          nameVariants: ['bajrangi', 'Bajrangi'],
          categoryId: 'cat_food',
          typicalAmount: 12,
          paymentMode: 'upi',
        ),
        // ── Food ─────────────────────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'SUNIL',
          nameVariants: ['sunil', 'Sunil'],
          categoryId: 'cat_food',
          typicalAmount: 20,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'JUME ALI',
          nameVariants: ['jume ali', 'Jume Ali', 'JUMEALI'],
          categoryId: 'cat_food',
          typicalAmount: 40,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'KARAN SI',
          nameVariants: ['karan si', 'Karan Si', 'KARANSI'],
          categoryId: 'cat_food',
          typicalAmount: 75,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'PYARE LAL',
          nameVariants: ['pyare lal', 'Pyare Lal', 'PYARELAL'],
          categoryId: 'cat_food',
          typicalAmount: 75,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'VIJAY PAL',
          nameVariants: ['vijay pal', 'Vijay Pal', 'VIJAYPAL'],
          categoryId: 'cat_food',
          typicalAmount: 75,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'SAKSHI',
          nameVariants: ['sakshi', 'Sakshi'],
          categoryId: 'cat_food',
          typicalAmount: 30,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'RAMESH',
          nameVariants: ['ramesh', 'Ramesh'],
          categoryId: 'cat_food',
          typicalAmount: 80,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'Baladev',
          nameVariants: ['BALADEV', 'baladev'],
          categoryId: 'cat_food',
          typicalAmount: 20,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'NARENDER',
          nameVariants: ['narender', 'Narender'],
          categoryId: 'cat_food',
          typicalAmount: 30,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'Munesh',
          nameVariants: ['MUNESH', 'munesh'],
          categoryId: 'cat_food',
          typicalAmount: 15,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'Dominos',
          nameVariants: ['DOMINOS', 'dominos', "Domino's"],
          categoryId: 'cat_food',
          typicalAmount: 300,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'LITE CAFE',
          nameVariants: ['lite cafe', 'Lite Cafe', 'LITECAFE'],
          categoryId: 'cat_food',
          typicalAmount: 150,
          paymentMode: 'upi',
        ),
        // ── Grocery ──────────────────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'Zepto',
          nameVariants: ['ZEPTO', 'zepto'],
          categoryId: 'cat_shopping',
          typicalAmount: 200,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'Blinkit',
          nameVariants: ['BLINKIT', 'blinkit'],
          categoryId: 'cat_shopping',
          typicalAmount: 200,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'AVENUE S',
          nameVariants: ['avenue s', 'Avenue S', 'AVENUES'],
          categoryId: 'cat_shopping',
          typicalAmount: 500,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'AVENUE F',
          nameVariants: ['avenue f', 'Avenue F', 'AVENUEF'],
          categoryId: 'cat_shopping',
          typicalAmount: 500,
          paymentMode: 'upi',
        ),
        // ── Transport ────────────────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'Redbus',
          nameVariants: ['REDBUS', 'redbus', 'Red Bus'],
          categoryId: 'cat_transport',
          typicalAmount: 300,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'Rapido',
          nameVariants: ['RAPIDO', 'rapido'],
          categoryId: 'cat_transport',
          typicalAmount: 50,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'UBER IND',
          nameVariants: ['uber ind', 'Uber', 'UBER'],
          categoryId: 'cat_transport',
          typicalAmount: 150,
          paymentMode: 'upi',
        ),
        // ── Entertainment ────────────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'PVR INOX',
          nameVariants: ['pvr inox', 'PVR', 'INOX'],
          categoryId: 'cat_entertainment',
          typicalAmount: 300,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'BOOKMYSHOW',
          nameVariants: ['bookmyshow', 'BookMyShow', 'Book My Show'],
          categoryId: 'cat_entertainment',
          typicalAmount: 300,
          paymentMode: 'upi',
        ),
        // ── Shopping ─────────────────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'FLIPKART',
          nameVariants: ['flipkart', 'Flipkart'],
          categoryId: 'cat_shopping',
          typicalAmount: 500,
          paymentMode: 'upi',
        ),
        // ── Investment ───────────────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'ZERODHA',
          nameVariants: ['zerodha', 'Zerodha'],
          categoryId: 'cat_investment',
          typicalAmount: 1000,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'Groww',
          nameVariants: ['GROWW', 'groww'],
          categoryId: 'cat_sip',
          typicalAmount: 1000,
          paymentMode: 'upi',
        ),
        // ── Health ───────────────────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'RAHILA W',
          nameVariants: ['rahila w', 'Rahila W', 'RAHILAW'],
          categoryId: 'cat_health',
          typicalAmount: 100,
          paymentMode: 'upi',
        ),
        // ── Grooming ─────────────────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'SHARIF',
          nameVariants: ['sharif', 'Sharif'],
          categoryId: 'cat_grooming',
          typicalAmount: 100,
          paymentMode: 'cash',
        ),
        // ── Others ───────────────────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'POPTECH',
          nameVariants: ['poptech', 'Poptech'],
          categoryId: 'cat_misc_expense',
          typicalAmount: 1102,
          paymentMode: 'upi',
        ),
        // ── Income / Transfers ───────────────────────────────────────────────
        const DefaultMerchantData(
          name: 'AVIRAL S',
          nameVariants: ['aviral s', 'Aviral S', 'AVIRALS'],
          categoryId: 'cat_received',
          typicalAmount: null,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'ANANAY S',
          nameVariants: ['ananay s', 'Ananay S', 'ANANAYS'],
          categoryId: 'cat_received',
          typicalAmount: null,
          paymentMode: 'upi',
        ),
        const DefaultMerchantData(
          name: 'Alankrit',
          nameVariants: ['ALANKRIT', 'alankrit'],
          categoryId: 'cat_received',
          typicalAmount: null,
          paymentMode: 'upi',
        ),
      ];
}

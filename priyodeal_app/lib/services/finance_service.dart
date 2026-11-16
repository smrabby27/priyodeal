import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_service.dart';

class FinanceService {
  static String activeMode = 'personal'; // 'personal' or 'business'

  static List<FinanceTransaction> transactions = [];
  static List<BusinessProduct> products = [];
  static List<BusinessParty> parties = []; // Customers & Suppliers
  static List<BusinessSaleInvoice> invoices = [];
  static List<PaymentAccount> accounts = [];
  static List<Budget> budgets = [];
  static List<SavingsGoal> goals = [];
  static List<FinanceCategory> customCategories = [];

  static bool _isSyncing = false;

  static String get _userId => ApiService.currentUser?.id.toString() ?? 'anonymous';
  static String get _kModeKey => 'offline_finance_${_userId}_mode';
  static String get _kTransactionsKey => 'offline_finance_${_userId}_transactions_v6';
  static String get _kProductsKey => 'offline_finance_${_userId}_products_v6';
  static String get _kPartiesKey => 'offline_finance_${_userId}_parties_v6';
  static String get _kInvoicesKey => 'offline_finance_${_userId}_invoices_v6';
  static String get _kAccountsKey => 'offline_finance_${_userId}_accounts_v6';
  static String get _kCategoriesKey => 'offline_finance_${_userId}_categories_v6';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    activeMode = prefs.getString(_kModeKey) ?? 'personal';

    // 1. Reset in-memory state cleanly for the current user session
    clearActiveMemory();

    // 2. Load cached local data for this user
    _loadFromLocalPrefs(prefs);

    // 3. If user is authenticated, sync with server database as source of truth
    if (ApiService.isLoggedIn) {
      await syncFromDatabase();
    } else {
      _ensureDefaultAccount();
    }
  }

  static void _loadFromLocalPrefs(SharedPreferences prefs) {
    // 1. Accounts
    final accString = prefs.getString(_kAccountsKey);
    if (accString != null) {
      try {
        final List list = jsonDecode(accString);
        accounts = list.map((item) => PaymentAccount.fromJson(item)).toList();
      } catch (e) {
        accounts = [];
      }
    } else {
      accounts = [];
    }

    // 2. Transactions
    final txString = prefs.getString(_kTransactionsKey);
    if (txString != null) {
      try {
        final List list = jsonDecode(txString);
        transactions = list.map((item) => FinanceTransaction.fromJson(item)).toList();
      } catch (e) {
        transactions = [];
      }
    } else {
      transactions = [];
    }

    // 3. Products
    final prodString = prefs.getString(_kProductsKey);
    if (prodString != null) {
      try {
        final List list = jsonDecode(prodString);
        products = list.map((item) => BusinessProduct.fromJson(item)).toList();
      } catch (e) {
        products = [];
      }
    } else {
      products = [];
    }

    // 4. Parties
    final partyString = prefs.getString(_kPartiesKey);
    if (partyString != null) {
      try {
        final List list = jsonDecode(partyString);
        parties = list.map((item) => BusinessParty.fromJson(item)).toList();
      } catch (e) {
        parties = [];
      }
    } else {
      parties = [];
    }

    // 5. Invoices
    final invString = prefs.getString(_kInvoicesKey);
    if (invString != null) {
      try {
        final List list = jsonDecode(invString);
        invoices = list.map((item) => BusinessSaleInvoice.fromJson(item)).toList();
      } catch (e) {
        invoices = [];
      }
    } else {
      invoices = [];
    }

    // 6. Custom Categories
    final catString = prefs.getString(_kCategoriesKey);
    if (catString != null) {
      try {
        final List list = jsonDecode(catString);
        customCategories = list.map((item) => FinanceCategory.fromJson(item)).toList();
      } catch (e) {
        customCategories = [];
      }
    } else {
      customCategories = [];
    }
  }

  static void _ensureDefaultAccount() {
    if (!accounts.any((a) => a.mode == 'personal' && a.type == 'cash')) {
      accounts.add(
        PaymentAccount(
          id: 'acc_cash_personal',
          name: 'ক্যাশ (Personal Cash)',
          type: 'cash',
          initialBalance: 0.0,
          mode: 'personal',
        ),
      );
    }
    if (!accounts.any((a) => a.mode == 'business' && a.type == 'cash')) {
      accounts.add(
        PaymentAccount(
          id: 'acc_cash_business',
          name: 'ক্যাশ বাক্স (Shop Cash)',
          type: 'cash',
          initialBalance: 0.0,
          mode: 'business',
        ),
      );
    }
  }

  static Future<void> syncFromDatabase() async {
    if (!ApiService.isLoggedIn) return;
    try {
      final dbData = await ApiService.fetchUserFinanceData();
      if (dbData != null) {
        final serverAccounts = dbData['accounts'] is List
            ? (dbData['accounts'] as List).map((item) => PaymentAccount.fromJson(item)).toList()
            : <PaymentAccount>[];
        final serverTransactions = dbData['transactions'] is List
            ? (dbData['transactions'] as List).map((item) => FinanceTransaction.fromJson(item)).toList()
            : <FinanceTransaction>[];
        final serverProducts = dbData['products'] is List
            ? (dbData['products'] as List).map((item) => BusinessProduct.fromJson(item)).toList()
            : <BusinessProduct>[];
        final serverParties = dbData['parties'] is List
            ? (dbData['parties'] as List).map((item) => BusinessParty.fromJson(item)).toList()
            : <BusinessParty>[];
        final serverInvoices = dbData['invoices'] is List
            ? (dbData['invoices'] as List).map((item) => BusinessSaleInvoice.fromJson(item)).toList()
            : <BusinessSaleInvoice>[];
        final serverCategories = dbData['categories'] is List
            ? (dbData['categories'] as List).map((item) => FinanceCategory.fromJson(item)).toList()
            : <FinanceCategory>[];

        // If server has data for this user, use server data as single source of truth
        if (serverAccounts.isNotEmpty || serverTransactions.isNotEmpty || serverProducts.isNotEmpty || serverParties.isNotEmpty || serverInvoices.isNotEmpty || serverCategories.isNotEmpty) {
          if (serverAccounts.isNotEmpty) {
            accounts = serverAccounts;
          } else {
            _ensureDefaultAccount();
          }
          transactions = serverTransactions;
          products = serverProducts;
          parties = serverParties;
          invoices = serverInvoices;
          if (serverCategories.isNotEmpty) {
            customCategories = serverCategories;
          }

          // Save strictly to local cache WITHOUT triggering syncToDatabase:
          await _saveAllToLocalPrefs();
        } else {
          // Server was empty for this user.
          // If we have local transactions/accounts for this user, push to server:
          if (accounts.isNotEmpty || transactions.isNotEmpty || products.isNotEmpty || customCategories.isNotEmpty) {
            await syncToDatabase();
          } else {
            // Brand new account: initialize default Cash with 0
            _ensureDefaultAccount();
            await _saveAllToLocalPrefs();
            await syncToDatabase();
          }
        }
      }
    } catch (e) {
      // offline fallback
    }
  }

  static Future<void> _saveAllToLocalPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccountsKey, jsonEncode(accounts.map((a) => a.toJson()).toList()));
    await prefs.setString(_kTransactionsKey, jsonEncode(transactions.map((t) => t.toJson()).toList()));
    await prefs.setString(_kProductsKey, jsonEncode(products.map((p) => p.toJson()).toList()));
    await prefs.setString(_kPartiesKey, jsonEncode(parties.map((p) => p.toJson()).toList()));
    await prefs.setString(_kInvoicesKey, jsonEncode(invoices.map((i) => i.toJson()).toList()));
    await prefs.setString(_kCategoriesKey, jsonEncode(customCategories.map((c) => c.toJson()).toList()));
  }

  static Future<void> syncToDatabase() async {
    if (!ApiService.isLoggedIn) return;
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await ApiService.syncUserFinanceData({
        'accounts': accounts.map((a) => a.toJson()).toList(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'products': products.map((p) => p.toJson()).toList(),
        'parties': parties.map((pt) => pt.toJson()).toList(),
        'invoices': invoices.map((inv) => inv.toJson()).toList(),
        'categories': customCategories.map((c) => c.toJson()).toList(),
      });
    } catch (e) {
      // offline fallback
    } finally {
      _isSyncing = false;
    }
  }

  static void clearActiveMemory() {
    accounts = [];
    transactions = [];
    products = [];
    parties = [];
    invoices = [];
    budgets = [];
    goals = [];
    customCategories = [];
  }

  static Future<void> setMode(String mode) async {
    activeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kModeKey, mode);
  }

  // --- Category Management ---
  static List<String> getCategories(String type, String mode) {
    List<String> defaults;
    if (mode == 'business') {
      defaults = type == 'income'
          ? ['নগদ বিক্রি (Cash Sales)', 'বাকি আদায় (Due Collection)', 'পাইকারি বিক্রি (Wholesale)', 'সার্ভিস চার্জ (Service)', 'অন্যান্য (Others)']
          : ['স্টক ক্রয় (Stock Purchase)', 'দোকান ভাড়া (Shop Rent)', 'কর্মচারীর বেতন (Staff Salary)', 'বিদ্যুৎ ও বিল (Utilities)', 'যাতায়াত ও পরিবহন (Transport)', 'প্যাকেজিং (Packaging)', 'মেরামত ও রক্ষণাবেক্ষণ (Maintenance)', 'অন্যান্য (Others)'];
    } else {
      defaults = type == 'income'
          ? ['বেতন (Salary)', 'বোনাস (Bonus)', 'ব্যবসায় মুনাফা (Profit)', 'ফ্রিল্যান্সিং (Freelancing)', 'উপহার (Gift)', 'বিনিয়োগ আয় (Investment)', 'অন্যান্য (Others)']
          : ['খাবার ও ডাইনিং (Food)', 'মুদি বাজার (Grocery)', 'বাড়ি ভাড়া (House Rent)', 'চিকিৎসা ও ওষুধ (Healthcare)', 'যাতায়াত (Transport)', 'শপিং (Shopping)', 'ইউটিলিটি বিল (Bills)', 'শিক্ষা (Education)', 'বিনোদন (Entertainment)', 'সৌন্দর্য ও সেলুন (Beauty)', 'অন্যান্য (Others)'];
    }

    final custom = customCategories
        .where((c) => c.type == type && c.mode == mode)
        .map((c) => c.name)
        .toList();

    return [...defaults, ...custom];
  }

  static Future<FinanceCategory> addCustomCategory({
    required String name,
    required String type, // 'income' or 'expense'
    required String mode, // 'personal' or 'business'
    String? icon,
    String? color,
  }) async {
    final cat = FinanceCategory(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      mode: mode,
      icon: icon ?? 'category',
      color: color ?? '#0284C7',
    );
    customCategories.add(cat);
    await _persistCategories();
    syncToDatabase();
    return cat;
  }

  static Future<void> deleteCustomCategory(String id) async {
    customCategories.removeWhere((c) => c.id == id);
    await _persistCategories();
    syncToDatabase();
  }

  static Future<void> _persistCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCategoriesKey, jsonEncode(customCategories.map((c) => c.toJson()).toList()));
  }

  // --- Account Management ---
  static List<PaymentAccount> get currentAccounts {
    return accounts.where((a) => a.mode == activeMode).toList();
  }

  static List<PaymentAccount> getAccountsByType(String type, [String? mode]) {
    final targetMode = mode ?? activeMode;
    return accounts.where((a) => a.type == type && a.mode == targetMode).toList();
  }

  static Future<void> addAccount({
    required String name,
    required String type, // 'cash', 'bank' or 'mfs'
    String? provider,
    String? accountNumber,
    double initialBalance = 0,
    String? mode,
  }) async {
    final targetMode = mode ?? activeMode;
    final newAcc = PaymentAccount(
      id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      provider: provider,
      accountNumber: accountNumber,
      initialBalance: initialBalance,
      mode: targetMode,
    );
    accounts.add(newAcc);
    await _persistAccounts();
    syncToDatabase();
  }

  // --- Strict Non-Negative Balance Calculations (Strictly isolated by Mode) ---
  static double getAccountBalance(String accountIdentifier, [String? mode]) {
    final targetMode = mode ?? activeMode;
    double bal = 0;

    // Find matching account strictly in the target mode
    final acc = accounts.firstWhere(
      (a) => a.mode == targetMode && (a.id == accountIdentifier || a.name.toLowerCase() == accountIdentifier.toLowerCase()),
      orElse: () => accounts.firstWhere(
        (a) => a.id == accountIdentifier || a.name.toLowerCase() == accountIdentifier.toLowerCase(),
        orElse: () => PaymentAccount(
          id: 'unknown',
          name: accountIdentifier,
          type: 'cash',
          initialBalance: 0,
          mode: targetMode,
        ),
      ),
    );
    bal = acc.initialBalance;

    for (var tx in transactions) {
      if (tx.mode != targetMode) continue; // STRICT ISOLATION! Personal vs Business

      final matchesName = tx.account.toLowerCase() == acc.name.toLowerCase() ||
          tx.account.toLowerCase() == acc.id.toLowerCase() ||
          (acc.type == 'cash' && (tx.account.toLowerCase() == 'cash' || tx.account.toLowerCase().contains('cash') || tx.account.toLowerCase().contains('ক্যাশ')));
      if (matchesName) {
        if (tx.type == 'income') {
          bal += tx.amount;
        } else if (tx.type == 'expense') {
          bal -= tx.amount;
        }
      }
    }
    return bal;
  }

  static double get totalBalance {
    double total = 0;
    for (var a in currentAccounts) {
      total += getAccountBalance(a.name, activeMode);
    }
    return total;
  }

  static double get cashBalance {
    double sum = 0;
    for (var a in currentAccounts.where((x) => x.type == 'cash')) {
      sum += getAccountBalance(a.name, activeMode);
    }
    return sum;
  }

  static double get bankBalance {
    double sum = 0;
    for (var a in currentAccounts.where((x) => x.type == 'bank')) {
      sum += getAccountBalance(a.name, activeMode);
    }
    return sum;
  }

  static double get mfsBalance {
    double sum = 0;
    for (var a in currentAccounts.where((x) => x.type == 'mfs')) {
      sum += getAccountBalance(a.name, activeMode);
    }
    return sum;
  }

  static Map<String, double> get accountBalances {
    return {
      'Cash': cashBalance,
      'Bank': bankBalance,
      'Mobile Banking': mfsBalance,
    };
  }

  // --- Validation to Prevent Negative Balance ---
  static bool canExpense(String accountName, double amount, [String? mode]) {
    final curr = getAccountBalance(accountName, mode ?? activeMode);
    return curr >= amount;
  }

  // --- Transactions Management ---
  static Future<void> addTransaction({
    required double amount,
    required String type,
    String? mode,
    required String category,
    required String account,
    required DateTime date,
    String? note,
    String? partyName,
    String? voucherNo,
  }) async {
    final txMode = mode ?? activeMode;
    // 1. Strict Negative Check: cannot expense more than current balance!
    if (type == 'expense') {
      final currentBal = getAccountBalance(account, txMode);
      if (currentBal < amount) {
        throw Exception(
          'অপর্যাপ্ত ব্যালেন্স! আপনার "$account" এ বর্তমান ব্যালেন্স ৳${currentBal.toStringAsFixed(2)}, আপনি এর বেশি খরচ করতে পারবেন না।',
        );
      }
    }

    final tx = FinanceTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: type,
      mode: txMode,
      category: category,
      account: account,
      date: date,
      note: note,
      partyName: partyName,
      voucherNo: voucherNo,
    );
    transactions.insert(0, tx);
    await _persistTransactions();
    syncToDatabase();
  }

  static Future<void> transferFunds({
    required String fromAccount,
    required String toAccount,
    required double amount,
    String? note,
  }) async {
    // Strict Negative Balance Check for Transfer
    final fromBal = getAccountBalance(fromAccount, activeMode);
    if (fromBal < amount) {
      throw Exception(
        'অপর্যাপ্ত ব্যালেন্স! "$fromAccount" থেকে ট্রান্সফার করার জন্য পর্যাপ্ত টাকা নেই। বর্তমান ব্যালেন্স: ৳${fromBal.toStringAsFixed(2)}',
      );
    }

    final now = DateTime.now();
    // 1. Debit from source
    transactions.insert(
      0,
      FinanceTransaction(
        id: '${now.millisecondsSinceEpoch}_out',
        amount: amount,
        type: 'expense',
        mode: activeMode,
        category: 'ফান্ড ট্রান্সফার (আউট)',
        account: fromAccount,
        date: now,
        note: 'ট্রান্সফার টু $toAccount: ${note ?? ''}',
      ),
    );
    // 2. Credit to destination
    transactions.insert(
      0,
      FinanceTransaction(
        id: '${now.millisecondsSinceEpoch}_in',
        amount: amount,
        type: 'income',
        mode: activeMode,
        category: 'ফান্ড ট্রান্সফার (ইন)',
        account: toAccount,
        date: now,
        note: 'ট্রান্সফার ফ্রম $fromAccount: ${note ?? ''}',
      ),
    );
    await _persistTransactions();
    syncToDatabase();
  }

  static Future<void> deleteTransaction(String id) async {
    transactions.removeWhere((tx) => tx.id == id);
    await _persistTransactions();
    syncToDatabase();
  }

  // --- Products Management ---
  static Future<void> addProduct({
    required String name,
    required String category,
    required String unit,
    required double stock,
    required double buyPrice,
    required double sellPrice,
  }) async {
    final prod = BusinessProduct(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      unit: unit,
      stock: stock,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
    );
    products.insert(0, prod);
    await _persistProducts();
    syncToDatabase();
  }

  // --- Customers & Suppliers ---
  static Future<BusinessParty> addParty({
    required String type, // 'customer' or 'supplier'
    required String name,
    required String phone,
    String? address,
    String? email,
    double openingBalance = 0,
  }) async {
    final party = BusinessParty(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      name: name,
      phone: phone,
      address: address,
      email: email,
      openingBalance: openingBalance,
      dueBalance: openingBalance,
    );
    parties.insert(0, party);
    await _persistParties();
    syncToDatabase();
    return party;
  }

  // --- Invoices (POS Sales with Partial / Full Payment & Stock Deduction) ---
  static Future<void> addSaleInvoice({
    required String customerName,
    required String customerPhone,
    String? customerAddress,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    double vat = 0,
    double delivery = 0,
    double discount = 0,
    String discountType = 'fixed',
    double discountValue = 0,
    required double total,
    required double paidAmount,
    required double dueAmount,
    required String paymentMethod,
    required String paymentStatus, // 'paid', 'partial', 'due'
    String targetAccount = 'ক্যাশ (Cash)',
  }) async {
    final invoiceNo = '#${(invoices.length + 2).toString().padLeft(6, '0')}';

    final inv = BusinessSaleInvoice(
      invoiceNo: invoiceNo,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      items: items,
      subtotal: subtotal,
      vat: vat,
      delivery: delivery,
      discount: discount,
      discountType: discountType,
      discountValue: discountValue,
      total: total,
      paidAmount: paidAmount,
      dueAmount: dueAmount,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      date: DateTime.now(),
      status: 'approved',
    );
    invoices.insert(0, inv);
    await _persistInvoices();

    // 1. Deduct stock for sold items
    for (var item in items) {
      final pName = item['name']?.toString() ?? '';
      final qty = (item['qty'] is num) ? (item['qty'] as num).toDouble() : 1.0;
      final idx = products.indexWhere((p) => p.name.toLowerCase() == pName.toLowerCase());
      if (idx != -1) {
        final cur = products[idx];
        products[idx] = BusinessProduct(
          id: cur.id,
          name: cur.name,
          category: cur.category,
          unit: cur.unit,
          stock: (cur.stock - qty).clamp(0.0, 999999.0),
          buyPrice: cur.buyPrice,
          sellPrice: cur.sellPrice,
          isActive: cur.isActive,
        );
      }
    }
    await _persistProducts();

    // 2. Record Income for Paid Amount (if any)
    if (paidAmount > 0) {
      await addTransaction(
        amount: paidAmount,
        type: 'income',
        mode: 'business',
        category: 'Cash Sales',
        account: targetAccount,
        date: DateTime.now(),
        note: 'বিক্রয় ইনভয়েস $invoiceNo ($paymentStatus)',
        partyName: customerName,
        voucherNo: invoiceNo,
      );
    }

    // 3. Record Due Amount in Customer Ledger (if any)
    if (dueAmount > 0) {
      final idx = parties.indexWhere((p) => p.name.toLowerCase() == customerName.toLowerCase());
      if (idx != -1) {
        final existing = parties[idx];
        parties[idx] = BusinessParty(
          id: existing.id,
          type: existing.type,
          name: existing.name,
          phone: existing.phone,
          address: existing.address,
          email: existing.email,
          openingBalance: existing.openingBalance,
          dueBalance: existing.dueBalance + dueAmount,
        );
      } else {
        parties.insert(
          0,
          BusinessParty(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: 'customer',
            name: customerName,
            phone: customerPhone,
            address: customerAddress,
            dueBalance: dueAmount,
          ),
        );
      }
      await _persistParties();
    }
    syncToDatabase();
  }

  // --- Customer Ledger Due Payment / Collection ---
  static Future<void> collectCustomerDue({
    required String customerName,
    required double amount,
    required String targetAccount,
    String? note,
  }) async {
    // 1. Reduce Customer's due balance
    final idx = parties.indexWhere((p) => p.name.toLowerCase() == customerName.toLowerCase());
    if (idx != -1) {
      final existing = parties[idx];
      parties[idx] = BusinessParty(
        id: existing.id,
        type: existing.type,
        name: existing.name,
        phone: existing.phone,
        address: existing.address,
        email: existing.email,
        openingBalance: existing.openingBalance,
        dueBalance: (existing.dueBalance - amount).clamp(0.0, 9999999.0),
      );
      await _persistParties();
    }

    // 2. Add Income transaction to business account
    await addTransaction(
      amount: amount,
      type: 'income',
      mode: 'business',
      category: 'Due Collection (বাকি আদায়)',
      account: targetAccount,
      date: DateTime.now(),
      note: note ?? 'কাস্টমার $customerName এর বাকি পরিশোধ',
      partyName: customerName,
    );
  }

  // --- Single Customer Ledger Query Helpers ---
  static List<BusinessSaleInvoice> getCustomerInvoices(String customerName) {
    return invoices.where((i) => i.customerName.toLowerCase() == customerName.toLowerCase()).toList();
  }

  static List<FinanceTransaction> getCustomerTransactions(String customerName) {
    return transactions.where((t) => (t.partyName?.toLowerCase() ?? '') == customerName.toLowerCase()).toList();
  }

  static double getCustomerTotalBuy(String customerName) {
    double sum = 0;
    for (var inv in getCustomerInvoices(customerName)) {
      sum += inv.total;
    }
    return sum;
  }

  static double getCustomerTotalPaid(String customerName) {
    double sum = 0;
    for (var inv in getCustomerInvoices(customerName)) {
      sum += inv.paidAmount;
    }
    for (var tx in getCustomerTransactions(customerName)) {
      if (tx.category.contains('Due Collection') || tx.category.contains('বাকি')) {
        sum += tx.amount;
      }
    }
    return sum;
  }

  static double getCustomerCurrentDue(String customerName) {
    final party = parties.firstWhere(
      (p) => p.name.toLowerCase() == customerName.toLowerCase(),
      orElse: () => BusinessParty(id: '', type: 'customer', name: customerName, phone: '', dueBalance: 0),
    );
    return party.dueBalance;
  }

  static double get totalReceivable {
    double sum = 0;
    for (var p in parties.where((x) => x.type == 'customer')) {
      if (p.dueBalance > 0) sum += p.dueBalance;
    }
    return sum;
  }

  static double get totalPayable {
    double sum = 0;
    for (var p in parties.where((x) => x.type == 'supplier')) {
      if (p.dueBalance > 0) sum += p.dueBalance;
    }
    return sum;
  }

  // Current transactions for active mode
  static List<FinanceTransaction> get currentTransactions {
    return transactions.where((tx) => tx.mode == activeMode).toList();
  }

  static double get monthlyIncome {
    final now = DateTime.now();
    double sum = 0;
    for (var tx in currentTransactions) {
      if (tx.type == 'income' && tx.date.month == now.month && tx.date.year == now.year) {
        sum += tx.amount;
      }
    }
    return sum;
  }

  static double get monthlyExpense {
    final now = DateTime.now();
    double sum = 0;
    for (var tx in currentTransactions) {
      if (tx.type == 'expense' && tx.date.month == now.month && tx.date.year == now.year) {
        sum += tx.amount;
      }
    }
    return sum;
  }

  // --- Persistence Handlers (Local Only, NO rogue sync calls) ---
  static Future<void> _persistAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccountsKey, jsonEncode(accounts.map((a) => a.toJson()).toList()));
  }

  static Future<void> _persistTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTransactionsKey, jsonEncode(transactions.map((t) => t.toJson()).toList()));
  }

  static Future<void> _persistProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProductsKey, jsonEncode(products.map((p) => p.toJson()).toList()));
  }

  static Future<void> _persistParties() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPartiesKey, jsonEncode(parties.map((p) => p.toJson()).toList()));
  }

  static Future<void> _persistInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kInvoicesKey, jsonEncode(invoices.map((i) => i.toJson()).toList()));
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    transactions.clear();
    products.clear();
    parties.clear();
    invoices.clear();
    accounts.clear();
    await prefs.remove(_kTransactionsKey);
    await prefs.remove(_kProductsKey);
    await prefs.remove(_kPartiesKey);
    await prefs.remove(_kInvoicesKey);
    await prefs.remove(_kAccountsKey);
    await ApiService.clearUserFinanceData();
    await init();
  }
}

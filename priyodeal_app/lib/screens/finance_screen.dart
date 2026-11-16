import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/finance_service.dart';
import '../services/api_service.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  bool _hideBalance = false;

  @override
  void initState() {
    super.initState();
    _refreshFinanceData();
  }

  Future<void> _refreshFinanceData() async {
    await FinanceService.syncFromDatabase();
    if (mounted) setState(() {});
  }

  void _switchMode(String mode) async {
    await FinanceService.setMode(mode);
    setState(() {});
  }

  void _openAddTransactionSheet(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddTransactionSheet(
        type: type,
        mode: FinanceService.activeMode,
        onAdded: () => setState(() {}),
      ),
    );
  }

  void _openTransferSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransferSheet(
        onTransferred: () => setState(() {}),
      ),
    );
  }

  void _openCashBookScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CashBookScreen()),
    );
  }

  void _openFinancialStatement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FinancialStatementScreen()),
    );
  }

  void _openDenaPawnaScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DenaPawnaScreen()),
    );
  }

  void _openInventoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessInventoryScreen()),
    );
  }

  void _openNewSaleScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusinessNewSaleScreen()),
    );
  }

  void _openSubscriptionPlans() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FreeSubscriptionSheet(),
    );
  }

  void _openCategoryManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryManagementSheet(
        mode: FinanceService.activeMode,
        onUpdated: () => setState(() {}),
      ),
    );
  }

  void _openAccountManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AccountManagementSheet(
        onUpdated: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusiness = FinanceService.activeMode == 'business';
    final totalBalance = FinanceService.totalBalance;
    final monthlyInc = FinanceService.monthlyIncome;
    final monthlyExp = FinanceService.monthlyExpense;
    final accounts = FinanceService.accountBalances;
    final transactions = FinanceService.currentTransactions;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Color(0xFF0284C7), size: 22),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBusiness ? 'ব্যবসা ক্যাশ বই' : 'ক্যাশ বই (পার্সোনাল)',
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  'স্বাগতম, ${ApiService.currentUser?.name ?? "ব্যবহারকারী"} • 📍 ${ApiService.currentLocation.split(',').first}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_rounded, color: Color(0xFF0284C7), size: 22),
            tooltip: 'ক্যাটাগরি ম্যানেজমেন্ট',
            onPressed: _openCategoryManagement,
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_rounded, color: Color(0xFF0284C7), size: 22),
            tooltip: 'অ্যাকাউন্ট ম্যানেজমেন্ট',
            onPressed: _openAccountManagement,
          ),
          GestureDetector(
            onTap: _openSubscriptionPlans,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, size: 14, color: Color(0xFF10B981)),
                  SizedBox(width: 4),
                  Text(
                    'সম্পূর্ণ ফ্রি',
                    style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFinanceData,
        color: const Color(0xFF0284C7),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Switcher Bar (Personal vs Business)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchMode('personal'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !isBusiness ? const Color(0xFF0F2942) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !isBusiness
                              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 16,
                              color: !isBusiness ? Colors.white : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ব্যক্তিগত (Personal)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: !isBusiness ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _switchMode('business'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isBusiness ? const Color(0xFF0F2942) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isBusiness
                              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              size: 16,
                              color: isBusiness ? Colors.white : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'ব্যবসায়িক (Business)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isBusiness ? Colors.white : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Master Total Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0C2340),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0C2340).withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'মোট ব্যালেন্স',
                            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _hideBalance = !_hideBalance),
                            child: Icon(
                              _hideBalance ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _openCashBookScreen,
                        child: Row(
                          children: [
                            Text(
                              _hideBalance ? '৳ •••••' : '৳ ${totalBalance.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right, color: Colors.white70, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Accounts Row (Cash, Bank, Mobile Banking)
                  Row(
                    children: [
                      Expanded(
                        child: _accountPill(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'ক্যাশ',
                          amount: accounts['Cash'] ?? 0,
                          onTap: _openAccountManagement,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _accountPill(
                          icon: Icons.account_balance_rounded,
                          title: 'ব্যাংক',
                          amount: accounts['Bank'] ?? 0,
                          onTap: _openAccountManagement,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _accountPill(
                          icon: Icons.phone_android_rounded,
                          title: 'মোবাইল ব্যাংকিং',
                          amount: accounts['Mobile Banking'] ?? 0,
                          onTap: _openAccountManagement,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Two Monthly Summary Cards (Income & Expense)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFC8E6C9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E7D32),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, size: 12, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'আয়',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                            ),
                            const Spacer(),
                            const Text(
                              'এই মাস',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '৳ ${monthlyInc.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFC62828),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.remove, size: 12, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'ব্যয়',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                            ),
                            const Spacer(),
                            const Text(
                              'এই মাস',
                              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '৳ ${monthlyExp.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB71C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions Header
            const Row(
              children: [
                Text(
                  'কুইক একশনস',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Divider(color: Color(0xFFCBD5E1), thickness: 1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Actions Grid
            if (!isBusiness) ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _actionButton(
                    icon: Icons.add_circle,
                    iconColor: const Color(0xFF10B981),
                    label: 'আয় যোগ করুন',
                    onTap: () => _openAddTransactionSheet('income'),
                  ),
                  _actionButton(
                    icon: Icons.remove_circle,
                    iconColor: const Color(0xFFEF4444),
                    label: 'দৈনন্দিন খরচ',
                    onTap: () => _openAddTransactionSheet('expense'),
                  ),
                  _actionButton(
                    icon: Icons.sync_alt_rounded,
                    iconColor: const Color(0xFF0284C7),
                    label: 'ফান্ড ট্রান্সফার',
                    onTap: _openTransferSheet,
                  ),
                  _actionButton(
                    icon: Icons.volunteer_activism_rounded,
                    iconColor: const Color(0xFF0D9488),
                    label: 'দেনা/পাওনা',
                    onTap: _openDenaPawnaScreen,
                  ),
                  _actionButton(
                    icon: Icons.pie_chart_rounded,
                    iconColor: const Color(0xFF6366F1),
                    label: 'বাজেট বিবরণী',
                    onTap: _openFinancialStatement,
                  ),
                  _actionButton(
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'ক্যাশ বুক',
                    onTap: _openCashBookScreen,
                  ),
                  _actionButton(
                    icon: Icons.category_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    label: 'ক্যাটাগরি তালিকা',
                    onTap: _openCategoryManagement,
                  ),
                ],
              ),
            ] else ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _actionButton(
                    icon: Icons.point_of_sale_rounded,
                    iconColor: const Color(0xFF10B981),
                    label: 'নতুন বিক্রয় (POS)',
                    onTap: _openNewSaleScreen,
                  ),
                  _actionButton(
                    icon: Icons.inventory_2_rounded,
                    iconColor: const Color(0xFF0284C7),
                    label: 'পণ্য ও স্টক',
                    onTap: _openInventoryScreen,
                  ),
                  _actionButton(
                    icon: Icons.people_alt_rounded,
                    iconColor: const Color(0xFF0D9488),
                    label: 'কাস্টমার লেজার',
                    onTap: _openDenaPawnaScreen,
                  ),
                  _actionButton(
                    icon: Icons.shopping_cart_checkout_rounded,
                    iconColor: const Color(0xFFEF4444),
                    label: 'ক্রয় ও খরচ',
                    onTap: () => _openAddTransactionSheet('expense'),
                  ),
                  _actionButton(
                    icon: Icons.menu_book_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    label: 'ক্যাশ বুক রিপোর্ট',
                    onTap: _openCashBookScreen,
                  ),
                  _actionButton(
                    icon: Icons.account_balance_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    label: 'ব্যাংক ও MFS',
                    onTap: _openAccountManagement,
                  ),
                  _actionButton(
                    icon: Icons.category_rounded,
                    iconColor: const Color(0xFF0284C7),
                    label: 'ক্যাটাগরি তালিকা',
                    onTap: _openCategoryManagement,
                  ),
                ],
              ),
            ],

            const SizedBox(height: 28),

            // Recent Transactions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'সাম্প্রতিক লেনদেন',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                GestureDetector(
                  onTap: _openCashBookScreen,
                  child: const Row(
                    children: [
                      Text(
                        'আরও দেখুন',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: Color(0xFF0284C7)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Transactions List
            if (transactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text('এখনো কোনো লেনদেন যোগ করা হয়নি', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length > 5 ? 5 : transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isIncome = tx.type == 'income';
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.category,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${DateFormat('dd MMM, yyyy').format(tx.date)} • ${tx.account}',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isIncome ? '+' : '-'} ৳${tx.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isIncome ? 'আয়' : 'ব্যয়',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isIncome ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

  Widget _accountPill({required IconData icon, required String title, required double amount, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _hideBalance ? '৳ •••' : '৳ ${amount.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// ADD TRANSACTION SHEET (With Strict Non-Negative Check & Sub-Accounts)
// -------------------------------------------------------------
class _AddTransactionSheet extends StatefulWidget {
  final String type; // 'income' or 'expense'
  final String mode; // 'personal' or 'business'
  final VoidCallback onAdded;

  const _AddTransactionSheet({
    required this.type,
    required this.mode,
    required this.onAdded,
  });

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _partyController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  late String _selectedCategory;
  String _selectedMethodType = 'cash'; // 'cash', 'bank', 'mfs'
  String _selectedAccountName = 'ক্যাশ (Cash)';

  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = FinanceService.getCategories(widget.type, widget.mode);
    _selectedCategory = _categories.isNotEmpty ? _categories.first : 'অন্যান্য (Others)';
    _updateSelectedAccountName();
  }

  void _openAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    int selectedColorIdx = 0;
    int selectedIconIdx = 0;

    final colorList = [
      const Color(0xFF10B981),
      const Color(0xFF0284C7),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFF64748B),
    ];

    final iconList = [
      Icons.category_rounded,
      Icons.restaurant_rounded,
      Icons.shopping_cart_rounded,
      Icons.directions_car_rounded,
      Icons.local_hospital_rounded,
      Icons.school_rounded,
      Icons.receipt_rounded,
      Icons.work_rounded,
      Icons.sports_esports_rounded,
      Icons.fitness_center_rounded,
      Icons.local_cafe_rounded,
      Icons.flight_rounded,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorList[selectedColorIdx].withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconList[selectedIconIdx], color: colorList[selectedColorIdx], size: 22),
              ),
              const SizedBox(width: 10),
              const Text('নতুন ক্যাটাগরি তৈরি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'ক্যাটাগরির নাম *',
                    hintText: 'যেমন: জিম, চা-নাস্তা, অফিস খরচ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('রং পছন্দ করুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(colorList.length, (i) {
                    final isSel = selectedColorIdx == i;
                    return GestureDetector(
                      onTap: () => setD(() => selectedColorIdx = i),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colorList[i],
                          shape: BoxShape.circle,
                          border: isSel ? Border.all(color: Colors.black, width: 2.5) : null,
                        ),
                        child: isSel ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('আইকন পছন্দ করুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(iconList.length, (i) {
                    final isSel = selectedIconIdx == i;
                    return GestureDetector(
                      onTap: () => setD(() => selectedIconIdx = i),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? colorList[selectedColorIdx].withOpacity(0.2) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: isSel ? Border.all(color: colorList[selectedColorIdx], width: 1.5) : null,
                        ),
                        child: Icon(iconList[i], size: 18, color: isSel ? colorList[selectedColorIdx] : Colors.grey.shade700),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2942),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final newCat = await FinanceService.addCustomCategory(
                  name: name,
                  type: widget.type,
                  mode: widget.mode,
                  icon: 'icon_$selectedIconIdx',
                  color: '#${colorList[selectedColorIdx].value.toRadixString(16).substring(2)}',
                );

                Navigator.pop(ctx);
                setState(() {
                  _categories = FinanceService.getCategories(widget.type, widget.mode);
                  _selectedCategory = newCat.name;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ক্যাটাগরি "$name" সফলভাবে তৈরি হয়েছে')),
                );
              },
              child: const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSelectedAccountName() {
    if (_selectedMethodType == 'cash') {
      final cashAcc = FinanceService.getAccountsByType('cash', widget.mode);
      _selectedAccountName = cashAcc.isNotEmpty
          ? cashAcc.first.name
          : (widget.mode == 'business' ? 'ক্যাশ বাক্স (Shop Cash)' : 'ক্যাশ (Personal Cash)');
    } else if (_selectedMethodType == 'bank') {
      final banks = FinanceService.getAccountsByType('bank', widget.mode);
      _selectedAccountName = banks.isNotEmpty ? banks.first.name : 'ব্যাংক অ্যাকাউন্ট';
    } else {
      final mfsList = FinanceService.getAccountsByType('mfs', widget.mode);
      _selectedAccountName = mfsList.isNotEmpty ? mfsList.first.name : 'মোবাইল ব্যাংকিং';
    }
  }

  void _submit() {
    final amt = double.tryParse(_amountController.text.trim());
    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সঠিক পরিমাণ টাকা লিখুন')),
      );
      return;
    }

    // 01. PREVENT NEGATIVE BALANCE CHECK
    if (widget.type == 'expense') {
      final available = FinanceService.getAccountBalance(_selectedAccountName, widget.mode);
      if (amt > available) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                SizedBox(width: 8),
                Text('অপর্যাপ্ত ব্যালেন্স!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            content: Text(
              'আপনার "$_selectedAccountName" ফান্ডে ব্যালেন্স আছে মাত্র ৳${available.toStringAsFixed(2)}।\n\nআপনি ৳${amt.toStringAsFixed(2)} খরচ করতে পারবেন না। অ্যাকাউন্টে নেগেটিভ ব্যালেন্সের অনুমতি নেই।',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2942)),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ঠিক আছে', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Confirmation Modal
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.type == 'income' ? 'আয় নিশ্চিত করুন' : 'খরচ নিশ্চিত করুন',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ক্যাটাগরি', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(_selectedCategory, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('পরিমাণ', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '৳ ${amt.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: widget.type == 'income' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('অ্যাকাউন্ট', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 4),
                Text(_selectedAccountName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: const Text('না', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      try {
                        await FinanceService.addTransaction(
                          amount: amt,
                          type: widget.type,
                          mode: widget.mode,
                          category: _selectedCategory,
                          account: _selectedAccountName,
                          date: _selectedDate,
                          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
                          partyName: _partyController.text.trim().isEmpty ? null : _partyController.text.trim(),
                        );
                        widget.onAdded();
                        if (mounted) Navigator.pop(context);
                        _showSuccessReceipt(amt);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F2942),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('হ্যাঁ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessReceipt(double amt) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFF2E7D32), size: 40),
              ),
              const SizedBox(height: 12),
              const Text('সফল', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xFFE2E8F0),
                          child: Icon(Icons.receipt_rounded, size: 20, color: Color(0xFF475569)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedCategory, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('#${DateTime.now().millisecondsSinceEpoch % 1000000}', style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _receiptRow('তারিখ', DateFormat('dd MMM yyyy').format(_selectedDate), 'সময়', DateFormat('hh:mm a').format(DateTime.now())),
                    const SizedBox(height: 8),
                    _receiptRow('ক্যাটাগরি', widget.type == 'income' ? 'Income' : 'Expense', 'টাকা', '৳ ${amt.toStringAsFixed(0)}'),
                    const SizedBox(height: 8),
                    _receiptRow('অ্যাকাউন্ট', _selectedAccountName, 'নোট', _noteController.text.isEmpty ? '--' : _noteController.text),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F2942),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('ঠিক আছে', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String t1, String v1, String t2, String v2) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t1, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              Text(v1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t2, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
              Text(v2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddAccountDialog(String type) {
    final nameCtrl = TextEditingController();
    final noCtrl = TextEditingController();
    final balCtrl = TextEditingController(text: '0');
    String provider = type == 'bank' ? 'DBBL' : 'bKash';
    final providers = type == 'bank' ? ['DBBL', 'Islami Bank', 'City Bank', 'Brac Bank', 'Other Bank'] : ['bKash', 'Nagad', 'Rocket', 'Upay'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(type == 'bank' ? 'নতুন ব্যাংক অ্যাকাউন্ট যোগ' : 'নতুন MFS অ্যাকাউন্ট যোগ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: provider,
                  decoration: const InputDecoration(labelText: 'সার্ভিস প্রোভাইডার'),
                  items: providers.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setD(() => provider = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: type == 'bank' ? 'অ্যাকাউন্টের নাম (যেমন: DBBL - Main)' : 'নাম (যেমন: bKash Personal)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noCtrl,
                  decoration: InputDecoration(
                    labelText: type == 'bank' ? 'অ্যাকাউন্ট নম্বর' : 'মোবাইল নম্বর',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: balCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'ওপেনিং ব্যালেন্স (৳)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                await FinanceService.addAccount(
                  name: nameCtrl.text.trim(),
                  type: type,
                  provider: provider,
                  accountNumber: noCtrl.text.trim(),
                  initialBalance: double.tryParse(balCtrl.text.trim()) ?? 0,
                );
                Navigator.pop(ctx);
                setState(() {
                  _selectedAccountName = nameCtrl.text.trim();
                });
              },
              child: const Text('যোগ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = FinanceService.getAccountBalance(_selectedAccountName, FinanceService.activeMode);

    final bankAccounts = FinanceService.getAccountsByType('bank', FinanceService.activeMode);
    final mfsAccounts = FinanceService.getAccountsByType('mfs', FinanceService.activeMode);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.type == 'income' ? 'আয় যোগ করুন' : 'খরচ যোগ করুন',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Amount field + Date picker badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'পরিমাণ *',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF0284C7)),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM, yyyy').format(_selectedDate),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('৳', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          autofocus: true,
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Live Available Balance display for selected account
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: available > 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        available > 0 ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                        size: 14,
                        color: available > 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'বর্তমান স্থিতি ($_selectedAccountName):',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: available > 0 ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '৳ ${available.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: available > 0 ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ক্যাটাগরি *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                GestureDetector(
                  onTap: _openAddCategoryDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 14, color: Color(0xFF0284C7)),
                        SizedBox(width: 4),
                        Text('নতুন ক্যাটাগরি', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _categories.contains(_selectedCategory) ? _selectedCategory : (_categories.isNotEmpty ? _categories.first : null),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                  items: [
                    ..._categories.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text(c, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      );
                    }),
                    const DropdownMenuItem(
                      value: '__create_new__',
                      child: Row(
                        children: [
                          Icon(Icons.add_rounded, size: 16, color: Color(0xFF0284C7)),
                          SizedBox(width: 6),
                          Text('+ নতুন ক্যাটাগরি তৈরি করুন...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val == '__create_new__') {
                      _openAddCategoryDialog();
                    } else if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Source / Account Pills (ক্যাশ, ব্যাংক, মোবাইল ব্যাংকিং)
            Text(
              widget.type == 'income' ? 'গ্রহণ করুন *' : 'প্রদানকারী ফান্ড *',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _accountSelectPill('cash', 'ক্যাশ'),
                const SizedBox(width: 8),
                _accountSelectPill('bank', 'ব্যাংক'),
                const SizedBox(width: 8),
                _accountSelectPill('mfs', 'মোবাইল ব্যাংকিং'),
              ],
            ),
            const SizedBox(height: 10),

            // Sub-account dropdown if Bank or MFS
            if (_selectedMethodType == 'bank') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ব্যাংক অ্যাকাউন্ট সিলেক্ট করুন:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  GestureDetector(
                    onTap: () => _showAddAccountDialog('bank'),
                    child: const Text('+ নতুন ব্যাংক যোগ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFCBD5E1))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: bankAccounts.any((b) => b.name == _selectedAccountName) ? _selectedAccountName : (bankAccounts.isNotEmpty ? bankAccounts.first.name : null),
                    hint: const Text('ব্যাংক সিলেক্ট করুন'),
                    isExpanded: true,
                    items: bankAccounts.map((b) => DropdownMenuItem(value: b.name, child: Text('${b.name} (৳${FinanceService.getAccountBalance(b.name).toStringAsFixed(0)})'))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedAccountName = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ] else if (_selectedMethodType == 'mfs') ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('MFS অ্যাকাউন্ট সিলেক্ট করুন:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  GestureDetector(
                    onTap: () => _showAddAccountDialog('mfs'),
                    child: const Text('+ নতুন MFS যোগ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFCBD5E1))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: mfsAccounts.any((m) => m.name == _selectedAccountName) ? _selectedAccountName : (mfsAccounts.isNotEmpty ? mfsAccounts.first.name : null),
                    hint: const Text('বিকাশ/নগদ সিলেক্ট করুন'),
                    isExpanded: true,
                    items: mfsAccounts.map((m) => DropdownMenuItem(value: m.name, child: Text('${m.name} (৳${FinanceService.getAccountBalance(m.name).toStringAsFixed(0)})'))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedAccountName = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Note (Optional)
            const Text('নোট (ঐচ্ছিক)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                hintText: 'নোট লিখুন...',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button: জমা দিন
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C2340),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('জমা দিন', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountSelectPill(String id, String label) {
    final selected = _selectedMethodType == id;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMethodType = id;
            _updateSelectedAccountName();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0C2340).withOpacity(0.08) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF0C2340) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: selected ? const Color(0xFF0C2340) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// FUND TRANSFER SHEET (With Negative Balance Check)
// -------------------------------------------------------------
class _TransferSheet extends StatefulWidget {
  final VoidCallback onTransferred;
  const _TransferSheet({required this.onTransferred});

  @override
  State<_TransferSheet> createState() => _TransferSheetState();
}

class _TransferSheetState extends State<_TransferSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late String _from;
  late String _to;

  @override
  void initState() {
    super.initState();
    final accs = FinanceService.currentAccounts;
    _from = accs.isNotEmpty ? accs.first.name : 'ক্যাশ (Cash)';
    _to = accs.length > 1 ? accs[1].name : (accs.isNotEmpty ? accs.first.name : 'DBBL');
  }

  void _transfer() async {
    final amt = double.tryParse(_amountController.text.trim());
    if (amt == null || amt <= 0) return;
    if (_from == _to) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('উৎস এবং গন্তব্য ফান্ড ভিন্ন হতে হবে')));
      return;
    }

    final fromBal = FinanceService.getAccountBalance(_from, FinanceService.activeMode);
    if (amt > fromBal) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('অপর্যাপ্ত ব্যালেন্স!', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('আপনার "$_from" এ ব্যালেন্স আছে মাত্র ৳${fromBal.toStringAsFixed(2)}।\nনেগেটিভ ব্যালেন্সের অনুমতি নেই।'),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('ঠিক আছে')),
          ],
        ),
      );
      return;
    }

    await FinanceService.transferFunds(
      fromAccount: _from,
      toAccount: _to,
      amount: amt,
      note: _noteController.text.trim(),
    );
    widget.onTransferred();
    if (mounted) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ফান্ড সফলভাবে ট্রান্সফার হয়েছে')));
  }

  @override
  Widget build(BuildContext context) {
    final accs = FinanceService.currentAccounts;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ফান্ড ট্রান্সফার (Fund Transfer)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: accs.any((a) => a.name == _from) ? _from : accs.first.name,
            decoration: const InputDecoration(labelText: 'যেখান থেকে পাঠাবেন (From)'),
            items: accs.map((a) {
              final bal = FinanceService.getAccountBalance(a.name);
              return DropdownMenuItem(value: a.name, child: Text('${a.name} (৳${bal.toStringAsFixed(0)})'));
            }).toList(),
            onChanged: (v) => setState(() => _from = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: accs.any((a) => a.name == _to) ? _to : accs.last.name,
            decoration: const InputDecoration(labelText: 'যে ফান্ডে জমা হবে (To)'),
            items: accs.map((a) {
              final bal = FinanceService.getAccountBalance(a.name);
              return DropdownMenuItem(value: a.name, child: Text('${a.name} (৳${bal.toStringAsFixed(0)})'));
            }).toList(),
            onChanged: (v) => setState(() => _to = v!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'পরিমাণ (৳) *', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'নোট (ঐচ্ছিক)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _transfer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F2942),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('ট্রান্সফার সম্পন্ন করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// ACCOUNT MANAGEMENT SHEET (Bank & MFS Management)
// -------------------------------------------------------------
class _AccountManagementSheet extends StatefulWidget {
  final VoidCallback onUpdated;
  const _AccountManagementSheet({required this.onUpdated});

  @override
  State<_AccountManagementSheet> createState() => _AccountManagementSheetState();
}

class _AccountManagementSheetState extends State<_AccountManagementSheet> {
  String _sheetMode = FinanceService.activeMode; // 'personal' or 'business'

  void _openAddModal(String type) {
    final nameCtrl = TextEditingController();
    final noCtrl = TextEditingController();
    final balCtrl = TextEditingController(text: '0');
    String provider = type == 'bank' ? 'DBBL' : 'bKash';
    final providers = type == 'bank' ? ['DBBL', 'Islami Bank', 'City Bank', 'Brac Bank', 'Other Bank'] : ['bKash', 'Nagad', 'Rocket', 'Upay'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(type == 'bank' ? 'নতুন ব্যাংক অ্যাকাউন্ট যোগ' : 'নতুন মোবাইল ব্যাংকিং (MFS) যোগ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _sheetMode == 'business' ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _sheetMode == 'business' ? Icons.storefront_rounded : Icons.person_rounded,
                        size: 16,
                        color: _sheetMode == 'business' ? const Color(0xFF0284C7) : const Color(0xFF475569),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _sheetMode == 'business' ? 'ব্যবসায়িক অ্যাকাউন্ট' : 'ব্যক্তিগত অ্যাকাউন্ট',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _sheetMode == 'business' ? const Color(0xFF0284C7) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: provider,
                  decoration: const InputDecoration(labelText: 'প্রোভাইডার'),
                  items: providers.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setD(() => provider = v!),
                ),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'অ্যাকাউন্টের নাম *')),
                const SizedBox(height: 10),
                TextField(controller: noCtrl, decoration: const InputDecoration(labelText: 'অ্যাকাউন্ট / মোবাইল নম্বর')),
                const SizedBox(height: 10),
                TextField(controller: balCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'প্রারম্ভিক ব্যালেন্স (৳)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                await FinanceService.addAccount(
                  name: nameCtrl.text.trim(),
                  type: type,
                  provider: provider,
                  accountNumber: noCtrl.text.trim(),
                  initialBalance: double.tryParse(balCtrl.text.trim()) ?? 0,
                  mode: _sheetMode,
                );
                Navigator.pop(ctx);
                setState(() {});
                widget.onUpdated();
              },
              child: const Text('সংরক্ষণ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accs = FinanceService.accounts.where((a) => a.mode == _sheetMode).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ফান্ড ও অ্যাকাউন্ট তালিকা', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.account_balance, color: Colors.blue),
                    tooltip: 'ব্যাংক যোগ',
                    onPressed: () => _openAddModal('bank'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone_android, color: Colors.teal),
                    tooltip: 'MFS যোগ',
                    onPressed: () => _openAddModal('mfs'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Tab switcher for Personal vs Business accounts inside sheet
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _sheetMode = 'personal'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _sheetMode == 'personal' ? const Color(0xFF0F2942) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 14, color: _sheetMode == 'personal' ? Colors.white : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'ব্যক্তিগত ফান্ড',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _sheetMode == 'personal' ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _sheetMode = 'business'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _sheetMode == 'business' ? const Color(0xFF0F2942) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront, size: 14, color: _sheetMode == 'business' ? Colors.white : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'ব্যবসায়িক ফান্ড',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _sheetMode == 'business' ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: accs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          _sheetMode == 'personal' ? 'কোনো ব্যক্তিগত ফান্ড যুক্ত নেই' : 'কোনো ব্যবসায়িক ফান্ড যুক্ত নেই',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: accs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final a = accs[index];
                      final bal = FinanceService.getAccountBalance(a.name, a.mode);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: a.type == 'cash'
                              ? Colors.amber.shade100
                              : (a.type == 'bank' ? Colors.blue.shade100 : Colors.teal.shade100),
                          child: Icon(
                            a.type == 'cash'
                                ? Icons.wallet
                                : (a.type == 'bank' ? Icons.account_balance : Icons.phone_android),
                            color: a.type == 'cash'
                                ? Colors.amber.shade800
                                : (a.type == 'bank' ? Colors.blue.shade800 : Colors.teal.shade800),
                            size: 20,
                          ),
                        ),
                        title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          '${a.type.toUpperCase()} • ${a.accountNumber ?? 'Primary'} • ${a.mode == 'business' ? 'ব্যবসা' : 'ব্যক্তিগত'}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        trailing: Text(
                          '৳ ${bal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// BUSINESS NEW SALE (POS Voucher with Products List Below, Discounts, VAT, Delivery & Partial Payment)
// -------------------------------------------------------------
class BusinessNewSaleScreen extends StatefulWidget {
  const BusinessNewSaleScreen({super.key});

  @override
  State<BusinessNewSaleScreen> createState() => _BusinessNewSaleScreenState();
}

class _BusinessNewSaleScreenState extends State<BusinessNewSaleScreen> {
  String? _selectedCustomer;
  String _customerPhone = '01315829868';
  final List<Map<String, dynamic>> _cartItems = [];

  // Discounts, VAT, Delivery Charges
  String _discountType = 'fixed'; // 'fixed' or 'percentage'
  final _discountController = TextEditingController(text: '0');
  final _vatController = TextEditingController(text: '0');
  final _deliveryController = TextEditingController(text: '0');

  // Payment Status: 'paid', 'partial', 'due'
  String _paymentStatus = 'paid'; // 'paid', 'partial', 'due'
  final _paidAmountController = TextEditingController(text: '0');
  String _targetAccount = 'ক্যাশ বাক্স (Shop Cash)';

  // Search product filter
  String _prodSearchQuery = '';

  @override
  void initState() {
    super.initState();
    final bizAccounts = FinanceService.accounts.where((a) => a.mode == 'business').toList();
    if (bizAccounts.isNotEmpty) {
      _targetAccount = bizAccounts.first.name;
    }
    final parties = FinanceService.parties.where((p) => p.type == 'customer').toList();
    if (parties.isNotEmpty) {
      _selectedCustomer = parties.first.name;
      _customerPhone = parties.first.phone;
    }
  }

  void _addProductToCart(BusinessProduct p) {
    setState(() {
      final idx = _cartItems.indexWhere((it) => it['name'] == p.name);
      if (idx != -1) {
        _cartItems[idx]['qty'] = (_cartItems[idx]['qty'] as int) + 1;
      } else {
        _cartItems.add({
          'name': p.name,
          'qty': 1,
          'price': p.sellPrice,
          'unit': p.unit,
        });
      }
    });
  }

  void _removeProductFromCart(String name) {
    setState(() {
      final idx = _cartItems.indexWhere((it) => it['name'] == name);
      if (idx != -1) {
        if ((_cartItems[idx]['qty'] as int) > 1) {
          _cartItems[idx]['qty'] = (_cartItems[idx]['qty'] as int) - 1;
        } else {
          _cartItems.removeAt(idx);
        }
      }
    });
  }

  void _openAddCustomerModal() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addrCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন কাস্টমার যোগ করুন'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'কাস্টমারের নাম *')),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর *')),
              const SizedBox(height: 8),
              TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'ঠিকানা (ঐচ্ছিক)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
              final p = await FinanceService.addParty(
                type: 'customer',
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                address: addrCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              setState(() {
                _selectedCustomer = p.name;
                _customerPhone = p.phone;
              });
            },
            child: const Text('সংরক্ষণ'),
          ),
        ],
      ),
    );
  }

  void _openContactBookPicker() {
    // Simulated contact book quick picks
    final sampleContacts = [
      {'name': 'সাকিব আল হাসান', 'phone': '01711223344'},
      {'name': 'আরিফুল ইসলাম', 'phone': '01922334455'},
      {'name': 'নাজমুল হোসেন', 'phone': '01833445566'},
      {'name': 'ফারুক হোসেন', 'phone': '01644556677'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📱 ফোনবুক / কন্টাক্ট থেকে নির্বাচন করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...sampleContacts.map((c) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(c['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(c['phone']!),
              onTap: () async {
                final p = await FinanceService.addParty(
                  type: 'customer',
                  name: c['name']!,
                  phone: c['phone']!,
                  address: 'Dhaka',
                );
                Navigator.pop(ctx);
                setState(() {
                  _selectedCustomer = p.name;
                  _customerPhone = p.phone;
                });
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parties = FinanceService.parties.where((p) => p.type == 'customer').toList();
    final allProducts = FinanceService.products;
    final filteredProducts = allProducts.where((p) {
      return p.name.toLowerCase().contains(_prodSearchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_prodSearchQuery.toLowerCase());
    }).toList();

    // Calculations
    double subtotal = 0;
    for (var it in _cartItems) {
      subtotal += (it['price'] as double) * (it['qty'] as int);
    }

    final rawDiscount = double.tryParse(_discountController.text.trim()) ?? 0;
    final discountAmount = _discountType == 'percentage'
        ? (subtotal * rawDiscount / 100)
        : rawDiscount;

    final vat = double.tryParse(_vatController.text.trim()) ?? 0;
    final delivery = double.tryParse(_deliveryController.text.trim()) ?? 0;
    final total = ((subtotal - discountAmount) + vat + delivery).clamp(0.0, 9999999.0);

    double paid = 0;
    double due = 0;
    if (_paymentStatus == 'paid') {
      paid = total;
      due = 0;
    } else if (_paymentStatus == 'due') {
      paid = 0;
      due = total;
    } else {
      paid = double.tryParse(_paidAmountController.text.trim()) ?? 0;
      if (paid > total) paid = total;
      due = total - paid;
    }

    final accs = FinanceService.accounts.where((a) => a.mode == 'business').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('নতুন বিক্রয় (POS Counter)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'কাস্টমার যোগ',
            onPressed: _openAddCustomerModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Section: Customer & Cart Invoice Summary (Scrollable)
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Customer Selection Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('কাস্টমার নির্বাচন করুন *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _openContactBookPicker,
                                  child: const Text('📱 ফোনবুক', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: _openAddCustomerModal,
                                  child: const Text('+ ম্যানুয়াল', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: parties.any((p) => p.name == _selectedCustomer) ? _selectedCustomer : (parties.isNotEmpty ? parties.first.name : null),
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder()),
                          items: parties.map((p) => DropdownMenuItem(value: p.name, child: Text('${p.name} • ${p.phone}'))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final pt = parties.firstWhere((p) => p.name == val);
                              setState(() {
                                _selectedCustomer = pt.name;
                                _customerPhone = pt.phone;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Cart Items
                  if (_cartItems.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('সিলেক্টেড আইটেমসমূহ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${_cartItems.length} টি পণ্য', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          const Divider(height: 16),
                          ..._cartItems.map((it) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(it['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      Text('৳${it['price']} / ${it['unit'] ?? 'item'}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                                      onPressed: () => _removeProductFromCart(it['name']),
                                    ),
                                    Text('${it['qty']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
                                      onPressed: () {
                                        final prod = allProducts.firstWhere((p) => p.name == it['name']);
                                        _addProductToCart(prod);
                                      },
                                    ),
                                    Text('৳${(it['price'] * it['qty']).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Discount, VAT & Delivery Charges
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('সমন্বয় ও চার্জসমূহ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          // Discount
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(value: 'fixed', label: Text('৳')),
                                    ButtonSegment(value: 'percentage', label: Text('%')),
                                  ],
                                  selected: {_discountType},
                                  onSelectionChanged: (s) => setState(() => _discountType = s.first),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: _discountController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(labelText: 'ছাড় (Discount)', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _vatController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(labelText: 'ভ্যাট (VAT ৳)', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder()),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _deliveryController,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  decoration: const InputDecoration(labelText: 'ডেলিভারি চার্জ (৳)', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), border: OutlineInputBorder()),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. Payment Status (Full vs Partial vs Due)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('পেমেন্ট ও পরিশোধের ধরন *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(child: Text('পরিশোধিত')),
                                  selected: _paymentStatus == 'paid',
                                  onSelected: (s) => setState(() => _paymentStatus = 'paid'),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(child: Text('আংশিক')),
                                  selected: _paymentStatus == 'partial',
                                  onSelected: (s) => setState(() => _paymentStatus = 'partial'),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Center(child: Text('বাকি (Due)')),
                                  selected: _paymentStatus == 'due',
                                  onSelected: (s) => setState(() => _paymentStatus = 'due'),
                                ),
                              ),
                            ],
                          ),
                          if (_paymentStatus == 'partial') ...[
                            const SizedBox(height: 10),
                            TextField(
                              controller: _paidAmountController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(labelText: 'পরিশোধিত টাকা (Paid Amount) *', border: OutlineInputBorder()),
                            ),
                          ],
                          if (_paymentStatus != 'due') ...[
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: accs.any((a) => a.name == _targetAccount) ? _targetAccount : accs.first.name,
                              decoration: const InputDecoration(labelText: 'যে ফান্ডে টাকা জমা হবে'),
                              items: accs.map((a) => DropdownMenuItem(value: a.name, child: Text(a.name))).toList(),
                              onChanged: (v) => setState(() => _targetAccount = v!),
                            ),
                          ],
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('পরিশোধিত:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
                              Text('৳ ${paid.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.green)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('বকেয়া / বাকি:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red)),
                              Text('৳ ${due.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.red)),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('সর্বমোট বিল:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              Text('৳ ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0284C7))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Button
                    ElevatedButton(
                      onPressed: () async {
                        if (_selectedCustomer == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কাস্টমার নির্বাচন করুন')));
                          return;
                        }
                        await FinanceService.addSaleInvoice(
                          customerName: _selectedCustomer!,
                          customerPhone: _customerPhone,
                          items: _cartItems,
                          subtotal: subtotal,
                          vat: vat,
                          delivery: delivery,
                          discount: discountAmount,
                          discountType: _discountType,
                          discountValue: rawDiscount,
                          total: total,
                          paidAmount: paid,
                          dueAmount: due,
                          paymentMethod: _paymentStatus == 'due' ? 'Credit' : (_paymentStatus == 'partial' ? 'Partial' : 'Cash'),
                          paymentStatus: _paymentStatus,
                          targetAccount: _targetAccount,
                        );
                        if (mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বিক্রয় ভাউচার সফলভাবে তৈরি হয়েছে!')));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C2340), minimumSize: const Size(double.infinity, 50)),
                      child: const Text('কনফার্ম ও ভাউচার প্রিন্ট করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 03. PRODUCT LIST DIRECTLY BELOW ON POS PAGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_rounded, size: 18, color: Color(0xFF0284C7)),
                const SizedBox(width: 8),
                const Text('পণ্য তালিকা (ট্যাপ করে যোগ করুন)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                const Spacer(),
                SizedBox(
                  width: 140,
                  height: 34,
                  child: TextField(
                    onChanged: (v) => setState(() => _prodSearchQuery = v),
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'পণ্য খুঁজুন...',
                      prefixIcon: const Icon(Icons.search, size: 14),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Product List View
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: filteredProducts.isEmpty
                  ? const Center(child: Text('কোনো পণ্য পাওয়া যায়নি', style: TextStyle(fontSize: 12, color: Colors.grey)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredProducts.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = filteredProducts[index];
                        final inCart = _cartItems.firstWhere((it) => it['name'] == p.name, orElse: () => {});
                        final qtyInCart = inCart.isNotEmpty ? (inCart['qty'] as int) : 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.shopping_bag_outlined, size: 18, color: Color(0xFF0F172A)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('স্টক: ${p.stock.toStringAsFixed(0)} ${p.unit} • ৳${p.sellPrice}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              if (qtyInCart > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                                  child: Text('$qtyInCart টি', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                              ElevatedButton(
                                onPressed: () => _addProductToCart(p),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F2942),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.add, size: 14, color: Colors.white),
                                    SizedBox(width: 2),
                                    Text('যোগ', style: TextStyle(color: Colors.white, fontSize: 11)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// DENA-PAWNA SCREEN (Customer & Supplier Due Ledger with Single View Navigation)
// -------------------------------------------------------------
class DenaPawnaScreen extends StatefulWidget {
  const DenaPawnaScreen({super.key});

  @override
  State<DenaPawnaScreen> createState() => _DenaPawnaScreenState();
}

class _DenaPawnaScreenState extends State<DenaPawnaScreen> {
  @override
  Widget build(BuildContext context) {
    final receivable = FinanceService.totalReceivable;
    final payable = FinanceService.totalPayable;
    final net = receivable - payable;
    final parties = FinanceService.parties;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('দেনা / পাওনা খাতা'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => _openAddPartyDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 3 Metric Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('আমি পাবো', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('৳${receivable.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('মোট দিবো', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('৳${payable.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.red)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('নেট ব্যালেন্স', style: TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('৳${net.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Parties List (Tap customer to open Single Customer Ledger View)
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: parties.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final p = parties[index];
                final isCustomer = p.type == 'customer';
                return GestureDetector(
                  onTap: () {
                    if (isCustomer) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerLedgerDetailScreen(customer: p),
                        ),
                      ).then((_) => setState(() {}));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isCustomer ? const Color(0xFFE0F2FE) : const Color(0xFFFFEBEE),
                          child: Icon(isCustomer ? Icons.person : Icons.local_shipping, color: isCustomer ? const Color(0xFF0284C7) : Colors.red),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('${p.phone} • ${isCustomer ? 'কাস্টমার (লেজার দেখতে ট্যাপ করুন)' : 'সাপ্লায়ার'}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '৳ ${p.dueBalance.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: isCustomer ? Colors.red : Colors.green,
                              ),
                            ),
                            Text(
                              isCustomer ? 'পাবো (Due)' : 'দিবো',
                              style: TextStyle(fontSize: 11, color: isCustomer ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (isCustomer) const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openAddPartyDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String type = 'customer';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setMState) => Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type == 'customer' ? 'কাস্টমার যোগ করুন' : 'সরবরাহকারী যোগ করুন', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('কাস্টমার'),
                    selected: type == 'customer',
                    onSelected: (s) => setMState(() => type = 'customer'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('সরবরাহকারী (সাপ্লায়ার)'),
                    selected: type == 'supplier',
                    onSelected: (s) => setMState(() => type = 'supplier'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'নাম *', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল নম্বর *', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'ঠিকানা', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                  await FinanceService.addParty(
                    type: type,
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    address: addressCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2942), minimumSize: const Size(double.infinity, 48)),
                child: const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 06. SINGLE CUSTOMER LEDGER VIEW (কাস্টমার লেজার বিস্তারিত)
// -------------------------------------------------------------
class CustomerLedgerDetailScreen extends StatefulWidget {
  final BusinessParty customer;
  const CustomerLedgerDetailScreen({super.key, required this.customer});

  @override
  State<CustomerLedgerDetailScreen> createState() => _CustomerLedgerDetailScreenState();
}

class _CustomerLedgerDetailScreenState extends State<CustomerLedgerDetailScreen> {
  void _openCollectDueDialog() {
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final accs = FinanceService.accounts.where((a) => a.mode == 'business').toList();
    String targetAcc = accs.isNotEmpty ? accs.first.name : 'ক্যাশ বাক্স (Shop Cash)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('বাকি টাকা আদায় (${widget.customer.name})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'আদায়কৃত টাকা (৳) *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: accs.any((a) => a.name == targetAcc) ? targetAcc : accs.first.name,
                decoration: const InputDecoration(labelText: 'যে ফান্ডে টাকা জমা হবে'),
                items: accs.map((a) => DropdownMenuItem(value: a.name, child: Text(a.name))).toList(),
                onChanged: (v) => setM(() => targetAcc = v!),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'নোট (ঐচ্ছিক)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
                  if (amt <= 0) return;
                  await FinanceService.collectCustomerDue(
                    customerName: widget.customer.name,
                    amount: amt,
                    targetAccount: targetAcc,
                    note: noteCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বাকি টাকা সফলভাবে আদায় করা হয়েছে')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2942), minimumSize: const Size(double.infinity, 48)),
                child: const Text('আদায় কনফার্ম করুন', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerInvoices = FinanceService.getCustomerInvoices(widget.customer.name);
    final totalBuy = FinanceService.getCustomerTotalBuy(widget.customer.name);
    final totalPaid = FinanceService.getCustomerTotalPaid(widget.customer.name);
    final currentDue = FinanceService.getCustomerCurrentDue(widget.customer.name);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.customer.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.customer.phone, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('লেজার পিডিএফ তৈরি হয়েছে')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFE0F2FE),
                    child: Icon(Icons.person, color: Color(0xFF0284C7), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.customer.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('ফোন: ${widget.customer.phone}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        if (widget.customer.address != null)
                          Text('ঠিকানা: ${widget.customer.address}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _openCollectDueDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('বাকি আদায়', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3 Core Metric Cards: Total Buy, Total Paid, Due Amount
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('মোট ক্রয় (Buy)', style: TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('৳${totalBuy.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0284C7))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('পরিশোধিত (Paid)', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('৳${totalPaid.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(14)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('বর্তমান বাকি (Due)', style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('৳${currentDue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transaction History Header
            const Text('লেনদেন ও ইনভয়েস ইতিহাস', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),

            if (customerInvoices.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: const Center(
                  child: Text('এই কাস্টমারের কোনো ইনভয়েস নেই', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: customerInvoices.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final inv = customerInvoices[index];
                  final isDue = inv.dueAmount > 0;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(inv.invoiceNo, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0284C7))),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDue ? Colors.red.shade50 : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    inv.paymentStatus.toUpperCase(),
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDue ? Colors.red : Colors.green),
                                  ),
                                ),
                              ],
                            ),
                            Text(DateFormat('dd MMM yyyy, hh:mm a').format(inv.date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                        const Divider(height: 16),
                        ...inv.items.map((it) => Text('• ${it['name']} (x${it['qty']}) - ৳${it['price']}', style: const TextStyle(fontSize: 12, color: Color(0xFF334155)))),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('মোট: ৳${inv.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('জমা: ৳${inv.paidAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('বাকি: ৳${inv.dueAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// CASH BOOK SCREEN
// -------------------------------------------------------------
class CashBookScreen extends StatefulWidget {
  const CashBookScreen({super.key});

  @override
  State<CashBookScreen> createState() => _CashBookScreenState();
}

class _CashBookScreenState extends State<CashBookScreen> {
  final DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  final DateTime _endDate = DateTime.now();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final txs = FinanceService.currentTransactions.where((t) {
      final matchesSearch = t.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.partyName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesSearch;
    }).toList();

    final currentCash = FinanceService.cashBalance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ক্যাশ বুক', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text(
              '${DateFormat('dd MMM').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'বর্তমান ক্যাশ ব্যালেন্স',
                  style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '৳ ${currentCash.toStringAsFixed(0)}',
                  style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w800, fontSize: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'খুঁজুন...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFE2E8F0),
            child: const Row(
              children: [
                SizedBox(width: 24, child: Text('#', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('তারিখ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text('বিবরণ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('টাকা', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text('ধরন', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: txs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tx = txs[index];
                final isInc = tx.type == 'income';
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 24, child: Text('${index + 1}', style: const TextStyle(fontSize: 11, color: Colors.grey))),
                      Expanded(flex: 2, child: Text(DateFormat('dd-MM-yy').format(tx.date), style: const TextStyle(fontSize: 11))),
                      Expanded(
                        flex: 3,
                        child: Text(
                          tx.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('৳${tx.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          isInc ? 'INCOME' : 'EXPENSE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isInc ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// FINANCIAL STATEMENT SCREEN
// -------------------------------------------------------------
class FinancialStatementScreen extends StatelessWidget {
  const FinancialStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inc = FinanceService.monthlyIncome;
    final exp = FinanceService.monthlyExpense;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('আর্থিক বিবরণী')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      children: [
                        const Row(children: [Icon(Icons.arrow_upward, color: Colors.green, size: 14), Text(' আয়', style: TextStyle(fontSize: 11))]),
                        const SizedBox(height: 6),
                        Text('৳${inc.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      children: [
                        const Row(children: [Icon(Icons.arrow_downward, color: Colors.red, size: 14), Text(' ব্যয়', style: TextStyle(fontSize: 11))]),
                        const SizedBox(height: 6),
                        Text('৳${exp.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: Column(
                      children: [
                        const Row(children: [Icon(Icons.sync_alt, color: Colors.blue, size: 14), Text(' স্থিতি', style: TextStyle(fontSize: 11))]),
                        const SizedBox(height: 6),
                        Text('৳${(inc - exp).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('আয় বনাম ব্যয়', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: 120,
                            decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(6)),
                          ),
                          const SizedBox(height: 8),
                          const Text('Income', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: 32,
                            height: (120 * (exp / (inc > 0 ? inc : 1))).clamp(20.0, 120.0),
                            decoration: BoxDecoration(color: const Color(0xFFC62828), borderRadius: BorderRadius.circular(6)),
                          ),
                          const SizedBox(height: 8),
                          const Text('Expense', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// BUSINESS INVENTORY & PRODUCTS SCREEN
// -------------------------------------------------------------
class BusinessInventoryScreen extends StatefulWidget {
  const BusinessInventoryScreen({super.key});

  @override
  State<BusinessInventoryScreen> createState() => _BusinessInventoryScreenState();
}

class _BusinessInventoryScreenState extends State<BusinessInventoryScreen> {
  @override
  Widget build(BuildContext context) {
    final prods = FinanceService.products;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('পণ্য ও স্টক ইনভেন্টরি'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded),
            onPressed: () => _openAddProductSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Text('${prods.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                        const Text('মোট পণ্য', style: TextStyle(fontSize: 11, color: Color(0xFF0284C7))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                        Text('লো স্টক', style: TextStyle(fontSize: 11, color: Color(0xFFD97706))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(12)),
                    child: const Column(
                      children: [
                        Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFEF4444))),
                        Text('স্টক শেষ', style: TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: prods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final p = prods[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('${p.category} • প্যাক সাইজ: ${p.unit}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('স্টক: ${p.stock.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('৳${p.sellPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF10B981))),
                          Text('ক্রয়: ৳${p.buyPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openAddProductSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final buyCtrl = TextEditingController();
    final sellCtrl = TextEditingController();
    String unit = 'PCS';
    final units = ['PCS', 'Dozen', 'Set', 'Pair', 'Box', 'Pack', 'KG', 'Gram', 'Ltr'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('নতুন পণ্য যোগ করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'পণ্যের নাম *', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: unit,
                      decoration: const InputDecoration(labelText: 'ইউনিট *', border: OutlineInputBorder()),
                      items: units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setS(() => unit = v!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'স্টক *', border: OutlineInputBorder())),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TextField(controller: buyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'ক্রয় মূল্য *', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: sellCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'বিক্রয় মূল্য *', border: OutlineInputBorder()))),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;
                  await FinanceService.addProduct(
                    name: nameCtrl.text.trim(),
                    category: 'General',
                    unit: unit,
                    stock: double.tryParse(stockCtrl.text.trim()) ?? 0,
                    buyPrice: double.tryParse(buyCtrl.text.trim()) ?? 0,
                    sellPrice: double.tryParse(sellCtrl.text.trim()) ?? 0,
                  );
                  Navigator.pop(ctx);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2942), minimumSize: const Size(double.infinity, 48)),
                child: const Text('পণ্য সংরক্ষণ করুন', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// FREE SUBSCRIPTION PLANS SHEET
// -------------------------------------------------------------
class FreeSubscriptionSheet extends StatelessWidget {
  const FreeSubscriptionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {'icon': Icons.point_of_sale, 'name': 'বিক্রয় ব্যবস্থাপনা (Sales POS)', 'status': 'হ্যাঁ (ফ্রি)'},
      {'icon': Icons.shopping_bag, 'name': 'ক্রয় ব্যবস্থাপনা (Purchase)', 'status': 'হ্যাঁ (ফ্রি)'},
      {'icon': Icons.inventory_2, 'name': 'স্টক/ইনভেন্টরি ব্যবস্থাপনা', 'status': 'হ্যাঁ (ফ্রি)'},
      {'icon': Icons.people, 'name': 'মানবসম্পদ (এইচআর) ও স্টাফ খাতা', 'status': 'Unlimited'},
      {'icon': Icons.payments, 'name': 'বেতন (পেরোল) ব্যবস্থাপনা', 'status': 'হ্যাঁ (ফ্রি)'},
      {'icon': Icons.event_available, 'name': 'ছুটি ও হাজিরা ট্র্যাকার', 'status': 'হ্যাঁ (ফ্রি)'},
      {'icon': Icons.account_balance, 'name': 'হিসাব ও আর্থিক ব্যবস্থাপনা', 'status': 'হ্যাঁ (ফ্রি)'},
      {'icon': Icons.receipt, 'name': 'বিক্রয় আদায় ও কাস্টমার খাতা', 'status': 'হ্যাঁ (ফ্রি)'},
      {'icon': Icons.picture_as_pdf, 'name': 'পিডিএফ ও এক্সেল রিপোর্ট', 'status': 'হ্যাঁ (ফ্রি)'},
      {'icon': Icons.account_balance_wallet, 'name': 'ব্যাংক ও ক্যাশ বুক রিপোর্ট', 'status': 'হ্যাঁ (ফ্রি)'},
      {'icon': Icons.replay, 'name': 'বিক্রয় ফেরত (Sales Return)', 'status': 'হ্যাঁ (ফ্রি)'},
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'বিজনেস ও পার্সোনাল প্ল্যান',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              Icon(Icons.info_outline, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F2942), Color(0xFF0284C7)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.verified, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('সম্পূর্ণ ফ্রি প্ল্যান (সক্রিয়)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 4),
                      Text('আজীবন সকল মডিউল উন্মুক্ত • কোনো পেমেন্ট লাগবে না', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                const Text('৳ 0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('প্ল্যানের সুবিধাসমূহ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: modules.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final m = modules[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Icon(m['icon'] as IconData, size: 18, color: const Color(0xFF0284C7)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(m['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          m['status'] as String,
                          style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C2340),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('ধন্যবাদ (ফ্রি এক্সেস সক্রিয়)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// CATEGORY MANAGEMENT SHEET (View, Filter & Create Custom Categories)
// -------------------------------------------------------------
class _CategoryManagementSheet extends StatefulWidget {
  final String mode; // 'personal' or 'business'
  final VoidCallback onUpdated;
  const _CategoryManagementSheet({required this.mode, required this.onUpdated});

  @override
  State<_CategoryManagementSheet> createState() => _CategoryManagementSheetState();
}

class _CategoryManagementSheetState extends State<_CategoryManagementSheet> {
  late String _currentMode;
  String _currentType = 'expense'; // 'expense' or 'income'

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
  }

  void _openAddCategoryModal() {
    final nameCtrl = TextEditingController();
    int selectedColorIdx = 0;
    int selectedIconIdx = 0;

    final colorList = [
      const Color(0xFF10B981),
      const Color(0xFF0284C7),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFF64748B),
    ];

    final iconList = [
      Icons.category_rounded,
      Icons.restaurant_rounded,
      Icons.shopping_cart_rounded,
      Icons.directions_car_rounded,
      Icons.local_hospital_rounded,
      Icons.school_rounded,
      Icons.receipt_rounded,
      Icons.work_rounded,
      Icons.sports_esports_rounded,
      Icons.fitness_center_rounded,
      Icons.local_cafe_rounded,
      Icons.flight_rounded,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorList[selectedColorIdx].withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconList[selectedIconIdx], color: colorList[selectedColorIdx], size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                'নতুন ${_currentType == 'expense' ? 'ব্যয়' : 'আয়'} ক্যাটাগরি',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _currentMode == 'business' ? const Color(0xFFE0F2FE) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _currentMode == 'business' ? Icons.storefront_rounded : Icons.person_rounded,
                        size: 16,
                        color: _currentMode == 'business' ? const Color(0xFF0284C7) : const Color(0xFF475569),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _currentMode == 'business' ? 'ব্যবসায়িক মোড' : 'ব্যক্তিগত মোড',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _currentMode == 'business' ? const Color(0xFF0284C7) : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'ক্যাটাগরির নাম *',
                    hintText: 'যেমন: জিম, চা-নাস্তা, অফিস খরচ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('রং পছন্দ করুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(colorList.length, (i) {
                    final isSel = selectedColorIdx == i;
                    return GestureDetector(
                      onTap: () => setD(() => selectedColorIdx = i),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colorList[i],
                          shape: BoxShape.circle,
                          border: isSel ? Border.all(color: Colors.black, width: 2.5) : null,
                        ),
                        child: isSel ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                const Text('আইকন পছন্দ করুন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(iconList.length, (i) {
                    final isSel = selectedIconIdx == i;
                    return GestureDetector(
                      onTap: () => setD(() => selectedIconIdx = i),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? colorList[selectedColorIdx].withOpacity(0.2) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: isSel ? Border.all(color: colorList[selectedColorIdx], width: 1.5) : null,
                        ),
                        child: Icon(iconList[i], size: 18, color: isSel ? colorList[selectedColorIdx] : Colors.grey.shade700),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2942),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                await FinanceService.addCustomCategory(
                  name: name,
                  type: _currentType,
                  mode: _currentMode,
                  icon: 'icon_$selectedIconIdx',
                  color: '#${colorList[selectedColorIdx].value.toRadixString(16).substring(2)}',
                );

                Navigator.pop(ctx);
                setState(() {});
                widget.onUpdated();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ক্যাটাগরি "$name" সফলভাবে তৈরি হয়েছে')),
                );
              },
              child: const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = FinanceService.getCategories(_currentType, _currentMode);
    final customList = FinanceService.customCategories.where((c) => c.type == _currentType && c.mode == _currentMode).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ক্যাটাগরি তালিকা', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('নতুন ক্যাটাগরি', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: _openAddCategoryModal,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Personal vs Business switcher inside sheet
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentMode = 'personal'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _currentMode == 'personal' ? const Color(0xFF0F2942) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 14, color: _currentMode == 'personal' ? Colors.white : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'ব্যক্তিগত ক্যাটাগরি',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _currentMode == 'personal' ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentMode = 'business'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _currentMode == 'business' ? const Color(0xFF0F2942) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront, size: 14, color: _currentMode == 'business' ? Colors.white : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'ব্যবসায়িক ক্যাটাগরি',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _currentMode == 'business' ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Expense vs Income toggle
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_downward_rounded, size: 14, color: _currentType == 'expense' ? Colors.white : const Color(0xFFEF4444)),
                        const SizedBox(width: 4),
                        Text('ব্যয় (${categories.length})', style: TextStyle(fontWeight: FontWeight.bold, color: _currentType == 'expense' ? Colors.white : const Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  selected: _currentType == 'expense',
                  selectedColor: const Color(0xFFEF4444),
                  backgroundColor: const Color(0xFFFEF2F2),
                  onSelected: (sel) => setState(() => _currentType = 'expense'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_upward_rounded, size: 14, color: _currentType == 'income' ? Colors.white : const Color(0xFF10B981)),
                        const SizedBox(width: 4),
                        Text('আয় (${FinanceService.getCategories('income', _currentMode).length})', style: TextStyle(fontWeight: FontWeight.bold, color: _currentType == 'income' ? Colors.white : const Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  selected: _currentType == 'income',
                  selectedColor: const Color(0xFF10B981),
                  backgroundColor: const Color(0xFFECFDF5),
                  onSelected: (sel) => setState(() => _currentType = 'income'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final catName = categories[index];
                final isCustom = customList.any((c) => c.name == catName);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: CircleAvatar(
                    backgroundColor: _currentType == 'expense' ? const Color(0xFFFEE2E2) : const Color(0xFFD1FAE5),
                    child: Icon(
                      _currentType == 'expense' ? Icons.receipt_outlined : Icons.monetization_on_outlined,
                      color: _currentType == 'expense' ? const Color(0xFFDC2626) : const Color(0xFF059669),
                      size: 20,
                    ),
                  ),
                  title: Text(catName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                  trailing: isCustom
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('কাস্টম', style: TextStyle(color: Color(0xFF0284C7), fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                              tooltip: 'মুছে ফেলুন',
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              onPressed: () async {
                                final cat = customList.firstWhere((c) => c.name == catName);
                                await FinanceService.deleteCustomCategory(cat.id);
                                widget.onUpdated();
                                setState(() {});
                              },
                            ),
                          ],
                        )
                      : const Text('ডিফল্ট', style: TextStyle(color: Colors.grey, fontSize: 11)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/finance_service.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPassController = TextEditingController();

  // Register controllers (ONLY EMAIL + PASSWORD as requested)
  final _regEmailController = TextEditingController();
  final _regPassController = TextEditingController();
  final _regConfirmPassController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscureLoginPass = true;
  bool _obscureRegPass = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPassController.dispose();
    _regEmailController.dispose();
    _regPassController.dispose();
    _regConfirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final pass = _loginPassController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = 'দয়া করে ইমেইল ও পাসওয়ার্ড প্রদান করুন');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await ApiService.login(email, pass);
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      await FinanceService.init();
      if (!mounted) return;
      _goToDashboard();
    } else {
      setState(() => _errorMessage = res['message'] ?? 'লগইন ব্যর্থ হয়েছে। তথ্য যাচাই করুন।');
    }
  }

  Future<void> _handleRegister() async {
    final email = _regEmailController.text.trim();
    final pass = _regPassController.text.trim();
    final confirmPass = _regConfirmPassController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'দয়া করে আপনার ইমেইল এড্রেস লিখুন');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = 'সঠিক ফরম্যাটের ইমেইল এড্রেস লিখুন (যেমন: user@example.com)');
      return;
    }

    if (pass.isEmpty) {
      setState(() => _errorMessage = 'পাসওয়ার্ড প্রদান করুন');
      return;
    }

    if (pass.length < 4) {
      setState(() => _errorMessage = 'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে');
      return;
    }

    if (pass != confirmPass) {
      setState(() => _errorMessage = 'পাসওয়ার্ড এবং কনফার্ম পাসওয়ার্ড মিলছে না');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await ApiService.register(
      email: email,
      password: pass,
      name: email.split('@')[0],
    );
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      await FinanceService.init();
      if (!mounted) return;
      _goToDashboard();
    } else {
      setState(() => _errorMessage = res['message'] ?? 'রেজিস্ট্রেশন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।');
    }
  }

  void _showForgotPasswordSheet() {
    final emailCtrl = TextEditingController(text: _loginEmailController.text.trim());
    final codeCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    bool isSubmitting = false;
    int step = 1; // 1 = enter email, 2 = enter code & new pass
    String? sheetError;
    String? hintCode;
    bool obscureNewPass = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lock_reset_rounded, color: AppColors.primaryDark, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'পাসওয়ার্ড পুনরুদ্ধার (Reset Password)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            step == 1
                                ? 'আপনার নিবন্ধিত ইমেইল এড্রেস প্রদান করুন'
                                : 'প্রাপ্ত কোড ও নতুন পাসওয়ার্ড লিখুন',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (sheetError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      sheetError!,
                      style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                if (step == 1) ...[
                  const Text('ইমেইল এড্রেস', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'name@example.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final email = emailCtrl.text.trim();
                            if (email.isEmpty) {
                              setSheetState(() => sheetError = 'দয়া করে ইমেইল এড্রেস লিখুন');
                              return;
                            }
                            setSheetState(() {
                              isSubmitting = true;
                              sheetError = null;
                            });

                            final res = await ApiService.forgotPassword(email);
                            setSheetState(() => isSubmitting = false);

                            if (res['success'] == true) {
                              setSheetState(() {
                                step = 2;
                                hintCode = res['code']?.toString();
                                if (hintCode != null) {
                                  codeCtrl.text = hintCode!;
                                }
                              });
                            } else {
                              setSheetState(() => sheetError = res['message'] ?? 'তথ্য পাওয়া যায়নি');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('রিসেট কোড পাঠান', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  if (hintCode != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ভেরিফিকেশন কোড: $hintCode',
                              style: const TextStyle(color: Color(0xFF047857), fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Text('৬-ডিজিট কোড (OTP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: codeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'রিসেট কোড লিখুন',
                      prefixIcon: Icon(Icons.pin_outlined, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('নতুন পাসওয়ার্ড (New Password)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: obscureNewPass,
                    decoration: InputDecoration(
                      hintText: 'কমপক্ষে ৪ অক্ষরের পাসওয়ার্ড',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNewPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () => setSheetState(() => obscureNewPass = !obscureNewPass),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final code = codeCtrl.text.trim();
                            final newPass = newPassCtrl.text.trim();
                            if (code.isEmpty || newPass.isEmpty) {
                              setSheetState(() => sheetError = 'কোড ও নতুন পাসওয়ার্ড লিখুন');
                              return;
                            }
                            if (newPass.length < 4) {
                              setSheetState(() => sheetError = 'পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে');
                              return;
                            }
                            setSheetState(() {
                              isSubmitting = true;
                              sheetError = null;
                            });

                            final res = await ApiService.resetPassword(
                              identifier: emailCtrl.text.trim(),
                              code: code,
                              newPassword: newPass,
                            );
                            setSheetState(() => isSubmitting = false);

                            if (res['success'] == true) {
                              Navigator.pop(ctx);
                              _loginEmailController.text = emailCtrl.text.trim();
                              _loginPassController.text = newPass;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.primary,
                                  content: Text('পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে! এখন লগইন করুন।'),
                                ),
                              );
                            } else {
                              setSheetState(() => sheetError = res['message'] ?? 'পাসওয়ার্ড রিসেট ব্যর্থ হয়েছে');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('পাসওয়ার্ড পরিবর্তন ও সংরক্ষণ করুন', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'প্রবেশ করুন • প্রিয় ডিল',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 88,
                    height: 88,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Priyo Deal (প্রিয় ডিল)',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text(
                  'ডাক্তার সিরিয়াল, শপিং ও আপনার নিজস্ব হিসাব খাতা',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tab Selector
              Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  tabs: const [
                    Tab(
                      child: Text(
                        'লগইন (Sign In)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Tab(
                      child: Text(
                        'রেজিস্ট্রেশন (Sign Up)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                height: 400,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Login Form
                    _buildLoginTab(),
                    // Tab 2: Register Form (Email Only)
                    _buildRegisterTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text(
          'আপনার ইমেইল এড্রেস',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'example@email.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'পাসওয়ার্ড',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _loginPassController,
          obscureText: _obscureLoginPass,
          decoration: InputDecoration(
            hintText: 'আপনার গোপন পাসওয়ার্ড',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textMuted,
              ),
              onPressed: () => setState(() => _obscureLoginPass = !_obscureLoginPass),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showForgotPasswordSheet,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'পাসওয়ার্ড ভুলে গেছেন? (Forgot Password)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _isLoading ? null : _handleLogin,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'লগইন করুন',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => _tabController.animateTo(1),
            child: const Text(
              'নতুন ব্যবহারকারী? এখানে ক্লিক করে একাউন্ট খুলুন',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const Text(
          'ইমেইল এড্রেস (Email)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'name@domain.com',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'পাসওয়ার্ড (Password)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regPassController,
          obscureText: _obscureRegPass,
          decoration: InputDecoration(
            hintText: 'কমপক্ষে ৪ অক্ষরের পাসওয়ার্ড',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.textMuted,
              ),
              onPressed: () => setState(() => _obscureRegPass = !_obscureRegPass),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'কনফার্ম পাসওয়ার্ড',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _regConfirmPassController,
          obscureText: _obscureRegPass,
          decoration: const InputDecoration(
            hintText: 'একই পাসওয়ার্ড পুনরায় লিখুন',
            prefixIcon: Icon(Icons.lock_clock_outlined, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _isLoading ? null : _handleRegister,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'রেজিস্ট্রেশন সম্পন্ন করুন',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}

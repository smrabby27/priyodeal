import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/finance_service.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'finance_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openUpdateProfileDialog() {
    final user = ApiService.currentUser;
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');
    final businessCtrl = TextEditingController(text: user?.businessName ?? '');
    final addressCtrl = TextEditingController(text: user?.address ?? ApiService.currentLocation);
    bool isSaving = false;
    String? formError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Container(
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
                      child: const Icon(Icons.manage_accounts_rounded, color: AppColors.primaryDark, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('প্রোফাইল আপডেট করুন', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          Text('আপনার ব্যক্তিগত ও ব্যবসায়িক তথ্য পরিবর্তন করুন', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (formError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      formError!,
                      style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const Text('পুরো নাম (Full Name) *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'আপনার নাম লিখুন',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('মোবাইল নম্বর (Phone Number)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '01XXXXXXXXX',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('ইমেইল এড্রেস (Email Address)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'example@domain.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('ব্যবসা / প্রতিষ্ঠানের নাম (Business Name)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: businessCtrl,
                  decoration: const InputDecoration(
                    hintText: 'দোকান বা ব্যবসা প্রতিষ্ঠানের নাম (ঐচ্ছিক)',
                    prefixIcon: Icon(Icons.storefront_outlined, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('ঠিকানা / এলাকা (Address & Location)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    hintText: 'আপনার ঠিকানা বা শহর লিখুন',
                    prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            setM(() => formError = 'দয়া করে আপনার নাম প্রদান করুন');
                            return;
                          }
                          setM(() {
                            isSaving = true;
                            formError = null;
                          });

                          final res = await ApiService.updateProfile(
                            name: name,
                            phone: phoneCtrl.text.trim().isNotEmpty ? phoneCtrl.text.trim() : null,
                            email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                            businessName: businessCtrl.text.trim().isNotEmpty ? businessCtrl.text.trim() : null,
                            address: addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
                          );

                          setM(() => isSaving = false);

                          if (res['success'] == true) {
                            if (addressCtrl.text.trim().isNotEmpty) {
                              await ApiService.setLocation(addressCtrl.text.trim());
                            }
                            Navigator.pop(ctx);
                            if (mounted) setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppColors.primary,
                                content: Text('প্রোফাইল সফলভাবে আপডেট করা হয়েছে!'),
                              ),
                            );
                          } else {
                            setM(() => formError = res['message'] ?? 'প্রোফাইল আপডেট ব্যর্থ হয়েছে');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('প্রোফাইল সংরক্ষণ করুন', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openBusinessProfileDialog() {
    final nameCtrl = TextEditingController(text: 'Sumus Dream');
    final ownerCtrl = TextEditingController(text: 'Md. Rabby Islam');
    final phoneCtrl = TextEditingController(text: '01796382854');
    String bType = 'মোবাইল রিচার্জ ও এজেন্ট ব্যাংকিং';
    final types = [
      'মোবাইল রিচার্জ ও এজেন্ট ব্যাংকিং',
      'জুতার দোকান',
      'খেলনার দোকান',
      'গিফট শপ',
      'হোটেল/মোটেল',
      'কম্পিউটার শপ',
      'ফার্মেসি ও ডায়াগনস্টিক',
      'অন্যান্য'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) => Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ব্যবসায়িক প্রোফাইল', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'ব্যবসার নাম *', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: bType,
                  decoration: const InputDecoration(labelText: 'ব্যবসার ধরন *', border: OutlineInputBorder()),
                  items: types.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) => setM(() => bType = v!),
                ),
                const SizedBox(height: 10),
                TextField(controller: ownerCtrl, decoration: const InputDecoration(labelText: 'মালিকের নাম *', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মালিকের ফোন নম্বর *', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ব্যবসায়িক প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে!')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F2942), minimumSize: const Size(double.infinity, 48)),
                  child: const Text('প্রোফাইল সংরক্ষণ করুন', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openClearDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('সকল ডাটা ডিলিট করবেন?'),
        content: const Text('আপনার সকল অফলাইন আয়-ব্যয় এবং স্টকের ডাটা মুছে যাবে। এটি আর ফেরত পাওয়া যাবে না।'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FinanceService.clearAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সকল আর্থিক ডাটা মুছে ফেলা হয়েছে')));
            },
            child: const Text('ডিলিট করুন', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openVendorApplyDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: ApiService.currentUser?.phone ?? '');
    final addressCtrl = TextEditingController();
    String type = 'doctor';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('ভেন্ডর হিসেবে আবেদন করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'আবেদনের ধরন'),
                  items: const [
                    DropdownMenuItem(value: 'doctor', child: Text('👨‍⚕️ ডাক্তার (Doctor / Chamber)')),
                    DropdownMenuItem(value: 'shop', child: Text('🏪 দোকান (Shop / Pharmacy / Grocery)')),
                  ],
                  onChanged: (val) => setDialogState(() => type = val!),
                ),
                const SizedBox(height: 10),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'নাম বা প্রতিষ্ঠানের নাম *')),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'মোবাইল নাম্বার *')),
                const SizedBox(height: 10),
                TextField(controller: addressCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'ঠিকানা / চেম্বার লোকেশন *')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.primary,
                    content: Text('আপনার আবেদন জমা হয়েছে! এডমিন অনুমোদনের পর ডিরেক্টরিতে আসবে।'),
                  ),
                );
              },
              child: const Text('আবেদন পাঠান'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;
    final isLoggedIn = user != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('প্রোফাইল ও সেটিংস'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      isLoggedIn ? user.name.substring(0, 1).toUpperCase() : 'G',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn ? user.name : 'গেস্ট ইউজার (Guest User)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLoggedIn ? (user.phone ?? user.email ?? '') : 'লগইন করে সব সুবিধা উপভোগ করুন',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        if (isLoggedIn) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isLoggedIn)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _openUpdateProfileDialog,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('এডিট', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                      },
                      child: const Text('লগইন', style: TextStyle(fontSize: 11)),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Vendor Partnership CTA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.business_center_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'আপনি কি ডাক্তার বা দোকানদার?',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'প্রিয় ডিলে ভেন্ডর হিসেবে যুক্ত হয়ে ব্যবসা বৃদ্ধি করুন',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _openVendorApplyDialog,
                    child: const Text('আবেদন', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings Options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.manage_accounts_rounded, color: AppColors.primary, size: 22),
                    title: const Text('প্রোফাইল আপডেট করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(
                      isLoggedIn ? '${user.name} • ${user.phone ?? user.email ?? "তথ্য হালনাগাদ"}' : 'আপনার নাম ও ঠিকানা সেট করুন',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                    onTap: _openUpdateProfileDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF10B981), size: 22),
                    title: const Text('আমার সাবস্ক্রিপশন প্ল্যান', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('সম্পূর্ণ ফ্রি • আজীবন সকল মডিউল উন্মুক্ত', style: TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const FreeSubscriptionSheet(),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.storefront_rounded, color: Color(0xFF0284C7), size: 22),
                    title: const Text('ব্যবসায়িক প্রোফাইল', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: const Text('দোকান / ব্যবসার নাম ও বিবরণ সেট করুন', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                    onTap: _openBusinessProfileDialog,
                  ),
                  const Divider(height: 1),
                  _buildListTile(Icons.language_rounded, 'ভাষা (Language)', 'বাংলা (Bangla)'),
                  const Divider(height: 1),
                  _buildListTile(Icons.currency_exchange_rounded, 'মুদ্রা (Currency)', 'টাকা (৳ BDT)'),
                  const Divider(height: 1),
                  _buildListTile(Icons.location_on_outlined, 'সংরক্ষিত ঠিকানা', user?.address ?? ApiService.currentLocation),
                  const Divider(height: 1),
                  _buildListTile(Icons.headset_mic_outlined, 'গ্রাহক সেবা ও হেল্পলাইন', '+880 1700-000000'),
                  const Divider(height: 1),
                  _buildListTile(Icons.mail_outline_rounded, 'সাপোর্ট ইমেইল', 'priyodealbd@gmail.com'),
                  const Divider(height: 1),
                  _buildListTile(Icons.info_outline_rounded, 'ডেভেলপার পরিচিতি', 'Md. Rabby Islam'),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                    title: const Text('সকল ডাটা ডিলিট করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.redAccent)),
                    subtitle: const Text('আর্থিক ও স্টকের অফলাইন হিস্ট্রি মুছে ফেলুন', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                    onTap: _openClearDataDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (isLoggedIn)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    await ApiService.logout();
                    FinanceService.clearActiveMemory();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('লগআউট করুন'),
                ),
              ),

            const SizedBox(height: 16),
            const Text(
              'Priyo Deal v1.0.5 • All Rights Reserved\nwww.priyodeal.com.bd',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
    );
  }
}


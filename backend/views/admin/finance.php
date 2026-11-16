<?php
// backend/views/admin/finance.php - Personal & Business Finance Admin Panel
ob_start();
?>

<div class="space-y-8">
    <!-- Free Pricing Policy Banner -->
    <div class="bg-gradient-to-r from-emerald-900/60 via-teal-950 to-slate-950 p-6 rounded-3xl border border-emerald-500/30 flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
        <div class="flex items-center gap-4">
            <div class="w-14 h-14 rounded-2xl bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 flex items-center justify-center font-bold text-2xl">
                <i data-lucide="gift" class="w-7 h-7"></i>
            </div>
            <div>
                <div class="flex items-center gap-2 mb-1">
                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-extrabold bg-emerald-500/20 text-emerald-300 border border-emerald-500/40">100% FREE ACTIVE</span>
                    <span class="text-xs text-slate-400">Zero Payment Gateway Needed</span>
                </div>
                <h3 class="text-xl font-extrabold text-white">All Finance & Business Modules are Completely Free</h3>
                <p class="text-xs text-slate-300 mt-1">Users have full access to Personal Cash Book, Business POS, Stock & Inventory, Ledger, and Invoices at ৳0 lifetime access.</p>
            </div>
        </div>

        <form action="/admin/finance" method="POST">
            <input type="hidden" name="action" value="save_plans">
            <button type="submit" class="px-5 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs shadow-lg shadow-emerald-600/30 transition flex items-center gap-2">
                <i data-lucide="check-circle" class="w-4 h-4"></i>
                <span>Confirm All Modules Free</span>
            </button>
        </form>
    </div>

    <!-- Active Modules Grid (matching screenshot list) -->
    <div class="bg-slate-950 p-6 rounded-3xl border border-slate-800">
        <div class="flex items-center justify-between mb-6">
            <div>
                <h4 class="font-extrabold text-white text-base">Unrestricted Free Modules Status</h4>
                <p class="text-xs text-slate-400">Features provided to mobile app users without subscription paywalls</p>
            </div>
            <span class="text-xs font-bold text-emerald-400 bg-emerald-500/10 px-3 py-1 rounded-full border border-emerald-500/20">11 of 11 Modules Active</span>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <?php
            $modulesList = [
                ['name' => 'বিক্রয় ব্যবস্থাপনা (Sales POS)', 'en' => 'Sales & POS Invoicing', 'icon' => 'shopping-cart', 'status' => 'Unlocked Free'],
                ['name' => 'ক্রয় ব্যবস্থাপনা (Purchase)', 'en' => 'Supplier Purchases & Restock', 'icon' => 'truck', 'status' => 'Unlocked Free'],
                ['name' => 'স্টক/ইনভেন্টরি ব্যবস্থাপনা', 'en' => 'Inventory & Low Stock Alert', 'icon' => 'box', 'status' => 'Unlocked Free'],
                ['name' => 'কাস্টমার লেজার (Customer Due)', 'en' => 'Receivables & Credit Ledger', 'icon' => 'users', 'status' => 'Unlimited Free'],
                ['name' => 'সাপ্লায়ার / মহাজন খাতা', 'en' => 'Payables & Supplier Accounts', 'icon' => 'building', 'status' => 'Unlocked Free'],
                ['name' => 'ক্যাশ বুক ও ব্যাংক বুক', 'en' => 'Daily Cash Book & Multi-account', 'icon' => 'book-open', 'status' => 'Unlocked Free'],
                ['name' => 'দেনা/পাওনা সামারি', 'en' => 'Receivables vs Payables Balance', 'icon' => 'heart-handshake', 'status' => 'Unlocked Free'],
                ['name' => 'পিডিএফ ও এক্সেল রিপোর্ট', 'en' => 'One-click PDF Export & Share', 'icon' => 'file-text', 'status' => 'Unlocked Free'],
                ['name' => 'আর্থিক বিবরণী ও চার্ট', 'en' => 'Income vs Expense Analytics', 'icon' => 'pie-chart', 'status' => 'Unlocked Free'],
                ['name' => 'ফান্ড ট্রান্সফার (Cash/Bank/MFS)', 'en' => 'Inter-account Balance Transfer', 'icon' => 'repeat', 'status' => 'Unlocked Free'],
                ['name' => 'বিক্রয় ফেরত (Sales Return)', 'en' => 'Customer Return & Adjustments', 'icon' => 'rotate-ccw', 'status' => 'Unlocked Free'],
            ];
            foreach ($modulesList as $m): ?>
                <div class="bg-slate-900/80 p-4 rounded-2xl border border-slate-800 flex items-center justify-between">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-teal-500/10 text-teal-400 flex items-center justify-center">
                            <i data-lucide="<?= $m['icon'] ?>" class="w-5 h-5"></i>
                        </div>
                        <div>
                            <div class="font-bold text-white text-xs"><?= htmlspecialchars($m['name']) ?></div>
                            <div class="text-[10px] text-slate-400"><?= htmlspecialchars($m['en']) ?></div>
                        </div>
                    </div>
                    <span class="px-2 py-0.5 rounded text-[10px] font-extrabold bg-emerald-500/20 text-emerald-300 border border-emerald-500/30">
                        <?= $m['status'] ?>
                    </span>
                </div>
            <?php endforeach; ?>
        </div>
    </div>

    <!-- Personal & Business Categories Management -->
    <div class="bg-slate-950 p-6 rounded-3xl border border-slate-800 space-y-6">
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div>
                <h4 class="font-extrabold text-white text-base">Finance Categories Management</h4>
                <p class="text-xs text-slate-400">Configure default income/expense categories for both Personal & Business modes</p>
            </div>
            <button onclick="document.getElementById('add-fcat-modal').classList.remove('hidden')" class="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-500 text-white font-bold text-xs flex items-center gap-2 transition">
                <i data-lucide="plus" class="w-4 h-4"></i>
                <span>Add Finance Category</span>
            </button>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <?php if (empty($financeCats)): ?>
                <div class="col-span-full py-8 text-center text-slate-500 text-xs">
                    No custom finance categories added yet. App uses smart pre-seeded defaults (Food, Salary, Salon, Rent, Cash Sales, etc.).
                </div>
            <?php else: ?>
                <?php foreach ($financeCats as $c): ?>
                    <div class="bg-slate-900 p-4 rounded-2xl border border-slate-800 flex items-center justify-between">
                        <div>
                            <span class="font-bold text-white text-xs block"><?= htmlspecialchars($c['name']) ?></span>
                            <span class="text-[10px] uppercase font-bold text-teal-400">
                                <?= $c['module'] === 'finance_business' ? 'Business Mode' : 'Personal Mode' ?>
                            </span>
                        </div>
                        <form action="/admin/finance" method="POST" onsubmit="return confirm('Delete category?')" class="inline">
                            <input type="hidden" name="action" value="delete_category">
                            <input type="hidden" name="id" value="<?= $c['id'] ?>">
                            <button type="submit" class="text-slate-500 hover:text-rose-400 p-1.5 transition">
                                <i data-lucide="trash-2" class="w-4 h-4"></i>
                            </button>
                        </form>
                    </div>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- Add Category Modal -->
<div id="add-fcat-modal" class="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4 hidden">
    <div class="bg-slate-900 rounded-3xl max-w-md w-full p-8 border border-slate-800 shadow-2xl relative">
        <button onclick="document.getElementById('add-fcat-modal').classList.add('hidden')" class="absolute top-6 right-6 text-slate-400 hover:text-white">✕</button>

        <h3 class="text-xl font-bold text-white mb-1">Add Finance Category</h3>
        <p class="text-xs text-slate-400 mb-6">Choose target mode and enter category title</p>

        <form action="/admin/finance" method="POST" class="space-y-4">
            <input type="hidden" name="action" value="add_category">

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Category Mode *</label>
                <select name="module" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                    <option value="finance_personal">👤 Personal Finance (বেতন, খাবার, বাসা ভাড়া, ইত্যাদি)</option>
                    <option value="finance_business">🏪 Business Ledger (Cash Sales, স্টক ক্রয়, দোকান ভাড়া, ইত্যাদি)</option>
                </select>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Category Name *</label>
                <input type="text" name="name" required placeholder="e.g. Beauty / Salon, Office Rent" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
            </div>

            <div class="pt-4 flex justify-end gap-3">
                <button type="button" onclick="document.getElementById('add-fcat-modal').classList.add('hidden')" class="px-4 py-2 rounded-xl bg-slate-800 text-slate-300 text-xs font-bold">Cancel</button>
                <button type="submit" class="px-5 py-2 rounded-xl bg-teal-600 hover:bg-teal-500 text-white text-xs font-bold">Save Category</button>
            </div>
        </form>
    </div>
</div>

<?php
$content = ob_get_clean();
$title = 'Finance & Free Modules Management';
require __DIR__ . '/layout.php';
?>


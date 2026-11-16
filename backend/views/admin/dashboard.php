<?php
ob_start();
?>

<!-- KPI Stat Cards -->
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
    <!-- Card 1 -->
    <div class="bg-slate-950 p-6 rounded-2xl border border-slate-800 shadow-sm">
        <div class="flex items-center justify-between mb-4">
            <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Total Users</span>
            <div class="w-10 h-10 rounded-xl bg-teal-500/10 text-teal-400 flex items-center justify-center">
                <i data-lucide="users" class="w-5 h-5"></i>
            </div>
        </div>
        <div class="text-3xl font-extrabold text-white"><?= number_format($totalUsers) ?></div>
        <div class="text-xs text-emerald-400 flex items-center gap-1 mt-2 font-medium">
            <i data-lucide="trending-up" class="w-3.5 h-3.5"></i> +12% active this week
        </div>
    </div>

    <!-- Card 2 -->
    <div class="bg-slate-950 p-6 rounded-2xl border border-slate-800 shadow-sm">
        <div class="flex items-center justify-between mb-4">
            <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Total Doctors</span>
            <div class="w-10 h-10 rounded-xl bg-sky-500/10 text-sky-400 flex items-center justify-center">
                <i data-lucide="stethoscope" class="w-5 h-5"></i>
            </div>
        </div>
        <div class="text-3xl font-extrabold text-white"><?= number_format($totalDoctors) ?></div>
        <div class="text-xs text-slate-400 mt-2 font-medium">
            Across 6 specialties
        </div>
    </div>

    <!-- Card 3 -->
    <div class="bg-slate-950 p-6 rounded-2xl border border-slate-800 shadow-sm">
        <div class="flex items-center justify-between mb-4">
            <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Total Shops</span>
            <div class="w-10 h-10 rounded-xl bg-indigo-500/10 text-indigo-400 flex items-center justify-center">
                <i data-lucide="store" class="w-5 h-5"></i>
            </div>
        </div>
        <div class="text-3xl font-extrabold text-white"><?= number_format($totalShops) ?></div>
        <div class="text-xs text-slate-400 mt-2 font-medium">
            Grocery, Pharmacy, Tech
        </div>
    </div>

    <!-- Card 4 -->
    <div class="bg-slate-950 p-6 rounded-2xl border border-slate-800 shadow-sm">
        <div class="flex items-center justify-between mb-4">
            <span class="text-xs font-bold uppercase tracking-wider text-slate-400">Total Bookings & Orders</span>
            <div class="w-10 h-10 rounded-xl bg-emerald-500/10 text-emerald-400 flex items-center justify-center">
                <i data-lucide="activity" class="w-5 h-5"></i>
            </div>
        </div>
        <div class="text-3xl font-extrabold text-white"><?= number_format($totalBookings + $totalOrders) ?></div>
        <div class="text-xs text-slate-400 mt-2 font-medium">
            ৳<?= number_format($totalRevenue) ?> total commerce
        </div>
    </div>
</div>

<!-- Finance & Free Plan Overview Banner -->
<div class="mb-8 p-6 rounded-3xl bg-gradient-to-r from-emerald-950/60 via-slate-950 to-slate-950 border border-emerald-500/30 flex flex-col sm:flex-row items-center justify-between gap-4">
    <div class="flex items-center gap-4">
        <div class="w-12 h-12 rounded-2xl bg-emerald-500/20 text-emerald-400 flex items-center justify-center font-bold">
            <i data-lucide="calculator" class="w-6 h-6"></i>
        </div>
        <div>
            <h4 class="text-white font-extrabold text-base">Finance Module: 100% Free Lifetime Active</h4>
            <p class="text-xs text-slate-400">Personal Cash Book, Business Sales POS, Inventory, Customer Ledger & PDF Reports enabled at ৳0.</p>
        </div>
    </div>
    <a href="/admin/finance" class="px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-xs shadow-md shadow-emerald-600/20 transition flex items-center gap-2">
        <i data-lucide="settings-2" class="w-4 h-4"></i>
        <span>Manage Finance & Plans</span>
    </a>
</div>

<!-- Pending Approvals Banner if any -->
<?php if ($pendingVendors > 0): ?>
    <div class="mb-8 p-4 rounded-2xl bg-amber-500/10 border border-amber-500/30 text-amber-300 flex items-center justify-between">
        <div class="flex items-center gap-3">
            <i data-lucide="alert-triangle" class="w-5 h-5 text-amber-400"></i>
            <span class="text-sm font-bold">You have <?= $pendingVendors ?> pending vendor registration(s) awaiting review!</span>
        </div>
        <a href="/admin/vendors?status=pending" class="px-4 py-1.5 rounded-xl bg-amber-500 text-slate-950 text-xs font-bold hover:bg-amber-400 transition">
            Review Applications
        </a>
    </div>
<?php endif; ?>

<!-- 2 Column Tables: Recent Bookings & Recent Orders -->
<div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
    
    <!-- Recent Appointments -->
    <div class="bg-slate-950 rounded-2xl border border-slate-800 p-6">
        <div class="flex items-center justify-between mb-6">
            <div>
                <h3 class="font-bold text-white text-base">Recent Doctor Bookings</h3>
                <p class="text-xs text-slate-400">Latest patient chamber appointments</p>
            </div>
            <a href="/admin/bookings" class="text-xs text-teal-400 hover:text-teal-300 font-bold">View All →</a>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 text-slate-400">
                        <th class="pb-3">Code / Patient</th>
                        <th class="pb-3">Doctor</th>
                        <th class="pb-3">Slot</th>
                        <th class="pb-3">Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    <?php if (empty($recentBookings)): ?>
                        <tr><td colspan="4" class="py-4 text-center text-slate-500">No bookings yet.</td></tr>
                    <?php else: foreach ($recentBookings as $b): ?>
                        <tr>
                            <td class="py-3">
                                <span class="font-mono text-teal-400 font-semibold block"><?= htmlspecialchars($b['booking_code']) ?></span>
                                <span class="text-slate-300 font-medium"><?= htmlspecialchars($b['patient_name']) ?></span>
                            </td>
                            <td class="py-3">
                                <span class="text-slate-200 font-medium block"><?= htmlspecialchars($b['doctor_name']) ?></span>
                                <span class="text-[10px] text-slate-500"><?= htmlspecialchars($b['chamber_name']) ?></span>
                            </td>
                            <td class="py-3">
                                <span class="text-slate-300 font-medium block"><?= htmlspecialchars($b['date']) ?></span>
                                <span class="text-[10px] text-teal-400"><?= htmlspecialchars($b['slot_time']) ?></span>
                            </td>
                            <td class="py-3">
                                <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-teal-500/10 text-teal-400 border border-teal-500/20">
                                    <?= ucfirst($b['status']) ?>
                                </span>
                            </td>
                        </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Recent Orders -->
    <div class="bg-slate-950 rounded-2xl border border-slate-800 p-6">
        <div class="flex items-center justify-between mb-6">
            <div>
                <h3 class="font-bold text-white text-base">Recent Shop Orders</h3>
                <p class="text-xs text-slate-400">Cash on Delivery customer purchases</p>
            </div>
            <a href="/admin/orders" class="text-xs text-sky-400 hover:text-sky-300 font-bold">View All →</a>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead>
                    <tr class="border-b border-slate-800 text-slate-400">
                        <th class="pb-3">Order / Customer</th>
                        <th class="pb-3">Shop</th>
                        <th class="pb-3">Total</th>
                        <th class="pb-3">Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    <?php if (empty($recentOrders)): ?>
                        <tr><td colspan="4" class="py-4 text-center text-slate-500">No orders yet.</td></tr>
                    <?php else: foreach ($recentOrders as $o): ?>
                        <tr>
                            <td class="py-3">
                                <span class="font-mono text-sky-400 font-semibold block"><?= htmlspecialchars($o['order_code']) ?></span>
                                <span class="text-slate-300 font-medium"><?= htmlspecialchars($o['shipping_name']) ?></span>
                            </td>
                            <td class="py-3 text-slate-300 font-medium">
                                <?= htmlspecialchars($o['shop_name']) ?>
                            </td>
                            <td class="py-3 font-bold text-white">
                                ৳<?= number_format($o['total']) ?>
                            </td>
                            <td class="py-3">
                                <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-sky-500/10 text-sky-400 border border-sky-500/20">
                                    <?= ucfirst($o['status']) ?>
                                </span>
                            </td>
                        </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>

</div>

<!-- Quick Action Shortcuts -->
<div class="bg-gradient-to-r from-slate-950 to-slate-900 rounded-2xl border border-slate-800 p-6 flex flex-wrap items-center justify-between gap-4">
    <div>
        <h4 class="font-bold text-white text-sm">Need to add a new Doctor or Shop?</h4>
        <p class="text-xs text-slate-400">You can create verified vendor profiles directly without waiting for self-registration.</p>
    </div>
    <div class="flex items-center gap-3">
        <a href="/admin/vendors" class="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-500 text-white font-bold text-xs transition">
            + Add New Vendor
        </a>
        <a href="/admin/products" class="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 font-bold text-xs transition">
            + Moderate Products
        </a>
    </div>
</div>

<?php
$content = ob_get_clean();
$title = "Admin Dashboard";
require __DIR__ . '/layout.php';
?>


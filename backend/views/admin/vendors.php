<?php
ob_start();
?>

<div class="space-y-6">
    <!-- Header with Filters & Add Button -->
    <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 bg-slate-950 p-6 rounded-2xl border border-slate-800">
        <div class="flex flex-wrap items-center gap-3">
            <a href="/admin/vendors" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= empty($filterStatus) && empty($filterType) ? 'bg-teal-600 text-white' : 'bg-slate-900 text-slate-400 hover:text-white' ?>">
                All Vendors
            </a>
            <a href="/admin/vendors?status=pending" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= $filterStatus === 'pending' ? 'bg-amber-600 text-white' : 'bg-slate-900 text-amber-400 hover:text-white' ?>">
                Pending Approvals
            </a>
            <a href="/admin/vendors?type=doctor" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= $filterType === 'doctor' ? 'bg-sky-600 text-white' : 'bg-slate-900 text-slate-400 hover:text-white' ?>">
                Doctors Only
            </a>
            <a href="/admin/vendors?type=shop" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= $filterType === 'shop' ? 'bg-indigo-600 text-white' : 'bg-slate-900 text-slate-400 hover:text-white' ?>">
                Shops Only
            </a>
        </div>

        <button onclick="document.getElementById('add-vendor-modal').classList.remove('hidden')" class="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-500 text-white font-bold text-xs flex items-center gap-2 transition">
            <i data-lucide="plus-circle" class="w-4 h-4"></i>
            <span>Add New Vendor</span>
        </button>
    </div>

    <!-- Vendors Table -->
    <div class="bg-slate-950 rounded-2xl border border-slate-800 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-slate-900/80 text-slate-400 border-b border-slate-800">
                    <tr>
                        <th class="py-3.5 px-6">Vendor Name / Type</th>
                        <th class="py-3.5 px-6">Category / Tagline</th>
                        <th class="py-3.5 px-6">Address & Area</th>
                        <th class="py-3.5 px-6">Phone</th>
                        <th class="py-3.5 px-6">Status</th>
                        <th class="py-3.5 px-6 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    <?php if (empty($vendors)): ?>
                        <tr><td colspan="6" class="py-8 text-center text-slate-500">No vendors found matching your filter.</td></tr>
                    <?php else: foreach ($vendors as $v): ?>
                        <tr class="hover:bg-slate-900/40 transition">
                            <td class="py-4 px-6">
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-xl bg-slate-800 flex items-center justify-center overflow-hidden border border-slate-700">
                                        <?php if (!empty($v['logo'])): ?>
                                            <img src="<?= htmlspecialchars($v['logo']) ?>" class="w-full h-full object-cover">
                                        <?php else: ?>
                                            <i data-lucide="<?= $v['type'] === 'doctor' ? 'stethoscope' : 'store' ?>" class="w-5 h-5 text-teal-400"></i>
                                        <?php endif; ?>
                                    </div>
                                    <div>
                                        <span class="font-bold text-white text-sm block"><?= htmlspecialchars($v['name']) ?></span>
                                        <span class="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-bold uppercase <?= $v['type'] === 'doctor' ? 'bg-sky-500/10 text-sky-400' : 'bg-indigo-500/10 text-indigo-400' ?>">
                                            <?= htmlspecialchars($v['type']) ?>
                                        </span>
                                    </div>
                                </div>
                            </td>
                            <td class="py-4 px-6">
                                <span class="font-medium text-slate-300 block"><?= htmlspecialchars($v['category_name'] ?? 'General') ?></span>
                                <span class="text-[11px] text-slate-500 truncate max-w-xs block"><?= htmlspecialchars($v['tagline'] ?? '') ?></span>
                            </td>
                            <td class="py-4 px-6">
                                <span class="text-slate-300 font-medium block"><?= htmlspecialchars($v['area'] ?? 'Dhaka') ?></span>
                                <span class="text-[10px] text-slate-500 truncate max-w-xs block"><?= htmlspecialchars($v['address'] ?? '') ?></span>
                            </td>
                            <td class="py-4 px-6 font-mono text-slate-300">
                                <?= htmlspecialchars($v['phone'] ?? '-') ?>
                            </td>
                            <td class="py-4 px-6">
                                <?php if ($v['status'] === 'approved'): ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">Approved</span>
                                <?php elseif ($v['status'] === 'pending'): ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-amber-500/10 text-amber-400 border border-amber-500/20 animate-pulse">Pending Review</span>
                                <?php elseif ($v['status'] === 'rejected'): ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-rose-500/10 text-rose-400 border border-rose-500/20">Rejected</span>
                                <?php else: ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-slate-500/10 text-slate-400 border border-slate-500/20">Suspended</span>
                                <?php endif; ?>
                            </td>
                            <td class="py-4 px-6 text-right">
                                <div class="inline-flex items-center gap-1.5">
                                    <?php if ($v['status'] !== 'approved'): ?>
                                        <form action="/admin/vendors" method="POST" class="inline">
                                            <input type="hidden" name="action" value="approve">
                                            <input type="hidden" name="business_id" value="<?= $v['id'] ?>">
                                            <button type="submit" class="px-2.5 py-1 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white font-bold text-[10px] transition">
                                                Approve
                                            </button>
                                        </form>
                                    <?php endif; ?>

                                    <?php if ($v['status'] !== 'rejected'): ?>
                                        <form action="/admin/vendors" method="POST" class="inline" onsubmit="return confirm('Reject this vendor application?')">
                                            <input type="hidden" name="action" value="reject">
                                            <input type="hidden" name="business_id" value="<?= $v['id'] ?>">
                                            <input type="hidden" name="reason" value="Verification documents could not be validated.">
                                            <button type="submit" class="px-2.5 py-1 rounded-lg bg-rose-600/20 hover:bg-rose-600/40 text-rose-300 font-bold text-[10px] transition">
                                                Reject
                                            </button>
                                        </form>
                                    <?php endif; ?>

                                    <?php if ($v['status'] === 'approved'): ?>
                                        <form action="/admin/vendors" method="POST" class="inline" onsubmit="return confirm('Suspend this vendor from the public app?')">
                                            <input type="hidden" name="action" value="suspend">
                                            <input type="hidden" name="business_id" value="<?= $v['id'] ?>">
                                            <button type="submit" class="px-2.5 py-1 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-400 font-bold text-[10px] transition">
                                                Suspend
                                            </button>
                                        </form>
                                    <?php endif; ?>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Add Vendor Modal -->
<div id="add-vendor-modal" class="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4 hidden">
    <div class="bg-slate-900 rounded-3xl max-w-lg w-full p-8 border border-slate-800 shadow-2xl relative">
        <button onclick="document.getElementById('add-vendor-modal').classList.add('hidden')" class="absolute top-6 right-6 text-slate-400 hover:text-white">✕</button>

        <h3 class="text-xl font-bold text-white mb-1">Add New Vendor Profile</h3>
        <p class="text-xs text-slate-400 mb-6">Create a verified doctor or shop directly in the system</p>

        <form action="/admin/vendors" method="POST" class="space-y-4">
            <input type="hidden" name="action" value="add">

            <div class="grid grid-cols-2 gap-3">
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Vendor Type</label>
                    <select name="type" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                        <option value="doctor">👨‍⚕️ Doctor</option>
                        <option value="shop">🏪 Shop / Merchant</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Category</label>
                    <select name="category_id" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                        <?php foreach ($categories as $c): ?>
                            <option value="<?= $c['id'] ?>"><?= htmlspecialchars($c['name']) ?> (<?= $c['module'] ?>)</option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Business / Doctor Name *</label>
                <input type="text" name="name" required placeholder="e.g. Dr. Anisur Rahman or Uttara Super Mart" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Specialty / Tagline</label>
                <input type="text" name="tagline" placeholder="e.g. Consultant Neurologist or Organic Dairy & Groceries" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
            </div>

            <div class="grid grid-cols-2 gap-3">
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Area / Zone</label>
                    <input type="text" name="area" value="Dhaka" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Contact Phone *</label>
                    <input type="tel" name="phone" required placeholder="017xxxxxxxx" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Detailed Address / Chamber</label>
                <textarea name="address" rows="2" placeholder="Full address..." class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500"></textarea>
            </div>

            <button type="submit" class="w-full py-2.5 bg-teal-600 hover:bg-teal-500 text-white font-bold rounded-xl text-xs transition shadow-lg shadow-teal-600/20">
                Save & Publish Vendor
            </button>
        </form>
    </div>
</div>

<?php
$content = ob_get_clean();
$title = "Vendor Management";
require __DIR__ . '/layout.php';
?>


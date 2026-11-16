<?php
ob_start();
?>

<div class="space-y-6">
    <div class="bg-slate-950 p-6 rounded-2xl border border-slate-800 flex justify-between items-center">
        <div>
            <h3 class="font-bold text-white text-base">Platform Users</h3>
            <p class="text-xs text-slate-400">Total <?= count($users) ?> registered customer and vendor accounts</p>
        </div>
    </div>

    <div class="bg-slate-950 rounded-2xl border border-slate-800 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-slate-900/80 text-slate-400 border-b border-slate-800">
                    <tr>
                        <th class="py-3.5 px-6">User / Name</th>
                        <th class="py-3.5 px-6">Contact Phone</th>
                        <th class="py-3.5 px-6">Email Address</th>
                        <th class="py-3.5 px-6">Assigned Role</th>
                        <th class="py-3.5 px-6">Status</th>
                        <th class="py-3.5 px-6">Registered Date</th>
                        <th class="py-3.5 px-6 text-right">Actions</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    <?php foreach ($users as $u): ?>
                        <tr class="hover:bg-slate-900/40 transition">
                            <td class="py-4 px-6">
                                <div class="flex items-center gap-3">
                                    <div class="w-8 h-8 rounded-full bg-slate-800 text-teal-400 flex items-center justify-center font-bold text-xs border border-slate-700">
                                        <?= strtoupper(substr($u['name'] ?? 'U', 0, 1)) ?>
                                    </div>
                                    <span class="font-bold text-white text-sm"><?= htmlspecialchars($u['name']) ?></span>
                                </div>
                            </td>
                            <td class="py-4 px-6 font-mono text-slate-300">
                                <?= htmlspecialchars($u['phone'] ?? '-') ?>
                            </td>
                            <td class="py-4 px-6 text-slate-300">
                                <?= htmlspecialchars($u['email'] ?? '-') ?>
                            </td>
                            <td class="py-4 px-6">
                                <span class="px-2 py-0.5 rounded text-[10px] font-bold uppercase <?= $u['role'] === 'admin' ? 'bg-rose-500/10 text-rose-400 border border-rose-500/20' : ($u['role'] === 'vendor' ? 'bg-sky-500/10 text-sky-400 border border-sky-500/20' : 'bg-slate-500/10 text-slate-400 border border-slate-500/20') ?>">
                                    <?= htmlspecialchars($u['role']) ?>
                                </span>
                            </td>
                            <td class="py-4 px-6">
                                <span class="px-2.5 py-1 rounded-md text-[10px] font-bold <?= $u['status'] === 'active' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-rose-500/10 text-rose-400 border border-rose-500/20' ?>">
                                    <?= ucfirst($u['status']) ?>
                                </span>
                            </td>
                            <td class="py-4 px-6 text-slate-400">
                                <?= date('M d, Y', strtotime($u['created_at'])) ?>
                            </td>
                            <td class="py-4 px-6 text-right">
                                <?php if ($u['role'] !== 'admin'): ?>
                                    <form action="/admin/users" method="POST" class="inline">
                                        <input type="hidden" name="action" value="toggle_status">
                                        <input type="hidden" name="user_id" value="<?= $u['id'] ?>">
                                        <input type="hidden" name="current_status" value="<?= $u['status'] ?>">
                                        <button type="submit" class="px-2.5 py-1 rounded-lg <?= $u['status'] === 'active' ? 'bg-slate-800 text-rose-400 hover:bg-slate-700' : 'bg-emerald-600/20 text-emerald-300 hover:bg-emerald-600/30' ?> font-bold text-[10px] transition">
                                            <?= $u['status'] === 'active' ? 'Suspend' : 'Activate' ?>
                                        </button>
                                    </form>
                                <?php endif; ?>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php
$content = ob_get_clean();
$title = "User Management";
require __DIR__ . '/layout.php';
?>


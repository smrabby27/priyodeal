<?php
ob_start();
?>

<div class="space-y-8 max-w-4xl">
    
    <!-- Database Connection Manager -->
    <div class="bg-slate-950 p-6 rounded-2xl border border-slate-800">
        <div class="flex items-center justify-between mb-6">
            <div>
                <h3 class="font-bold text-white text-base">Database Configuration</h3>
                <p class="text-xs text-slate-400">Current storage backend and MySQL database credentials</p>
            </div>
            <div>
                <?php if (($currentConfig['db_type'] ?? '') === 'mysql'): ?>
                    <span class="px-3 py-1 rounded-full text-xs font-bold bg-sky-500/10 text-sky-400 border border-sky-500/20 flex items-center gap-1.5">
                        <span class="w-2 h-2 rounded-full bg-sky-400"></span> Active: MySQL (Hostinger)
                    </span>
                <?php else: ?>
                    <span class="px-3 py-1 rounded-full text-xs font-bold bg-teal-500/10 text-teal-400 border border-teal-500/20 flex items-center gap-1.5">
                        <span class="w-2 h-2 rounded-full bg-teal-400"></span> Active: SQLite (Local High Performance)
                    </span>
                <?php endif; ?>
            </div>
        </div>

        <?php if (!empty($testResult)): ?>
            <div class="mb-6 p-4 rounded-xl <?= $testResult['success'] ? 'bg-emerald-500/10 border border-emerald-500/20 text-emerald-400' : 'bg-rose-500/10 border border-rose-500/20 text-rose-400' ?> text-xs font-bold">
                <?= htmlspecialchars($testResult['message']) ?>
            </div>
        <?php endif; ?>

        <!-- MySQL Form -->
        <form action="/admin/settings" method="POST" class="space-y-4">
            <input type="hidden" name="action" value="test_mysql">

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">MySQL Host</label>
                    <input type="text" name="db_host" value="<?= htmlspecialchars($currentConfig['db_host'] ?? '127.0.0.1') ?>" required class="w-full px-3 py-2 rounded-xl bg-slate-900 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Database Name</label>
                    <input type="text" name="db_name" value="<?= htmlspecialchars($currentConfig['db_name'] ?? '') ?>" placeholder="e.g. u698961719_priyodeal" class="w-full px-3 py-2 rounded-xl bg-slate-900 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">MySQL Username</label>
                    <input type="text" name="db_user" value="<?= htmlspecialchars($currentConfig['db_user'] ?? '') ?>" placeholder="e.g. u698961719_user" class="w-full px-3 py-2 rounded-xl bg-slate-900 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">MySQL Password</label>
                    <input type="password" name="db_pass" value="<?= htmlspecialchars($currentConfig['db_pass'] ?? '') ?>" placeholder="••••••••" class="w-full px-3 py-2 rounded-xl bg-slate-900 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
            </div>

            <div class="flex items-center gap-3 pt-2">
                <button type="submit" class="px-5 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-500 text-white font-bold text-xs transition">
                    Test & Connect MySQL
                </button>
                <button type="submit" formaction="/admin/settings" name="action" value="switch_sqlite" class="px-4 py-2.5 rounded-xl bg-slate-900 hover:bg-slate-800 border border-slate-800 text-slate-300 font-bold text-xs transition">
                    Switch to SQLite
                </button>
            </div>
        </form>
    </div>

    <!-- General Platform Settings -->
    <div class="bg-slate-950 p-6 rounded-2xl border border-slate-800">
        <h3 class="font-bold text-white text-base mb-1">Platform General Settings</h3>
        <p class="text-xs text-slate-400 mb-6">Manage support hotline, email, developer credit, and default delivery fees</p>

        <form action="/admin/settings" method="POST" class="space-y-4">
            <input type="hidden" name="action" value="save_settings">

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Support Phone</label>
                    <input type="text" name="support_phone" value="<?= htmlspecialchars(getSetting('support_phone', '+880 1700-000000')) ?>" class="w-full px-3 py-2 rounded-xl bg-slate-900 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Support Email</label>
                    <input type="email" name="support_email" value="<?= htmlspecialchars(getSetting('support_email', 'priyodealbd@gmail.com')) ?>" class="w-full px-3 py-2 rounded-xl bg-slate-900 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Developer Name</label>
                    <input type="text" name="developer_name" value="<?= htmlspecialchars(getSetting('developer_name', 'Md. Rabby Islam')) ?>" class="w-full px-3 py-2 rounded-xl bg-slate-900 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Default Delivery Fee (৳)</label>
                    <input type="number" name="default_delivery_fee" value="<?= htmlspecialchars(getSetting('default_delivery_fee', '60')) ?>" class="w-full px-3 py-2 rounded-xl bg-slate-900 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Platform Domain</label>
                    <input type="text" name="domain" value="<?= htmlspecialchars(getSetting('domain', 'www.priyodeal.com.bd')) ?>" class="w-full px-3 py-2 rounded-xl bg-slate-900 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Android APK Version</label>
                    <input type="text" name="apk_version" value="<?= htmlspecialchars(getSetting('apk_version', '1.0.0')) ?>" class="w-full px-3 py-2 rounded-xl bg-slate-900 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
            </div>

            <div class="pt-4 border-t border-slate-800">
                <button type="submit" class="px-5 py-2.5 rounded-xl bg-teal-600 hover:bg-teal-500 text-white font-bold text-xs transition">
                    Save Changes
                </button>
            </div>
        </form>
    </div>

</div>

<?php
$content = ob_get_clean();
$title = "Platform Settings";
require __DIR__ . '/layout.php';
?>


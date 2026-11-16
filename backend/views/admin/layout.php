<?php
// backend/views/admin/layout.php - Admin Shell Layout
$admin = $_SESSION['admin_user'] ?? ['name' => 'Admin', 'email' => 'admin@priyodeal.com'];
$flash = $_SESSION['flash'] ?? null;
unset($_SESSION['flash']);

$currentUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
function isActive(string $route, string $currentUri): string {
    if ($route === '/admin' && ($currentUri === '/admin' || $currentUri === '/admin/dashboard')) {
        return 'bg-teal-600 text-white font-bold shadow-md shadow-teal-600/30';
    }
    return str_starts_with($currentUri, $route) && $route !== '/admin'
        ? 'bg-teal-600 text-white font-bold shadow-md shadow-teal-600/30'
        : 'text-slate-400 hover:text-white hover:bg-slate-800 font-medium';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($title ?? 'Admin Panel') ?> - Priyo Deal</title>
    <link rel="icon" type="image/png" href="/assets/images/app-logo.png">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; }
    </style>
</head>
<body class="bg-slate-900 text-slate-100 min-h-screen flex antialiased">

    <!-- Sidebar -->
    <aside class="w-64 bg-slate-950 border-r border-slate-800 flex flex-col justify-between fixed inset-y-0 z-40">
        <div>
            <!-- Brand -->
            <div class="h-20 flex items-center gap-3 px-6 border-b border-slate-800">
                <img src="/assets/images/app-logo.png" alt="Priyo Deal" class="w-10 h-10 rounded-xl shadow-md border border-slate-700 object-cover">
                <div>
                    <h1 class="font-extrabold text-white text-lg tracking-tight">Priyo Deal</h1>
                    <span class="text-[10px] uppercase font-bold text-teal-400 tracking-wider">Super Admin</span>
                </div>
            </div>

            <!-- Navigation Links -->
            <nav class="p-4 space-y-1.5 text-sm">
                <a href="/admin" class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition <?= isActive('/admin', $currentUri) ?>">
                    <i data-lucide="layout-dashboard" class="w-4 h-4"></i>
                    <span>Dashboard</span>
                </a>
                <a href="/admin/vendors" class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition <?= isActive('/admin/vendors', $currentUri) ?>">
                    <i data-lucide="building-2" class="w-4 h-4"></i>
                    <span>Vendors (Doctors/Shops)</span>
                </a>
                <a href="/admin/bookings" class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition <?= isActive('/admin/bookings', $currentUri) ?>">
                    <i data-lucide="calendar" class="w-4 h-4"></i>
                    <span>Doctor Bookings</span>
                </a>
                <a href="/admin/orders" class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition <?= isActive('/admin/orders', $currentUri) ?>">
                    <i data-lucide="shopping-bag" class="w-4 h-4"></i>
                    <span>Shop Orders (COD)</span>
                </a>
                <a href="/admin/categories" class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition <?= isActive('/admin/categories', $currentUri) ?>">
                    <i data-lucide="layers" class="w-4 h-4"></i>
                    <span>Categories</span>
                </a>
                <a href="/admin/products" class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition <?= isActive('/admin/products', $currentUri) ?>">
                    <i data-lucide="box" class="w-4 h-4"></i>
                    <span>Products Moderation</span>
                </a>
                <a href="/admin/users" class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition <?= isActive('/admin/users', $currentUri) ?>">
                    <i data-lucide="users" class="w-4 h-4"></i>
                    <span>User Management</span>
                </a>
                <a href="/admin/banners" class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition <?= isActive('/admin/banners', $currentUri) ?>">
                    <i data-lucide="image" class="w-4 h-4"></i>
                    <span>App Banners</span>
                </a>
                <a href="/admin/finance" class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition <?= isActive('/admin/finance', $currentUri) ?>">
                    <i data-lucide="calculator" class="w-4 h-4"></i>
                    <span>Finance & Free Plans</span>
                </a>
                <a href="/admin/settings" class="flex items-center gap-3 px-4 py-2.5 rounded-xl transition <?= isActive('/admin/settings', $currentUri) ?>">
                    <i data-lucide="settings" class="w-4 h-4"></i>
                    <span>Settings & Database</span>
                </a>
            </nav>
        </div>

        <!-- User bottom section -->
        <div class="p-4 border-t border-slate-800 space-y-3">
            <a href="/" target="_blank" class="flex items-center justify-between text-xs text-slate-400 hover:text-white px-3 py-2 rounded-lg bg-slate-900 border border-slate-800 transition">
                <span class="flex items-center gap-2"><i data-lucide="external-link" class="w-3.5 h-3.5 text-teal-400"></i> View Landing Page</span>
                <i data-lucide="chevron-right" class="w-3 h-3"></i>
            </a>

            <div class="flex items-center justify-between px-3">
                <div class="flex items-center gap-2">
                    <div class="w-8 h-8 rounded-full bg-teal-500/20 text-teal-400 flex items-center justify-center font-bold text-xs">
                        <?= strtoupper(substr($admin['name'] ?? 'A', 0, 1)) ?>
                    </div>
                    <div class="text-left">
                        <span class="block text-xs font-bold text-white"><?= htmlspecialchars($admin['name'] ?? 'Admin') ?></span>
                        <span class="block text-[10px] text-slate-500"><?= htmlspecialchars($admin['email'] ?? '') ?></span>
                    </div>
                </div>
                <a href="/admin/logout" title="Sign Out" class="text-slate-500 hover:text-rose-400 transition">
                    <i data-lucide="log-out" class="w-4 h-4"></i>
                </a>
            </div>
        </div>
    </aside>

    <!-- Main Content Area -->
    <main class="ml-64 flex-1 flex flex-col min-w-0 bg-slate-900 min-h-screen">
        <!-- Top Bar -->
        <header class="h-20 bg-slate-950/70 backdrop-blur-md border-b border-slate-800 flex items-center justify-between px-8 sticky top-0 z-30">
            <div>
                <h2 class="text-xl font-extrabold text-white"><?= htmlspecialchars($title ?? 'Dashboard') ?></h2>
                <p class="text-xs text-slate-400">Manage vendors, approvals, bookings, and commerce</p>
            </div>
            <div class="flex items-center gap-4">
                <a href="/downloads/priyodeal.apk" class="inline-flex items-center gap-2 px-3 py-1.5 rounded-lg bg-teal-500/10 text-teal-400 border border-teal-500/20 text-xs font-bold hover:bg-teal-500/20 transition">
                    <i data-lucide="download" class="w-3.5 h-3.5"></i>
                    <span>APK v1.0.0</span>
                </a>
                <span class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 text-xs font-semibold">
                    <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                    API Active
                </span>
            </div>
        </header>

        <!-- Flash Notice -->
        <?php if (!empty($flash)): ?>
            <div class="m-8 mb-0 p-4 rounded-xl bg-teal-500/20 border border-teal-500/40 text-teal-300 text-sm flex items-center justify-between">
                <div class="flex items-center gap-2 font-medium">
                    <i data-lucide="check-circle-2" class="w-5 h-5 text-teal-400"></i>
                    <span><?= htmlspecialchars($flash) ?></span>
                </div>
                <button onclick="this.parentElement.remove()" class="text-teal-400 hover:text-white">✕</button>
            </div>
        <?php endif; ?>

        <!-- Dynamic Body Content -->
        <div class="p-8">
            <?= $content ?? '' ?>
        </div>
    </main>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Priyo Deal</title>
    <link rel="icon" type="image/png" href="/assets/images/app-logo.png">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <style> body { font-family: 'Plus Jakarta Sans', sans-serif; } </style>
</head>
<body class="bg-slate-950 text-slate-100 min-h-screen flex items-center justify-center p-4">
    <div class="max-w-md w-full bg-slate-900 border border-slate-800 p-8 rounded-3xl shadow-2xl relative">
        <div class="text-center mb-8">
            <img src="/assets/images/app-logo.png" alt="Priyo Deal" class="w-16 h-16 rounded-2xl mx-auto mb-4 shadow-xl border border-slate-700 object-cover">
            <h1 class="text-2xl font-extrabold text-white">Priyo Deal Admin</h1>
            <p class="text-slate-400 text-xs mt-1">Sign in with your master administrative credentials</p>
        </div>

        <?php if (!empty($error)): ?>
            <div class="mb-6 p-4 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs font-semibold flex items-center gap-2">
                <i data-lucide="alert-circle" class="w-4 h-4"></i>
                <span><?= htmlspecialchars($error) ?></span>
            </div>
        <?php endif; ?>

        <form action="/admin/login" method="POST" class="space-y-5">
            <div>
                <label class="block text-xs font-bold text-slate-300 mb-2">Admin Email / Phone</label>
                <div class="relative">
                    <i data-lucide="mail" class="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5"></i>
                    <input type="text" name="email" value="admin@priyodeal.com" required placeholder="admin@priyodeal.com" class="w-full pl-10 pr-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-sm text-white focus:outline-none focus:border-teal-500 transition">
                </div>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-2">Password</label>
                <div class="relative">
                    <i data-lucide="lock" class="w-4 h-4 text-slate-500 absolute left-3.5 top-3.5"></i>
                    <input type="password" name="password" value="admin123" required placeholder="••••••••" class="w-full pl-10 pr-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-sm text-white focus:outline-none focus:border-teal-500 transition">
                </div>
            </div>

            <div class="bg-slate-950/60 p-3 rounded-xl border border-slate-800/80 text-[11px] text-slate-400 flex items-center justify-between">
                <span>Default Demo Login:</span>
                <span class="text-teal-400 font-mono font-bold">admin@priyodeal.com / admin123</span>
            </div>

            <button type="submit" class="w-full py-3 bg-gradient-to-r from-teal-500 to-sky-500 hover:from-teal-600 hover:to-sky-600 text-white font-bold rounded-xl shadow-lg shadow-teal-500/20 transition active:scale-95 text-sm">
                Sign In to Admin Panel
            </button>
        </form>

        <div class="mt-8 pt-6 border-t border-slate-800 text-center">
            <a href="/" class="text-xs text-slate-400 hover:text-teal-400 transition inline-flex items-center gap-1">
                <i data-lucide="arrow-left" class="w-3.5 h-3.5"></i>
                <span>Return to Landing Page</span>
            </a>
        </div>
    </div>

    <script> lucide.createIcons(); </script>
</body>
</html>


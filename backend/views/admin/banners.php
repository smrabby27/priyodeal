<?php
ob_start();
?>

<div class="space-y-6">
    <div class="flex justify-between items-center bg-slate-950 p-6 rounded-2xl border border-slate-800">
        <div>
            <h3 class="font-bold text-white text-base">Promotional Banners</h3>
            <p class="text-xs text-slate-400">Featured banners displayed on mobile app home screen</p>
        </div>
        <button onclick="document.getElementById('add-banner-modal').classList.remove('hidden')" class="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-500 text-white font-bold text-xs flex items-center gap-2 transition">
            <i data-lucide="plus" class="w-4 h-4"></i>
            <span>Add Banner</span>
        </button>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <?php foreach ($banners as $b): ?>
            <div class="bg-slate-950 rounded-2xl border border-slate-800 overflow-hidden shadow-sm flex flex-col justify-between">
                <div>
                    <img src="<?= htmlspecialchars($b['image']) ?>" class="w-full h-40 object-cover">
                    <div class="p-5">
                        <span class="text-[10px] uppercase font-bold text-teal-400 block mb-1">Sort: #<?= $b['sort_order'] ?></span>
                        <h4 class="font-bold text-white text-base mb-1"><?= htmlspecialchars($b['title']) ?></h4>
                        <p class="text-xs text-slate-400"><?= htmlspecialchars($b['subtitle'] ?? '') ?></p>
                        <?php if (!empty($b['target_url'])): ?>
                            <span class="text-[11px] font-mono text-slate-500 mt-2 block">Action: <?= htmlspecialchars($b['target_url']) ?></span>
                        <?php endif; ?>
                    </div>
                </div>

                <div class="p-5 pt-0 border-t border-slate-800/60 flex justify-end">
                    <form action="/admin/banners" method="POST" onsubmit="return confirm('Delete this banner?')">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<?= $b['id'] ?>">
                        <button type="submit" class="text-xs font-bold text-rose-400 hover:text-rose-300 transition flex items-center gap-1">
                            <i data-lucide="trash-2" class="w-3.5 h-3.5"></i>
                            <span>Delete</span>
                        </button>
                    </form>
                </div>
            </div>
        <?php endforeach; ?>
    </div>
</div>

<!-- Add Banner Modal -->
<div id="add-banner-modal" class="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4 hidden">
    <div class="bg-slate-900 rounded-3xl max-w-md w-full p-8 border border-slate-800 shadow-2xl relative">
        <button onclick="document.getElementById('add-banner-modal').classList.add('hidden')" class="absolute top-6 right-6 text-slate-400 hover:text-white">✕</button>

        <h3 class="text-xl font-bold text-white mb-1">Add Home Banner</h3>
        <p class="text-xs text-slate-400 mb-6">Create a slider promotional banner</p>

        <form action="/admin/banners" method="POST" class="space-y-4">
            <input type="hidden" name="action" value="add">

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Banner Title *</label>
                <input type="text" name="title" required placeholder="e.g. 50% Off Doctor Consultation" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Subtitle</label>
                <input type="text" name="subtitle" placeholder="e.g. Book in Dhanmondi & Panthapath" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Image URL *</label>
                <input type="url" name="image" required placeholder="https://images.unsplash.com/..." class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
            </div>

            <div class="grid grid-cols-2 gap-3">
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Target Action</label>
                    <input type="text" name="target_url" value="/booking" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Sort Order</label>
                    <input type="number" name="sort_order" value="1" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
            </div>

            <button type="submit" class="w-full py-2.5 bg-teal-600 hover:bg-teal-500 text-white font-bold rounded-xl text-xs transition shadow-lg shadow-teal-600/20">
                Publish Banner
            </button>
        </form>
    </div>
</div>

<?php
$content = ob_get_clean();
$title = "App Banners";
require __DIR__ . '/layout.php';
?>


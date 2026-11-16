<?php
ob_start();
?>

<div class="space-y-6">
    <div class="flex justify-between items-center bg-slate-950 p-6 rounded-2xl border border-slate-800">
        <div>
            <h3 class="font-bold text-white text-base">Categories Directory</h3>
            <p class="text-xs text-slate-400">Configure directory taxonomies for both Booking and Shopping modules</p>
        </div>
        <button onclick="document.getElementById('add-cat-modal').classList.remove('hidden')" class="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-500 text-white font-bold text-xs flex items-center gap-2 transition">
            <i data-lucide="plus" class="w-4 h-4"></i>
            <span>Add Category</span>
        </button>
    </div>

    <!-- Category Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <?php foreach ($categories as $c): ?>
            <div class="bg-slate-950 p-5 rounded-2xl border border-slate-800 flex items-center justify-between">
                <div class="flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl <?= $c['module'] === 'booking' ? 'bg-sky-500/10 text-sky-400' : 'bg-teal-500/10 text-teal-400' ?> flex items-center justify-center font-bold">
                        <i data-lucide="<?= htmlspecialchars($c['icon'] ?? 'folder') ?>" class="w-6 h-6"></i>
                    </div>
                    <div>
                        <span class="font-bold text-white text-sm block"><?= htmlspecialchars($c['name']) ?></span>
                        <span class="text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded <?= $c['module'] === 'booking' ? 'bg-sky-500/20 text-sky-300' : 'bg-teal-500/20 text-teal-300' ?>">
                            <?= ucfirst($c['module']) ?> Module
                        </span>
                    </div>
                </div>

                <form action="/admin/categories" method="POST" onsubmit="return confirm('Delete this category?')" class="inline">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="id" value="<?= $c['id'] ?>">
                    <button type="submit" class="text-slate-600 hover:text-rose-400 transition p-2">
                        <i data-lucide="trash-2" class="w-4 h-4"></i>
                    </button>
                </form>
            </div>
        <?php endforeach; ?>
    </div>
</div>

<!-- Add Category Modal -->
<div id="add-cat-modal" class="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4 hidden">
    <div class="bg-slate-900 rounded-3xl max-w-md w-full p-8 border border-slate-800 shadow-2xl relative">
        <button onclick="document.getElementById('add-cat-modal').classList.add('hidden')" class="absolute top-6 right-6 text-slate-400 hover:text-white">✕</button>

        <h3 class="text-xl font-bold text-white mb-1">Add New Category</h3>
        <p class="text-xs text-slate-400 mb-6">Create a category for Booking or Shopping</p>

        <form action="/admin/categories" method="POST" class="space-y-4">
            <input type="hidden" name="action" value="add">

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Target Module *</label>
                <select name="module" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                    <option value="booking">🩺 Booking Module (Doctor Specialties)</option>
                    <option value="shopping">🛒 Shopping Module (Stores & Products)</option>
                </select>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Category Name *</label>
                <input type="text" name="name" required placeholder="e.g. Neurologist or Organic Food" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
            </div>

            <div class="grid grid-cols-2 gap-3">
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Lucide Icon Name</label>
                    <input type="text" name="icon" value="folder" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Sort Order</label>
                    <input type="number" name="sort_order" value="1" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Cover Image URL</label>
                <input type="url" name="image" placeholder="https://images.unsplash.com/..." class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
            </div>

            <button type="submit" class="w-full py-2.5 bg-teal-600 hover:bg-teal-500 text-white font-bold rounded-xl text-xs transition shadow-lg shadow-teal-600/20">
                Create Category
            </button>
        </form>
    </div>
</div>

<?php
$content = ob_get_clean();
$title = "Categories Management";
require __DIR__ . '/layout.php';
?>


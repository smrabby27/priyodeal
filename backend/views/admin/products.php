<?php
ob_start();
?>

<div class="space-y-6">
    <div class="flex justify-between items-center bg-slate-950 p-6 rounded-2xl border border-slate-800">
        <div>
            <h3 class="font-bold text-white text-base">Product Moderation</h3>
            <p class="text-xs text-slate-400">Moderate product listings, manage stock, and assign to vendor shops</p>
        </div>
        <button onclick="document.getElementById('add-prod-modal').classList.remove('hidden')" class="px-4 py-2 rounded-xl bg-teal-600 hover:bg-teal-500 text-white font-bold text-xs flex items-center gap-2 transition">
            <i data-lucide="plus" class="w-4 h-4"></i>
            <span>Add Product</span>
        </button>
    </div>

    <!-- Products Table -->
    <div class="bg-slate-950 rounded-2xl border border-slate-800 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-slate-900/80 text-slate-400 border-b border-slate-800">
                    <tr>
                        <th class="py-3.5 px-6">Product Item</th>
                        <th class="py-3.5 px-6">Shop Vendor</th>
                        <th class="py-3.5 px-6">Category</th>
                        <th class="py-3.5 px-6">Price / Discount</th>
                        <th class="py-3.5 px-6">Stock Level</th>
                        <th class="py-3.5 px-6">Status</th>
                        <th class="py-3.5 px-6 text-right">Moderation</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    <?php if (empty($products)): ?>
                        <tr><td colspan="7" class="py-8 text-center text-slate-500">No products in catalog.</td></tr>
                    <?php else: foreach ($products as $p): ?>
                        <tr class="hover:bg-slate-900/40 transition">
                            <td class="py-4 px-6">
                                <div class="flex items-center gap-3">
                                    <div class="w-12 h-12 rounded-xl bg-slate-800 flex items-center justify-center overflow-hidden border border-slate-700">
                                        <?php if (!empty($p['image'])): ?>
                                            <img src="<?= htmlspecialchars($p['image']) ?>" class="w-full h-full object-cover">
                                        <?php else: ?>
                                            <i data-lucide="package" class="w-5 h-5 text-slate-500"></i>
                                        <?php endif; ?>
                                    </div>
                                    <div>
                                        <span class="font-bold text-white text-sm block"><?= htmlspecialchars($p['name']) ?></span>
                                        <span class="text-[11px] text-slate-500">Unit: <?= htmlspecialchars($p['unit']) ?></span>
                                    </div>
                                </div>
                            </td>
                            <td class="py-4 px-6 font-semibold text-slate-300">
                                <?= htmlspecialchars($p['shop_name']) ?>
                            </td>
                            <td class="py-4 px-6 text-slate-400">
                                <?= htmlspecialchars($p['category_name'] ?? 'General') ?>
                            </td>
                            <td class="py-4 px-6">
                                <span class="font-bold text-white text-sm block">৳<?= number_format($p['discount_price'] ?: $p['price']) ?></span>
                                <?php if (!empty($p['discount_price']) && $p['discount_price'] < $p['price']): ?>
                                    <span class="text-[10px] text-slate-500 line-through">৳<?= number_format($p['price']) ?></span>
                                <?php endif; ?>
                            </td>
                            <td class="py-4 px-6">
                                <span class="font-mono font-bold <?= $p['stock'] < 10 ? 'text-amber-400' : 'text-slate-300' ?>">
                                    <?= $p['stock'] ?> <?= $p['unit'] ?>s
                                </span>
                            </td>
                            <td class="py-4 px-6">
                                <span class="px-2.5 py-1 rounded-md text-[10px] font-bold <?= $p['status'] === 'active' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'bg-slate-500/10 text-slate-400 border border-slate-500/20' ?>">
                                    <?= ucfirst($p['status']) ?>
                                </span>
                            </td>
                            <td class="py-4 px-6 text-right">
                                <form action="/admin/products" method="POST" class="inline">
                                    <input type="hidden" name="action" value="toggle_status">
                                    <input type="hidden" name="product_id" value="<?= $p['id'] ?>">
                                    <input type="hidden" name="status" value="<?= $p['status'] ?>">
                                    <button type="submit" class="px-3 py-1 rounded-lg <?= $p['status'] === 'active' ? 'bg-rose-500/10 text-rose-400 hover:bg-rose-500/20 border border-rose-500/20' : 'bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20 border border-emerald-500/20' ?> font-bold text-[10px] transition">
                                        <?= $p['status'] === 'active' ? 'Hide / Deactivate' : 'Publish / Activate' ?>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Add Product Modal -->
<div id="add-prod-modal" class="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4 hidden">
    <div class="bg-slate-900 rounded-3xl max-w-lg w-full p-8 border border-slate-800 shadow-2xl relative">
        <button onclick="document.getElementById('add-prod-modal').classList.add('hidden')" class="absolute top-6 right-6 text-slate-400 hover:text-white">✕</button>

        <h3 class="text-xl font-bold text-white mb-1">Add Product to Shop</h3>
        <p class="text-xs text-slate-400 mb-6">List an inventory item on a vendor store</p>

        <form action="/admin/products" method="POST" class="space-y-4">
            <input type="hidden" name="action" value="add">

            <div class="grid grid-cols-2 gap-3">
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Target Shop *</label>
                    <select name="business_id" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                        <?php foreach ($shops as $s): ?>
                            <option value="<?= $s['id'] ?>"><?= htmlspecialchars($s['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Category</label>
                    <select name="category_id" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                        <?php foreach ($categories as $c): ?>
                            <option value="<?= $c['id'] ?>"><?= htmlspecialchars($c['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Product Title *</label>
                <input type="text" name="name" required placeholder="e.g. Pure Honey (500g)" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
            </div>

            <div class="grid grid-cols-3 gap-3">
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Regular Price (৳)</label>
                    <input type="number" step="0.01" name="price" required placeholder="500" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Sale Price (৳)</label>
                    <input type="number" step="0.01" name="discount_price" placeholder="450" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1">Stock</label>
                    <input type="number" name="stock" value="50" class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
                </div>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Image URL</label>
                <input type="url" name="image" placeholder="https://images.unsplash.com/..." class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500">
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1">Description</label>
                <textarea name="description" rows="2" placeholder="Item description..." class="w-full px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-teal-500"></textarea>
            </div>

            <button type="submit" class="w-full py-2.5 bg-teal-600 hover:bg-teal-500 text-white font-bold rounded-xl text-xs transition shadow-lg shadow-teal-600/20">
                Save & List Product
            </button>
        </form>
    </div>
</div>

<?php
$content = ob_get_clean();
$title = "Product Moderation";
require __DIR__ . '/layout.php';
?>


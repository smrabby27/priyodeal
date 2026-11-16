<?php
ob_start();
?>

<div class="space-y-6">
    <!-- Filters -->
    <div class="flex items-center gap-3 bg-slate-950 p-6 rounded-2xl border border-slate-800">
        <span class="text-xs font-bold text-slate-400 mr-2">Filter by Status:</span>
        <a href="/admin/orders" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= empty($status) ? 'bg-sky-600 text-white' : 'bg-slate-900 text-slate-400 hover:text-white' ?>">
            All Orders
        </a>
        <a href="/admin/orders?status=placed" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= $status === 'placed' ? 'bg-sky-600 text-white' : 'bg-slate-900 text-sky-400 hover:text-white' ?>">
            Placed
        </a>
        <a href="/admin/orders?status=confirmed" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= $status === 'confirmed' ? 'bg-teal-600 text-white' : 'bg-slate-900 text-teal-400 hover:text-white' ?>">
            Confirmed
        </a>
        <a href="/admin/orders?status=shipped" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= $status === 'shipped' ? 'bg-indigo-600 text-white' : 'bg-slate-900 text-indigo-400 hover:text-white' ?>">
            Shipped
        </a>
        <a href="/admin/orders?status=delivered" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= $status === 'delivered' ? 'bg-emerald-600 text-white' : 'bg-slate-900 text-emerald-400 hover:text-white' ?>">
            Delivered
        </a>
    </div>

    <!-- Orders Table -->
    <div class="bg-slate-950 rounded-2xl border border-slate-800 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-slate-900/80 text-slate-400 border-b border-slate-800">
                    <tr>
                        <th class="py-3.5 px-6">Order Code</th>
                        <th class="py-3.5 px-6">Customer & Shipping Address</th>
                        <th class="py-3.5 px-6">Shop</th>
                        <th class="py-3.5 px-6">Items Purchased</th>
                        <th class="py-3.5 px-6">Total Amount</th>
                        <th class="py-3.5 px-6">Status</th>
                        <th class="py-3.5 px-6 text-right">Update Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    <?php if (empty($orders)): ?>
                        <tr><td colspan="7" class="py-8 text-center text-slate-500">No shop orders found.</td></tr>
                    <?php else: foreach ($orders as $o): ?>
                        <tr class="hover:bg-slate-900/40 transition">
                            <td class="py-4 px-6 font-mono font-bold text-sky-400">
                                <?= htmlspecialchars($o['order_code']) ?>
                            </td>
                            <td class="py-4 px-6">
                                <span class="font-bold text-white block"><?= htmlspecialchars($o['shipping_name']) ?></span>
                                <span class="text-slate-400 text-[11px] block"><?= htmlspecialchars($o['shipping_phone']) ?></span>
                                <span class="text-slate-500 text-[10px] truncate max-w-xs block"><?= htmlspecialchars($o['shipping_address']) ?></span>
                            </td>
                            <td class="py-4 px-6 font-semibold text-slate-200">
                                <?= htmlspecialchars($o['shop_name']) ?>
                            </td>
                            <td class="py-4 px-6">
                                <ul class="space-y-1">
                                    <?php foreach ($o['items'] as $item): ?>
                                        <li class="text-slate-300">
                                            <?= htmlspecialchars($item['product_name']) ?>
                                            <span class="text-slate-500 font-mono">x<?= $item['quantity'] ?> (৳<?= $item['price'] ?>)</span>
                                        </li>
                                    <?php endforeach; ?>
                                </ul>
                            </td>
                            <td class="py-4 px-6">
                                <span class="font-bold text-white text-sm block">৳<?= number_format($o['total']) ?></span>
                                <span class="text-[10px] text-teal-400 font-bold uppercase">Cash on Delivery</span>
                            </td>
                            <td class="py-4 px-6">
                                <?php if ($o['status'] === 'delivered'): ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">Delivered</span>
                                <?php elseif ($o['status'] === 'shipped'): ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-indigo-500/10 text-indigo-400 border border-indigo-500/20">Shipped</span>
                                <?php elseif ($o['status'] === 'cancelled'): ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-rose-500/10 text-rose-400 border border-rose-500/20">Cancelled</span>
                                <?php else: ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-sky-500/10 text-sky-400 border border-sky-500/20"><?= ucfirst($o['status']) ?></span>
                                <?php endif; ?>
                            </td>
                            <td class="py-4 px-6 text-right">
                                <form action="/admin/orders" method="POST" class="inline-flex items-center gap-1.5">
                                    <input type="hidden" name="order_id" value="<?= $o['id'] ?>">
                                    <select name="status" onchange="this.form.submit()" class="px-2 py-1 rounded bg-slate-900 border border-slate-700 text-slate-300 text-[10px] font-semibold focus:outline-none">
                                        <option value="placed" <?= $o['status'] === 'placed' ? 'selected' : '' ?>>Placed</option>
                                        <option value="confirmed" <?= $o['status'] === 'confirmed' ? 'selected' : '' ?>>Confirmed</option>
                                        <option value="packed" <?= $o['status'] === 'packed' ? 'selected' : '' ?>>Packed</option>
                                        <option value="shipped" <?= $o['status'] === 'shipped' ? 'selected' : '' ?>>Shipped</option>
                                        <option value="delivered" <?= $o['status'] === 'delivered' ? 'selected' : '' ?>>Delivered</option>
                                        <option value="cancelled" <?= $o['status'] === 'cancelled' ? 'selected' : '' ?>>Cancelled</option>
                                    </select>
                                </form>
                            </td>
                        </tr>
                    <?php endforeach; endif; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php
$content = ob_get_clean();
$title = "Shop Orders (COD)";
require __DIR__ . '/layout.php';
?>


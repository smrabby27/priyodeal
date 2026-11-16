<?php
ob_start();
?>

<div class="space-y-6">
    <!-- Filters -->
    <div class="flex items-center gap-3 bg-slate-950 p-6 rounded-2xl border border-slate-800">
        <span class="text-xs font-bold text-slate-400 mr-2">Filter by Status:</span>
        <a href="/admin/bookings" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= empty($status) ? 'bg-teal-600 text-white' : 'bg-slate-900 text-slate-400 hover:text-white' ?>">
            All Bookings
        </a>
        <a href="/admin/bookings?status=confirmed" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= $status === 'confirmed' ? 'bg-teal-600 text-white' : 'bg-slate-900 text-teal-400 hover:text-white' ?>">
            Confirmed
        </a>
        <a href="/admin/bookings?status=completed" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= $status === 'completed' ? 'bg-emerald-600 text-white' : 'bg-slate-900 text-emerald-400 hover:text-white' ?>">
            Completed
        </a>
        <a href="/admin/bookings?status=cancelled" class="px-3.5 py-1.5 rounded-xl text-xs font-bold transition <?= $status === 'cancelled' ? 'bg-rose-600 text-white' : 'bg-slate-900 text-rose-400 hover:text-white' ?>">
            Cancelled
        </a>
    </div>

    <!-- Bookings Table -->
    <div class="bg-slate-950 rounded-2xl border border-slate-800 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-slate-900/80 text-slate-400 border-b border-slate-800">
                    <tr>
                        <th class="py-3.5 px-6">Booking Code / Serial</th>
                        <th class="py-3.5 px-6">Patient Details</th>
                        <th class="py-3.5 px-6">Doctor & Chamber</th>
                        <th class="py-3.5 px-6">Date & Slot</th>
                        <th class="py-3.5 px-6">Fee & Pay Status</th>
                        <th class="py-3.5 px-6">Status</th>
                        <th class="py-3.5 px-6 text-right">Update Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-slate-800/60">
                    <?php if (empty($bookings)): ?>
                        <tr><td colspan="7" class="py-8 text-center text-slate-500">No appointments recorded yet.</td></tr>
                    <?php else: foreach ($bookings as $b): ?>
                        <tr class="hover:bg-slate-900/40 transition">
                            <td class="py-4 px-6">
                                <span class="font-mono text-teal-400 font-bold block"><?= htmlspecialchars($b['booking_code']) ?></span>
                                <span class="text-[10px] text-slate-400">Serial #<?= $b['serial_no'] ?></span>
                            </td>
                            <td class="py-4 px-6">
                                <span class="font-bold text-white block"><?= htmlspecialchars($b['patient_name']) ?></span>
                                <span class="text-slate-400 text-[11px] block"><?= htmlspecialchars($b['patient_phone']) ?></span>
                                <span class="text-[10px] text-slate-500"><?= $b['patient_age'] ?> yrs • <?= $b['patient_gender'] ?></span>
                            </td>
                            <td class="py-4 px-6">
                                <span class="font-semibold text-slate-200 block"><?= htmlspecialchars($b['doctor_name']) ?></span>
                                <span class="text-[10px] text-slate-400 block"><?= htmlspecialchars($b['chamber_name']) ?></span>
                            </td>
                            <td class="py-4 px-6">
                                <span class="text-slate-200 font-medium block"><?= htmlspecialchars($b['date']) ?></span>
                                <span class="text-teal-400 font-bold text-[11px] block"><?= htmlspecialchars($b['slot_time']) ?></span>
                            </td>
                            <td class="py-4 px-6">
                                <span class="font-bold text-white block">৳<?= number_format($b['fee']) ?></span>
                                <span class="text-[10px] uppercase font-bold text-teal-400"><?= str_replace('_', ' ', $b['payment_status']) ?></span>
                            </td>
                            <td class="py-4 px-6">
                                <?php if ($b['status'] === 'confirmed'): ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-teal-500/10 text-teal-400 border border-teal-500/20">Confirmed</span>
                                <?php elseif ($b['status'] === 'completed'): ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">Completed</span>
                                <?php else: ?>
                                    <span class="px-2.5 py-1 rounded-md text-[10px] font-bold bg-rose-500/10 text-rose-400 border border-rose-500/20"><?= ucfirst($b['status']) ?></span>
                                <?php endif; ?>
                            </td>
                            <td class="py-4 px-6 text-right">
                                <form action="/admin/bookings" method="POST" class="inline-flex items-center gap-1.5">
                                    <input type="hidden" name="booking_id" value="<?= $b['id'] ?>">
                                    <select name="status" onchange="this.form.submit()" class="px-2 py-1 rounded bg-slate-900 border border-slate-700 text-slate-300 text-[10px] font-semibold focus:outline-none">
                                        <option value="confirmed" <?= $b['status'] === 'confirmed' ? 'selected' : '' ?>>Confirmed</option>
                                        <option value="completed" <?= $b['status'] === 'completed' ? 'selected' : '' ?>>Completed</option>
                                        <option value="cancelled" <?= $b['status'] === 'cancelled' ? 'selected' : '' ?>>Cancelled</option>
                                        <option value="no-show" <?= $b['status'] === 'no-show' ? 'selected' : '' ?>>No-Show</option>
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
$title = "Doctor Bookings";
require __DIR__ . '/layout.php';
?>

